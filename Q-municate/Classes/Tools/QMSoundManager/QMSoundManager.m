//
//  QMSoundManager.m
//  Qmunicate
//
//  Created by Andrey Ivanov on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSoundManager.h"

NSString * const kSystemSoundTypeCAF = @"caf";
NSString * const kSystemSoundTypeAIF = @"aif";
NSString * const kSystemSoundTypeAIFF = @"aiff";
NSString * const kystemSoundTypeWAV = @"wav";

static NSString * const kQMSoundManagerSettingKey = @"kQMSoundManagerSettingKey";

@interface QMSoundManager()

@property (strong, nonatomic) NSMutableDictionary *sounds;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation QMSoundManager

- (void)dealloc {
    
    NSNotificationCenter *notifcationCenter =
    [NSNotificationCenter defaultCenter];
    [notifcationCenter removeObserver:self];
}

+ (instancetype)instance {
    
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        self.on = YES;
        
        _sounds = [NSMutableDictionary dictionary];
        
        NSNotificationCenter *notifcationCenter =
        [NSNotificationCenter defaultCenter];
        
        [notifcationCenter addObserver:self
                              selector:@selector(didReceiveMemoryWarningNotification:)
                                  name:UIApplicationDidReceiveMemoryWarningNotification
                                object:nil];
    }
    
    return self;
}

- (void)setOn:(BOOL)on {
    
    _on = on;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:on forKey:kQMSoundManagerSettingKey];
    [userDefaults synchronize];
    
    if (!on) {
        
        [self stopAllSounds];
    }
}

#pragma mark - Playing sounds

- (void)playSoundWithName:(NSString *)filename extension:(NSString *)extension {
    
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    
    if (self.sounds[filename]) {
        
        self.audioPlayer = self.sounds[filename];
    }
    else {
        
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        
        if (error) {
            
            NSLog(@"%@",[error localizedDescription]);
        }
        else {
            
            self.sounds[filename] = self.audioPlayer;
        }
    }
    
    [self.audioPlayer play];
}

- (void)playVibrateSound {
    
    if (self.on) {
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)stopAllSounds {
    
    if (self.audioPlayer) {
        
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    
    [self.sounds removeAllObjects];
}

- (void)stopSoundWithFilename:(NSString *)filename {
    
    [self.sounds removeObjectForKey:filename];
}

#pragma mark - Did Receive Memory Warning Notification

- (void)didReceiveMemoryWarningNotification:(NSNotification *)notification {
    
    [self.sounds removeAllObjects];
}

#pragma mark - Default sounds

NSString *const kQMReceivedSoundName = @"received";
NSString *const kQMSendSoundName = @"sent";
NSString *const kQMCallingSoundName = @"calling";
NSString *const kQMBusySoundName = @"busy";
NSString *const kQMEndOfCallSoundName = @"end_of_call";
NSString *const kQMRingtoneSoundName = @"ringtone";

+ (void)playMessageReceivedSound {
    
    [QMSysPlayer playSoundWithName:kQMReceivedSoundName
                         extension:kystemSoundTypeWAV];
}

+ (void)playMessageSentSound {
    
    [QMSysPlayer playSoundWithName:kQMSendSoundName
                         extension:kystemSoundTypeWAV];
}

+ (void)playCallingSound {
    
    [QMSysPlayer playSoundWithName:kQMCallingSoundName
                         extension:kystemSoundTypeWAV];
}

+ (void)playBusySound {
    
    [QMSysPlayer playSoundWithName:kQMBusySoundName
                         extension:kystemSoundTypeWAV];
}

+ (void)playEndOfCallSound {
    
    [QMSysPlayer playSoundWithName:kQMEndOfCallSoundName
                         extension:kystemSoundTypeWAV];
}

+ (void)playRingtoneSound {
    
    [QMSysPlayer playSoundWithName:kQMRingtoneSoundName
                         extension:kystemSoundTypeWAV];
    [QMSysPlayer playVibrateSound];
}

@end
