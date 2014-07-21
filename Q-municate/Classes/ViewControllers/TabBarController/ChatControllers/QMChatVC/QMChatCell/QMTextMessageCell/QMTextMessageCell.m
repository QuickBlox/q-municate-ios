//
//  QMTextMessageCell.m
//  Qmunicate
//
//  Created by Andrey on 17.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTextMessageCell.h"
#import "Parus.h"

@interface QMTextMessageCell()

@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UILabel *userName;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation QMTextMessageCell

- (void)createContainerSubviews {
    
    [super createContainerSubviews];
    
    self.textView = [[UITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.editable = NO;
    self.textView.selectable = YES;
    self.textView.userInteractionEnabled = YES;
    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.textView.showsHorizontalScrollIndicator = NO;
    self.textView.showsVerticalScrollIndicator = NO;
    self.textView.scrollEnabled = NO;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.linkTextAttributes = @{
                                         NSForegroundColorAttributeName : [UIColor whiteColor],
                                         NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid)
                                         };
    
    
    [self.containerView addSubview:self.textView];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.containerView addConstraints:PVGroup(@[
                                                 
                                                 PVLeftOf(self.textView).equalTo.leftOf(self.containerView).asConstraint,
                                                 PVBottomOf(self.textView).equalTo.bottomOf(self.containerView).asConstraint,
                                                 PVTopOf(self.textView).equalTo.topOf(self.containerView).asConstraint,
                                                 PVRightOf(self.textView).equalTo.rightOf(self.containerView).asConstraint]).asArray];
    
    self.userName = [[UILabel alloc] init];
    self.userName.font = [UIFont boldSystemFontOfSize:10];
    self.userName.textColor = [UIColor darkGrayColor];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    self.userName.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.headerView addSubview:self.userName];
    [self.headerView addSubview:self.timeLabel];
    
    [self.headerView addConstraints:PVGroup(@[
                                              PVWidthOf(self.timeLabel).equalTo.constant(40).asConstraint,
                                              PVRightOf(self.timeLabel).equalTo.rightOf(self.headerView).asConstraint,
                                              PVTopOf(self.timeLabel).equalTo.topOf(self.headerView).asConstraint,
                                              PVBottomOf(self.timeLabel).equalTo.bottomOf(self.headerView).asConstraint,
                                              
                                              PVBottomOf(self.userName).equalTo.bottomOf(self.headerView).asConstraint,
                                              PVLeftOf(self.userName).equalTo.leftOf(self.headerView).asConstraint,
                                              PVTopOf(self.userName).equalTo.topOf(self.headerView).asConstraint,
                                              PVRightOf(self.userName).equalTo.leftOf(self.timeLabel).asConstraint,
                                              ]).asArray];
    [self setNeedsUpdateConstraints];
}

- (void)setMessage:(QMMessage *)message {
    
    [super setMessage:message];
    
    self.textView.font = UIFontFromQMMessageLayout(self.message.layout);
    self.textView.text = message.text;
    self.textView.textColor = [message textColor];
    
    self.balloonImage =  message.balloonImage;
    self.balloonTintColor = message.balloonColor;
    self.timeLabel.text = [self.formatter stringFromDate:message.datetime];
}

- (void)setUser:(QBUUser *)user {
    
    [super setUser:user];
    self.userName.text = user.fullName;
}


- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
