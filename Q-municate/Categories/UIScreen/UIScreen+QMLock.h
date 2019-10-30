//
//  UIScreen+QMLock.h
//  Q-municate
//
//  Created by Injoit on 3/22/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (QMLock)

@property (assign, readonly, nonatomic) UIInterfaceOrientation qm_lockedInterfaceOrientation;

- (void)qm_lockCurrentOrientation;
- (void)qm_unlockCurrentOrientation;
- (UIInterfaceOrientationMask)qm_allowedInterfaceOrientationMask;

@end
