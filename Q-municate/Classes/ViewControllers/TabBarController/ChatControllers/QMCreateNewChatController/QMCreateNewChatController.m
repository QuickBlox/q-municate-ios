//
//  QMCreateNewChatController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCreateNewChatController.h"
#import "QMChatViewController.h"
#import "QMInviteFriendCell.h"
#import "QMUsersService.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

@interface QMCreateNewChatController ()

@end

@implementation QMCreateNewChatController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Overriden Actions

- (IBAction)performAction:(id)sender {
    
	NSMutableArray *selectedUsersMArray = self.selectedFriends;
    NSString *chatName = [self chatNameFromUserNames:selectedUsersMArray];

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] createGroupChatDialogWithName:chatName ocupants:self.selectedFriends completion:^(QBChatDialogResult *result) {
    
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

- (NSString *)chatNameFromUserNames:(NSMutableArray *)users {
    
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [names addObject:user.fullName];
    }
    
    return [names componentsJoinedByString:@", "];
}

@end
