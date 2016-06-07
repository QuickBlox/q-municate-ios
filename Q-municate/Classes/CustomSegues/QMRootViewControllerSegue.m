//
//  QMRootViewControllerSegue.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMRootViewControllerSegue.h"
#import "QMAppDelegate.h"

@implementation QMRootViewControllerSegue

- (void)perform {
    
    QMAppDelegate *delegate = (QMAppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.window.rootViewController = self.destinationViewController;
}

@end
