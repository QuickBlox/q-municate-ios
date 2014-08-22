//
//  QMVideoCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMVideoCallController.h"
#import "QMIncomingCallHandler.h"
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
    [[QMApi instance] callUser:self.opponent.ID opponentView:self.opponentsView conferenceType:QBVideoChatConferenceTypeAudioAndVideo];
    [QMSoundManager playCallingSound];
}

- (void)confirmCall
{
    [super confirmCall];
    [self callStartedWithUser];
}

- (void)callAcceptedByUser
{
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    [self callStartedWithUser];
}

- (void)callStartedWithUser
{
    [self.contentView hide];
}

- (void)callStoppedByOpponentForReason:(NSString *)reason
{
    [self.contentView show];
    self.opponentsView.hidden = YES;
    [super callStoppedByOpponentForReason:reason];
}

@end
