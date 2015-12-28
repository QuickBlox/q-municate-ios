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
#import "QMUsersUtils.h"

@implementation QMAddMembersToGroupController


- (void)viewDidLoad {
    
    NSArray *friends = [[QMApi instance] contactsOnly];
    NSArray *usersIDs = [[QMApi instance] idsWithUsers:friends];
    NSArray *friendsIDsToAdd = [self filteredIDs:usersIDs forChatDialog:self.chatDialog];
    
    NSArray *toAdd = [[QMApi instance] usersWithIDs:friendsIDsToAdd];
    self.contacts = [QMUsersUtils sortUsersByFullname:toAdd];
    
    [super viewDidLoad];
}

#pragma mark - Overriden methods

- (IBAction)performAction:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] joinOccupants:self.selectedFriends toChatDialog:self.chatDialog completion:^(QBChatDialog *updatedDialog) {
        //
        if (updatedDialog != nil) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
        
        [SVProgressHUD dismiss];
    }];
}

- (NSArray *)filteredIDs:(NSArray *)IDs forChatDialog:(QBChatDialog *)chatDialog
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:IDs];
    [newArray removeObjectsInArray:chatDialog.occupantIDs];
    return [newArray copy];
}

@end
