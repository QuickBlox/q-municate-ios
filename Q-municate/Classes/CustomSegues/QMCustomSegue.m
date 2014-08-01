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
    window.rootViewController = self.destinationViewController;
}

@end
