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

@class QMChatMediaItem;
@protocol QMAudioPlayerDelegate;

typedef NS_ENUM(NSUInteger, QMPlayerStatus) {
    QMPlayerStatusStopped = 0,
    QMPlayerStatusPaused  = 1,
    QMPlayerStatusPlaying = 2
};

@interface QMAudioPlayerStatus : NSObject

@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) NSString *mediaID;

@property (nonatomic, assign) QMPlayerStatus playerStatus;

@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) NSTimeInterval duration;

@end


@interface QMAudioPlayer : NSObject

@property (nonatomic, copy) void (^onStatusChanged)(NSString *, BOOL);
@property (nonatomic, strong, readonly) QMAudioPlayerStatus *status;

@property (nonatomic, weak) id <QMAudioPlayerDelegate> playerDelegate;

+ (instancetype)audioPlayer;

- (void)activateAttachment:(QBChatAttachment *)attachment;
- (void)activateMediaAtURL:(NSURL *)url withID:(NSString *)itemID;

- (void)pause;
- (void)stop;

@end

@protocol QMAudioPlayerDelegate <NSObject>

- (void)player:(QMAudioPlayer *)player didChangePlayingStatus:(QMAudioPlayerStatus *)status;

@end
