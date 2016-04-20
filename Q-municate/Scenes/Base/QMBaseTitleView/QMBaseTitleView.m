//
//  QMBaseTitleView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMBaseTitleView.h"

@implementation QMBaseTitleView

#pragma mark - Overrides

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [UIView animateWithDuration:kQMBaseAnimationDuration animations:^{
        
        self.layer.opacity = highlighted ? 0.6f : 1.0f;
        
    } completion:nil];
}

@end
