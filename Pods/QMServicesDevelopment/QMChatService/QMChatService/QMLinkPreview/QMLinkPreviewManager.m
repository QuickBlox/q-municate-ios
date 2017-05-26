//
//  QMLinkPreviewManager.m
//  Pods
//
//  Created by Vitaliy Gurkovsky on 4/3/17.
//
//

#import "QMLinkPreviewManager.h"
#import "QMLinkPreviewMemoryStorage.h"

static NSString *const kQMBaseGraphURL = @"https://ogs.quickblox.com/?url=";
static NSString *const kQMKeyTitle = @"ogTitle";
static NSString *const kQMKeyDescription = @"ogDescription";
static NSString *const kQMKeyImageURL = @"ogImage";

@interface QMLinkPreviewManager()

@property (nonatomic, strong) NSMutableSet *previewsInProgress;
@property (nonatomic, strong) NSMutableSet *failedURLs;
@property (nonatomic, strong) NSMutableSet *messagesWithoutLinks;
@property (nonatomic, strong) NSMutableDictionary *links;
@property (nonatomic, strong) NSDataDetector *linkDataDetector;

@end

@implementation QMLinkPreviewManager

- (instancetype)init {
    
    if (self = [super init]) {
        
        _memoryStorage = [[QMLinkPreviewMemoryStorage alloc] init];
        _previewsInProgress = [NSMutableSet set];
        _failedURLs = [NSMutableSet set];
        _links = [NSMutableDictionary dictionary];
        _messagesWithoutLinks = [NSMutableSet set];
    }
    
    return self;
}

- (NSDataDetector *)linkDataDetector {
    
    if  (!_linkDataDetector) {
        
        _linkDataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                            error:nil];
    }
    
    return _linkDataDetector;
}

- (void)downloadLinkPreviewForMessage:(QBChatMessage *)message
                       withCompletion:(QMLinkPreviewCompletionBlock)completion {
    
    NSURL *url = [self linkForMessage:message];
    
    if (!url) {
        completion(NO);
        return;
    }
    
    [self linkPreviewForURL:url withCompletion:completion];
}


- (void)linkPreviewForURL:(NSURL *)url withCompletion:(QMLinkPreviewCompletionBlock)completion {
    
    NSString *urlKey = [self cacheKeyForURL:url];
    
    if (urlKey.length == 0) {
        completion(NO);
        return;
    }
    
    if ([_failedURLs containsObject:urlKey]) {
        completion(NO);
        return;
    }
    
    if ([_previewsInProgress containsObject:urlKey]) {
        return;
    }
    else {
        
        @synchronized (self.previewsInProgress) {
            [_previewsInProgress addObject:urlKey];
        }
    }
    
    NSString *graphURL = [NSString stringWithFormat:@"%@%@&token=%@",
                          kQMBaseGraphURL,
                          url,
                          [QBSession currentSession].sessionDetails.token];
    
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:graphURL]];
    
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData * _Nullable data,
                                                         NSURLResponse * _Nullable response,
                                                         NSError * _Nullable error)
      {
          void(^blockCompletion)(BOOL success) = ^(BOOL success) {
              
              if (completion) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      completion(success);
                  });
              }
          };
          
          if ([(NSHTTPURLResponse *)response statusCode] == 404) {
              
              @synchronized (self.previewsInProgress) {
                  [_previewsInProgress removeObject:urlKey];
              }
              @synchronized (self.failedURLs) {
                  [_failedURLs addObject:urlKey];
              }
              
              blockCompletion(NO);
              return;
          }
          else if (data != nil) {
              
              NSError *jsonError = nil;
              id jsonObject = [NSJSONSerialization
                               JSONObjectWithData:data
                               options:NSJSONReadingAllowFragments
                               error:&jsonError];
              
              if (jsonObject != nil &&
                  jsonError == nil) {
                  
                  NSLog(@"Successfully deserialized...");
                  
                  if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                      
                      NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                      
                      if (deserializedDictionary.allKeys.count == 0) {
                          
                          @synchronized (self.previewsInProgress) {
                              [_previewsInProgress removeObject:urlKey];
                          }
                          @synchronized (self.failedURLs) {
                              [_failedURLs addObject:urlKey];
                          }
                          blockCompletion(NO);
                          return;
                      }
                      
                      if (![deserializedDictionary[@"err"] isKindOfClass:[NSNull class]]) {
                          
                          QMLinkPreview *linkPreview =
                          [self linkPreviewFromDictionary:deserializedDictionary];
                          linkPreview.siteUrl = urlKey;
                          
                          if (linkPreview.imageURL.length > 0) {
                              
                              if ([NSURL URLWithString:linkPreview.imageURL].host == nil) {
                                  
                                  NSString *urlString =
                                  [NSString stringWithFormat:@"%@%@",
                                   linkPreview.siteUrl,
                                   [NSURL URLWithString:linkPreview.imageURL].absoluteString];
                                  
                                  linkPreview.imageURL = urlString;
                              }
                          }
                          
                          [self.memoryStorage addLinkPreview:linkPreview
                                                      forKey:[self cacheKeyForURL:url]];
                          
                          if ([self.delegate respondsToSelector:@selector(linkPreviewManager:
                                                                          didAddLinkPreviewToMemoryStorage:)]) {
                              [self.delegate linkPreviewManager:self
                               didAddLinkPreviewToMemoryStorage:linkPreview];
                          }
                          
                          @synchronized (self.previewsInProgress) {
                              [_previewsInProgress removeObject:urlKey];
                          }
                          
                          blockCompletion(YES);
                      }
                      else {
                          blockCompletion(NO);
                      }
                  }
              }
          }
          else if (error != nil) {
              
              @synchronized (self.previewsInProgress) {
                  [_previewsInProgress removeObject:urlKey];
              }
              blockCompletion(NO);
          }
          
      }] resume];
}

- (QMLinkPreview *)linkPreviewForMessage:(QBChatMessage *)message {
    
    NSURL *url = [self linkForMessage:message];
    
    if (!url) {
        return nil;
    }
    NSString *keyURL = [self cacheKeyForURL:url];
    
    if ([_failedURLs containsObject:keyURL]) {
        return nil;
    }
    
    QMLinkPreview *linkPreview = [self.memoryStorage linkPreviewForKey:keyURL];
    
    if (!linkPreview) {
        
        if ([self.delegate respondsToSelector:@selector(cachedLinkPreviewForURLKey:)]) {
            linkPreview = [self.delegate cachedLinkPreviewForURLKey:keyURL];
        }
        
        if (linkPreview != nil) {
            [self.memoryStorage addLinkPreview:linkPreview forKey:keyURL];
        }
    }
    
    return linkPreview;
}

//MARK: - Helpers

- (NSString *)cacheKeyForURL:(NSURL *)url {
    
    if (!url) {
        return @"";
    }
    
    return [url absoluteString];
}

- (QMLinkPreview *)linkPreviewFromDictionary:(NSDictionary *)deserializedDictionary {
    
    QMLinkPreview *linkPreview = [[QMLinkPreview alloc] init];
    
    if (![deserializedDictionary[kQMKeyTitle] isKindOfClass:[NSNull class]]) {
        
        linkPreview.siteTitle = deserializedDictionary[kQMKeyTitle];
    }
    if (![deserializedDictionary[kQMKeyDescription] isKindOfClass:[NSNull class]]) {
        
        linkPreview.siteDescription = deserializedDictionary[kQMKeyDescription];
    }
    if (![deserializedDictionary[kQMKeyImageURL] isKindOfClass:[NSNull class]]) {
        
        NSString *imagePath = deserializedDictionary[kQMKeyImageURL][@"url"];
        
        if (imagePath != nil) {
            linkPreview.imageURL = [[self qm_standartitizedURLFromString:imagePath] absoluteString];
        }
    }
    
    return linkPreview;
}

- (NSURL *)linkForMessage:(QBChatMessage *)message {
    
    if (_links[message.ID] != nil) {
        return _links[message.ID];
    }
    
    if ([_messagesWithoutLinks containsObject:message.ID]) {
        return nil;
    }
    NSURL *url = nil;
    
    NSString *text = message.text;
    
    if (text.length > 0) {
        
        NSTextCheckingResult *result = [self.linkDataDetector firstMatchInString:text
                                                                         options:0
                                                                           range:NSMakeRange(0, text.length)];
        
        if (result.range.location > 0 || result.range.length != text.length) {
            
            [_messagesWithoutLinks addObject:message.ID];
            url = nil;
        }
        else if (result.resultType == NSTextCheckingTypeLink) {
            
            NSString *stringLink = [[text substringWithRange:result.range] lowercaseString];
            url = [self qm_standartitizedURLFromString:stringLink];
            _links[message.ID] = url;
        }
    }
    
    return url;
}

- (NSURL *)qm_standartitizedURLFromString:(NSString *)stringURL {
    
    NSArray *prefixes = @[@"https:", @"http:", @"//", @"/"];
    
    for (NSString *prefix in prefixes) {
        
        if ([stringURL hasPrefix:prefix]) {
            stringURL = [stringURL stringByReplacingOccurrencesOfString:prefix
                                                             withString:@""
                                                                options:NSAnchoredSearch
                                                                  range:NSMakeRange(0,stringURL.length)];
        }
    }
    
    stringURL = [@"https://" stringByAppendingString:stringURL];
    
    return [NSURL URLWithString:stringURL];
}

//MARK: - QMMemoryStorageProtocol

- (void)free {
    
    [_messagesWithoutLinks removeAllObjects];
    [_memoryStorage free];
    [_failedURLs removeAllObjects];
    [_links removeAllObjects];
}

@end
