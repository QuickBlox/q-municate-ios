//
//  Utilities.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUtilities.h"

@interface QMUtilities ()

@property (strong, nonatomic) UIView *activityView;

@end

@implementation QMUtilities

+ (instancetype)shared {
    static id utilitiesInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utilitiesInstance = [[self alloc] init];
    });
    return utilitiesInstance;
}

- (id)init
{
    if (self= [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showIncomingCallController:) name:kIncomingCallNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissIncomingCallController:) name:kCallWasStoppedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissIncomingCallController:) name:kCallWasRejectedNotification object:nil];
        
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setLocale:[NSLocale currentLocale]];
        [self.dateFormatter setDateFormat:@"HH':'mm"];
        [self.dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
        self.incomingCallController = nil;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)activityView {
    
    if (!_activityView) {
        
        UIWindow *window = [[UIApplication sharedApplication].delegate window];
        
        _activityView = [[UIView alloc] initWithFrame:window.bounds];
		_activityView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
		indicator.center = CGPointMake(_activityView.frame.size.width/2,
                                       _activityView.frame.size.height/2);
        
		[_activityView addSubview:indicator];
        
		[indicator startAnimating];
		[window addSubview:_activityView];
    }
    
    return _activityView;
}

- (void)showActivity {
    
    if (!self.activityView.superview) {
        [self.window addSubview:self.activityView];
    }
}

- (void)hideActivity {
    
    if (self.activityView.superview) {
        [self.activityView removeFromSuperview];
    }
}

+ (void)showActivityView {
    
    [QMUtilities.shared showActivity];
}

+ (void)hideActivityView {
    
    [QMUtilities.shared hideActivity];
}

- (void)showIncomingCallController:(NSNotification *)notification
{
    if ([QMUtilities shared].incomingCallController == nil) {
        
        NSUInteger opponentID = [notification.userInfo[kId] intValue];
        NSUInteger type = [notification.userInfo[@"type"] intValue];
        
        [QMUtilities shared].incomingCallController =
        [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kIncomingCallIdentifier];
        
        [QMUtilities shared].incomingCallController.opponentID = opponentID;
        
        [QMUtilities shared].incomingCallController.callType = type;
        
        [self.window.rootViewController presentViewController:[QMUtilities shared].incomingCallController
                                                     animated:NO completion:nil];
    }
}

- (UIWindow *)window {
    return [[UIApplication sharedApplication].delegate window];
}

- (void)dismissIncomingCallController {
    
    if ([QMUtilities shared].incomingCallController != nil) {
        [[[UIApplication sharedApplication].delegate window].rootViewController dismissViewControllerAnimated:NO completion:^{
            [QMUtilities shared].incomingCallController = nil;
        }];
    }
}

- (void)dismissIncomingCallController:(NSNotification *)notification {
    
    [self dismissIncomingCallController];
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
