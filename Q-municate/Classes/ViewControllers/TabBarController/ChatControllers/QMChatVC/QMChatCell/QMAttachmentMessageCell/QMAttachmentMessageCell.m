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

@interface QMAttachmentMessageCell()

@property (strong, nonatomic) CALayer *maskLayer;

//@property (strong, nonatomic) UIImageView *attachmentView;
//@property (strong, nonatomic) CALayer *contentLayer;

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
    self.maskLayer.contentsScale = 2;
}

- (void)setMessage:(QMMessage *)message {
    [super setMessage:message];
    
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    QBChatAttachment *attachment = self.message.attachments.lastObject;

    __weak __typeof(self)weakSelf = self;
    self.balloonImageView.image = nil;
    NSURL *imageUrl = [NSURL URLWithString:attachment.url];
    [manager downloadImageWithURL:imageUrl options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        NSLog(@"%d %d", receivedSize, expectedSize);
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {

        weakSelf.balloonImageView.image = image;
    }];
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    QMMessageLayout layout = self.message.layout;
    QMMessageContentAlign align = self.message.align;
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (align == QMMessageContentAlignLeft) {
        insets = layout.leftBalloon.imageCapInsets;
    } else if (align == QMMessageContentAlignRight) {
        insets = layout.rightBalloon.imageCapInsets;
    }
    
    UIImage *maskImage = self.message.balloonImage;
    
    self.maskLayer.contentsCenter =
    CGRectMake(insets.left/maskImage.size.width,
               insets.top/maskImage.size.height,
               1.0/maskImage.size.width,
               1.0/maskImage.size.height);
    
    self.maskLayer.contents = (id)maskImage.CGImage;
   
    self.maskLayer.frame = self.balloonImageView.bounds;
    self.balloonImageView.layer.mask = self.maskLayer;
}

@end
