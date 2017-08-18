//
//  QMAudioPlayer.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 1/26/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>


@protocol QMAudioPlayerDelegate;

typedef NS_ENUM(NSUInteger, QMAudioPlayerState) {
    QMAudioPlayerStateStopped = 0,
    QMAudioPlayerStatePaused  = 1,
    QMAudioPlayerStatePlaying = 2
};

@interface QMAudioPlayerStatus : NSObject

@property (nonatomic, strong) NSString *mediaID;
@property (nonatomic, assign) QMAudioPlayerState playerState;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval duration;

@end


@interface QMAudioPlayer : NSObject

@property (nonatomic, strong, readonly) QMAudioPlayerStatus *status;

@property (nonatomic, weak) id <QMAudioPlayerDelegate> playerDelegate;

+ (instancetype)audioPlayer;

- (void)activateAttachment:(QBChatAttachment *)attachment;
- (void)playMediaAtURL:(NSURL *)url withID:(NSString *)itemID;

- (void)pause;
- (void)stop;

@end

@protocol QMAudioPlayerDelegate <NSObject>

- (void)player:(QMAudioPlayer *)player
didUpdateStatus:(QMAudioPlayerStatus *)status;

@end
