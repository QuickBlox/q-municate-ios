//
//  QMPermissions.h
//  Q-municate
//
//  Created by Injoit on 5/11/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PermissionBlock)(BOOL granted);

/**
 *  QMPerfmissions class interface.
 *  Used as main permission request.
 */
@interface QMPermissions : NSObject

/**
 *  Request permission to microphone.
 *
 *  @param completion completion block with granted flag
 */
+ (void)requestPermissionToMicrophoneWithCompletion:(PermissionBlock)completion;

/**
 *  Request permission to camera.
 *
 *  @param completion completion block with granted flag
 */
+ (void)requestPermissionToCameraWithCompletion:(PermissionBlock)completion;

@end
