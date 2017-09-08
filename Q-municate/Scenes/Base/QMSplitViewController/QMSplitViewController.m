//
//  QMSplitViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 8/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSplitViewController.h"
#import "QMNavigationBar.h"
#import "QMNavigationController.h"

NSString *const kViewControllerNoSelection = @"ViewControllerNoSelection";

@interface QMSplitViewController() <UISplitViewControllerDelegate>

@property (weak, nonatomic) UIViewController *placeholderVC;

@end

@implementation QMSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    QMNavigationController *selectedNavigationController = (QMNavigationController *)masterVC.selectedViewController;
    QMNavigationController *navigationController = nil;
    
    NSArray *viewControllers = selectedNavigationController.viewControllers;

    if (viewControllers.count > 1) {
        
        NSMutableArray *mutableViewControllers = [viewControllers mutableCopy];
        [mutableViewControllers removeObjectAtIndex:0];
        
        NSArray *finalViewControllers = [mutableViewControllers copy];
        // removing controllers from old stack
        NSMutableArray *mutableSelectedVCs = [viewControllers mutableCopy];
        [mutableSelectedVCs removeObjectsInArray:finalViewControllers];
        [selectedNavigationController setViewControllers:[mutableSelectedVCs copy]];
        
        navigationController =
        [[QMNavigationController alloc] initWithNavigationBarClass:[QMNavigationBar class]
                                                      toolbarClass:nil];
        if (finalViewControllers.count > 0) {
            [navigationController setViewControllers:finalViewControllers];
        }
        if (selectedNavigationController.currentAdditionalNavigationBarHeight > 0) {
            navigationController.currentAdditionalNavigationBarHeight = 0;
        }
    }
    else {
        
        // updating display mode to not stuck on primary visible
        if (self.displayMode != UISplitViewControllerDisplayModeAllVisible) {
            
            self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        }
        
        id vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewControllerNoSelection];
        navigationController = vc;
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
    QMNavigationController *primaryNavigationController =
    (QMNavigationController *)[(UITabBarController *)primaryViewController selectedViewController];
    
    // taking top controller from secondary one
    QMNavigationController *secondaryNavigationController = (QMNavigationController *)secondaryViewController;
    secondaryNavigationController.currentAdditionalNavigationBarHeight = primaryNavigationController.currentAdditionalNavigationBarHeight;
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
    id vc = [self.storyboard instantiateViewControllerWithIdentifier:kViewControllerNoSelection];
    [self showDetailViewController:vc sender:nil];
    
    // updating display mode to not stuck on primary visible
    if (self.displayMode != UISplitViewControllerDisplayModeAllVisible) {
        
        self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
}

@end
