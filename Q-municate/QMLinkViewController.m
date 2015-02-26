//
//  QMLinkViewController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 25.02.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMLinkViewController.h"

@interface QMLinkViewController ()

@property (nonatomic, strong) UIViewController *child;

@end

@implementation QMLinkViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSAssert(self.storyboardName.length > 0, @"No storyboard name");
    
    UIStoryboard * storyboard =
    [UIStoryboard storyboardWithName:self.storyboardName
                              bundle:[NSBundle mainBundle]];
    // Creates the linked scene.
    self.child = (self.sceneIdentifier.length == 0) ?
    [storyboard instantiateInitialViewController] :
    [storyboard instantiateViewControllerWithIdentifier:self.sceneIdentifier];
    
    NSAssert(self.child, @"No scene found in storyboard: \"%@\" with optional identifier: \"%@\"", self.storyboardName, self.sceneIdentifier);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:self.child];
    [self.view addSubview:self.child.view];
    self.child.view.autoresizingMask = self.view.autoresizingMask;
    [self.child didMoveToParentViewController:self];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return YES;
}

@end