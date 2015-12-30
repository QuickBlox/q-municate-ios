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
#import "QMAVCallManager.h"
#import "QMUsersUtils.h"

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
    
    if( opponent ){
        self.userNameLabel.text = opponent.fullName;
    }
    else{
        self.userNameLabel.text = @"Unknown caller";
    }
 
    if (self.callType == QBRTCConferenceTypeVideo) {
        [self.incomingCallView setHidden:YES];
        self.incomingCallLabel.text = NSLocalizedString(@"QM_STR_INCOMING_VIDEO_CALL", nil);
    } else if (self.callType == QBRTCConferenceTypeAudio) {
        [self.incomingVideoCallView setHidden:YES];
        self.incomingCallLabel.text = NSLocalizedString(@"QM_STR_INCOMING_CALL", nil);
    }

    NSURL *url = [QMUsersUtils userAvatarURL:opponent];
    UIImage *placeholder = [UIImage imageNamed:@"upic_call"];
    
    [self.userAvatarView setImageWithURL:url
                             placeholder:placeholder
                                 options:SDWebImageLowPriority
                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                          completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
     }];

}

#pragma mark - Actions

- (void)confirmCall {
    [[QMApi instance] acceptCall];
}

- (IBAction)acceptCall:(id)sender {
    __weak __typeof(self) weakSelf = self;
    [[[QMApi instance] avCallManager] checkPermissionsWithConferenceType:self.callType completion:^(BOOL canContinue) {
        if( canContinue ) {
            [weakSelf confirmCall];
			[[QMSoundManager instance] stopAllSounds];
            if (weakSelf.callType == QBRTCConferenceTypeVideo) {
                [weakSelf performSegueWithIdentifier:kGoToDuringVideoCallSegueIdentifier sender:weakSelf];
            } else {
                [weakSelf performSegueWithIdentifier:kGoToDuringAudioCallSegueIdentifier sender:nil];
            }
        }
    }];
}

- (IBAction)acceptCallWithVideo:(id)sender {
    __weak __typeof(self) weakSelf = self;
    [[QMSoundManager instance] stopAllSounds];
    [[[QMApi instance] avCallManager] checkPermissionsWithConferenceType:self.callType completion:^(BOOL canContinue) {
        if( canContinue ) {
            [weakSelf confirmCall];
            [[QMSoundManager instance] stopAllSounds];
            [weakSelf performSegueWithIdentifier:kGoToDuringVideoCallSegueIdentifier sender:nil];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // sender is not nil when accepting video call with denying my(local) video track
    if( [segue.identifier isEqualToString:kGoToDuringVideoCallSegueIdentifier] && sender != nil ){
        QMVideoP2PController *vc = segue.destinationViewController;
        vc.disableSendingLocalVideoTrack = YES;
    }
}

- (IBAction)declineCall:(id)sender {
    
    [[QMSoundManager instance] stopAllSounds];
    [[QMApi instance] rejectCall];
    [QMSoundManager playEndOfCallSound];
    self.incomingCallLabel.text = NSLocalizedString(@"QM_STR_CALL_WAS_CANCELLED", nil);
}

- (void)cleanUp {
    [[QMSoundManager instance] stopAllSounds];
    [QBRTCClient.instance removeDelegate:self];
}

- (void)sessionDidClose:(QBRTCSession *)session {
    if( self.session == session ) {
        [self cleanUp];
    }
}

- (void)dealloc {
    [self cleanUp];
}
@end
