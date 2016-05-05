//
//  QMTabBarController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMTabBarController.h"

static const CGFloat kQMTabBarHeight = 49.0f;

@interface QMTabBarController () <UITabBarDelegate>

@property (strong, nonatomic, readwrite) UITabBar *tabBar;
@property (strong, nonatomic, readwrite) NSArray *viewControllers;
@property (strong, nonatomic, readwrite) UIViewController *selectedViewController;

@property (assign, nonatomic) NSUInteger selectedItemIndex;

@end

@implementation QMTabBarController

- (void)awakeFromNib {
    
    [self.view addSubview:self.tabBar];
}

#pragma mark - Getters

- (UITabBar *)tabBar {
    
    if (_tabBar == nil) {
        
        _tabBar = [[UITabBar alloc]
                   initWithFrame:CGRectMake(0,
                                            CGRectGetHeight([UIScreen mainScreen].bounds) - kQMTabBarHeight,
                                            [UIScreen mainScreen].bounds.size.width,
                                            kQMTabBarHeight)];
        _tabBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _tabBar.delegate = self;
    }
    
    return _tabBar;
}

#pragma mark - Setters

- (void)setViewControllers:(NSArray *)viewControllers {
    
    if (![_viewControllers isEqualToArray:viewControllers]) {
        
        if (self.selectedViewController && ![viewControllers containsObject:self.selectedViewController]) {
            
            [self selectViewControllerForItemIndex:0];
        }
        
        _viewControllers = viewControllers;
    }
}

#pragma mark - Methods

- (void)addBarItemWithTitle:(NSString *)title image:(UIImage *)image viewController:(UIViewController *)viewController {
    
    NSMutableArray *mutableItems = [NSMutableArray arrayWithArray:self.tabBar.items];
    NSMutableArray *mutableViewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    [mutableItems addObject:item];
    self.tabBar.items = mutableItems.copy;
    
    [mutableViewControllers addObject:viewController];
    self.viewControllers = mutableViewControllers.copy;
    
    if (self.tabBar.selectedItem == nil) {
        
        self.tabBar.selectedItem = self.tabBar.items.firstObject;
        [self selectViewControllerForItemIndex:0];
    }
}

- (void)removeItemAtIndex:(NSUInteger)itemIndex {
    
    NSMutableArray *mutableItems = [NSMutableArray arrayWithArray:self.tabBar.items];
    NSMutableArray *mutableViewControllers = [NSMutableArray arrayWithArray:self.viewControllers];
    
    [mutableItems removeObjectAtIndex:itemIndex];
    [mutableViewControllers removeObjectAtIndex:itemIndex];
    
    self.tabBar.items = mutableItems.copy;
    self.viewControllers = mutableViewControllers.copy;
}

- (void)clearSelectedViewController {
    
    [self.selectedViewController willMoveToParentViewController:nil];
    [self.selectedViewController.view removeFromSuperview];
    [self.selectedViewController removeFromParentViewController];
    self.selectedViewController = nil;
}

- (void)selectViewControllerForItemIndex:(NSUInteger)itemIndex {
    
    if (self.selectedViewController) {
        
        [self clearSelectedViewController];
    }
    
    if (itemIndex > self.viewControllers.count - 1) {
        
        NSAssert(nil, @"Unexpected tab bar item.");
        return;
    }
    
    self.selectedItemIndex = itemIndex;
    self.selectedViewController = self.viewControllers[itemIndex];
    
    [self addChildViewController:self.selectedViewController];
    
    if (self.tabBar.isTranslucent && [self.selectedViewController.view isKindOfClass:[UITableView class]]) {
        
        // configuring tableview insets for transculent tabbar
        [self.selectedViewController.view setFrame:self.view.frame];
        
        UITableView *tableView = (UITableView *)self.selectedViewController.view;
        UIEdgeInsets tableViewInsets = tableView.contentInset;
        tableViewInsets.bottom = CGRectGetHeight(self.tabBar.frame);
        tableView.contentInset = tableViewInsets;
    }
    else {
        
        CGRect frame = self.view.frame;
        frame.size.height -= CGRectGetHeight(self.tabBar.frame);
        [self.selectedViewController.view setFrame:frame];
    }
    
    [self.view insertSubview:self.selectedViewController.view belowSubview:self.tabBar];
    [self.selectedViewController didMoveToParentViewController:self];
    
    [self updateNavigationItem:self.selectedViewController.navigationItem];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)updateNavigationItem:(UINavigationItem *)navigationItem {
    
    self.navigationItem.title = navigationItem.title;
    self.navigationItem.titleView = navigationItem.titleView;
    self.navigationItem.prompt = navigationItem.prompt;
    self.navigationItem.leftBarButtonItems = navigationItem.leftBarButtonItems;
    self.navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems;
    self.navigationItem.backBarButtonItem = navigationItem.backBarButtonItem;
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)__unused tabBar didSelectItem:(UITabBarItem *)item {
    
    NSUInteger index = [tabBar.items indexOfObject:item];
    if (self.selectedItemIndex == index) {
        
        return;
    }
    
    [self selectViewControllerForItemIndex:index];
}

@end
