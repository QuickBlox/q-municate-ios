//
//  QMFriendsListDataSource.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsListDataSource.h"
#import "QMContactList.h"

@implementation QMFriendsListDataSource

- (id)init
{
    self = [super init];
    if (self) {
        _friendsArray = [NSMutableArray new];
        _otherUsersArray = [NSMutableArray new];
    }
    return self;
}

- (void)updateFriendsArray:(void (^)(BOOL isEmpty))block
{
    self.friendsArray = [[[QMContactList shared].friendsAsDictionary allValues] mutableCopy];
    if ([self.friendsArray count] == 0) {
        [QMContactList shared].friendsAsDictionary = [NSMutableDictionary new];
        block(YES);
    } else {
        block(NO);
    }
}

- (void)updateOtherUsersArray:(void(^)(BOOL isEmpty))block
{
    self.otherUsersArray = [[QMContactList shared].allUsers mutableCopy];
    if ([self.otherUsersArray count] == 0) {
        [QMContactList shared].allUsers = [NSMutableArray new];
        block(YES);
    } else {
        block(NO);
    }
}

- (void)updateFriendsArrayForSearchPhrase:(NSString *)searchPhraseString
{
    //TODO: try setArray - that is more optimised
    NSMutableArray *searchedUsers = [self searchText:searchPhraseString inArray:[[QMContactList shared].friendsAsDictionary allValues]];
    [self.friendsArray setArray:searchedUsers];
}

- (void)emptyOtherUsersArray
{
    [self.otherUsersArray setArray:[@[] mutableCopy]];
}

- (NSMutableArray *)searchText:(NSString *)text  inArray:(NSArray *)array
{
    NSMutableArray *foundMArray = [[NSMutableArray alloc] init];
    for (QBUUser *user in array) {
        if ([self searchingString:user.fullName inString:text]) {
            [foundMArray addObject:user];
        }
    }
    return foundMArray;
}

- (BOOL)searchingString:(NSString *)source inString:(NSString *)searchString
{
    NSRange range = [source rangeOfString:searchString options:NSCaseInsensitiveSearch];
    if (range.location == NSNotFound) {
        return NO;
    }
    return YES;
}

@end
