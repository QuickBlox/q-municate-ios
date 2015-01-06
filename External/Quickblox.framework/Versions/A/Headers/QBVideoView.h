//
//  QBVideoView.h
//  Quickblox
//
//  Created by Andrey Moskvin on 3/20/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTCVideoTrack;
@interface QBVideoView : UIView

@property (nonatomic, assign) UIInterfaceOrientation remoteVideoOrientation;
@property (nonatomic, strong) NSString* remotePlatform;

- (void)renderVideoTrackInterface:(RTCVideoTrack *)track;

- (void)configure;

- (void)applyInterfaceRotation:(UIInterfaceOrientation)orientation;

@end
