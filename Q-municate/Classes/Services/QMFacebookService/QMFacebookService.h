//
//  QMFacebookService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FBSDKAppInviteDialogDelegate;

@interface QMFacebookService : NSObject
/**
 */
+ (void)connectToFacebook:(void(^)(NSString *sessionToken))completion;

/**
 */
+ (void)inviteFriendsWithDelegate:(id<FBSDKAppInviteDialogDelegate>)delegate;

/**
 */
+ (void)fetchMyFriends:(void(^)(NSArray *facebookFriends))completion;

/**
 */
+ (void)fetchMyFriendsIDs:(void(^)(NSArray *facebookFriendsIDs))completion;

/**
 */
+ (NSURL *)userImageUrlWithUserID:(NSString *)userID;

/**
 */
+ (void)loadMe:(void(^)(NSDictionary *user))completion;

/**
 */
+ (void)logout;

@end
