//
//  QMFriendsListDataSource.h
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/3/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//


@interface QMFriendsListDataSource : NSObject

@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSMutableArray *otherUsersArray;


/** If returns YES - it means that array is empty, if NO - not empty */
- (BOOL)updateFriendsArrayAndCheckForEmpty;

/** If returns YES - it means that array is empty, if NO - not empty */
- (BOOL)updateSearchedUsersArrayAndCheckForEmpty;

- (void)updateFriendsArrayForSearchPhrase:(NSString *)searchPhraseString;

- (void)emptyOtherUsersArray;

@end
