//
//  QMChatCell.h
//  Q-municate
//
//  Created by Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMMessage.h"

@class QMMessage;

@interface QMChatCell : UITableViewCell

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) UIImage *balloonImage;
@property (strong, nonatomic) UIColor *balloonTintColor;
@property (strong, nonatomic, readonly) UIImageView *balloonImageView;
@property (weak, nonatomic) QMMessage *message;
@property (nonatomic, getter = isHiddenUserImage) BOOL hideUserImage; //Default NO

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)createContainerSubviews;
/**
 static NSDateFormatter need for performance
 */
- (NSDateFormatter *)formatter;

@end
