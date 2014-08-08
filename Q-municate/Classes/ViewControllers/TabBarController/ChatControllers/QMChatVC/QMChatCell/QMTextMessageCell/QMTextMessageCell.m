//
//  QMTextMessageCell.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 17.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTextMessageCell.h"
#import "Parus.h"

@interface QMTextMessageCell()

@property (strong, nonatomic) UILabel *textView;
@property (strong, nonatomic) UILabel *userName;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) NSLayoutConstraint *timeWidhtConstraint;

@end

@implementation QMTextMessageCell

- (void)createContainerSubviews {
    
    [super createContainerSubviews];
    
    self.textView = [[UILabel alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.numberOfLines = 0;
    
    //    self.textView.editable = NO;
    //    self.textView.selectable = YES;
    //    self.textView.userInteractionEnabled = YES;
    //    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    //    self.textView.showsHorizontalScrollIndicator = NO;
    //    self.textView.showsVerticalScrollIndicator = NO;
    //    self.textView.scrollEnabled = NO;
    //    self.textView.textContainer.lineFragmentPadding = 0;
    //    self.textView.scrollIndicatorInsets = UIEdgeInsetsZero;
    //    self.textView.textContainerInset = UIEdgeInsetsZero;
    //    self.textView.linkTextAttributes = @{
    //                                         NSForegroundColorAttributeName : [UIColor whiteColor],
    //                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)
    //                                         };
    
    
    [self.containerView addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.userName = [[UILabel alloc] init];
    self.userName.font = [UIFont boldSystemFontOfSize:12];
    self.userName.textColor = [UIColor darkGrayColor];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    self.userName.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.headerView addSubview:self.userName];
    [self.headerView addSubview:self.timeLabel];

    [self.containerView addConstraints:PVGroup(@[
                                                 
                                                 PVLeftOf(self.textView).equalTo.leftOf(self.containerView).asConstraint,
                                                 PVBottomOf(self.textView).equalTo.bottomOf(self.containerView).asConstraint,
                                                 PVTopOf(self.textView).equalTo.topOf(self.containerView).asConstraint,
                                                 PVRightOf(self.textView).equalTo.rightOf(self.containerView).asConstraint]).asArray];

    self.timeWidhtConstraint = PVWidthOf(self.timeLabel).equalTo.constant(0).asConstraint;
    [self.headerView addConstraints:PVGroup(@[
                                              self.timeWidhtConstraint,
                                              PVRightOf(self.timeLabel).equalTo.rightOf(self.headerView).asConstraint,
                                              PVTopOf(self.timeLabel).equalTo.topOf(self.headerView).asConstraint,
                                              PVBottomOf(self.timeLabel).equalTo.bottomOf(self.headerView).asConstraint,
                                              
                                              PVBottomOf(self.userName).equalTo.bottomOf(self.headerView).asConstraint,
                                              PVLeftOf(self.userName).equalTo.leftOf(self.headerView).asConstraint,
                                              PVTopOf(self.userName).equalTo.topOf(self.headerView).asConstraint,
                                              PVRightOf(self.userName).equalTo.leftOf(self.timeLabel).asConstraint,
                                              ]).asArray];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.timeWidhtConstraint.constant = 40;
}

- (void)setMessage:(QMMessage *)message {
    
    [super setMessage:message];
    
    self.textColor = message.textColor;
    self.font = UIFontFromQMMessageLayout(self.message.layout);
    self.textView.text = message.text;
    
    self.balloonImage =  message.balloonImage;
    self.timeLabel.text = [self.formatter stringFromDate:message.datetime];
}

- (void)setTextColor:(UIColor *)textColor {
    
    if (![_textColor isEqual:textColor] ) {
        _textColor = textColor;
        self.textView.textColor = textColor;
    }
}

- (void)setFont:(UIFont *)font {
    
    if (![_font isEqual:font]) {
        _font = font;
        self.textView.font = font;
    }
}

- (void)setUser:(QBUUser *)user isMe:(BOOL)isMe {
    [super setUser:user isMe:isMe];
    self.userName.text = isMe ? nil : user.fullName;
}

@end
