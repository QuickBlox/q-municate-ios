//
//  QMBaseService.m
//  Q-municate
//
//  Created by Andrey Ivanov on 04.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMBaseService.h"

@implementation QMBaseService

@synthesize active = _active;

- (void)start {
    
    NSAssert(self.active == NO, @"Need stop service before start...");
    self.active = YES;
    ILog(@"******************** (START %@ SERVICE) ********************", NSStringFromClass(self.class));
}

- (void)stop {
    
    NSAssert(self.active == YES, @"Service dont running..");
    self.active = NO;
    ILog(@"******************** (STOP %@ SERVICE )********************", NSStringFromClass(self.class));
}

@end
