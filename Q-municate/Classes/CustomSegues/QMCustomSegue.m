//
//  QMCustomSegue.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCustomSegue.h"
#import "AppDelegate.h"

@implementation QMCustomSegue

- (void)perform {
    
    AppDelegate *delegate =  (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = delegate.window;
    window.rootViewController = self.destinationViewController;
}

@end
