//
//  QMIncomingCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 08/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMIncomingCallController.h"
#import "QMApi.h"
#import "QMImageView.h"
#import "QMSoundManager.h"
#import "QMVideoP2PController.h"

@interface QMIncomingCallController ()<QBRTCClientDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomingCallLabel;
@property (weak, nonatomic) IBOutlet QMImageView *userAvatarView;
/// buttons for audio
@property (weak, nonatomic) IBOutlet UIView *incomingCallView;
/// buttons for video
@property (weak, nonatomic) IBOutlet UIView *incomingVideoCallView;

@end

@implementation QMIncomingCallController

@synthesize opponent;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userAvatarView.imageViewType = QMImageViewTypeCircle;
    
    [QBRTCClient.instance addDelegate:self];
    
    opponent = [[QMApi instance] userWithID:self.opponentID];
    
    self.userNameLabel.text = opponent ? opponent.fullName : @"Unknown caller";
 
    if (self.callType == QBConferenceTypeVideo) {
        [self.incomingCallView setHidden:YES];
        self.incomingCallLabel.text = NSLocalizedString(@"QM_STR_INCOMING_VIDEO_CALL", nil);
    } else if (self.callType == QBConferenceTypeAudio) {
        [self.incomingVideoCallView setHidden:YES];
        self.incomingCallLabel.text = NSLocalizedString(@"QM_STR_INCOMING_CALL", nil);
    }

    NSURL *url = [NSURL URLWithString:opponent.website];
    UIImage *placeholder = [UIImage imageNamed:@"upic_call"];
    
    [self.userAvatarView setImageWithURL:url
                             placeholder:placeholder
                                 options:SDWebImageLowPriority
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                          completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
     }];

    [QMSoundManager playRingtoneSound];
}

#pragma mark - Actions

- (IBAction)acceptCall:(id)sender {
    [[QMSoundManager shared] stopAllSounds];
    if (self.callType == QBConferenceTypeVideo) {
        [self performSegueWithIdentifier:kGoToDuringVideoCallSegueIdentifier sender:self];
    } else {
        [self performSegueWithIdentifier:kGoToDuringAudioCallSegueIdentifier sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // sender is not nil when accepting video call with denying my(local) video track
    if( [segue.identifier isEqualToString:kGoToDuringVideoCallSegueIdentifier] && sender != nil ){
        QMVideoP2PController *vc = segue.destinationViewController;
        vc.disableSendingLocalVideoTrack = YES;
    }
}

- (IBAction)acceptCallWithVideo:(id)sender {
    [[QMSoundManager shared] stopAllSounds];
    [self performSegueWithIdentifier:kGoToDuringVideoCallSegueIdentifier sender:nil];
}

- (IBAction)declineCall:(id)sender {
    
    [[QMSoundManager shared] stopAllSounds];
    [[QMApi instance] rejectCall];
    [QMSoundManager playEndOfCallSound];
    self.incomingCallLabel.text = NSLocalizedString(@"QM_STR_CALL_WAS_CANCELLED", nil);
}

- (void)cleanUp {
    [[QMSoundManager shared] stopAllSounds];
    [QBRTCClient.instance removeDelegate:self];
}

- (void)sessionWillClose:(QBRTCSession *)session {
    
    [self cleanUp];
}

- (void)dealloc {
    [self cleanUp];
}
@end
