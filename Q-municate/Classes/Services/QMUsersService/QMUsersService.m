//
//  QMUsersService.m
//  Q-municate
//
//  Created by Igor Alefirenko on 14/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUsersService.h"
#import "QBEchoObject.h"

@implementation QMUsersService

#pragma mark - FRIEND LIST ROASTER

- (void)retrieveUsersWithFacebookIDs:(NSArray *)facebookIDs completion:(QBUUserPagedResultBlock)completion {
    [QBUsers usersWithFacebookIDs:facebookIDs delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}
/**
 * @param contacts - QBContactListItem collection
 * @return colletion NSString QBContactListItem userID
 */
- (NSArray *)idsFromContacts:(NSArray *)contacts {

    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:contacts.count];
    
    for (QBContactListItem *item in contacts) {
        NSString *stringID = [NSString stringWithFormat:@"%d", item.userID];
        [ids addObject:stringID];
    }
    
    return ids;
}

- (void)retrieveUsersWithContactListInfo:(QBContactList *)contactList completion:(QBUUserPagedResultBlock)completion {

    // searching IDs of users out of Friends list:
    NSMutableArray *idsToFetch = [NSMutableArray new];
    
    // search active friends:
    [idsToFetch addObjectsFromArray:[self idsFromContacts:contactList.contacts]];
    //search in pending list:
    [idsToFetch addObjectsFromArray:[self idsFromContacts:contactList.pendingApproval]];
    
    if (idsToFetch.count > 0) {
        // retrive users with ids:
        NSString *joinedIds = [idsToFetch componentsJoinedByString:@","];
        [QBUsers usersWithIDs:joinedIds delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
    }
}

- (void)retrieUsersWithPagedRequest:(PagedRequest*)pagedRequest completion:(QBUUserPagedResultBlock)completion {
    [QBUsers usersWithPagedRequest:pagedRequest delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)retrieveUsersWithFullName:(NSString *)fullName completion:(QBUUserPagedResultBlock)completion {
    [QBUsers usersWithFullName:fullName delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)retrieveUserWithID:(NSUInteger)userID completion:(QBUUserResultBlock)completion {
    [QBUsers userWithID:userID delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

- (void)retrieveUsersWithEmails:(NSArray *)emails completion:(QBUUserPagedResultBlock)completion {
    [QBUsers usersWithEmails:emails delegate:[QBEchoObject instance] context:[QBEchoObject makeBlockForEchoObject:completion]];
}

#pragma mark -
#pragma mark Contact list

/**
 Called in case receiving contact request
 
 @param userID User ID from which received contact request
 */
- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID {
    
}

/**
 Called in case changing contact list
 */
- (void)chatContactListDidChange:(QBContactList *)contactList {
    //    [[QMContactList shared] retrieveFriendsWithContactListInfo:contactList completion:^(BOOL success, NSError *error) {
    //    }];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsReloadedNotification object:nil];
}

/**
 Called in case changing contact's online status
 
 @param userID User which online status has changed
 @param isOnline New user status (online or offline)
 @param status Custom user status
 */
- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    
}

/** Contact Requests */
- (void)sendFriendsRequestToUserWithID:(NSUInteger)userID {
    [[QBChat instance] addUserToContactListRequest:userID];
}

- (void)confirmFriendsRequestFromUserWithID:(NSUInteger)userID {
    [[QBChat instance] confirmAddContactRequest:userID];
}

- (void)rejectFriendsRequestFromUserWithID:(NSUInteger)userID {
    [[QBChat instance] rejectAddContactRequest:userID];
}

- (void)removeContactFromFriendsWithID:(NSUInteger)userID {
    [[QBChat instance] removeUserFromContactList:userID];
}

@end
