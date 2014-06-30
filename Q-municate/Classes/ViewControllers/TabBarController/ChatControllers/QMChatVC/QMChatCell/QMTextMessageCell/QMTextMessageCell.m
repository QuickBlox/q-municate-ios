//
//  QMTextMessageCell.m
//  Qmunicate
//
//  Created by Andrey on 17.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTextMessageCell.h"

@interface QMTextMessageCell()

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIFont *font;

@end

@implementation QMTextMessageCell

- (void)createContainerSubviews {
    
    [super createContainerSubviews];
    
    self.textView = [[UITextView alloc] init];
    
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.scrollEnabled = NO;
    
    [self.containerView addSubview:self.textView];
}

- (void)setMessage:(QMMessage *)message {
    
    [super setMessage:message];
    
    self.textView.font = UIFontFromQMMessageLayout(self.message.layout);
    self.textView.text = message.data.text;
    self.balloonImage =  message.balloonImage;
    self.balloonTintColor = message.balloonColor;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.textView.text = nil;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.textView.frame = self.containerView.bounds;
}

@end
