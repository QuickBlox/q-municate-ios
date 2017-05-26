//
//  QMLinkPreviewChatModel.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 5/19/17.
//
//

#import "QMChatModel.h"

@interface QMLinkPreviewChatModel : QMChatModel

@property (nonatomic, copy, readonly, nullable) void (^imageDidSet)();

@property (nonatomic, copy, nullable) NSString *siteTitle;
@property (nonatomic, copy, nullable) NSString *siteDescription;
@property (nonatomic, copy, nullable) NSString *siteURL;
@property (nonatomic, copy, nullable) NSString *imageURL;
@property (nonatomic, strong, nullable) UIImage *siteImage;
@property (nonatomic, strong, nullable) UIImage *siteIconImage;

@end
