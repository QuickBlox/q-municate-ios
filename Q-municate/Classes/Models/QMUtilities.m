//
//  Utilities.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUtilities.h"


@implementation QMUtilities

+ (instancetype)shared {
    static id utilitiesInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utilitiesInstance = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showIncomingCallController:) name:kIncomingCallNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissIncomingCallController:) name:kCallWasStoppedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissIncomingCallController:) name:kCallWasRejectedNotification object:nil];
    });
    return utilitiesInstance;
}

- (id)init
{
    if (self= [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.incomingCallController = nil;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)createIndicatorView
{
	if (![[QMUtilities shared] getIndicatorViewIfExists]) {
		UIWindow *window = [[UIApplication sharedApplication].delegate window];

		UIView *backgroundView = [[UIView alloc] initWithFrame:[window bounds]];
		backgroundView.backgroundColor = [UIColor blackColor];
		backgroundView.alpha = 0.0f;
		backgroundView.tag = 1304;

		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		indicator.center = CGPointMake(backgroundView.frame.size.width/2, backgroundView.frame.size.height/2);
		[backgroundView addSubview:indicator];

		[indicator startAnimating];
		[window addSubview:backgroundView];
		[UIView animateWithDuration:0.2f
						 animations:^{
							 [backgroundView setAlpha:0.5f];
						 }
		];
	}
}

+ (void)removeIndicatorView
{
    UIView *indicatorView = [[QMUtilities shared] getIndicatorViewIfExists];
	if ([indicatorView superview]) {
		[UIView animateWithDuration:0.2f
						 animations:^{
							 [indicatorView setAlpha:0.0f];
						 }
						 completion:^(BOOL finished) {
							 [indicatorView removeFromSuperview];
						 }
		];
	}
}

- (UIView *)getIndicatorViewIfExists
{
	UIWindow *window = [[UIApplication sharedApplication].delegate window];
	UIView *indicatorView = [window viewWithTag:1304];
	if (indicatorView) {
		return indicatorView;
	}
	return nil;
}


+ (void)showIncomingCallController:(NSNotification *)notification
{
    if ([QMUtilities shared].incomingCallController == nil) {
        NSUInteger opponentID = [notification.userInfo[kId] intValue];
        NSUInteger type = [notification.userInfo[@"type"] intValue];
        
        [QMUtilities shared].incomingCallController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kIncomingCallIdentifier];
        [QMUtilities shared].incomingCallController.opponentID = opponentID;
        
        if (type == QBVideoChatConferenceTypeAudioAndVideo) {
            [QMUtilities shared].incomingCallController.isVideoCall = YES;
        }
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:[QMUtilities shared].incomingCallController animated:NO completion:nil];
    }
}

+ (void)dismissIncomingCallController:(NSNotification *)notification
{
    if ([QMUtilities shared].incomingCallController != nil) {
        [[[UIApplication sharedApplication].delegate window].rootViewController dismissViewControllerAnimated:NO completion:^{
            [QMUtilities shared].incomingCallController = nil;
        }];
    }
}


#pragma mark -

- (void)playSoundOfType:(QMSoundPlayType)soundType
{
    if (self.audioPlayer != nil) {
        return;
    }
    NSString *soundFile = nil;
    NSInteger numberOfLoops = 0;
    if (soundType == QMSoundPlayTypeIncommingCall) {
        soundFile = [[NSBundle mainBundle] pathForResource:@"ringtone" ofType:@"wav"];
        numberOfLoops = 30;
    } else if (soundType == QMSoundPlayTypeCallingNow) {
        soundFile = [[NSBundle mainBundle] pathForResource:@"calling" ofType:@"mp3"];
        numberOfLoops = 40;
    } else if (soundType == QMSoundPlayTypeUserIsBusy) {
        soundFile = [[NSBundle mainBundle] pathForResource:@"busy" ofType:@"mp3"];
    } else if (soundType == QMSoundPlayTypeEndOfCall) {
        soundFile = [[NSBundle mainBundle] pathForResource:@"end_of_call" ofType:@"mp3"];
    }
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:soundFile] error:nil];
    self.audioPlayer.numberOfLoops = numberOfLoops;
    
    [self.audioPlayer play];
}

- (void)stopPlaying
{
    if (self.audioPlayer != nil) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
}


#pragma mark -

- (NSString *)formattedTimeFromTimeInterval:(double_t)time
{
    NSString *formattedTime = nil;
    if (time <=9) {
        formattedTime = [NSString stringWithFormat:@"00:0%i",(int)time];
    } else if (time <=59) {
        formattedTime = [NSString stringWithFormat:@"00:%i", (int)time];
    } else if (time <= 359) {
        int minutes = time/60;
        int seconds = time - (minutes * 60);
        if (minutes<=9) {
            if (seconds <=9) {
                formattedTime = [NSString stringWithFormat:@"0%i:0%i", minutes, seconds];
            } else {
                formattedTime = [NSString stringWithFormat:@"0%i:%i", minutes, seconds];
            }
        } else {
            if (seconds <=9) {
                formattedTime = [NSString stringWithFormat:@"%i:0%i", minutes, seconds];
            } else {
                formattedTime = [NSString stringWithFormat:@"%i:%i", minutes, seconds];
            }
        }
    }
    return formattedTime;
}

@end
