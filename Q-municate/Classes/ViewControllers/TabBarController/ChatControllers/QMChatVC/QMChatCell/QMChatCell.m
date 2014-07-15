//
//  QMChatCell.m
//  Q-municate
//
//  Created by Ivanov Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatCell.h"
#import "NSString+UsedSize.h"

@interface QMChatCell ()

@property (strong, nonatomic) UIView *messageContainer;
@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) UIImageView *balloonImageView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) CALayer *maskLayer;

@end

@implementation QMChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createContainerSubviews];
    }
    return self;
}

//#define SHOW_BORDERS

- (void)createContainerSubviews {
    
    self.messageContainer = [[UIView alloc] init];
    self.containerView = [[UIView alloc] init];
    self.balloonImageView = [[UIImageView alloc] init];
    self.userImageView = [[UIImageView alloc] init];
    self.timeLabel = [[UILabel alloc] init];
    self.maskLayer = [CALayer layer];
    
    self.userImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    self.contentView.clipsToBounds = NO;
    self.clipsToBounds = NO;
    
    [self.contentView addSubview:self.messageContainer];
    [self.messageContainer addSubview:self.userImageView];
    [self.messageContainer addSubview:self.balloonImageView];
    [self.balloonImageView addSubview:self.containerView];
    [self.balloonImageView addSubview:self.headerLabel];
    [self.balloonImageView addSubview:self.timeLabel];
    
    self.userImage = [UIImage imageNamed:@"group_placeholder"];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
#ifdef SHOW_BORDERS
    
    self.messageContainer.layer.borderColor = [UIColor colorWithRed:0.669 green:0.760 blue:1.000 alpha:1.000].CGColor;
    self.messageContainer.layer.borderWidth = 1;
    
    self.containerView.layer.borderColor = [UIColor colorWithRed:0.641 green:0.706 blue:0.437 alpha:1.000].CGColor;
    self.containerView.layer.borderWidth = 1;
    
    self.userImageView.layer.borderColor = [UIColor colorWithRed:1.000 green:0.475 blue:0.087 alpha:1.000].CGColor;
    self.userImageView.layer.borderWidth = 1;
    
    self.balloonImageView.layer.borderColor = [UIColor colorWithRed:0.286 green:0.587 blue:0.663 alpha:1.000].CGColor;
    self.balloonImageView.layer.borderWidth = 1;
    
    /***** ******/
    self.messageContainer.backgroundColor = [UIColor yellowColor];
    self.balloonImageView.backgroundColor = [UIColor lightGrayColor];
    self.containerView.backgroundColor = [UIColor orangeColor];
    self.userImageView.backgroundColor = [UIColor greenColor];
    
#endif
    
}

- (void)setBalloonImage:(UIImage *)balloonImage {
    
    _balloonImage = balloonImage;
    self.balloonImageView.image = _balloonImage;
}

- (void)setBalloonTintColor:(UIColor *)balloonTintColor {
    
    _balloonTintColor = balloonTintColor;
    self.messageContainer.tintColor = _balloonTintColor;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    QMMessageLayout layout = self.message.layout;
    QMMessageContentAlign align = self.message.align;
    
    CGSize userImageSize = self.hideUserImage ? CGSizeZero : layout.userImageSize;
    
    CGRect messageContainerFrame = CGRectZero;
    CGRect containerFrame = CGRectZero;
    CGRect userImageRect = CGRectZero;
    CGRect balloonFrame = CGRectZero;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    CGFloat messageContainerX = 0;
    CGFloat balloonContainerX = 0;
    CGFloat userImageX = 0;
    
    /*
     * Calculate x for views
     */
    if (align == QMMessageContentAlignLeft) {
        
        insets = layout.leftBalloon.imageCapInsets;
        messageContainerX = layout.messageMargin.left;
        userImageX = 0;
        balloonContainerX = userImageSize.width;
        
    } else if (align == QMMessageContentAlignRight) {
        
        insets = layout.rightBalloon.imageCapInsets;
        messageContainerX = self.contentView.frame.size.width - layout.messageMaxWidth - layout.messageMargin.right;
        userImageX = layout.messageMaxWidth - userImageSize.width;
        balloonContainerX = layout.messageMaxWidth - userImageSize.width - insets.left - layout.contentSize.width - insets.right;
        
    } else if (align == QMMessageContentAlignCenter) {
        messageContainerX = self.contentView.center.x - self.containerView.frame.size.width / 2;
    }
    
    CGFloat balloonWidth = insets.left + layout.contentSize.width + insets.right;
    CGFloat balloonHeight = insets.top + layout.contentSize.height + insets.bottom;
    /*
     *Calculate message container rect
     */
    messageContainerFrame.origin.x = messageContainerX;
    messageContainerFrame.origin.y = layout.messageMargin.top;
    messageContainerFrame.size.width = layout.messageMaxWidth;
    messageContainerFrame.size.height = balloonHeight;
    
    if (!CGSizeEqualToSize(layout.userImageSize, CGSizeZero)) {
        
        if (messageContainerFrame.size.height < layout.userImageSize.height) {
            messageContainerFrame.size.height = layout.userImageSize.height;
        }
    }
    /*
     * Calculate content container rect
     */
    containerFrame.origin.x = insets.left;
    containerFrame.origin.y = insets.top;
    containerFrame.size.width = layout.contentSize.width;
    containerFrame.size.height = layout.contentSize.height;
    /*
     * Calculate user image rect
     */
    userImageRect.origin.x = userImageX;
    userImageRect.origin.y = CGRectGetMaxY(messageContainerFrame) - userImageSize.height - layout.messageMargin.bottom;
    userImageRect.size.width = userImageSize.width;
    userImageRect.size.height = userImageSize.height;
    /*
     * Calculate balloon rect
     */
    balloonFrame.origin.x = balloonContainerX;
    balloonFrame.origin.y =  CGRectGetMaxY(messageContainerFrame) - balloonHeight - layout.messageMargin.bottom;
    balloonFrame.size.width = balloonWidth;
    balloonFrame.size.height = balloonHeight;
    /*
     * Set Frames
     */
    self.messageContainer.frame = messageContainerFrame;
    self.userImageView.frame = userImageRect;
    self.balloonImageView.frame = balloonFrame;
    self.containerView.frame = containerFrame;

    UIImage *maskImage = self.message.balloonImage;
    
    self.maskLayer.frame = self.containerView.bounds;
    self.maskLayer.contents = (__bridge id)[maskImage CGImage];
    
    QMChatBalloon ballonSettings = self.message.balloonSettings;
    self.maskLayer.contentsScale = 2;
    
    self.maskLayer.contentsCenter = CGRectMake(ballonSettings.imageCapInsets.left / maskImage.size.width,
                                               ballonSettings.imageCapInsets.top / maskImage.size.height,
                                               1.0 / maskImage.size.width,
                                               1.0 / maskImage.size.height);
}

#pragma mark - Set user image

- (void)setUserImage:(UIImage *)userImage {
    
    _userImage = userImage;
    self.userImageView.image = _userImage;
}

static NSDateFormatter *_dateFormatter = nil;

- (NSDateFormatter *)formatter {
    
    if (_dateFormatter) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
    }
    
    return _dateFormatter;
}

@end
