//
//  QMNewChatDataSource.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMNewChatDataSource.h"
#import "QMContactList.h"

@implementation QMNewChatDataSource


- (id)init
{
	self = [super init];
	if (self) {
		_friendListArray = [[[QMContactList shared].friendsAsDictionary allValues] copy];
		_friendsSelectedMArray = [NSMutableArray new];
	}
	return self;
}

- (id)initWithChatDialog:(QBChatDialog *)chatDialog
{
    if (self = [super init]) {
        _friendsSelectedMArray = [NSMutableArray new];
        
        NSArray *unsortedUsers = [[QMContactList shared].friendsAsDictionary allValues];
        NSMutableArray *sortedUsers = [self sortUsersByFullname:unsortedUsers];
        
        NSMutableArray *usersToDelete = [NSMutableArray new];
        for (NSString *participantID in chatDialog.occupantIDs) {
            
            QBUUser *user = [QMContactList shared].friendsAsDictionary[participantID];
            if (user != nil) {
                [usersToDelete addObject:user];
            }
        }
        [sortedUsers removeObjectsInArray:usersToDelete];
        
        _friendListArray = sortedUsers;
    }
    return self;
}

- (NSInteger)friendsListCount
{
    return [_friendListArray count];
}

- (NSInteger)friendsSelectedCount
{
    return [_friendsSelectedMArray count];
}

- (NSMutableArray *)sortUsersByFullname:(NSArray *)users
{
    NSArray *sortedUsers = nil;
    NSSortDescriptor *fullNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
    sortedUsers = [users sortedArrayUsingDescriptors:@[fullNameDescriptor]];
    return [sortedUsers mutableCopy];
}

@end
