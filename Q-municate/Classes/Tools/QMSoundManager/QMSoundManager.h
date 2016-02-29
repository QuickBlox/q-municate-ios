//
//  QMSoundManager.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 01.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#define QMSysPlayer [QMSoundManager instance]

#import <Foundation/Foundation.h>

@interface QMSoundManager : NSObject

@property (assign, nonatomic) BOOL on;

+ (instancetype)instance;

/**
 *  Plays a system sound object corresponding to an audio file with the given filename and extension.
 *  The system sound player will lazily initialize and load the file before playing it, and then cache its corresponding `SystemSoundID`.
 *  If this file has previously been played, it will be loaded from cache and played immediately.
 *
 *  @param filename      A string containing the base name of the audio file to play.
 *  @param fileExtension A string containing the extension of the audio file to play.
 *  This parameter must be one of `caf`, `aif`, `aiff`, or `wav`
 *
 *  @warning If the system sound object cannot be created, this method does nothing.
 */
- (void)playSoundWithName:(NSString *)filename
                extension:(NSString *)extension;

/**
 *  On some iOS devices, you can call this method to invoke vibration.
 *  On other iOS devices this functionaly is not available, and calling this method does nothing.
 */
- (void)playVibrateSound;

/**
 *  Stops playing all sounds immediately.
 *
 *  @warning Any completion blocks attached to any currently playing sound will *not* be executed.
 *  Also, calling this method will purge all `SystemSoundID` objects from cache, regardless of whether or not they were currently playing.
 */
- (void)stopAllSounds;

/*Sounds*/
+ (void)playCallingSound;
+ (void)playBusySound;
+ (void)playEndOfCallSound;
+ (void)playRingtoneSound;
+ (void)playMessageReceivedSound;
+ (void)playMessageSentSound;
@end
