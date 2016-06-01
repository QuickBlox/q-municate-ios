//
//  QMUserInfoCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 6/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMUserInfoCell.h"

@implementation QMUserInfoCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Get the separator view
    UIView *separatorView = [self valueForKey:@"_separatorView"];
    
    if (separatorView != nil) {
        
        CGRect newFrame = CGRectMake(self.separatorInset.left/2,
                                     CGRectGetMinY(separatorView.frame),
                                     CGRectGetWidth(self.bounds),
                                     CGRectGetHeight(separatorView.frame));
        newFrame = CGRectInset(newFrame, self.separatorInset.left/2, 0);
        separatorView.frame = newFrame;
        
        // Show or hide the bar based on cell state
        if (!self.selected) {
            
            separatorView.hidden = NO;
        }
        
        if (self.isHighlighted) {
            
            separatorView.hidden = YES;
        }
    }
}

@end
