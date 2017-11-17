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

@property (assign, nonatomic) CGFloat maxFileSize;  //In megabytes
@property (assign, nonatomic) CGFloat maxImageSize; //In pixels
@property (assign, nonatomic) CGFloat imageQuality; // from 0 to 1.0
@end

@interface QMAttachmentProvider : NSObject

+ (BFTask <QBChatAttachment *>*)attachmentWithFileURL:(NSURL *)fileURL
                                             settings:(nullable QMAttachmentProviderSettings *)providerSettings;
+ (BFTask <QBChatAttachment *>*)imageAttachmentWithData:(NSData *)imageData
                                             settings:(nullable QMAttachmentProviderSettings *)providerSettings;
@end

NS_ASSUME_NONNULL_END
