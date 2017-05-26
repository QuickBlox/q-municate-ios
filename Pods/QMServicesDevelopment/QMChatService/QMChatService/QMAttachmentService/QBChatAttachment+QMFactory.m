//
//  QBChatAttachment+QMFactory.m
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import "QBChatAttachment+QMFactory.h"

@implementation QBChatAttachment (QMFactory)

+ (instancetype)initWithName:(NSString *)name
                     mediaID:(NSString *)mediaID
                    localURL:(NSURL *)localURL
                 contentType:(QMAttachmentContentType)contentType {
    
    QBChatAttachment *attachment = [QBChatAttachment new];
    attachment.name = name;
    attachment.ID = mediaID;
    attachment.localFileURL = localURL;
    attachment.contentType = contentType;
    attachment.type = [attachment stringContentType];
    
    return attachment;
}

+ (instancetype)videoAttachmentwWithFileURL:(NSURL *)itemURL {
    
    return  [self initWithName:@"Video attachment"
                       mediaID:nil
                      localURL:itemURL
                   contentType:QMAttachmentContentTypeVideo];
}

+ (instancetype)audioAttachmentWithFileURL:(NSURL *)itemURL {
    
    return [self initWithName:@"Voice message"
                      mediaID:nil
                     localURL:itemURL
                  contentType:QMAttachmentContentTypeAudio];
}

+ (instancetype)imageAttachmentWithImage:(UIImage *)image {
    
    QBChatAttachment *attachment =  [self initWithName:@"Image attachment"
                                               mediaID:nil
                                              localURL:nil
                                           contentType:QMAttachmentContentTypeImage];
    
    attachment.image = image;
    return attachment;
}

@end
