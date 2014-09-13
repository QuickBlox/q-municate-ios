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
@property (strong, nonatomic) NSArray *currentAlignConstrains;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) QMImageView *userImageView;
@property (strong, nonatomic) QMImageView *balloonImageView;

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIImageView *deliveryStatusView;

@property (strong, nonatomic) QMMessage *message;
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

@property (strong, nonatomic) NSLayoutConstraint *timeWidhtConstraint;
@property (strong, nonatomic) NSLayoutConstraint *timeRightConstraint;

@property (strong, nonatomic) NSArray *nameConstrains;
@property (strong, nonatomic) NSArray *deliveryViewConstraints;

@property (assign, nonatomic) BOOL showUserImage;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation QMChatCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createContainerSubviews];
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapRecognize:)];
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }
    return self;
}

#define SHOW_BORDERS 0
#define DELIVERY_STATUS_ACTIVATED 0


- (void)createContainerSubviews {
    
    self.messageContainer = [[UIView alloc] init];
    self.containerView = [[UIView alloc] init];
    self.balloonImageView = [[QMImageView alloc] init];
    self.userImageView = [[QMImageView alloc] init];
    self.headerView = [[UIView alloc] init];
    
    self.containerView.backgroundColor = [UIColor clearColor];
    self.balloonImageView.backgroundColor = [UIColor clearColor];
    self.headerView.backgroundColor = [UIColor clearColor];
    self.messageContainer.backgroundColor = [UIColor clearColor];
    
    self.userImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.userImageView.imageViewType = QMImageViewTypeCircle;
    self.balloonImageView.imageViewType = QMImageViewTypeNone;
    
    self.title = [[UILabel alloc] init];
    self.title.font = [UIFont boldSystemFontOfSize:12];
    self.title.textColor = [UIColor darkGrayColor];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    self.deliveryStatusView = [[UIImageView alloc] init];
    self.deliveryStatusView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.title.backgroundColor = [UIColor clearColor];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.deliveryStatusView.backgroundColor = [UIColor clearColor];
    
    self.messageContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.balloonImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.userImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.title.translatesAutoresizingMaskIntoConstraints = NO;
    self.deliveryStatusView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    self.nameConstrains = @[PVBottomOf(self.title).equalTo.bottomOf(self.headerView).asConstraint,
                            PVLeftOf(self.title).equalTo.leftOf(self.headerView).asConstraint,
                            PVTopOf(self.title).equalTo.topOf(self.headerView).asConstraint,
                            PVRightOf(self.title).equalTo.leftOf(self.timeLabel).asConstraint];
    
#if DELIVERY_STATUS_ACTIVATED
    self.deliveryViewConstraints = @[PVWidthOf(self.deliveryStatusView).equalTo.constant(12).asConstraint,
                                     PVRightOf(self.deliveryStatusView).equalTo.rightOf(self.headerView).asConstraint,
                                     PVTopOf(self.deliveryStatusView).equalTo.topOf(self.headerView).asConstraint,
                                     PVBottomOf(self.deliveryStatusView).equalTo.bottomOf(self.headerView).asConstraint];
#endif
    
    [self.contentView addSubview:self.messageContainer];
    [self.messageContainer addSubview:self.balloonImageView];
    [self.messageContainer addSubview:self.userImageView];
    [self.balloonImageView addSubview:self.containerView];
    [self.messageContainer addSubview:self.headerView];
    
    [self.headerView addSubview:self.title];
    [self.headerView addSubview:self.timeLabel];
    [self.headerView addSubview:self.deliveryStatusView];
    
    
    self.timeWidhtConstraint = PVWidthOf(self.timeLabel).equalTo.constant(0).asConstraint;
    self.timeRightConstraint = PVRightOf(self.timeLabel).equalTo.rightOf(self.headerView).asConstraint;
    
    [self.headerView addConstraints:@[self.timeWidhtConstraint,
                                      self.timeRightConstraint,
                                      PVTopOf(self.timeLabel).equalTo.topOf(self.headerView).asConstraint,
                                      PVBottomOf(self.timeLabel).equalTo.bottomOf(self.headerView).asConstraint,
                                      ]];
    
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
        
        self.currentAlignConstrains = @[
                                        PVLeftOf(self.userImageView).equalTo.leftOf(self.messageContainer).asConstraint,
                                        PVLeftOf(self.balloonImageView).equalTo.rightOf(self.userImageView).asConstraint,
                                        PVLeftOf(self.containerView).equalTo.leftOf(self.balloonImageView).plus(insets.left).asConstraint];
    }
    else if (align == QMMessageContentAlignRight) {
        
        self.currentAlignConstrains = @[
                                        PVRightOf(self.userImageView).equalTo.rightOf(self.messageContainer).asConstraint,
                                        PVRightOf(self.balloonImageView).equalTo.leftOf(self.userImageView).asConstraint,
                                        PVRightOf(self.containerView).equalTo.rightOf(self.balloonImageView).minus(insets.right).asConstraint];
    }
    
    self.tTitleConstraint.constant = insets.top;
    self.bContainerConstraint.constant = -insets.top;
    self.hContainerConstraint.constant = layout.contentSize.height;
    self.wContainerConstraint.constant = layout.contentSize.width;
    
    self.hBalloonConstraint.constant = insets.top + layout.contentSize.height + insets.bottom + layout.titleHeight;
    self.wBalloonConstraint.constant = balloonWidth;
    
    self.lTitleConstraint.constant = insets.left;
    self.rTitleConstraint.constant = -insets.right;
    self.timeWidhtConstraint.constant = 34;
    
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

- (void)setMessage:(QMMessage *)message user:(QBUUser *)user isMe:(BOOL)isMe {
    
    self.showUserImage = !isMe;
    self.user = user;
    self.message = message;
    
    if (isMe || (message.chatDialog.type == QBChatDialogTypePrivate)) {
        self.title.text = nil;
        [self.headerView removeConstraints:self.nameConstrains];
    } else {
        self.title.text = user.fullName;
        [self.headerView addConstraints:self.nameConstrains];
    }
#if DELIVERY_STATUS_ACTIVATED
    if (isMe && (message.chatDialog.type == QBChatDialogTypePrivate)) {
        self.timeRightConstraint.constant = -12;
        [self.headerView addConstraints:self.deliveryViewConstraints];
        [self setDeliveryStatus:2];
    } else {
        self.timeRightConstraint.constant = 0;
        [self.headerView removeConstraints:self.deliveryViewConstraints];
        [self setDeliveryStatus:0];
    }
#endif
}

- (void)setUser:(QBUUser *)user {
    
    _user = user;
    
    if (self.showUserImage) {
        
        NSURL *url = [NSURL URLWithString:user.website];
        UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
        
        [self.userImageView setImageWithURL:url
                                placeholder:placeholder
                                    options:SDWebImageLowPriority
                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                             completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
    }
    else {
        self.userImageView.image = nil;
    }
}

- (void)setDeliveryStatus:(NSUInteger)deliveryStatus
{
    UIImage *statusImg;
    if (deliveryStatus == 0) {
        statusImg = nil;
    } else if (deliveryStatus == 1) {
        statusImg = [UIImage imageNamed:@"sent_ic"];
    } else if (deliveryStatus == 2) {
        statusImg = [UIImage imageNamed:@"sent-received_ic"];
    } else {
        statusImg = [UIImage imageNamed:@"notreceived_ic"];
    }
    [self.deliveryStatusView setImage:statusImg];
}


#pragma mark - Date formatter

- (NSDateFormatter *)formatter {
    
    static dispatch_once_t onceToken;
    static NSDateFormatter *_dateFormatter = nil;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"HH:mm"];
    });
    
    return _dateFormatter;
}

#pragma mark - Tap gesture

- (void)didTapRecognize:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(chatCell:didSelectMessage:)]) {
        [self.delegate chatCell:self didSelectMessage:self.message];
    }
}

@end
