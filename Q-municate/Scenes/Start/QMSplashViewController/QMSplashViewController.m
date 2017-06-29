//
//  QMSplashViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSplashViewController.h"
#import "QMCore.h"

@implementation QMSplashViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self performSegueWithIdentifier:QMCore.instance.currentProfile.userData != nil ? kQMSceneSegueMain : kQMSceneSegueAuth
                              sender:nil];
}

@end
