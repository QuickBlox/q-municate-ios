//
//  QMFacebook.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FBSDKAppInviteDialogDelegate;

/**
 *  This class provides interface for facebook SDK.
 */
@interface QMFacebook : NSObject

/**
 *  Connect to facebook.
 *
 *  @return facebook access tocken if succeed
 */
+ (BFTask <NSString *> *)connect;

/**
 *  User image url for user ID.
 *
 *  @param userID facebook user ID
 *
 *  @return user image url
 */
+ (NSURL *)userImageUrlWithUserID:(NSString *)userID;

/**
 *  Load current user data.
 *
 *  @return dictionary of current facebook user data
 */
+ (BFTask <NSDictionary *> *)loadMe;

/**
 *  Complete logout from facebook.
 */
+ (void)logout;

@end
