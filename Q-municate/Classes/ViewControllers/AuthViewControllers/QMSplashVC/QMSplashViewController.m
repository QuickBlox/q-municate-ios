//
//  QMSplashViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSplashViewController.h"
#import "QMProfile.h"

@implementation QMSplashViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    QMProfile *currentProfile = [QMProfile currentProfile];
    [self performSegueWithIdentifier:currentProfile.userData != nil ? kQMSceneSegueMain : kQMSceneSegueAuth
                              sender:nil];
}

@end
