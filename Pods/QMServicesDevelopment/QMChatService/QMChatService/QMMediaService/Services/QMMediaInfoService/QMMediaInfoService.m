//
//  QMMediaInfoService.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 2/22/17.
//
//

#import "QMMediaInfoService.h"
#import <AVKit/AVKit.h>
#import "QMImageOperation.h"

@interface QMMediaInfoService()

@property (strong, nonatomic) NSOperationQueue *imagesOperationQueue;

@end

@implementation QMMediaInfoService

//MARK: - NSObject

- (instancetype)init {
    
    if (self = [super init]) {
    
        _imagesOperationQueue = [[NSOperationQueue alloc] init];
        _imagesOperationQueue.maxConcurrentOperationCount  = 2;
    }
    
    return self;
}

- (void)videoThumbnailForAttachment:(QBChatAttachment *)attachment completion:(void(^)(UIImage *image, NSError *error))completion {
    
    NSString *key = attachment.ID;
    if (key == nil) {
        return;
    }
    
    for (QMImageOperation *op in [self.imagesOperationQueue operations]) {
        if ([op.attachment.ID isEqualToString:key]) {
            [op cancel];
        }
    }
    
    QMImageOperation *imageOperation = [[QMImageOperation alloc] initWithAttachment:attachment
                                                                  completionHandler:^(UIImage * _Nullable image, NSError * _Nullable error) {
                                                                      if (completion) {
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              completion(image, error);
                                                                          });
                                                                      }
                                                                  }];
    [self.imagesOperationQueue addOperation:imageOperation];
}




- (void)cancellAllInfoOperations {
    
    NSEnumerator *enumerator = [[[self class] mediaInfoOperations] keyEnumerator];
    
    NSString *mediaID = nil;
    
    while (mediaID = [enumerator nextObject]) {
        
        QMMediaInfo *mediaInfo = [[[self class] mediaInfoOperations] objectForKey:mediaID];
        [mediaInfo cancel];
    }
}


- (void)cancelInfoOperationForKey:(NSString *)key {
    
    [QMImageOperation cancelOperationWithID:key
                                      queue:self.imagesOperationQueue];
}

+ (NSMutableDictionary *)mediaInfoOperations {
    
    static NSMutableDictionary *mediaInfoOperations = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        mediaInfoOperations = [NSMutableDictionary dictionary];
    });
    NSLog(@"mediaInfoOperations = %lu",(unsigned long)mediaInfoOperations.count);
    return mediaInfoOperations;
}
@end
