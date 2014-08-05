//
//  QMChatCell.m
//  Q-municate
//
//  Created by Andrey Ivanov on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatCell.h"
#import "NSString+UsedSize.h"
#import "QMImageView.h"
#import "Parus.h"

@interface QMChatCell ()

@property (strong, nonatomic) UIView *messageContainer;
@property (strong, nonatomic) UIImageView *balloonImageView;
@property (strong, nonatomic) NSArray *currentAlignConstrains;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) QMImageView *userImageView;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) QBUUser *user;

@property (strong, nonatomic) NSLayoutConstraint *rMessageContainerConstraint;
@property (strong, nonatomic) NSLayoutConstraint *lMessageContainerConstraint;
@property (strong, nonatomic) NSLayoutConstraint *tMessageContainerConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bMessageContainerConstraint;

@property (strong, nonatomic) NSLayoutConstraint *hUserImageViewConstraint;
@property (strong, nonatomic) NSLayoutConstraint *wUserImageViewConstraint;

@property (strong, nonatomic) NSLayoutConstraint *hBalloonConstraint;
@property (strong, nonatomic) NSLayoutConstraint *wBalloonConstraint;

@property (strong, nonatomic) NSLayoutConstraint *bContainerConstraint;
@property (strong, nonatomic) NSLayoutConstraint *hContainerConstraint;
@property (strong, nonatomic) NSLayoutConstraint *wContainerConstraint;

@property (strong, nonatomic) NSLayoutConstraint *tTitleConstraint;
@property (strong, nonatomic) NSLayoutConstraint *lTitleConstraint;
@property (strong, nonatomic) NSLayoutConstraint *rTitleConstraint;
@property (strong, nonatomic) NSLayoutConstraint *bTitleConstraint;

@property (assign, nonatomic) BOOL showUserImage;

@end

@implementation QMChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createContainerSubviews];
    }
    return self;
}

#define SHOW_BORDERS 0

- (void)createContainerSubviews {
    
    self.messageContainer = [[UIView alloc] init];
    self.containerView = [[UIView alloc] init];
    self.balloonImageView = [[UIImageView alloc] init];
    self.userImageView = [[QMImageView alloc] init];
    self.headerView = [[UIView alloc] init];

    self.containerView.backgroundColor = [UIColor clearColor];
    self.balloonImageView.backgroundColor = [UIColor clearColor];
    self.headerView.backgroundColor = [UIColor clearColor];
    self.messageContainer.backgroundColor = [UIColor clearColor];
    
    self.messageContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.balloonImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.userImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.userImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.userImageView.imageViewType = QMImageViewTypeCircle;
    
    [self.contentView addSubview:self.messageContainer];
    [self.messageContainer addSubview:self.balloonImageView];
    [self.messageContainer addSubview:self.userImageView];
    [self.balloonImageView addSubview:self.containerView];
    [self.messageContainer addSubview:self.headerView];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
#if SHOW_BORDERS
    
    self.messageContainer.layer.borderColor = [UIColor colorWithRed:1.000 green:0.975 blue:0.000 alpha:1.000].CGColor;
    self.messageContainer.layer.borderWidth = 1;
    
    self.containerView.layer.borderColor = [UIColor colorWithRed:0.706 green:0.147 blue:0.000 alpha:1.000].CGColor;
    self.containerView.layer.borderWidth = 1;
    
    self.userImageView.layer.borderColor = [UIColor colorWithRed:0.000 green:1.000 blue:0.552 alpha:1.000].CGColor;
    self.userImageView.layer.borderWidth = 1;
    
    self.balloonImageView.layer.borderColor = [UIColor colorWithRed:0.000 green:0.826 blue:1.000 alpha:1.000].CGColor;
    self.balloonImageView.layer.borderWidth = 1;
    
    self.balloonImageView.backgroundColor = [UIColor lightGrayColor];
    self.containerView.backgroundColor = [UIColor colorWithRed:0.974 green:0.599 blue:1.000 alpha:1.000];
    self.userImageView.backgroundColor = [UIColor greenColor];
    self.headerView.backgroundColor = [UIColor colorWithWhite:0.128 alpha:0.400];
    self.messageContainer.backgroundColor = [UIColor yellowColor];
    
#endif
    
    [self createConstrains];
}

- (void)setBalloonImage:(UIImage *)balloonImage {
    self.balloonImageView.image = balloonImage;
}

- (void)createConstrains {
    
    self.bMessageContainerConstraint = PVBottomOf(self.messageContainer).equalTo.bottomOf(self.contentView).asConstraint;
    self.tMessageContainerConstraint = PVTopOf(self.messageContainer).equalTo.topOf(self.contentView).asConstraint;
    self.lMessageContainerConstraint = PVLeftOf(self.messageContainer).equalTo.leftOf(self.contentView).asConstraint;
    self.rMessageContainerConstraint = PVRightOf(self.messageContainer).equalTo.rightOf(self.contentView).asConstraint;
    
    self.wUserImageViewConstraint = PVWidthOf(self.userImageView).equalTo.constant(0).asConstraint;
    self.hUserImageViewConstraint = PVHeightOf(self.userImageView).equalTo.constant(0).asConstraint;
    
    self.hBalloonConstraint = PVHeightOf(self.balloonImageView).equalTo.constant(0).asConstraint;
    self.wBalloonConstraint = PVWidthOf(self.balloonImageView).equalTo.constant(0).asConstraint;
    
    self.tTitleConstraint = PVTopOf(self.headerView).equalTo.topOf(self.balloonImageView).asConstraint;
    self.lTitleConstraint = PVLeftOf(self.headerView).equalTo.leftOf(self.balloonImageView).asConstraint;
    self.rTitleConstraint = PVRightOf(self.headerView).equalTo.rightOf(self.balloonImageView).asConstraint;
    
    self.bContainerConstraint = PVBottomOf(self.containerView).equalTo.bottomOf(self.balloonImageView).asConstraint;
    self.hContainerConstraint = PVHeightOf(self.containerView).equalTo.constant(0).asConstraint;
    self.wContainerConstraint = PVWidthOf(self.containerView).equalTo.constant(0).asConstraint;
    
    [self.contentView addConstraints:@[self.bMessageContainerConstraint,
                                       self.tMessageContainerConstraint,
                                       self.lMessageContainerConstraint,
                                       self.rMessageContainerConstraint,
                                       
                                       self.wUserImageViewConstraint,
                                       self.hUserImageViewConstraint,
                                       
                                       PVBottomOf(self.userImageView).equalTo.bottomOf(self.messageContainer).asConstraint,
                                       
                                       self.hBalloonConstraint,
                                       self.wBalloonConstraint,
                                       PVBottomOf(self.balloonImageView).equalTo.bottomOf(self.messageContainer).asConstraint,
                                       
                                       self.bContainerConstraint,
                                       self.hContainerConstraint,
                                       self.wContainerConstraint,
                                       
                                       self.tTitleConstraint,
                                       self.lTitleConstraint,
                                       self.rTitleConstraint]];
}

- (void)setMessage:(QMMessage *)message {
    
    _message = message;
    
    QMMessageContentAlign align = self.message.align;
    QMMessageLayout layout = self.message.layout;
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    /*Layout text container*/
    self.bMessageContainerConstraint.constant = -layout.messageMargin.bottom;
    self.tMessageContainerConstraint.constant = layout.messageMargin.top;
    self.lMessageContainerConstraint.constant = layout.messageMargin.left;
    self.rMessageContainerConstraint.constant = - layout.messageMargin.right;
    
    CGSize userImageSize = self.showUserImage ?  layout.userImageSize : CGSizeZero;
    self.hUserImageViewConstraint.constant = userImageSize.height;
    self.wUserImageViewConstraint.constant = userImageSize.width;
    
    if (align == QMMessageContentAlignLeft) {
        insets = layout.leftBalloon.imageCapInsets;
    } else if (align == QMMessageContentAlignRight) {
        insets = layout.rightBalloon.imageCapInsets;
    }
    
    CGFloat balloonWidth = insets.left + layout.contentSize.width + insets.right;
    
    if (balloonWidth < layout.messageMinWidth) {
        balloonWidth = layout.messageMinWidth;
    }
    
    if (align == QMMessageContentAlignLeft) {
        
        self.currentAlignConstrains =
        PVGroup(@[
                  PVLeftOf(self.userImageView).equalTo.leftOf(self.messageContainer).asConstraint,
                  PVLeftOf(self.balloonImageView).equalTo.rightOf(self.userImageView).asConstraint,
                  PVLeftOf(self.containerView).equalTo.leftOf(self.balloonImageView).plus(insets.left).asConstraint,
                  ]).asArray;
        
    }
    else if (align == QMMessageContentAlignRight) {
        
        self.currentAlignConstrains =
        PVGroup(@[
                  PVRightOf(self.userImageView).equalTo.rightOf(self.messageContainer).asConstraint,
                  PVRightOf(self.balloonImageView).equalTo.leftOf(self.userImageView).asConstraint,
                  PVRightOf(self.containerView).equalTo.rightOf(self.balloonImageView).minus(insets.right).asConstraint,
                  
                  ]).asArray;
    }
    
    self.tTitleConstraint.constant = insets.top;
    self.bContainerConstraint.constant = -insets.top;
    self.hContainerConstraint.constant = layout.contentSize.height;
    self.wContainerConstraint.constant = layout.contentSize.width;
    
    self.hBalloonConstraint.constant = insets.top + layout.contentSize.height + insets.bottom + layout.titleHeight;
    self.wBalloonConstraint.constant = balloonWidth;
    
    self.lTitleConstraint.constant = insets.left;
    self.rTitleConstraint.constant = -insets.right;

    [self layoutIfNeeded];
}

- (void)setCurrentAlignConstrains:(NSArray *)currentAlignConstrains {
    
    if (_currentAlignConstrains) {
        [self.contentView removeConstraints:_currentAlignConstrains];
    }
    _currentAlignConstrains = currentAlignConstrains;
    
    [self.contentView addConstraints:_currentAlignConstrains];
}

#pragma mark - Set user image

- (void)setUser:(QBUUser *)user isMe:(BOOL)isMe {

    self.showUserImage = !isMe;
    self.user = user;
}

- (void)setUser:(QBUUser *)user {
    
    _user = user;

    if (self.showUserImage) {
        
        NSURL *url = [NSURL URLWithString:user.website];
        UIImage *placeHolder = [UIImage imageNamed:@"upic-placeholder"];
        [self.userImageView sd_setImageWithURL:url placeholderImage:placeHolder];
    }
    else {
        self.userImageView.image = nil;
    }
}

- (NSDateFormatter *)formatter {

    static dispatch_once_t onceToken;
    static NSDateFormatter *_dateFormatter = nil;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"HH:mm"];
    });

    return _dateFormatter;
}

@end
