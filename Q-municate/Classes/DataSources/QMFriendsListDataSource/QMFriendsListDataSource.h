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

- (void)updateFriendsArray:(void (^)(BOOL isEmpty))block;

- (void)updateSearchedUsersArray:(void (^)(BOOL isEmpty))block;

- (void)updateFriendsArrayForSearchPhrase:(NSString *)searchPhraseString;

- (void)emptyOtherUsersArray;
@end
