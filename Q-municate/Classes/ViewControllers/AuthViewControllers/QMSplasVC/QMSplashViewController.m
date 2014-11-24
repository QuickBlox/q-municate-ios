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
@property (weak, nonatomic) IBOutlet UIButton *reconnectBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation QMSplashViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.splashLogoView setImage:[UIImage imageNamed:IS_HEIGHT_GTE_568 ? @"splash" : @"splash-960"]];
    
    if (QM.profile.userData) {
        
        [self performSegueWithIdentifier:kTabBarSegueIdnetifier
                                  sender:nil];
    }
    else {
        
        [self performSegueWithIdentifier:kWelcomeScreenSegueIdentifier
                                  sender:nil];
    }
}

- (IBAction)pressReconnectBtn:(id)sender {
}

@end
