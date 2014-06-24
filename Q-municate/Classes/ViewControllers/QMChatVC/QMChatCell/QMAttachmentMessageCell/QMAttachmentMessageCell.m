//
//  QMAttachmentMessageCell.m
//  Qmunicate
//
//  Created by Andrey on 17.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAttachmentMessageCell.h"

@interface QMAttachmentMessageCell()

@property (strong, nonatomic) UIImageView *attachmentImageView;

@end

@implementation QMAttachmentMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    QMAttachmentMessageCell *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return cell;
}

- (void)createContainerSubviews {
    
    [super createContainerSubviews];
    
    self.attachmentImageView = [[UIImageView alloc] init];
    self.attachmentImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.containerView addSubview:self.attachmentImageView];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.balloonImageView.layer.mask = nil;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    CGRect rect = self.containerView.bounds;
    
    self.attachmentImageView.frame = rect;
    
    UIImage *image = [UIImage imageNamed:@"video_call_me"];
    UIImage *maskImage = self.message.balloonImage;
    
    CALayer* mask = [CALayer layer];
    
    mask.frame = rect;
    mask.contents = (__bridge id)[maskImage CGImage];
    
    QMChatBalloon ballonSettings = self.message.balloonSettings;
    
    mask.contentsCenter = CGRectMake(ballonSettings.imageCapInsets.left / maskImage.size.width,
                                     ballonSettings.imageCapInsets.top / maskImage.size.height,
                                     1.0 / maskImage.size.width,
                                     1.0 / maskImage.size.height);
    
    self.attachmentImageView.layer.mask = mask;
    self.attachmentImageView.image = image;
}

@end
