//
//  QBChatAttachment+QMFactory.h
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import <Quickblox/Quickblox.h>
#import "QBChatAttachment+QMCustomParameters.h"

@interface QBChatAttachment (QMFactory)

+ (instancetype)initWithName:(NSString *)name
                     mediaID:(NSString *)mediaID
                    localURL:(NSURL *)localURL
                 contentType:(QMAttachmentContentType)contentType;

+ (instancetype)videoAttachmentWithFileURL:(NSURL *)itemURL;
+ (instancetype)audioAttachmentWithFileURL:(NSURL *)itemURL;
+ (instancetype)imageAttachmentWithImage:(UIImage *)image;

@end
