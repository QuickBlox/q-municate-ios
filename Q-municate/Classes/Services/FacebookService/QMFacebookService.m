//
//  QMFacebookService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFacebookService.h"
#import "QMContactList.h"

@interface QMFacebookService ()

@end

@implementation QMFacebookService

NSString *const kQMQuickbloxHomeUrl = @"http://quickblox.com";
NSString *const kQMQuickbloxLogoUrl = @"https://qbprod.s3.amazonaws.com/c6e81081d5954ed68485eead941b91a000";
NSString *const kQMAppName = @"Q-municate";

+ (void)shareToFacebookUsersWithIDs:(NSString *)facebookIDs withCompletion:(FBCompletionBlock)handler {
    
    NSDictionary *postParams = @{
                                 @"link" : kQMQuickbloxHomeUrl,
                                 @"picture" : kQMQuickbloxLogoUrl,
                                 @"name" : kQMAppName,
                                 @"caption" : @"By QuickBlox",
                                 @"description" : @"Join to new world of audio & video calls",
                                 @"place":@"155021662189",
                                 @"message": @"Very Nice!",
                                 @"tags" : facebookIDs
                                 };
    
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:postParams
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              handler((BOOL)result, error);
                          }];
}

NSString *const kFBGraphGetPictureFormat = @"https://graph.facebook.com/%@/picture?height=100&width=100&access_token=%@";

- (void)loadUserImageFromFacebookWithUserID:(NSString *)userID completion:(ImageBlock)handler {
    
    FBSession *session = [FBSession activeSession];
    NSString *urlString = [NSString stringWithFormat:kFBGraphGetPictureFormat, userID, session.accessTokenData.accessToken];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(image);
        });
    });
}

- (void)loadMeWithCompletion:(FBContentBlock)handler {
    
    FBRequest *friendsRequest = [FBRequest requestForMe];
    
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
        handler(user, error);
    }];
    
}

- (void)fetchFacebookFriendsUsingBlock:(QBChatResultBlock)block {
    
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        NSMutableArray *myFriends = [(FBGraphObject *)result objectForKey:kData];
        [QMContactList shared].facebookFriendsToInvite = myFriends;
        
        block(YES);
    }];
}

@end
