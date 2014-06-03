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


@end

@implementation QMRootViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[QMAuthService shared] isSessionCreated]) {
        [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
        return;
    }
    [self performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
