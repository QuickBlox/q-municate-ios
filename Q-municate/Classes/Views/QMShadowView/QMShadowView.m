//
//  QMShadowView.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMShadowView.h"

static UIColor *backgroundColor() {
    
    static UIColor *color = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        color = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    });
    
    return color;
}

@implementation QMShadowView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = backgroundColor();
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    return self;
}

@end
