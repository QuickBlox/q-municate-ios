//
//  QMMediaInfoServiceDelegate.h
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 2/22/17.
//
//

@protocol QMMediaInfoServiceDelegate <NSObject>

- (void)cancellAllInfoOperations;
- (void)cancelInfoOperationForKey:(NSString *)key;

- (void)videoThumbnailForAttachment:(QBChatAttachment *)attachment
                         completion:(void(^)(UIImage *image, NSError *error))completion;

@end
