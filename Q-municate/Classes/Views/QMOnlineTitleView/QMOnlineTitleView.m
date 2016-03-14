//
//  QMOnlineTitleView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/14/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMOnlineTitleView.h"

@interface QMOnlineTitleView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *status;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelTrailingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTrailingConstraint;

@end

@implementation QMOnlineTitleView

- (void)setTitle:(NSString *)title {
    
    if (![_title isEqualToString:title]) {
        
        _title = title;
        self.titleLabel.text = title;
        
        [self sizeToFit];
    }
}

- (void)setStatus:(NSString *)status {
    
    if (![_status isEqualToString:status]) {
        
        _status = status;
        self.statusLabel.text = status;
        
        [self sizeToFit];
    }
}

#pragma mark - Overrides

- (void)sizeToFit {
    
    [self.titleLabel sizeToFit];
    [self.statusLabel sizeToFit];
    
    [super sizeToFit];
}

- (CGSize)sizeThatFits:(CGSize)size {
    
    CGFloat width = 0.0;
    for (UIView *view in [self subviews]) {
        
        if (view.frame.size.width > width) {
            
            width = view.frame.size.width;
            
            if (view == self.titleLabel) {
                
                width += self.titleLabelLeadingConstraint.constant + self.titleLabelTrailingConstraint.constant;
            }
            else if (view == self.statusLabel) {
                
                width += self.statusLabelLeadingConstraint.constant + self.statusLabelTrailingConstraint.constant;
            }
        }
    }
    
    size.width = width;
    return size;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.alpha = highlighted ? 0.3f : 1.0f;
}

@end
