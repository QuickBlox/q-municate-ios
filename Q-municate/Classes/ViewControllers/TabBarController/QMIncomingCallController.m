//
//  QMIncomingCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 08/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMIncomingCallController.h"
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
@synthesize isVideoCall;
@synthesize opponent;
@synthesize sessionID;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureUserAvatarCircledView];
    
    opponent = [[QMContactList shared] findFriendWithID:self.opponentID];
    if (opponent != nil) {
        self.userNameLabel.text = opponent.fullName;
    } else {
        self.userNameLabel.text = @"Unknown caller";
    }
    if (isVideoCall) {
        self.incomingCallLabel.text = @"Incomming video call";
        [self.acceptButton setImage:[ UIImage imageNamed:@"answer-video"] forState:UIControlStateNormal];
    } else {
        self.incomingCallLabel.text = @"Incomming call";
        [self.acceptButton setImage:[ UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
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

- (void)dealloc
{
    [[QMUtilities shared] stopPlaying];
}


#pragma mark - Actions

- (IBAction)acceptCall:(id)sender
{
    // stop playing music:
    [[QMUtilities shared] stopPlaying];
    
    [self performSegueWithIdentifier:kStartCallSegueIdentifier sender:nil];
}

- (IBAction)declineCall:(id)sender
{
    // stop playing sound
    [[QMUtilities shared] stopPlaying];
    
    [[QMChatService shared] initActiveStream];
    [[QMChatService shared] rejectCallFromUser:self.opponentID];
    [[QMChatService shared] releaseActiveStream];
    
    [[QMUtilities shared] playSoundOfType:QMSoundPlayTypeEndOfCall];
    
    [self performSelector:@selector(dismissIncommingCallController) withObject:self afterDelay:1.0f];
}

- (void)dismissIncommingCallController
{
    [[QMUtilities shared] stopPlaying];
    [QMUtilities dismissIncomingCallController:nil];
}

@end
