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

@property (assign, nonatomic) NSUInteger maxFileSize;  //In megabytes
@property (assign, nonatomic) NSUInteger maxImageSideSize; //In pixels
@property (assign, nonatomic) CGFloat dataQuality; // from 0 to 1.0

@end


@interface QMAttachmentProvider : NSObject

@property (strong, nonatomic) QMAttachmentProviderSettings *providerSettings;

- (BFTask <QBChatAttachment*> *)taskAttachmentWithImage:(UIImage *)image
                                        typeIdentifiers:(NSArray *)typeIdentifiers;

- (BFTask <QBChatAttachment*> *)taskAttachmentWithFileURL:(NSURL *)fileURL
                                          typeIdentifiers:(NSArray *)typeIdentifiers;

- (BFTask <QBChatAttachment*> *)taskAttachmentWithData:(NSData *)data
                                       typeIdentifiers:(NSArray *)typeIdentifiers;

@end

NS_ASSUME_NONNULL_END
