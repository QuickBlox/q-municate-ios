//
//  QMAttachmentProvider.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/30/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/Bolts.h>
#import <MobileCoreServices/MobileCoreServices.h>

@class QBChatAttachment;

NS_ASSUME_NONNULL_BEGIN

@interface QMAttachmentProviderSettings : NSObject

@property CGFloat maxFileSize;
@property CGFloat maxImageSize;
@property CGFloat imageQuality;

@end

@interface QMAttachmentProvider : NSObject

+ (BFTask <QBChatAttachment *>*)attachmentWithFileURL:(NSURL *)fileURL
                                             settings:(nullable QMAttachmentProviderSettings *)providerSettings;

@end

NS_ASSUME_NONNULL_END
