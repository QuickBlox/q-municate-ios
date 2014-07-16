//
//  Utilities.m
//  Q-municate
//
//  Created by Igor Alefirenko on 19/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMIncomingCallService.h"
#import "QMChatReceiver.h"

@interface QMIncomingCallService ()

@property (strong, nonatomic) QMIncomingCallController *incomingCallController;
@property (strong, nonatomic) UIView *activityView;

@end

@implementation QMIncomingCallService

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

- (void)showIncomingCallControllerWithOpponentID:(NSUInteger)opponentID conferenceType:(QBVideoChatConferenceType)conferenceType
{
    if (!self.incomingCallController) {
        
        self.incomingCallController =
        [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:kIncomingCallIdentifier];
        
        self.incomingCallController.opponentID = opponentID;
        
        self.incomingCallController.callType = conferenceType;
        
        [self.window.rootViewController presentViewController:self.incomingCallController
                                                     animated:NO completion:nil];
    }
}

- (UIWindow *)window {
    return [[UIApplication sharedApplication].delegate window];
}

- (void)dismissIncomingCallController {
    
    if (self.incomingCallController != nil) {
        [self.window.rootViewController dismissViewControllerAnimated:NO completion:^{
            self.incomingCallController = nil;
        }];
    }
}

- (void)hideIncomingCallControllerWithStatus:(NSString *)status
{
    [self performSelector:@selector(dismissIncomingCallController) withObject:self afterDelay:2.0f];
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
