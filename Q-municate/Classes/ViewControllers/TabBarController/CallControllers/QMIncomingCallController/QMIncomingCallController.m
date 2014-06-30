//
//  QMIncomingCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 08/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMIncomingCallController.h"
#import "UIImageView+ImageWithBlobID.h"
#import "QMChatService.h"
#import "QMContactList.h"
#import "QMUtilities.h"

@interface QMIncomingCallController ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *incomingCallLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatarView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

@property (copy, nonatomic) NSString *sessionID;

@end

@implementation QMIncomingCallController

@synthesize opponent;
@synthesize sessionID;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureUserAvatarCircledView];
    
    opponent = [[QMContactList shared] findFriendWithID:self.opponentID];
    
    self.userNameLabel.text = opponent ? opponent.fullName : @"Unknown caller";
 
    
    if (self.callType == QMVideoChatTypeVideo) {
        self.incomingCallLabel.text = @"Incoming video call";
        [self.acceptButton setImage:[ UIImage imageNamed:@"answer-video"] forState:UIControlStateNormal];
    } else if (self.callType == QMVideoChatTypeAudio) {
        self.incomingCallLabel.text = @"Incoming call";
        [self.acceptButton setImage:[ UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
    }
    
    if (opponent.website != nil) {
        #warning image
//        [self.userAvatarView setImageURL:[NSURL URLWithString:opponent.website]];
    } else {
        [self.userAvatarView loadImageWithBlobID:opponent.blobID];
    }
    
    [[QMUtilities shared] playSoundOfType:QMSoundPlayTypeIncommingCall];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureUserAvatarCircledView
{
    self.userAvatarView.layer.cornerRadius = self.userAvatarView.frame.size.width / 2;
    self.userAvatarView.layer.borderWidth = 2.0f;
    self.userAvatarView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userAvatarView.layer.masksToBounds = YES;
}

- (void)dealloc {
    [[QMUtilities shared] stopPlaying];
}

#pragma mark - Actions

- (IBAction)acceptCall:(id)sender {
    
    [[QMUtilities shared] stopPlaying];
    [self performSegueWithIdentifier:kStartCallSegueIdentifier sender:nil];
}

- (IBAction)declineCall:(id)sender {
    
    [[QMUtilities shared] stopPlaying];
    [[QMChatService shared] rejectCallFromUser:opponent ? self.opponent.ID : self.opponentID  opponentView:nil];
    [[QMUtilities shared] playSoundOfType:QMSoundPlayTypeEndOfCall];
    
    [self performSelector:@selector(dismissIncomingCallController) withObject:self afterDelay:1.0f];
}

- (void)dismissIncomingCallController {
    
    [QMUtilities.shared stopPlaying];
    [QMUtilities.shared dismissIncomingCallController];
}

@end
