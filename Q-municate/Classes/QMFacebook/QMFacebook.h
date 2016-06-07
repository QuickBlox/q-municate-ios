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


+ (BFTask QB_GENERIC(NSString *) *)connect;


+ (void)inviteFriendsWithDelegate:(id<FBSDKAppInviteDialogDelegate>)delegate;


+ (void)fetchMyFriends:(void(^)(NSArray *facebookFriends))completion;


+ (void)fetchMyFriendsIDs:(void(^)(NSArray *facebookFriendsIDs))completion;


+ (NSURL *)userImageUrlWithUserID:(NSString *)userID;


+ (BFTask QB_GENERIC(NSDictionary *) *)loadMe;


+ (void)logout;

@end
