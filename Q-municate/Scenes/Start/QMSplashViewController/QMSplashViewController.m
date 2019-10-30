//
//  QMSplashViewController.m
//  Q-municate
//
//  Created by Injoit on 3/24/14.
//  Copyright © 2014 QuickBlox. All rights reserved.
//

#import "QMSplashViewController.h"
#import "QMCore.h"

@implementation QMSplashViewController

- (void)dealloc {
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self performSegueWithIdentifier:QMCore.instance.currentProfile.userData != nil ? kQMSceneSegueMain : kQMSceneSegueAuth
                              sender:nil];
}

@end
