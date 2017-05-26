//
//  UIScreen+QMLock.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 3/22/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "UIScreen+QMLock.h"
#import <objc/runtime.h>

static void *kQMLockedOrientationObjectKey = &kQMLockedOrientationObjectKey;

@implementation UIScreen (QMLock)

- (UIInterfaceOrientation)lockedInterfaceOrientation {
    
    NSNumber *lockedOrientationWrapper =
    objc_getAssociatedObject(self, kQMLockedOrientationObjectKey);
    
    return [lockedOrientationWrapper integerValue];
}

- (void)setLockedInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    NSNumber *lockedOrientationWrapper = @((UIInterfaceOrientation)orientation);
    objc_setAssociatedObject(self,
                             kQMLockedOrientationObjectKey,
                             lockedOrientationWrapper,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)lockCurrentOrientation {
    
    self.lockedInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

- (void)unlockCurrentOrientation {
    
    self.lockedInterfaceOrientation = UIInterfaceOrientationUnknown;
    
    if (!UIDeviceOrientationIsValidInterfaceOrientation([[UIDevice currentDevice] orientation])) {
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
