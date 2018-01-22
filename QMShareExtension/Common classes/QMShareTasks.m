//
//  QMShareTasks.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/20/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareTasks.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Quickblox/Quickblox.h>

#import <Bolts/Bolts.h>
#import "QBChatAttachment+QMFactory.h"
#import "NSURL+QMShareExtension.h"
#import "QBChatMessage+QMCustomParameters.h"
#import "QMBaseService.h"
#import "QMAttachmentProvider.h"
#import "QMExtensionCache+QMShareExtension.h"
#import "UIImage+QM.h"

@implementation QMItemProviderResult

- (NSString *)description {
    
    NSMutableString *result = [NSMutableString stringWithString:[super description]];
    [result appendFormat:@"Text: %@/n", _text];
    [result appendFormat:@"Attachment: %@",_attachment];
    
    return result.copy;
}
@end

@interface QMItemProviderLoader<__covariant ResultType> : NSObject

@property (strong, nonatomic, readonly) NSItemProvider *itemProvider;
@property (copy, nonatomic, readonly) NSString *typeIdentifier;


- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithProvider:(NSItemProvider *)provider
                  typeIdentifier:(NSString *)typeIdentifier NS_DESIGNATED_INITIALIZER;

- (void)loadItemForTypeIdentifier:(NSString *)typeIdentifier
                completionHandler:(void(^)(ResultType item , NSError * __null_unspecified error))completionHandler;
- (BFTask <ResultType> *)taskLoadItem;


@end

@implementation QMItemProviderLoader

- (instancetype)initWithProvider:(NSItemProvider *)provider
                  typeIdentifier:(NSString *)typeIdentifier {
    
    if (self = [super init]) {
        _itemProvider = provider;
        _typeIdentifier = [typeIdentifier copy];
    }
    
    return self;
}

- (void)loadItemForTypeIdentifier:(NSString *)typeIdentifier
                completionHandler:(void(^)(id item , NSError * __null_unspecified error))completionHandler {
    [self.itemProvider loadItemForTypeIdentifier:typeIdentifier options:nil completionHandler:completionHandler];
}

- (BFTask *)taskLoadItem {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [self loadItemForTypeIdentifier:self.typeIdentifier
                      completionHandler:^(id item, NSError * _Null_unspecified error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (error) {
                                  [source setError:error];
                              }
                              else {
                                  [source setResult:item];
                              }
                          });
                      }];
    });
}

@end

@implementation QMShareTasks

/* TODO: for test
static NSSet<NSString *>*acceptableTypes() {
    
    static NSSet *acceptableTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        acceptableTypes =
        [NSSet setWithArray:@[
                              //Text
                              (__bridge NSString *)kUTTypeText,
                              (__bridge NSString *)kUTTypePlainText,
                              //URLs
                              (__bridge NSString *)kUTTypeFileURL,
                              (__bridge NSString *)kUTTypeURL,
                              //Audio
                              (__bridge NSString *)kUTTypeMP3,
                              (__bridge NSString *)kUTTypeMPEG4Audio,
                              @"com.apple.m4a-audio",//m4a
                              //Images
                              (__bridge NSString *)kUTTypePNG,
                              (__bridge NSString *)kUTTypeJPEG,
                              //Video
                              (__bridge NSString *)kUTTypeMPEG4,
                              //Data
                              (__bridge NSString *)kUTTypeData,
                              //Custom types
                              //
                              ]];
    });
    
    return acceptableTypes;
}

*/

+ (BFTask <NSArray<QMItemProviderResult *>*> *)loadItemsForItemProviders:(NSArray <NSItemProvider *> *)providers {
    
    NSMutableArray *availableProviders = [NSMutableArray arrayWithCapacity:providers.count];
    
    for (NSItemProvider *provider in providers) {
        
        if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie]) {
            [availableProviders addObject:provider];
        }
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio]) {
            [availableProviders addObject:provider];
        }
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
            [availableProviders addObject:provider];
        }
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
            [availableProviders addObject:provider];
        }
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
            [availableProviders removeAllObjects];
            [availableProviders addObject:provider];
            break;
        }
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePlainText]) {
            [availableProviders addObject:provider];
        }
        else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeData]) {
            [availableProviders addObject:provider];
        }
    }
    
    NSMutableArray *tasks = [NSMutableArray array];
    
    for (NSItemProvider *provider in availableProviders) {
        [tasks addObject:[self loadItemsForItemProvider:provider]];
    }
    
    return [BFTask taskForCompletionOfAllTasksWithResults:tasks];
}


+ (BFTask <QMItemProviderResult*> *)loadItemsForItemProvider:(NSItemProvider *)provider {
    
    QMItemProviderResult *result = [QMItemProviderResult new];
    
    if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
        
        QMItemProviderLoader *itemProvider = [[QMItemProviderLoader alloc] initWithProvider:provider
                                                                             typeIdentifier:(NSString *)kUTTypeImage];
        
        return [[itemProvider taskLoadItem] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
            
            if ([t.result isKindOfClass:[NSURL class]]) {
                NSURL *fileURL = t.result;
                return [self taskProvideResultWithAttachmentForFileURL:fileURL
                                                       typeIdentifiers:provider.registeredTypeIdentifiers];
            }
            else if ([t.result isKindOfClass:[UIImage class]]) {
                UIImage *image = t.result;
                return [self taskProvideResultWithAttachmentImage:image
                                                  typeIdentifiers:provider.registeredTypeIdentifiers];
            }
            
            NSString *errorDescription =
            [NSString stringWithFormat:@"Item tagged as image has unsupported type:%@",
             NSStringFromClass([t.result class])];
            
            NSError *error =
            [[NSError alloc] initWithDomain:NSBundle.mainBundle.bundleIdentifier
                                       code:0
                                   userInfo:@{NSLocalizedDescriptionKey : errorDescription }];
            return [BFTask taskWithError:error];
        }];
    }
    else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeMovie] ||
             [provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeAudio] ||
             [provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeFileURL]) {
        
        QMItemProviderLoader<NSURL *> *itemProvider = [[QMItemProviderLoader alloc] initWithProvider:provider
                                                                                      typeIdentifier:(NSString *)kUTTypeFileURL];
        
        return [[itemProvider taskLoadItem] continueWithSuccessBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull t) {
            
            NSAssert([t.result isKindOfClass:NSURL.self], @"");
            return [self taskProvideResultWithAttachmentForFileURL:t.result
                                                   typeIdentifiers:provider.registeredTypeIdentifiers];
        }];
    }
    else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePlainText]) {
        
        QMItemProviderLoader<NSString *> *itemProvider = [[QMItemProviderLoader alloc] initWithProvider:provider
                                                                                         typeIdentifier:(NSString *)kUTTypeText];
        return [[itemProvider taskLoadItem] continueWithSuccessBlock:^id _Nullable(BFTask<NSString *> * _Nonnull t) {
            result.text = t.result;
            return [BFTask taskWithResult:result];
        }];
    }
    
    else if ([provider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        
        QMItemProviderLoader<NSURL *> *itemProvider = [[QMItemProviderLoader alloc] initWithProvider:provider
                                                                                      typeIdentifier:(NSString *)kUTTypeURL];
        
        return [[itemProvider taskLoadItem] continueWithSuccessBlock:^id _Nullable(BFTask<NSURL *> * _Nonnull urlTask) {
            
            NSURL *URL = urlTask.result;
            
            if (URL.isFileURL) {
                return [self taskProvideResultWithAttachmentForFileURL:URL
                                                       typeIdentifiers:provider.registeredTypeIdentifiers];
            }
            else if (URL.isLocationURL) {
                
                return [[URL location] continueWithBlock:^id _Nullable(BFTask<CLLocation *> * _Nonnull locationTask) {
                    
                    if (locationTask.error) {
                        result.text = URL.absoluteString;
                    }
                    else {
                        result.text = @"Location";
                        QBChatAttachment *locationAttachment =
                        [QBChatAttachment locationAttachmentWithCoordinate:locationTask.result.coordinate];
                        result.attachment = locationAttachment;
                    }
                    
                    return [BFTask taskWithResult:result];
                }];
            }
            else {
                result.text = URL.absoluteString;
                return [BFTask taskWithResult:result];
            }
        }];
    }
    
    
    return [BFTask cancelledTask];
}

+ (BFTask <QMItemProviderResult*> *)taskProvideResultWithAttachmentImage:(UIImage *)image
                                                         typeIdentifiers:(NSArray *)typeIdentifiers {
    QMAttachmentProvider *provider = [QMAttachmentProvider new];
    
    return [[provider taskAttachmentWithImage:image
                              typeIdentifiers:typeIdentifiers] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatAttachment *> * _Nonnull attachmentTask)
            {
                QBChatAttachment *attachment = attachmentTask.result;
                
                QMItemProviderResult *result = [QMItemProviderResult new];
                
                result.attachment = attachment;
                result.text =
                [NSString stringWithFormat:@"%@ attachment",
                 attachment.type.capitalizedString];
                
                return [BFTask taskWithResult:result];
            }];
}

+ (BFTask <QMItemProviderResult*> *)taskProvideResultWithAttachmentForData:(NSData *)data
                                                           typeIdentifiers:(NSArray *)typeIdentifiers {
    QMAttachmentProvider *provider = [QMAttachmentProvider new];
    
    return [[provider taskAttachmentWithData:data
                             typeIdentifiers:typeIdentifiers] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatAttachment *> * _Nonnull attachmentTask)
            {
                QBChatAttachment *attachment = attachmentTask.result;
                
                QMItemProviderResult *result = [QMItemProviderResult new];
                
                result.attachment = attachment;
                result.text =
                [NSString stringWithFormat:@"%@ attachment",
                 attachment.type.capitalizedString];
                
                return [BFTask taskWithResult:result];
            }];
}

+ (BFTask <QMItemProviderResult*> *)taskProvideResultWithAttachmentForFileURL:(NSURL *)fileURL
                                                              typeIdentifiers:(NSArray *)typeIdentifiers {
    
    QMAttachmentProvider *provider =  [QMAttachmentProvider new];
    
    return [[provider taskAttachmentWithFileURL:fileURL
                                typeIdentifiers:typeIdentifiers] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatAttachment *> * _Nonnull attachmentTask)
            {
                QBChatAttachment *attachment = attachmentTask.result;
                
                QMItemProviderResult *result = [QMItemProviderResult new];
                
                result.attachment = attachment;
                result.text =
                [NSString stringWithFormat:@"%@ attachment",
                 attachment.type.capitalizedString];
                
                return [BFTask taskWithResult:result];
            }];
}

+ (BFTask *)taskFetchAllDialogsFromDate:(NSDate *)date {
    
    NSMutableArray *dialogs = [NSMutableArray array];
    void (^iterationBlock)(QBResponse *, NSArray *, NSSet *, BOOL *) =
    ^(QBResponse *__unused response, NSArray *__unused dialogObjects, NSSet *__unused dialogsUsersIDs, BOOL *__unused stop) {
        [dialogs addObjectsFromArray:dialogObjects];
    };
    
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask *__unused task) {
        return [BFTask taskWithResult:dialogs.copy];
    };
    
    NSDictionary *extendedRequest = nil;
    
    if (date) {
        NSTimeInterval timeInterval = [date timeIntervalSince1970];
        extendedRequest = @{@"updated_at[gte]" : @(timeInterval),
                            @"sort_desc" :  @"lastMessageDate"};
    }
    
    return [[self taskAllDialogsWithPageLimit:100
                              extendedRequest:extendedRequest
                               iterationBlock:iterationBlock]
            continueWithBlock:completionBlock];
}

+ (BFTask *)taskAllDialogsWithPageLimit:(NSUInteger)limit
                        extendedRequest:(nullable NSDictionary *)extendedRequest
                         iterationBlock:(nullable void(^)(QBResponse *response, NSArray<QBChatDialog *> * _Nullable dialogObjects, NSSet<NSNumber *> * _Nullable dialogsUsersIDs, BOOL *stop))iterationBlock {
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self allDialogsWithPageLimit:limit
                      extendedRequest:extendedRequest
                       iterationBlock:iterationBlock
                           completion:^(QBResponse *response)
         {
             if (response.success) {
                 
                 [source setResult:nil];
             }
             else {
                 
                 [source setError:response.error.error];
             }
         }];
    });
}

+ (void)allDialogsWithPageLimit:(NSUInteger)limit
                extendedRequest:(NSDictionary *)extendedRequest
                 iterationBlock:(void(^)(QBResponse *response, NSArray<QBChatDialog *>  *dialogObjects, NSSet<NSNumber *>  *dialogsUsersIDs, BOOL *stop))iterationBlock
                     completion:(void(^)(QBResponse *response))completion {
    
    
    __block void(^t_request)(QBResponsePage *responsePage);
    void(^request)(QBResponsePage *responsePage) = ^(QBResponsePage *responsePage) {
        
        [QBRequest dialogsForPage:responsePage
                  extendedRequest:extendedRequest
                     successBlock:^(QBResponse *response, NSArray *dialogs, NSSet *dialogsUsersIDs, QBResponsePage *page)
         {
             
             BOOL cancel = NO;
             page.skip += dialogs.count;
             
             if (page.totalEntries <= (NSUInteger)page.skip) {
                 
                 cancel = YES;
             }
             
             if (iterationBlock != nil) {
                 
                 iterationBlock(response, dialogs, dialogsUsersIDs, &cancel);
             }
             
             if (!cancel) {
                 
                 t_request(page);
             }
             else {
                 
                 if (completion) {
                     completion(response);
                 }
                 
                 t_request = nil;
             }
             
         } errorBlock:^(QBResponse *response) {
             
             if (completion) {
                 
                 completion(response);
             }
             
             t_request = nil;
         }];
    };
    
    t_request = [request copy];
    request([QBResponsePage responsePageWithLimit:limit]);
}

+ (BFTask <QBChatDialog*> *)dialogForUser:(QBUUser *)user {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatDialog*_Nullable dialog, NSDictionary<NSString *,id> * _Nullable __unused bindings) {
        return dialog.type == QBChatDialogTypePrivate && [dialog.occupantIDs containsObject:@(user.ID)];
    }];
    
    QBChatDialog *dialog = [[QMExtensionCache.chatCache.allDialogs filteredArrayUsingPredicate:predicate] firstObject];
    
    if (dialog) {
        return [BFTask taskWithResult:dialog];
    }
    else {
        return [[self createPrivateChatWithOpponentID:user.ID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
            if (t.error) {
                return [BFTask taskWithError:t.error];
            }
            else {
                return [BFTask taskWithResult:t.result];
            }
        }];
    }
}


+ (BFTask <QBChatDialog *>*)createPrivateChatWithOpponentID:(NSUInteger)opponentID {
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil
                                                                 type:QBChatDialogTypePrivate];
    chatDialog.occupantIDs = @[@(opponentID)];
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest createDialog:chatDialog successBlock:^(QBResponse *__unused response, QBChatDialog *createdDialog) {
            [source setResult:createdDialog];
            
        } errorBlock:^(QBResponse *__unused response) {
            [source setError:response.error.error];
        }];
    });
}

@end
