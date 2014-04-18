//
//  SplashControllerViewController.h
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMSplashViewController;

@interface QMWelcomeScreenViewController : UIViewController

@property (strong, nonatomic) UIView *lastView;
@property (strong, nonatomic) UINavigationController *lastController;
@property (strong, nonatomic) QMSplashViewController *root;

- (void)signUpToQuickblox;
- (void)logInToQuickblox;

@end
