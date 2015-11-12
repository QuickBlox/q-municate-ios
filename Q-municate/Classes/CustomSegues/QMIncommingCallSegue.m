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
    QMBaseCallsController *callsController = (QMVideoCallController *)self.destinationViewController;
    [callsController setOpponent:incommingCallController.opponent];
    
    incommingCallController.navigationController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
//    [incommingCallController.navigationController transitionFromViewController:incommingCallController toViewController:callsController duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:nil completion:nil];
    [incommingCallController.navigationController setViewControllers:@[callsController] animated:YES];
}

@end
