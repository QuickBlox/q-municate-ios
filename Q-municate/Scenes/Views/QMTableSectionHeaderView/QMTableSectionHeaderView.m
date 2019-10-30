//
//  QMTableSectionHeaderView.m
//  Q-municate
//
//  Created by Injoit on 4/5/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
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

//MARK: - Construction

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = QMTableViewBackgroundColor();
        
        [self addSubview:self.titleLabel];
        if (@available(iOS 11, *)) {
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
            UILayoutGuide * guide = self.safeAreaLayoutGuide;
            NSLayoutConstraint *leading = [self.titleLabel.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor];
            leading.constant = 16;
            leading.active = YES;
            
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES;
            [self.titleLabel.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
            [self.titleLabel.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
        } else {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        }
    }
    
    return self;
}

//MARK: - Getters

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

//MARK: - Setters

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = [title copy];
        
        self.titleLabel.text = title;
        [self.titleLabel sizeToFit];
    }
}

@end
