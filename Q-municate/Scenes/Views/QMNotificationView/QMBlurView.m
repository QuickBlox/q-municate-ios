//
//  QMBlurView.m
//  Q-municate
//
//  Created by Andrey Ivanov on 19.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMBlurView.h"

@interface QMBlurView()

@property (nonatomic, strong) UIView *tintColorView;

@end

@implementation QMBlurView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    if (self) {
        
        self.tintColorView = [[UIView alloc] initWithFrame:self.bounds];
        self.tintColorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.userInteractionEnabled = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.tintColorView];
    }
    
    return self;
}

- (void)setBlurTintColor:(UIColor *)tintColor {
    
    self.tintColorView.backgroundColor = [tintColor colorWithAlphaComponent:0.6];
}

@end
