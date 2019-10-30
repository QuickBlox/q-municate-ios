//
//  QBChatAttachment+QMFactory.h
//  QMChatService
//
//  Created by Injoit on 3/26/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Quickblox/Quickblox.h>
#import <CoreLocation/CLLocation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QBChatAttachment (QMFactory)

- (instancetype)initWithName:(NSString *)name
                     fileURL:(nullable NSURL *)fileURL
                 contentType:(NSString *)contentType
              attachmentType:(NSString *)type;

+ (instancetype)videoAttachmentWithFileURL:(NSURL *)fileURL;
+ (instancetype)audioAttachmentWithFileURL:(NSURL *)fileURL;
+ (instancetype)imageAttachmentWithImage:(UIImage *)image;
+ (instancetype)locationAttachmentWithCoordinate:(CLLocationCoordinate2D)locationCoordinate;

@end

NS_ASSUME_NONNULL_END
