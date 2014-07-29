//
//  QMChatCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMMessage.h"

@class QMMessage;
@class QMImageView;

@interface QMChatCell : UITableViewCell

@property (strong, nonatomic, readonly) UIView *containerView;
@property (strong, nonatomic, readonly) UIView *headerView;
@property (strong, nonatomic, readonly) UIImageView *balloonImageView;
@property (strong, nonatomic, readonly) QMImageView *userImageView;

@property (strong, nonatomic) QMMessage *message;

- (void)setUser:(QBUUser *)user isMe:(BOOL)isMe;

- (void)setBalloonImage:(UIImage *)balloonImage;
- (void)setBalloonTintColor:(UIColor *)balloonTintColor;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)createContainerSubviews;
- (NSDateFormatter *)formatter;

@end