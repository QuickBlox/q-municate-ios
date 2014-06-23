//
//  QMIncommingCallSegue.m
//  Q-municate
//
//  Created by Igor Alefirenko on 09/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMIncommingCallSegue.h"
#import "QMIncomingCallController.h"
#import "QMVideoCallController.h"

@implementation QMIncommingCallSegue

- (void)perform
{
    QMIncomingCallController *incommingCallController = (QMIncomingCallController *)self.sourceViewController;
    QMVideoCallController *callsController = (QMVideoCallController *)self.destinationViewController;
    
    callsController.callType = incommingCallController.callType;
    callsController.opponent = incommingCallController.opponent;
    callsController.isOpponentCall = YES;
    
    [incommingCallController addChildViewController:callsController];
    [incommingCallController.view addSubview:callsController.view];
}

@end
