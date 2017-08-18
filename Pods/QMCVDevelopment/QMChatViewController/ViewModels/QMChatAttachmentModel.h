//
//  QMChatAttachmentModel.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 5/30/17.
//
//

#import "QMChatModel.h"

@interface QMChatAttachmentModel : QMChatModel

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnailImage;

@end
