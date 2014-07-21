//
//  QMChatCell.h
//  Q-municate
//
//  Created by Ivanov Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMMessage.h"

@class QMMessage;

@interface QMChatCell : UITableViewCell

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) QBUUser *user;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic, readonly) UIImageView *balloonImageView;
@property (strong, nonatomic) QMMessage *message;
@property (nonatomic, getter = isHiddenUserImage) BOOL hideUserImage; //Default NO

@property (strong, nonatomic, readonly) CALayer *maskLayer;

- (void)setBalloonImage:(UIImage *)balloonImage;
- (void)setBalloonTintColor:(UIColor *)balloonTintColor;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)createContainerSubviews;
- (NSDateFormatter *)formatter;

@end