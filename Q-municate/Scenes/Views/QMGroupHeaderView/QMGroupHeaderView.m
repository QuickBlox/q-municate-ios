//
//  QMGroupHeaderView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupHeaderView.h"
#import "QMShadowView.h"

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

//MARK: - Overrides

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarImage.imageViewType = QMImageViewTypeCircle;
    self.avatarImage.delegate = self;
    
    QMShadowView *shadowView = [[QMShadowView alloc] initWithFrame:CGRectMake(0,
                                                                              CGRectGetHeight(self.frame) - kQMShadowViewHeight,
                                                                              CGRectGetWidth(self.frame),
                                                                              kQMShadowViewHeight)];
    shadowView.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:shadowView];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
        
        self.backgroundColor = highlighted ? highlightedColor() : [UIColor whiteColor];
        
    } completion:nil];
}

//MARK: - Methods

- (void)setTitle:(NSString *)title avatarUrl:(NSString *)avatarUrl {
    
    if (![_title isEqualToString:title]) {
        _title = [title copy];
        self.titleLabel.text = title;
    }
    
    [self.avatarImage setImageWithURL:[NSURL URLWithString:avatarUrl]
                                title:title
                       completedBlock:nil];
}

//MARK: - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)imageView {
    
    [self.delegate groupHeaderView:self didTapAvatar:imageView];
}

@end
