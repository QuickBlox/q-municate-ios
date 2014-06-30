//
//  QMFacebookService.h
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FBContentBlock)(NSDictionary *content, NSError *error);
typedef void(^ImageBlock)(UIImage *img);



@interface QMFacebookService : NSObject

+ (void)shareToFacebookUsersWithIDs:(NSString *)facebookIDs withCompletion:(FBCompletionBlock)handler;
- (void)loadUserImageFromFacebookWithUserID:(NSString *)userID completion:(ImageBlock)handler;
- (void)loadMeWithCompletion:(FBContentBlock)handler;
- (void)fetchFacebookFriendsUsingBlock:(QBChatResultBlock)block;

@end
