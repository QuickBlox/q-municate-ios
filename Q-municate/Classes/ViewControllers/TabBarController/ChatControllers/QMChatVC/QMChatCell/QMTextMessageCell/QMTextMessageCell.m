//
//  QMTextMessageCell.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 17.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTextMessageCell.h"
#import "Parus.h"
#import "QMApi.h"

@interface QMTextMessageCell()

@property (strong, nonatomic) UILabel *textView;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIColor *textColor;

@end

@implementation QMTextMessageCell

- (void)createContainerSubviews {
    
    [super createContainerSubviews];
    
    self.textView = [[UILabel alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.numberOfLines = 0;
    
    [self.containerView addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addConstraints:@[PVLeftOf(self.textView).equalTo.leftOf(self.containerView).asConstraint,
                                         PVBottomOf(self.textView).equalTo.bottomOf(self.containerView).asConstraint,
                                         PVTopOf(self.textView).equalTo.topOf(self.containerView).asConstraint,
                                         PVRightOf(self.textView).equalTo.rightOf(self.containerView).asConstraint]];
}

- (void)setMessage:(QMMessage *)message user:(QBUUser *)user isMe:(BOOL)isMe {

    [super setMessage:message user:user isMe:isMe];
    
    self.textColor = message.textColor;
    self.font = UIFontFromQMMessageLayout(message.layout);
    self.textView.text = message.encodedText;
    
    self.balloonImage =  message.balloonImage;
    
    self.timeLabel.text = [self.formatter stringFromDate:message.datetime];
    self.timeLabel.textColor = (isMe) ? [UIColor colorWithRed:0.938 green:0.948 blue:0.898 alpha:1.000] : [UIColor grayColor];
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

@end
