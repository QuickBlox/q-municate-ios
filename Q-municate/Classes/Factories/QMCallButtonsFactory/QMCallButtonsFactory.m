//
//  QMCallButtonsFactory.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/10/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMCallButtonsFactory.h"

static const CGFloat kQMButtonSizeBig = 72.0f;
static const CGFloat kQMButtonSizeSmall = 44.0f;

static const CGFloat kQMVideoCallDeclineButtonWidth = 147.0f;

@implementation QMCallButtonsFactory

+ (UIButton *)acceptButton {
    
    UIButton *acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        kQMButtonSizeBig,
                                                                        kQMButtonSizeBig)];
    
    [acceptButton setImage:[UIImage imageNamed:@"qm-ic-accept"]
                  forState:UIControlStateNormal];
    
    return acceptButton;
}

+ (UIButton *)acceptVideoCallButton {
    
    UIButton *acceptVideoCallButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                                 0,
                                                                                 kQMButtonSizeBig,
                                                                                 kQMButtonSizeBig)];
    
    [acceptVideoCallButton setImage:[UIImage imageNamed:@"qm-ic-accept-video"]
                           forState:UIControlStateNormal];
    
    return acceptVideoCallButton;
}

+ (UIButton *)declineButton {
    
    UIButton *declineButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         kQMButtonSizeBig,
                                                                         kQMButtonSizeBig)];
    
    [declineButton setImage:[UIImage imageNamed:@"qm-ic-decline"]
                   forState:UIControlStateNormal];
    
    return declineButton;
}

+ (UIButton *)declineVideoCallButton {
    
    UIButton *declineVideoCallButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                                  0,
                                                                                  kQMVideoCallDeclineButtonWidth,
                                                                                  kQMButtonSizeSmall)];
    
    [declineVideoCallButton setImage:[UIImage imageNamed:@"qm-ic-decline-video"]
                            forState:UIControlStateNormal];
    
    
    return declineVideoCallButton;
}

+ (UIButton *)muteAudioCallButton {
    
    UIButton *muteAudioCallButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               kQMButtonSizeBig,
                                                                               kQMButtonSizeBig)];
    
    [muteAudioCallButton setImage:[UIImage imageNamed:@"qm-ic-mute"]
                         forState:UIControlStateNormal];
    
    [muteAudioCallButton setImage:[UIImage imageNamed:@"qm-ic-mute-selected"]
                         forState:UIControlStateSelected];
    
    return muteAudioCallButton;
}

+ (UIButton *)muteVideoCallButton {
    
    UIButton *muteVideoCallButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               kQMButtonSizeSmall,
                                                                               kQMButtonSizeSmall)];
    
    [muteVideoCallButton setImage:[UIImage imageNamed:@"qm-ic-mute"]
                         forState:UIControlStateNormal];
    
    [muteVideoCallButton setImage:[UIImage imageNamed:@"qm-ic-mute-selected"]
                         forState:UIControlStateSelected];
    
    return muteVideoCallButton;
}

+ (UIButton *)speakerButton {
    
    UIButton *speakerButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         kQMButtonSizeBig,
                                                                         kQMButtonSizeBig)];
    
    [speakerButton setImage:[UIImage imageNamed:@"qm-ic-speaker"]
                   forState:UIControlStateNormal];
    
    [speakerButton setImage:[UIImage imageNamed:@"qm-ic-speaker-selected"]
                   forState:UIControlStateSelected];
    
    return speakerButton;
}

+ (UIButton *)cameraButton {
    
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        kQMButtonSizeSmall,
                                                                        kQMButtonSizeSmall)];
    
    [cameraButton setImage:[UIImage imageNamed:@"qm-ic-camera"]
                  forState:UIControlStateNormal];
    
    [cameraButton setImage:[UIImage imageNamed:@"qm-ic-camera-selected"]
                  forState:UIControlStateSelected];
    
    return cameraButton;
}

+ (UIButton *)cameraRotationButton {
    
    UIButton *cameraRotationButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                kQMButtonSizeSmall,
                                                                                kQMButtonSizeSmall)];
    
    [cameraRotationButton setImage:[UIImage imageNamed:@"qm-ic-camera-rotation"]
                          forState:UIControlStateNormal];
    
    [cameraRotationButton setImage:[UIImage imageNamed:@"qm-ic-camera-rotation-selected"]
                          forState:UIControlStateSelected];
    
    return cameraRotationButton;
}

+ (UIButton *)minimizeButton {
    UIButton *minimizeButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                                0,
                                                                                kQMButtonSizeSmall,
                                                                                kQMButtonSizeSmall)];
    [minimizeButton setTitle:@"M" forState:UIControlStateNormal];
    return minimizeButton;
}

@end
