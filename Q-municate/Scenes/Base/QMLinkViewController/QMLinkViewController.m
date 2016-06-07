//
//  QMLinkViewController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 25.02.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMLinkViewController.h"

@implementation QMLinkViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // logic for tab bar controllers
    if (self.tabBarController) {
        
        NSUInteger index = [self.tabBarController.viewControllers indexOfObject:self];
        
        if (index == NSNotFound) NSAssert(nil, @"Must be QMLinkViewController class");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:self.storyboardName bundle:nil];
        
        id scene = nil;
        if (self.sceneIdentifier) {
            
            scene = [storyboard instantiateViewControllerWithIdentifier:self.sceneIdentifier];
        }
        else {
            
            scene = [storyboard instantiateInitialViewController];
        }
        
        [scene setTabBarItem:self.tabBarItem];
        
        NSMutableArray *viewControllers = [self.tabBarController.viewControllers mutableCopy];
        viewControllers[index] = scene;
        
        self.tabBarController.viewControllers = [viewControllers copy];
    }
}

@end
