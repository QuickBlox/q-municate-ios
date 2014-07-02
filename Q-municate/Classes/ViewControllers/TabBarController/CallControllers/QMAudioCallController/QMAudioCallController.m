//
//  QMAudioCallController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 01/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAudioCallController.h"

@interface QMAudioCallController ()

@end

@implementation QMAudioCallController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Overriden actions

- (IBAction)leftControlTapped:(id)sender
{
    //
}

- (IBAction)rightControlTapped:(id)sender
{
    //
}

- (void)stopCallTapped:(id)sender
{
    [[QMChatService shared] callUser:self.opponent.ID opponentView:self.opponentsView callType:self.callType];
    [QMSoundManager playCallingSound];
    //
}

@end
