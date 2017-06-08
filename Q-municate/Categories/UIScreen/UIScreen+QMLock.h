//
//  UIScreen+QMLock.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 3/22/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (QMLock)

@property (assign, readonly) UIInterfaceOrientation lockedInterfaceOrientation;

- (void)lockCurrentOrientation;
- (void)unlockCurrentOrientation;
- (UIInterfaceOrientationMask)allowedInterfaceOrientationMask;

@end
