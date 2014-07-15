//
//  QMTextMessageCell.m
//  Qmunicate
//
//  Created by Andrey on 17.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTextMessageCell.h"

@interface QMTextMessageCell()

@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIFont *font;

@end

@implementation QMTextMessageCell

- (void)createContainerSubviews {
    
    [super createContainerSubviews];
    
    self.messageLabel = [[UILabel alloc] init];
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.opaque = YES;
    self.messageLabel.backgroundColor = [UIColor clearColor];

    [self.containerView addSubview:self.messageLabel];
}

- (void)setMessage:(QMMessage *)message {
    
    [super setMessage:message];
    
    self.messageLabel.font = UIFontFromQMMessageLayout(self.message.layout);
    self.messageLabel.text = message.text;
    self.messageLabel.textColor = [message textColor];
    
    self.balloonImage =  message.balloonImage;
    self.balloonTintColor = message.balloonColor;
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.messageLabel.text = nil;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.messageLabel.frame = self.containerView.bounds;
}

@end
