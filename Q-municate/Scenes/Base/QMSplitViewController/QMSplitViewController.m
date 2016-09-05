//
//  QMSplitViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 8/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSplitViewController.h"
#import "QMChatVC.h"
#import "QMHelpers.h"

#import "QMNavigationBar.h"

@interface QMSplitViewController() <UISplitViewControllerDelegate>

@end

@implementation QMSplitViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.delegate = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

#pragma mark - UISplitViewControllerDelegate

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
    
    UINavigationController *masterNavigationController = (UINavigationController *)masterVC.viewControllers.firstObject;
    NSArray *viewControllers = [masterNavigationController viewControllers];
    BOOL shouldMoveToStack = NO;
    UINavigationController *navigationController = nil;
    
    for (UIViewController *obj in viewControllers) {
        
        if (shouldMoveToStack) {
            
            removeControllerFromNavigationStack(masterNavigationController, obj);
            addControllerToNavigationStack(navigationController, obj);
        }
        
        if ([obj isKindOfClass:[QMChatVC class]] && !shouldMoveToStack) {
            
            shouldMoveToStack = YES;
            removeControllerFromNavigationStack(masterNavigationController, obj);
            navigationController = [self navigationControllerWithRootViewController:obj];
        }
    }
    
    if (navigationController == nil) {
        
        navigationController = [self navigationControllerWithRootViewController:[[QMChatVC alloc] init]];
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

#pragma mark - Methods

- (void)showPlaceholderDetailViewController {
    
    // showing placeholder chat VC as placeholder
    [self showDetailViewController:[self navigationControllerWithRootViewController:[[QMChatVC alloc] init]] sender:nil];
    
    // updating display mode to not stuck on primary visible
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

#pragma mark - Helpers

- (UINavigationController *)navigationControllerWithRootViewController:(UIViewController *)rvc {
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithNavigationBarClass:[QMNavigationBar class] toolbarClass:nil];
    
    if (rvc != nil) {
        
        [navVC setViewControllers:@[rvc]];
    }
    
    return navVC;
}

@end
