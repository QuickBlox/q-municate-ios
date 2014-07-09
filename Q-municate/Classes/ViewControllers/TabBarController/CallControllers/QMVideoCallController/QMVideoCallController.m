//
//  QMVideoCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//
#import "AppDelegate.h"
#import "QMVideoCallController.h"
#import "QMUtilities.h"
#import "QMImageView.h"
#import "QMSoundManager.h"

@interface QMVideoCallController ()

// Video calls UI
@property (weak, nonatomic) IBOutlet UIImageView *myView;

@end

@implementation QMVideoCallController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Controls

- (IBAction)leftControlTapped:(id)sender
{
    // Not Implemented
}

- (IBAction)rightControlTapped:(id)sender
{
    // Not Implemented
}

- (void)stopCallTapped:(id)sender
{
    [self.contentView show];
    [super stopCallTapped:sender];
}


#pragma mark - Overriden methods

-(void)startCall
{
//    [[QMChatService shared] callUser:self.opponent.ID opponentView:self.opponentsView callType:QBVideoChatConferenceTypeAudioAndVideo];
    [QMSoundManager playCallingSound];
}

- (void)callAcceptedByUser
{
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    [self.contentView updateViewWithStatus:kCallConnectingStatus];
}

- (void)callStartedWithUser
{
    [self.contentView hide];
}

- (void)callStoppedByOpponentForReason:(NSNotification *)notification
{
    [self.contentView show];
    [super callStoppedByOpponentForReason:notification];
}

@end
