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

- (void)viewDidLoad {
    
    NSMutableSet *friendsIDS = [NSMutableSet setWithArray:[[QMApi instance] idsFromContactListItems]];
    NSSet *minusSet = [NSSet setWithArray:self.chatDialog.occupantIDs];
    [friendsIDS minusSet:minusSet];
    
    NSArray * friends = [[QMApi instance] usersWithIDs:friendsIDS.allObjects];
    self.friends = friends;
    
    [super viewDidLoad];
}

#pragma mark - Overriden methods

- (IBAction)performAction:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] joinOccupants:self.selectedFriends toChatDialog:self.chatDialog completion:^(QBChatDialogResult *result) {
        if (result.success) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        [SVProgressHUD dismiss];
    }];
}

@end
