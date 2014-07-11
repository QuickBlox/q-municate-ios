//
//  QMFacebookService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMFacebookService : NSObject
/**
 */
- (void)connectToFacebook:(void(^)(NSString *sessionToken))completion;
/**
 */
- (void)loadUserImageWithUserID:(NSString *)userID completion:(void(^)(UIImage *fbUserImage))completion;
/**
 */
- (void)inviteFriends;
/**
 */
- (void)fetchMyFriends:(void(^)(NSArray *facebookFriends))completion;
/**
 */
- (void)fetchMyFriendsIDs:(void(^)(NSArray *facebookFriendsIDs))completion;
/**
 */
- (NSURL *)userImageUrlWithUserID:(NSString *)userID;
/**
 */
- (void)shareToUsers:(NSString *)usersIDs completion:(void(^)(NSError *error))completion;
/**
 */
- (void)loadMe:(void(^)(NSDictionary<FBGraphUser> *user))completion;
/**
 */
- (void)logout;

@end
