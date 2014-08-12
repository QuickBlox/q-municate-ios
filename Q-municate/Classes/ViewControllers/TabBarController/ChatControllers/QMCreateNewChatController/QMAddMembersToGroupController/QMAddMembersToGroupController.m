//
//  QMAddMembersToGroupController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddMembersToGroupController.h"
#import "QMApi.h"
#import "SVProgressHUD.h"

@implementation QMAddMembersToGroupController

- (NSArray *)sortUsersByFullname:(NSArray *)users {
    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"fullName"
                                ascending:YES
                                selector:@selector(localizedCaseInsensitiveCompare:)];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[sorter]];
    
    return sortedUsers;
}

- (void)viewDidLoad {
    
    NSArray *friends = [[QMApi instance] friends];
    NSArray *usersIDs = [[QMApi instance] idsWithUsers:friends];
    
    NSMutableSet *friendsIDs = [NSMutableSet setWithArray:usersIDs];
    NSSet *minusSet = [NSSet setWithArray:self.chatDialog.occupantIDs];
    [friendsIDs minusSet:minusSet];
    
    NSArray *toAdd = [[QMApi instance] usersWithIDs:friendsIDs.allObjects];
    self.friends = [self sortUsersByFullname:toAdd];
    
    [super viewDidLoad];
}

#pragma mark - Overriden methods

- (IBAction)performAction:(id)sender {
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] joinOccupants:self.selectedFriends toChatDialog:self.chatDialog completion:^(QBChatDialogResult *result) {
        
        if (result.success) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
        [SVProgressHUD dismiss];
    }];
}

@end
