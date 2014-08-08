//
//  QMSearchDisplayController.m
//  Q-municate
//
//  Created by Andrey on 01.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSearchDisplayController.h"

@implementation QMSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    [super setActive: visible animated: animated];
    [[UIApplication sharedApplication] setStatusBarStyle:visible ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent];
}


@end
