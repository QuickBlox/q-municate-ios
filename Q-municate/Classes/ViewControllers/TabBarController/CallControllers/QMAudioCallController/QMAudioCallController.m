//
//  QMAudioCallController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAudioCallController.h"
#import "QMApi.h"
#import "QMAVCallManager.h"

@implementation QMAudioCallController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnMic.enabled = NO;
}

#pragma mark - Overridden methods

- (void)session:(QBRTCSession *)session connectedToUser:(NSNumber *)userID{
    [super session:session connectedToUser:userID];
    
    if( [[QMApi instance].avCallManager isOpponentCaller] ){
        // Me is not a caller
        
        [self updateButtonsState];
    }
}

@end
