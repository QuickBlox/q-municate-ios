//
//  UIScreen+QMLock.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 3/22/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (QMLock)

@property (assign, readonly, nonatomic) UIInterfaceOrientation qm_lockedInterfaceOrientation;

- (void)qm_lockCurrentOrientation;
- (void)qm_unlockCurrentOrientation;
- (UIInterfaceOrientationMask)qm_allowedInterfaceOrientationMask;

@end
