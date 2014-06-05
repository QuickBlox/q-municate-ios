//
//  QMRootViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 03/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMRootViewController.h"
#import "QMAuthService.h"

@interface QMRootViewController ()

@property (assign) BOOL isLoggedIn;

@end

@implementation QMRootViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_isLoggedIn) {
        [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
    } else {
        [self performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
    }
    _isLoggedIn = !_isLoggedIn;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
