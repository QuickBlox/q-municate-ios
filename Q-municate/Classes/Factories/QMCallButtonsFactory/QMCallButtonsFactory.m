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
    
    static UIButton *acceptButton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  kQMButtonSizeBig,
                                                                  kQMButtonSizeBig)];
        
        [acceptButton setImage:[UIImage imageNamed:@"qm-ic-accept"]
                      forState:UIControlStateNormal];
    });
    
    return acceptButton;
}

+ (UIButton *)acceptVideoCallButton {
    
    static UIButton *acceptVideoCallButton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        acceptVideoCallButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           kQMButtonSizeBig,
                                                                           kQMButtonSizeBig)];
        
        [acceptVideoCallButton setImage:[UIImage imageNamed:@"qm-ic-accept-video"]
                               forState:UIControlStateNormal];
    });
    
    return acceptVideoCallButton;
}

+ (UIButton *)declineButton {
    
    static UIButton *declineButton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        declineButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   kQMButtonSizeBig,
                                                                   kQMButtonSizeBig)];
        
        [declineButton setImage:[UIImage imageNamed:@"qm-ic-decline"]
                       forState:UIControlStateNormal];
    });
    
    return declineButton;
}

+ (UIButton *)declineVideoCallButton {
    
    static UIButton *declineVideoCallButton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        declineVideoCallButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                            0,
                                                                            kQMVideoCallDeclineButtonWidth,
                                                                            kQMButtonSizeSmall)];
        
        [declineVideoCallButton setImage:[UIImage imageNamed:@"qm-ic-decline-video"]
                                forState:UIControlStateNormal];
    });
    
    
    return declineVideoCallButton;
}

+ (UIButton *)muteAudioCallButton {
    
    static UIButton *muteAudioCallButton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        muteAudioCallButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         kQMButtonSizeBig,
                                                                         kQMButtonSizeBig)];
        
        [muteAudioCallButton setImage:[UIImage imageNamed:@"qm-ic-mute"]
                             forState:UIControlStateNormal];
        
        [muteAudioCallButton setImage:[UIImage imageNamed:@"qm-ic-mute-selected"]
                             forState:UIControlStateSelected];
    });
    
    return muteAudioCallButton;
}

+ (UIButton *)muteVideoCallButton {
    
    static UIButton *muteVideoCallButton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        muteVideoCallButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         kQMButtonSizeSmall,
                                                                         kQMButtonSizeSmall)];
        
        [muteVideoCallButton setImage:[UIImage imageNamed:@"qm-ic-mute"]
                             forState:UIControlStateNormal];
        
        [muteVideoCallButton setImage:[UIImage imageNamed:@"qm-ic-mute-selected"]
                             forState:UIControlStateSelected];
    });
    
    return muteVideoCallButton;
}

+ (UIButton *)speakerButton {
    
    static UIButton *speakerButton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        speakerButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   kQMButtonSizeBig,
                                                                   kQMButtonSizeBig)];
        
        [speakerButton setImage:[UIImage imageNamed:@"qm-ic-speaker"]
                       forState:UIControlStateNormal];
        
        [speakerButton setImage:[UIImage imageNamed:@"qm-ic-speaker-selected"]
                       forState:UIControlStateSelected];
    });
    
    return speakerButton;
}

+ (UIButton *)cameraButton {
    
    static UIButton *cameraButton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  kQMButtonSizeSmall,
                                                                  kQMButtonSizeSmall)];
        
        [cameraButton setImage:[UIImage imageNamed:@"qm-ic-camera"]
                      forState:UIControlStateNormal];
        
        [cameraButton setImage:[UIImage imageNamed:@"qm-ic-camera-selected"]
                      forState:UIControlStateSelected];
    });
    
    return cameraButton;
}

+ (UIButton *)cameraRotationButton {
    
    static UIButton *cameraRotationButton = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        cameraRotationButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          kQMButtonSizeSmall,
                                                                          kQMButtonSizeSmall)];
        
        [cameraRotationButton setImage:[UIImage imageNamed:@"qm-ic-camera-rotation"]
                              forState:UIControlStateNormal];
        
        [cameraRotationButton setImage:[UIImage imageNamed:@"qm-ic-camera-rotation-selected"]
                              forState:UIControlStateSelected];
    });
    
    return cameraRotationButton;
}

@end
