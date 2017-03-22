//
//  UIScreen+QMLock.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 3/22/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "UIScreen+QMLock.h"
#import <objc/runtime.h>

static void *kAssociatedObjectKey = &kAssociatedObjectKey;

@implementation UIScreen (QMLock)

- (UIInterfaceOrientation)lockedInterfaceOrientation {
    NSNumber *locationWrapper = objc_getAssociatedObject(self, kAssociatedObjectKey);
    return [locationWrapper integerValue];
}

- (void)setLockedInterfaceOrientation:(UIInterfaceOrientation)orientation {
    NSNumber *locationWrapper = [NSNumber numberWithInteger:(UIInterfaceOrientation)orientation];
    objc_setAssociatedObject(self, kAssociatedObjectKey, locationWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)lockCurrentOrientation {
    
    self.lockedInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

- (void)unlockCurrentOrientation {
    
    self.lockedInterfaceOrientation = UIInterfaceOrientationUnknown;
    
    if (!UIDeviceOrientationIsValidInterfaceOrientation([UIApplication sharedApplication].statusBarOrientation)) {
       [UIViewController attemptRotationToDeviceOrientation];
    }
}

- (UIInterfaceOrientationMask)allowedInterfaceOrientationMask {
    
    if (self.lockedInterfaceOrientation != UIInterfaceOrientationUnknown) {
        return 1 << self.lockedInterfaceOrientation;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

@end
