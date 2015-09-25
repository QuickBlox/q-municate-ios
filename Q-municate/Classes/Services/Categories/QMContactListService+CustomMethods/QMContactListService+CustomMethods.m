//
//  QMContactListService+CustomMethods.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

@implementation QMContactListService(CustomMethods)

- (NSArray *)idsOfContactsOnly {
    
    NSMutableSet *IDs = [NSMutableSet new];
    NSArray *contactItems = [QBChat instance].contactList.contacts;
    
    for (QBContactListItem *item in contactItems) {
        [IDs addObject:@(item.userID)];
    }
    
    for (QBContactListItem *item in [QBChat instance].contactList.pendingApproval) {
        
        if (item.subscriptionState == QBPresenseSubscriptionStateFrom) {
            [IDs addObject:@(item.userID)];
        }
    }
    return IDs.allObjects;
}

- (void)retrieveUsersWithFacebookIDs:(NSArray *)facebookIDs completion:(QBUUserPagedResponseBlock)completion {
    NSUInteger currentPage = 1;
    NSUInteger perPage = facebookIDs.count < 100 ? facebookIDs.count : 100;
    [QBRequest usersWithFacebookIDs:facebookIDs page:[QBGeneralResponsePage responsePageWithCurrentPage:currentPage perPage:perPage] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
        //
        completion(response,page,users);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil,nil);
    }];
}

- (void)retrieveUsersWithEmails:(NSArray *)emails completion:(QBUUserPagedResponseBlock)completion {
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest usersWithEmails:emails successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
         //
         [weakSelf.usersMemoryStorage addUsers:[users copy]];
         
//         if ([weakSelf.multicastDelegate respondsToSelector:@selector(contactListService:didAddUsers:)]) {
//             [weakSelf.multicastDelegate contactListService:weakSelf didAddUsers:users];
//         }
     } errorBlock:^(QBResponse *response) {
         //
         completion(response,nil,nil);
     }];
}

- (void)resetUserPasswordWithEmail:(NSString *)email completion:(QBResponseBlock)completion {
    
    [QBRequest resetUserPasswordWithEmail:email successBlock:^(QBResponse *response) {
        //
        completion(response);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response);
    }];
}

- (QBRequest *)retrieveUsersWithFullName:(NSString *)searchText pagedRequest:(QBGeneralResponsePage *)page completion:(QBUUserPagedResponseBlock)completion {
    return [QBRequest usersWithFullName:searchText page:page successBlock:^(QBResponse *response, QBGeneralResponsePage *responsePage, NSArray *users) {
        //
        completion(response,responsePage,users);
    } errorBlock:^(QBResponse *response) {
        //
        completion(response,nil,nil);
    }];
}

@end
