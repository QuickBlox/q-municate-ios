//
//  QMSplitViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 8/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSplitViewController.h"
#import "QMChatVC.h"

@interface QMSplitViewController() <UISplitViewControllerDelegate>

@end

@implementation QMSplitViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.delegate = self;
}

#pragma mark - UISplitViewControllerDelegate

static inline void addControllerToNavigationStack(UINavigationController *navC, UIViewController *vc) {
    
    NSMutableArray *viewControllers = [navC.viewControllers mutableCopy];
    [viewControllers addObject:vc];
    [navC setViewControllers:[viewControllers copy]];
}

static inline void removeControllerFromNavigationStack(UINavigationController *navC, UIViewController *vc) {
    
    NSMutableArray *viewControllers = [navC.viewControllers mutableCopy];
    [viewControllers removeObject:vc];
    [navC setViewControllers:[viewControllers copy]];
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)detailVC sender:(id)sender {
    
    UITabBarController *masterVC = splitViewController.viewControllers.firstObject;
    
    if (splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        
        [masterVC.selectedViewController showViewController:[(UINavigationController *)detailVC topViewController] sender:sender];
    }
    else {
        
        [splitViewController setViewControllers:@[masterVC, detailVC]];
    }
    
    return YES;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)__unused primaryViewController {
    
    UITabBarController *masterVC = splitViewController.viewControllers.firstObject;
    
    UINavigationController *masterNavigationController = (UINavigationController *)masterVC.selectedViewController;
    NSArray *viewControllers = [masterNavigationController viewControllers];
    BOOL shouldMoveToStack = NO;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[QMChatVC alloc] init]];
    
    for (UIViewController *obj in viewControllers) {
        
        if (shouldMoveToStack) {
            
            removeControllerFromNavigationStack(masterNavigationController, obj);
            addControllerToNavigationStack(navigationController, obj);
        }
        
        if ([obj isKindOfClass:[QMChatVC class]] && !shouldMoveToStack) {
            
            shouldMoveToStack = YES;
            removeControllerFromNavigationStack(masterNavigationController, obj);
            navigationController = [[UINavigationController alloc] initWithRootViewController:obj];
        }
    }
    
    return navigationController;
}

- (BOOL)splitViewController:(UISplitViewController *)__unused splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    // taking navigation stack for Chats tab
    UINavigationController *primaryNavigationController = [(UITabBarController *)primaryViewController viewControllers].firstObject;
    
    // taking top controller from secondary one
    UINavigationController *secondaryNavigationController = (UINavigationController *)secondaryViewController;
    NSArray *detailViewControllers = [secondaryNavigationController viewControllers];
    QMChatVC *topVC = (QMChatVC *)detailViewControllers.firstObject;
    
    if (topVC.chatDialog != nil) {
        
        // controller is not a placeholder
        // pushing view controller from detail onto primary one
        NSMutableArray *viewControllers = [primaryNavigationController.viewControllers mutableCopy];
        [viewControllers addObjectsFromArray:detailViewControllers];
        [primaryNavigationController setViewControllers:[viewControllers copy]];
        
        return YES;
    }
    
    return NO;
}

@end
