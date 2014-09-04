//
//  QMAlertsFactory.m
//  Q-municate
//
//  Created by Andrey Ivanov on 05.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAlertsFactory.h"
#import "REAlertView.h"

@implementation QMAlertsFactory

+ (void)comingSoonAlert {
    
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        alertView.title = NSLocalizedString(@"QM_STR_COMING_SOON", nil);
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_OK", nil) andActionBlock:nil];
    }];
}

@end
