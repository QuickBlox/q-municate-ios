//
//  QMSplitViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 8/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSplitViewController.h"
#import "QMNavigationBar.h"

NSString *const kViewControllerNoSelection = @"ViewControllerNoSelection";

@interface QMSplitViewController() <UISplitViewControllerDelegate>

@property (weak, nonatomic) UIViewController *placeholderVC;

@end

@implementation QMSplitViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.delegate = self;
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
}

//MARK: - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
   showDetailViewController:(UIViewController *)detailVC
                     sender:(id)sender {
    
    UITabBarController *masterVC = splitViewController.viewControllers.firstObject;
    
    if (splitViewController.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        
        [masterVC.selectedViewController showViewController:[(UINavigationController *)detailVC topViewController]
                                                     sender:sender];
    }
    else {
        
        [splitViewController setViewControllers:@[masterVC, detailVC]];
    }
    
    return YES;
}

- (UIViewController *)splitViewController:(UISplitViewController *)splitViewController
separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)__unused primaryViewController {
    
    UITabBarController *masterVC = splitViewController.viewControllers.firstObject;
    UINavigationController *selectedNavigationController = masterVC.selectedViewController;
    UINavigationController *navigationController = nil;
    
    NSArray *viewControllers = selectedNavigationController.viewControllers;
    if (viewControllers.count > 1) {
        
        NSMutableArray *mutableViewControllers = [viewControllers mutableCopy];
        [mutableViewControllers removeObjectAtIndex:0];
        
        NSArray *finalViewControllers = [mutableViewControllers copy];
        
        // removing controllers from old stack
        NSMutableArray *mutableSelectedVCs = [viewControllers mutableCopy];
        [mutableSelectedVCs removeObjectsInArray:finalViewControllers];
        [selectedNavigationController setViewControllers:[mutableSelectedVCs copy]];
        
        navigationController = QMNavigationController(finalViewControllers);
    }
    else {
        
        // updating display mode to not stuck on primary visible
        if (self.displayMode != UISplitViewControllerDisplayModeAllVisible) {
            
            self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        }
//        
//        navigationController = QMNavigationController(@[self.placeholderVC ?: [[QMChatVC alloc] init]]);
//        self.placeholderVC = navigationController.topViewController;
    }
    
    return navigationController;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull __unused context) {
        
        self.view.backgroundColor = self.isCollapsed ? [UIColor grayColor] : [UIColor whiteColor];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull __unused context) {
        self.view.backgroundColor = !self.isCollapsed ? [UIColor grayColor] : [UIColor whiteColor];
    }];
}

- (BOOL)splitViewController:(UISplitViewController *)__unused splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {

    if ([secondaryViewController.restorationIdentifier isEqualToString:kViewControllerNoSelection]) {
        // controller is a placeholder
        return NO;
    }
    
    // taking navigation stack for Chats tab
    UINavigationController *primaryNavigationController = [(UITabBarController *)primaryViewController selectedViewController];
    
    // taking top controller from secondary one
    UINavigationController *secondaryNavigationController = (UINavigationController *)secondaryViewController;
    NSArray *detailViewControllers = [secondaryNavigationController viewControllers];
    
    
    // pushing view controller from detail onto primary one
    NSMutableArray *viewControllers = [primaryNavigationController.viewControllers mutableCopy];
    [viewControllers addObjectsFromArray:detailViewControllers];
    [primaryNavigationController setViewControllers:[viewControllers copy]];
    
    return YES;
}

//MARK: - Methods

- (void)showPlaceholderDetailViewController {
    
    // showing placeholder chat VC as placeholder
//    [self showDetailViewController:QMNavigationController(@[[[QMChatVC alloc] init]]) sender:nil];
//    
//    // updating display mode to not stuck on primary visible
//    if (self.displayMode != UISplitViewControllerDisplayModeAllVisible) {
//        
//        self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
//    }
}

//MARK: - Helpers

static inline UINavigationController *QMNavigationController(NSArray <__kindof UIViewController *> *vcs) {
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithNavigationBarClass:[QMNavigationBar class] toolbarClass:nil];
    
    if (vcs.count > 0) {
        
        [navVC setViewControllers:vcs];
    }
    
    return navVC;
}

- (BOOL)isPlaceholderViewController:(__kindof UIViewController *)viewController {
    
//    if ([viewController isKindOfClass:[QMChatVC class]]
//        && [viewController chatDialog] == nil) {
//        
//        return YES;
//    }
    
    return NO;
}

@end
