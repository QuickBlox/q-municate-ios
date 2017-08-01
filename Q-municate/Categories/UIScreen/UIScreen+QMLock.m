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


- (UIInterfaceOrientation)qm_lockedInterfaceOrientation {
    
    NSNumber *lockedOrientationWrapper =
    objc_getAssociatedObject(self, kQMLockedOrientationObjectKey);
    
    return [lockedOrientationWrapper integerValue];
}

- (void)setQm_lockedInterfaceOrientation:(UIInterfaceOrientation)qm_lockedInterfaceOrientation {
    
    NSNumber *lockedOrientationWrapper = @((UIInterfaceOrientation)qm_lockedInterfaceOrientation);
    objc_setAssociatedObject(self,
                             kQMLockedOrientationObjectKey,
                             lockedOrientationWrapper,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)qm_lockCurrentOrientation {
    
    self.qm_lockedInterfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
}

- (void)qm_unlockCurrentOrientation {
    
    self.qm_lockedInterfaceOrientation = UIInterfaceOrientationUnknown;
    
    if (!UIDeviceOrientationIsValidInterfaceOrientation([[UIDevice currentDevice] orientation])) {
        [UIViewController attemptRotationToDeviceOrientation];
    }
}

- (UIInterfaceOrientationMask)qm_allowedInterfaceOrientationMask {
    
    if (self.qm_lockedInterfaceOrientation != UIInterfaceOrientationUnknown) {
        return 1 << self.qm_lockedInterfaceOrientation;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

@end
