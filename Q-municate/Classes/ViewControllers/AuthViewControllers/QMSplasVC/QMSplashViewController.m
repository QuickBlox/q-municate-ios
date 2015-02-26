//
//  QMSplashViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSplashViewController.h"
#import "QMServicesManager.h"

@interface QMSplashViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *splashLogoView;

@end

@implementation QMSplashViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    if (QM.profile.userData) {
        
        [self performSegueWithIdentifier:kTabBarSegueIdnetifier
                                  sender:nil];
    }
    else {
        
        [self performSegueWithIdentifier:kWelcomeScreenSegueIdentifier
                                  sender:nil];
    }
}

@end
