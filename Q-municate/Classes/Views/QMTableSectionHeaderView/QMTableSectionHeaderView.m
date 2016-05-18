//
//  QMTableSectionHeaderView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTableSectionHeaderView.h"
#import "QMColors.h"

static const CGFloat kQMTitleLabelX = 16.0f;
static const CGFloat kQMTitleLabelY = 22.0f;

static UIColor *labelTextColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:109.0f/255.0f green:109.0f/255.0f blue:114.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

static UIFont *labelFont() {
    
    static UIFont *font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        font = [UIFont systemFontOfSize:13.0f];
    });
    
    return font;
}

@interface QMTableSectionHeaderView ()

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation QMTableSectionHeaderView

#pragma mark - Construction

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = QMTableViewBackgroundColor();
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    
    if (_titleLabel == nil) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kQMTitleLabelX,
                                                                CGRectGetHeight(self.frame) - kQMTitleLabelY,
                                                                0,
                                                                0)];
        _titleLabel.font = labelFont();
        _titleLabel.textColor = labelTextColor();
        _titleLabel.numberOfLines = 1;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    return _titleLabel;
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = [title copy];
        
        self.titleLabel.text = title;
        [self.titleLabel sizeToFit];
    }
}

@end
