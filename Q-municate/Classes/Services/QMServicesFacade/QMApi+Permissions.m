//
//  QMApi+Permissions.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/24/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import <AVFoundation/AVAudioSession.h>
#import <AVFoundation/AVFoundation.h>

@implementation QMApi (Permissions)

- (void)requestPermissionToMicrophoneWithCompletion:(void(^)(BOOL granted))completion {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if( completion ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(granted);
            });
        }
    }];
}

- (void)requestPermissionToCameraWithCompletion:(void(^)(BOOL authorized))completion {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        if( completion ){
            completion(YES);
        }
    } else if(authStatus == AVAuthorizationStatusDenied){
        if( completion ){
            completion(NO);
        }
    } else if(authStatus == AVAuthorizationStatusRestricted){
        if( completion ){
            completion(NO);
        }
    } else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if( completion ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(granted);
                });
            }
        }];
    } else {
        if( completion ){
            completion(NO);
        }
    }
}

@end
