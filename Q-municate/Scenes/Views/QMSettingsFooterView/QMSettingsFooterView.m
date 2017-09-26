//
//  QMSettingsFooterView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/30/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSettingsFooterView.h"
#import "QMColors.h"

static UIColor *labelTextColor(void) {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:164.0f/255.0f green:170.0f/255.0f blue:179.0f/255.0f alpha:1.0f];
    });
    
    return color;
}

static UIFont *labelFont(void) {
    
    static UIFont *font = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        font = [UIFont systemFontOfSize:15.0f];
    });
    
    return font;
}

static const CGFloat kQMVersionLabelPosiitonY = 33.0f;
static const CGFloat kQMSpaceBetweenLabels = 16.0f;

static NSString *const kQMBundleShortVersionString = @"CFBundleShortVersionString";
static NSString *const KQMBundleVersion = @"CFBundleVersion";

@interface QMSettingsFooterView ()

@property (strong, nonatomic) UILabel *versionLabel;
@property (strong, nonatomic) UILabel *copyrightLabel;

@end

@implementation QMSettingsFooterView

+ (CGFloat)preferredHeight {
    
    return 100.0f;
}

//MARK: - Construction

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = QMTableViewBackgroundColor();
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:self.versionLabel];
        [self addSubview:self.copyrightLabel];
    }
    
    return self;
}

//MARK: - Getters

- (UILabel *)versionLabel {
    
    if (_versionLabel == nil) {
        
        // configuring label
        _versionLabel = [[UILabel alloc] init];
        [self configureLabel:_versionLabel];
        NSDictionary *info = NSBundle.mainBundle.infoDictionary;
        // setting custom text
        NSString *versionString = [NSString stringWithFormat:@"%@ %@ (%@)",
                                   NSLocalizedString(@"QM_STR_VERSION", nil),
                                   info[kQMBundleShortVersionString],
                                   info[KQMBundleVersion]];
        
        _versionLabel.text = versionString;
        [_versionLabel sizeToFit];
        
        // centering view and setting its y position
        CGPoint center = self.center;
        center.y = kQMVersionLabelPosiitonY;
        _versionLabel.center = center;
    }
    
    return _versionLabel;
}

- (UILabel *)copyrightLabel {
    
    if (_copyrightLabel == nil) {
        
        // configuring label
        _copyrightLabel = [[UILabel alloc] init];
        [self configureLabel:_copyrightLabel];
        
        // setting custom text
        _copyrightLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"QM_STR_POWERED_BY_QUICKBLOX", nil), QuickbloxFrameworkVersion];
        [_copyrightLabel sizeToFit];
        
        // centering view and setting its y position
        CGPoint center = self.center;
        center.y = CGRectGetMinY(self.versionLabel.frame) + CGRectGetHeight(self.versionLabel.frame) + kQMSpaceBetweenLabels;
        _copyrightLabel.center = center;
    }
    
    return _copyrightLabel;
}

//MARK: - Helpers

- (void)configureLabel:(UILabel *)label {
    
    label.font = labelFont();
    label.textColor = labelTextColor();
    label.numberOfLines = 1;
    label.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin);
}

@end
