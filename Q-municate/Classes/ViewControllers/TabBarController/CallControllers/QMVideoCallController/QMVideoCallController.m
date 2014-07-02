//
//  QMVideoCallController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//
#import "AppDelegate.h"
#import "QMVideoCallController.h"
#import "QMChatService.h"
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


#pragma mark -

- (void)callAcceptedByUser
{
    // stop playing sound:
    [[QMSoundManager shared] stopAllSounds];
    [self.contentView startTimer];
}

- (void)callStartedWithUser
{
    [self.contentView setHidden:YES];
}

@end
