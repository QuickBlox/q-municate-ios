//
//  QMAttachmentMessageCell.m
//  Qmunicate
//
//  Created by Andrey on 17.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAttachmentMessageCell.h"

@interface QMAttachmentMessageCell()

@property (strong, nonatomic) UIView *attachmentView;
@property (strong, nonatomic) CALayer *contentLayer;

@end

@implementation QMAttachmentMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    QMAttachmentMessageCell *cell = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return cell;
}

- (void)createContainerSubviews {
    
    [super createContainerSubviews];
    
    self.attachmentView = [[UIView alloc] init];
    self.attachmentView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.containerView addSubview:self.attachmentView];
    
    self.contentLayer = [CALayer layer];
    self.contentLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.contentLayer.anchorPoint = CGPointMake(0, 0);
    [self.attachmentView.layer addSublayer:self.contentLayer];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    self.balloonImageView.layer.mask = nil;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.attachmentView.frame = self.containerView.bounds;
    
    UIImage *image = [UIImage imageNamed:@"qm.png"];
    
    self.contentLayer.bounds = (CGRect){CGPointZero, self.containerView.frame.size};
    self.contentLayer.contents = (id)image.CGImage;
    self.contentLayer.mask = self.maskLayer;
}

@end
