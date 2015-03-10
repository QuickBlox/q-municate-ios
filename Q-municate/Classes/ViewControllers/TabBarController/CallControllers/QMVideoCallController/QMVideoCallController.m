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


#pragma mark - Overridden methods

-(void)startCall
{
    [[QMApi instance] callToUser:@(self.opponent.ID) conferenceType:QBConferenceTypeVideo];
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

- (void)sessionDidClose:(QBRTCSession *)session{
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
