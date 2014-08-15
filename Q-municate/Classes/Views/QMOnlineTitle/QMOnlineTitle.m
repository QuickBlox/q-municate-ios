//
//  QMOnlineTitle.m
//  Q-municate
//
//  Created by Andrey on 14.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMOnlineTitle.h"
#import "Parus.h"

@interface QMOnlineTitle()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *statusLabel;

@end

@implementation QMOnlineTitle

- (void)setTitle:(NSString *)title {
    
    if (_title != title) {
        _title = title;
        self.titleLabel.text = title;
        [self layoutIfNeeded];
    }
}

- (void)setStatus:(NSString *)status {
    
    if (_status != status) {
        _status = status;
        self.statusLabel.text = status;
    }
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor greenColor];
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.backgroundColor = [UIColor redColor];
    
        [self addSubview:self.titleLabel];
        
        [self addConstraints:@[PVTopOf(self.titleLabel).equalTo.topOf(self).asConstraint,
                               PVBottomOf(self.titleLabel).equalTo.bottomOf(self).asConstraint,
                               PVLeftOf(self.titleLabel).equalTo.leftOf(self).asConstraint,
                               PVRightOf(self.titleLabel).equalTo.rightOf(self).asConstraint]];

    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

@end
