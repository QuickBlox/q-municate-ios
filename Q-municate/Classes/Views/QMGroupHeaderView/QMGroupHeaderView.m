//
//  QMGroupHeaderView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupHeaderView.h"
#import "QMShadowView.h"
#import "QMPlaceholder.h"

static UIColor *highlightedColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:227.0f/255.0f green:227.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

@interface QMGroupHeaderView () <QMImageViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (copy, nonatomic) NSString *title;

@end

@implementation QMGroupHeaderView

#pragma mark - Overrides

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarImage.imageViewType = QMImageViewTypeCircle;
    self.avatarImage.delegate = self;
    
    QMShadowView *shadowView = [[QMShadowView alloc] initWithFrame:CGRectMake(0,
                                                                              CGRectGetHeight(self.frame) - kQMShadowViewHeight,
                                                                              CGRectGetWidth(self.frame),
                                                                              kQMShadowViewHeight)];
    [self addSubview:shadowView];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
        
        self.backgroundColor = highlighted ? highlightedColor() : [UIColor whiteColor];
        
    } completion:nil];
}

#pragma mark - Methods

- (void)setTitle:(NSString *)title avatarUrl:(NSString *)avatarUrl placeholderID:(NSUInteger)placeholderID {
    
    if (![_title isEqualToString:title]) {
        
        _title = title;
        
        self.titleLabel.text = title;
    }
    
    UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.avatarImage.bounds title:title ID:placeholderID];
    [self.avatarImage setImageWithURL:[NSURL URLWithString:avatarUrl]
                          placeholder:placeholder
                              options:SDWebImageLowPriority
                             progress:nil
                       completedBlock:nil];
}

#pragma mark - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)imageView {
    
    [self.delegate groupHeaderView:self didTapAvatar:imageView];
}

@end
