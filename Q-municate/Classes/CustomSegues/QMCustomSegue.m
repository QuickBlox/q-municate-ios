//
//  QMCustomSegue.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCustomSegue.h"


@implementation QMCustomSegue

- (void)perform {
    
    UIWindow *window = (UIWindow *)[[UIApplication sharedApplication].windows firstObject];
    UINavigationController *navController = (UINavigationController *)window.rootViewController;
    navController.viewControllers = @[self.destinationViewController];
}

@end
