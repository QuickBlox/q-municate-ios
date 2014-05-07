//
//  QMInviteFriendsDataSource.h
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/4/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//



@class QMPerson;

@interface QMInviteFriendsDataSource : NSObject

@property (strong, nonatomic) NSMutableArray *users;
@property (strong, nonatomic) NSMutableArray *checkedFacebookUsers;
@property (strong, nonatomic) NSMutableArray *checkedABContacts;

- (void)updateFacebookDataSource:(void (^)(NSError *error))completionBlock;

- (void)updateContactListDataSource:(void (^)(NSError *error))completionBlock;

- (void)changeStateForFacebookUsers;

- (void)changeStateForContactUsers;

- (void)changeUserState:(QMPerson *)user;

- (void)emptyCheckedFBUsersArray;

- (void)emptyCheckedABUsersArray;

- (NSArray *)emailsFromContactListPersons;
- (NSString *)emailsFromFacebookPersons;
- (void)fetchAndSaveFacebookFriendsWithBlock:(void(^)(NSError *error))block;


@end
