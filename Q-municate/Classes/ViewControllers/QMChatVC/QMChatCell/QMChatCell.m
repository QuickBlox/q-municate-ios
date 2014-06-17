//
//  QMChatCell.m
//  Q-municate
//
//  Created by Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatCell.h"
#import "QMMessage.h"
#import "NSString+UsedSize.h"
#import "QMChatLayoutConfigs.h"


@interface QMChatCell ()

@property (nonatomic) CGSize userImageViewSize;

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *balloonImageView;
@property (strong, nonatomic) UIImageView *userImageView;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) UIImage *balloonImage;

@end

@implementation QMChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self configureViews];
    }
    
    return self;
}

//#define DEBUG_COLORS_MODE

#ifdef DEBUG_COLORS_MODE

- (void)setDebugColors {
    
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    
    UIColor *randColor = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
    
    self.backgroundColor = randColor;
    self.balloonImageView.backgroundColor = [UIColor colorWithRed:1.000 green:0.958 blue:0.388 alpha:1.000];
    self.containerView.backgroundColor = [UIColor colorWithRed:0.868 green:0.640 blue:0.843 alpha:1.000];
    self.textView.backgroundColor = [UIColor colorWithRed:1.000 green:0.945 blue:0.837 alpha:0.770];
    self.timeLabel.backgroundColor = [UIColor colorWithRed:0.000 green:0.769 blue:0.961 alpha:1.000];
}

#endif

- (void)configureViews {
    
    self.textView = [[UITextView alloc] init];
    self.containerView = [[UIView alloc] init];
    self.balloonImageView = [[UIImageView alloc] init];
    self.userImageView = [[UIImageView alloc] init];
    self.timeLabel = [[UILabel alloc] init];
    
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.editable = NO;
    self.textView.scrollEnabled = NO;
    self.textView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;

    self.userImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = 5;
    
    self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    self.contentView.clipsToBounds = NO;
    self.clipsToBounds = NO;
    
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
//    self.containerView.backgroundColor = [UIColor redColor];
//    self.contentView.backgroundColor = [UIColor grayColor];
    
    [self.contentView addSubview:self.containerView];
    [self.containerView addSubview:self.balloonImageView];
    [self.containerView addSubview:self.textView];
//    [self.containerView addSubview:self.userImageView];
//    [self.containerView addSubview:self.timeLabel];
    
    [self setUserImageViewSize:CGSizeMake(60, 60)];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
#ifdef DEBUG_COLORS_MODE
    [self setDebugColors];
#endif
}

- (void)setMessage:(QMMessage *)message {
    
    _message = message;
    
    self.containerView.tintColor = [UIColor colorWithRed:0.103 green:0.790 blue:0.279 alpha:1.000];
    self.textView.font = [UIFont fontWithName:self.message.layout.fontName size:self.message.layout.fontSize];
    self.textView.text = self.message.data.text;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self layout];
}

- (void)setUserImage:(UIImage *)userImage {
    
    _userImage = userImage;
    if (!userImage) {
        self.userImageViewSize = CGSizeZero;
    }
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
}

#pragma mark -
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGRect)usedRectForWidth:(CGFloat)width {
    
    CGRect usedFrame = CGRectZero;
    
    if (self.message.attributes) {
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.message.data.text
                                                                             attributes:self.message.attributes];
        self.textView.attributedText = attributedText;
        usedFrame.size = [self.message.data.text usedSizeForMaxWidth:width
                                                      withAttributes:self.message.attributes];
    } else {
        
        self.textView.text = self.message.data.text;
        usedFrame.size = [self.message.data.text usedSizeForMaxWidth:width
                                                            withFont:self.textView.font];
    }
    
    return usedFrame;
}

- (UIImage *)balloonImageForReceiving {
    
    UIImage *bubble = [UIImage imageNamed:@"bubble-left"];
    bubble = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 16, 27)];
    bubble = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    return bubble;
}

- (UIImage *)balloonImageForSending {
    
    UIImage *bubble = [UIImage imageNamed:@"bubble-right"];
    bubble = [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 8, 13)];
    bubble = [bubble imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    return  bubble;
}


#pragma mark - Helper methods

- (void)layout {
    
//    self.containerView.autoresizingMask = self.message.fromMe ? UIViewAutoresizingFlexibleLeftMargin : UIViewAutoresizingFlexibleRightMargin;
    
    CGRect usedFrame = CGRectMake(0,
                                  0,
                                  self.message.layout.textSize.width,
                                  self.message.layout.textSize.height);//[self usedRectForWidth:self.message.layout.messageMaxWidth];
    
    CGRect textViewFrame = CGRectMake(self.message.layout.messageLeftMargin,
                                      self.message.layout.messageTopMargin + self.message.layout.balloonTopMargin,
                                      usedFrame.size.width,
                                      usedFrame.size.height);
    
    if (self.message.layout.balloonMinWidth > 0) {
        
        CGFloat messageMinWidth = self.message.layout.balloonMinWidth - self.message.layout.messageLeftMargin - self.message.layout.messageRightMargin;
        
        if (usedFrame.size.width <  messageMinWidth) {
            usedFrame.size.width = messageMinWidth;
            usedFrame.size.height = [self usedRectForWidth:messageMinWidth].size.height;
        }
    }


    CGFloat messageMinHeight = self.message.layout.balloonMinHeight - self.message.layout.messageTopMargin - self.message.layout.messageBottomMargin;
    
    if (self.message.layout.balloonMinHeight > 0 && usedFrame.size.height < messageMinHeight) {
        usedFrame.size.height = messageMinHeight;
    }


    CGRect balloonFrame = CGRectZero;

    balloonFrame.size.width =
    self.message.layout.messageLeftMargin +
    self.message.layout.messageRightMargin +
    textViewFrame.size.width;
    
    balloonFrame.size.height =
    self.message.layout.messageTopMargin +
    self.message.layout.messageBottomMargin +
    textViewFrame.size.height;
    
    balloonFrame.origin.y = self.message.layout.balloonTopMargin;

//    (balloonFrame.size.width - textViewFrame.size.width - self.message.layout.messageLeftMargin);

//    if (!self.message.fromMe && self.userImage) {
//        
//        textViewFrame.origin.x += self.userImageViewSize.width;
//        balloonFrame.origin.x = self.userImageViewSize.width;
//    }
    
//    textViewFrame.origin.x += self.contentInsets.left - self.contentInsets.right;
    
    self.textView.frame = textViewFrame;
    
//    CGRect userRect = self.userImageView.frame;
//    
//    //    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImage) {
//    if (balloonFrame.size.height < userRect.size.height) {
//        balloonFrame.size.height = userRect.size.height;
//    }
    //    }
    self.balloonImage = [self balloonImageForSending];
    self.balloonImageView.frame = balloonFrame;
    self.balloonImageView.image = self.balloonImage;

    
//    if (self.userImageView.autoresizingMask & UIViewAutoresizingFlexibleTopMargin) {
//        //        userRect.origin.y = balloonFrame.origin.y + balloonFrame.size.height - userRect.size.height;
//    } else {
//        userRect.origin.y = 0;
//    }
    
//    if (self.message.fromMe) {
//        userRect.origin.x += balloonFrame.size.width;
//    } else {
//        userRect.origin.x -= userRect.size.width;
//    }
    
//    self.userImageView.frame = userRect;
//    self.userImageView.image = self.userImage;
    
    CGRect containerFrame = CGRectZero;
    
    containerFrame.origin.x = self.message.fromMe? self.contentView.frame.size.width - balloonFrame.size.width  : 0;
    containerFrame.origin.y = 0;
    
    containerFrame.size.height = balloonFrame.size.height;
    containerFrame.size.width = balloonFrame.size.width;
//    //    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImage)
//    {
//        containerFrame.size.width += containerFrame.size.width;
//        if (self.message.fromMe) {
//            containerFrame.origin.x -= containerFrame.size.width;
//        }
//    }
    
//    if (containerFrame.size.height < self.userImageViewSize.height) {
//        CGFloat delta = self.userImageViewSize.height - containerFrame.size.height;
//        containerFrame.size.height = self.userImageViewSize.height;
//        
//        for (UIView *sub in self.containerView.subviews) {
//            CGRect fr = sub.frame;
//            fr.origin.y += delta;
//            sub.frame = fr;
//        }
//    }
    
    self.containerView.frame = containerFrame;
    
//    NSLog(@"%@", NSStringFromCGRect(self.userImageView.frame));
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    self.timeLabel.text = [formatter stringFromDate:[NSDate date]];
    
    [self.timeLabel sizeToFit];
}

@end
