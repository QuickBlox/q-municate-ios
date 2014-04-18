//
//  QMLogInController.h
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMWelcomeScreenViewController;

@interface QMLogInController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic) QMWelcomeScreenViewController *root;

@end
