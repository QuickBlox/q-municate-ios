//
//  QMHelpers.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 7/19/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMHelpers.h"

CGRect CGRectOfSize(CGSize size) {
    
    return (CGRect) {CGPointZero, size};
}

NSString *QMStringForTimeInterval(NSTimeInterval timeInterval) {
    
    NSInteger minutes = (NSInteger)(timeInterval / 60);
    NSInteger seconds = (NSInteger)timeInterval % 60;
    
    NSString *timeStr = [NSString stringWithFormat:@"%zd:%02zd", minutes, seconds];
    
    return timeStr;
}

inline void addControllerToNavigationStack(UINavigationController *navC, UIViewController *vc) {
    
    NSMutableArray *viewControllers = [navC.viewControllers mutableCopy];
    [viewControllers addObject:vc];
    [navC setViewControllers:[viewControllers copy]];
}

inline void removeControllerFromNavigationStack(UINavigationController *navC, UIViewController *vc) {
    
    NSMutableArray *viewControllers = [navC.viewControllers mutableCopy];
    [viewControllers removeObject:vc];
    [navC setViewControllers:[viewControllers copy]];
}
