//
//  QMFriendsListDataSource.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsListDataSource.h"
#import "QMUsersService.h"

@interface QMFriendsListDataSource()

@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSMutableArray *otherUsersArray;

@end

@implementation QMFriendsListDataSource

- (id)init {
    
    self = [super init];
    if (self) {
        _friendsArray = [NSMutableArray new];
        _otherUsersArray = [NSMutableArray new];
    }
    return self;
}


- (BOOL)updateFriendsArrayAndCheckForEmpty {
    
//    NSMutableArray *usersArray = [[[QMContactList shared].friendsAsDictionary allValues] mutableCopy];
//    self.friendsArray = [self sortUsersByFullname:usersArray];
//    if ([self.friendsArray count] == 0) {
//        [QMContactList shared].friendsAsDictionary = [NSMutableDictionary new];
//        return YES;
//    }
    return NO;
}

- (BOOL)updateSearchedUsersArrayAndCheckForEmpty {
    
//    NSMutableArray *usersArray = [[[QMContactList shared].searchedUsers allValues] mutableCopy];
//    self.otherUsersArray = [self sortUsersByFullname:usersArray];
//    
//    if ([self.otherUsersArray count] == 0) {
//        [QMContactList shared].searchedUsers = [NSMutableDictionary new];
//        return YES;
//    }
//    
    return NO;
}

- (void)updateFriendsArrayForSearchPhrase:(NSString *)searchPhraseString {

//    if ([searchPhraseString isEqualToString:kEmptyString]) {
//        [self.friendsArray setArray:[[QMContactList shared].friendsAsDictionary allValues]];
//        return;
//    }
//    
//    NSMutableArray *searchedUsers = [self searchText:searchPhraseString inArray:[[QMContactList shared].friendsAsDictionary allValues]];
//    [self.friendsArray setArray:searchedUsers];
}

- (void)emptyOtherUsersArray
{
//    [self.otherUsersArray setArray:[@[] mutableCopy]];
}

- (NSMutableArray *)searchText:(NSString *)text  inArray:(NSArray *)array {
    
    NSMutableArray *foundMArray = [[NSMutableArray alloc] init];
//    for (QBUUser *user in array) {
//        if ([self searchingString:user.fullName inString:text]) {
//            [foundMArray addObject:user];
//        }
//    }
    return foundMArray;
}

- (BOOL)searchingString:(NSString *)source inString:(NSString *)searchString {
    
    NSRange range = [source rangeOfString:searchString options:NSCaseInsensitiveSearch];
    if (range.location == NSNotFound) {
        return NO;
    }
    
    return YES;
}

- (NSMutableArray *)sortUsersByFullname:(NSArray *)users {
    
    NSArray *sortedUsers = nil;
    NSSortDescriptor *fullNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
    sortedUsers = [users sortedArrayUsingDescriptors:@[fullNameDescriptor]];
    return [sortedUsers mutableCopy];
}

@end
