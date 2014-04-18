//
//  QMFacebookService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FBContentBlock)(NSData *data, NSError *error);



@interface QMFacebookService : NSObject

+ (void)shareToFacebookUsersWithIDs:(NSString *)facebookIDs withCompletion:(FBCompletionBlock)handler;
- (void)loadAvatarImageFromFacebookWithCompletion:(FBContentBlock)handler;
- (void)loadMeWithCompletion:(FBContentBlock)handler;
- (void)fetchFacebookFriendsUsingBlock:(QBChatResultBlock)block;

@end
