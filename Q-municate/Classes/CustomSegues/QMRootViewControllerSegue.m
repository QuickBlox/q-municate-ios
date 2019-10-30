//
//  QMRootViewControllerSegue.m
//  Q-municate
//
//  Created by Injoit on 13/02/2014.
//  Copyright © 2014 QuickBlox. All rights reserved.
//

#import "QMRootViewControllerSegue.h"
#import "QMAppDelegate.h"

@implementation QMRootViewControllerSegue

- (void)perform {
    
    QMAppDelegate *delegate = (QMAppDelegate *)UIApplication.sharedApplication.delegate;
    delegate.window.rootViewController = self.destinationViewController;
}

@end
