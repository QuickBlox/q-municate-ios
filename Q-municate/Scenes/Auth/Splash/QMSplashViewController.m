//
//  QMSplashViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSplashViewController.h"
#import "QMServicesManager.h"

@implementation QMSplashViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self performSegueWithIdentifier:QM.profile.userData ? kSceneSegueChat : kSceneSegueAuth
                              sender:nil];
}

@end
