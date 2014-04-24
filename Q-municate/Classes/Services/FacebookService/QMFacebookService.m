//
//  QMFacebookService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 26/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFacebookService.h"
#import "QMContactList.h"



@interface QMFacebookService () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) FBContentBlock contentBlock;
@property (nonatomic, strong) NSMutableData *receivedMData;

@end

@implementation QMFacebookService

+ (void)shareToFacebookUsersWithIDs:(NSString *)facebookIDs withCompletion:(FBCompletionBlock)handler
{
    NSMutableDictionary *postParams = [@{
                                         @"link" : @"http://quickblox.com/",
                                         @"picture" : @"http://www.apps-world.net/europe/images/stories/Quickblox.jpg",
                                         @"name" : @"Q-municate",
                                         @"caption" : @"By QuickBlox",
                                         @"description" : @"Join to new world of audio & video calls",
                                         @"place":@"155021662189",
                                         @"message": @"Weeery Nice!"
                                         } mutableCopy];
    
    postParams[@"tags"] = facebookIDs;
    
    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:postParams HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error){
            handler(NO, error);
            return;
        }
        handler(YES, nil);
    }];
}

- (void)loadAvatarImageFromFacebookWithCompletion:(FBContentBlock)handler
{
    _contentBlock = [handler copy];
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@", [QMContactList shared].facebookMe[@"id"],[FBSession activeSession].accessTokenData.accessToken];
    NSURLRequest *avatarRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:avatarRequest delegate:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [connection start];
    });
}

- (void)loadMeWithCompletion:(FBContentBlock)handler
{
    _contentBlock = [handler copy];
    NSString *urlString = [NSString stringWithFormat:@"https://graph.facebook.com/me?fields=id,name,email&access_token=%@", [FBSession activeSession].accessTokenData.accessToken];
    NSURLRequest *requestForMe = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:requestForMe delegate:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [connection start];
    });
}

- (void)fetchFacebookFriendsUsingBlock:(QBChatResultBlock)block
{
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSMutableArray *myFriends = [(FBGraphObject *)result objectForKey:kData];
        if ([myFriends count] == 0) {
            return;
        }
        [QMContactList shared].facebookFriendsToInvite = myFriends;
        block(YES);
    }];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data.length) {
        ILog(@"data.length: %lu", (unsigned long)data.length);
        if (!self.receivedMData) {
            self.receivedMData = [NSMutableData new];
        }
        [self.receivedMData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _contentBlock(self.receivedMData, nil);
        _contentBlock = nil;
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _contentBlock(nil, error);
        _contentBlock = nil;
    });
}

@end
