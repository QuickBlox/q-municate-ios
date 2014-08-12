//
//  QMAttachmentMessageCell.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 17.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAttachmentMessageCell.h"
#import "Parus.h"
#import "SDWebImageManager.h"
#import "QMProgressView.h"
#import "QMImageView.h"

@interface QMAttachmentMessageCell()

@property (strong, nonatomic) QMProgressView *progressView;
@property (strong, nonatomic) CALayer *maskLayer;

@end

@implementation QMAttachmentMessageCell

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    QMAttachmentMessageCell *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return cell;
}

- (void)createContainerSubviews {
    
    [super createContainerSubviews];
    
    self.maskLayer = [CALayer layer];
    self.maskLayer.contentsScale = [UIScreen mainScreen].scale;
    
    self.progressView  = [[QMProgressView alloc] init];
    self.progressView.trackTintColor = [UIColor colorWithWhite:0.956 alpha:1.000];
    
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.mask = self.maskLayer;
    
    [self.balloonImageView addSubview:self.progressView];
    [self.balloonImageView addConstraints:PVGroup(@[
                                                    
                                                    PVLeftOf(self.progressView).equalTo.leftOf(self.balloonImageView).asConstraint,
                                                    PVBottomOf(self.progressView).equalTo.bottomOf(self.balloonImageView).asConstraint,
                                                    PVTopOf(self.progressView).equalTo.topOf(self.balloonImageView).asConstraint,
                                                    PVRightOf(self.progressView).equalTo.rightOf(self.balloonImageView).asConstraint]).asArray];
    
    
    self.balloonImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.balloonImageView.layer.mask = self.maskLayer;
    self.timeLabel.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.250];
    self.timeLabel.layer.cornerRadius = 6;
}

- (void)setMessage:(QMMessage *)message user:(QBUUser *)user isMe:(BOOL)isMe {
    [super setMessage:message user:user isMe:isMe];
    
    QMMessageLayout layout = message.layout;
    QMMessageContentAlign align = message.align;
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (align == QMMessageContentAlignLeft) {
        insets = layout.leftBalloon.imageCapInsets;
    } else if (align == QMMessageContentAlignRight) {
        insets = layout.rightBalloon.imageCapInsets;
    }
    
    self.timeLabel.text = [self.formatter stringFromDate:message.datetime];
    self.timeLabel.textColor = (isMe) ? [UIColor colorWithRed:0.938 green:0.948 blue:0.898 alpha:1.000] : [UIColor grayColor];
    
    UIImage *maskImage = message.balloonImage;
    
    self.maskLayer.contentsCenter =
    CGRectMake(insets.left/maskImage.size.width, insets.top/maskImage.size.height, 1.0/maskImage.size.width, 1.0/maskImage.size.height);
    
    self.maskLayer.contents = (id)maskImage.CGImage;
    
    QBChatAttachment *attachment = message.attachments.lastObject;
    self.balloonImageView.image = nil;
    
    self.progressView.hidden = NO;
    self.progressView.progressTintColor = message.balloonColor;
    
    NSURL *imageUrl = [NSURL URLWithString:attachment.url];
    
    __weak __typeof(self)weakSelf = self;
    
    [weakSelf.balloonImageView sd_setImageWithURL:imageUrl progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        CGFloat progress = ((CGFloat)receivedSize)/((CGFloat)expectedSize);
        weakSelf.progressView.progress = progress;
    } placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        weakSelf.progressView.hidden = YES;
    }];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.maskLayer.frame = self.balloonImageView.bounds;
    
}

@end
