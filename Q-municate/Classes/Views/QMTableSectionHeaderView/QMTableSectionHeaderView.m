//
//  QMTableSectionHeaderView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTableSectionHeaderView.h"
#import "QMColors.h"

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

+ (CGFloat)preferredHeight {
    
    return 32.0f;
}

#pragma mark - Construction

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = QMTableViewBackgroundColor();
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self configureTitleLabel];
    }
    
    return self;
}

- (void)configureTitleLabel {
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f,
                                                            10.0f,
                                                            0,
                                                            0)];
    _titleLabel.font = labelFont();
    _titleLabel.textColor = labelTextColor();
    _titleLabel.numberOfLines = 1;
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:_titleLabel];
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = title;
        
        self.titleLabel.text = title;
        [self.titleLabel sizeToFit];
    }
}

@end
