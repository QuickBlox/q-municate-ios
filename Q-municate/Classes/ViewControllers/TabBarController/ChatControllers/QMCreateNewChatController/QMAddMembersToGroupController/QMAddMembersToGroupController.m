//
//  QMAddMembersToGroupController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddMembersToGroupController.h"
#import "QMApi.h"

@interface QMAddMembersToGroupController ()

@end

@implementation QMAddMembersToGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overriden methods


- (IBAction)performAction:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] joinOccupants:self.selectedFriends toChatDialog:self.chatDialog completion:^(QBChatDialogResult *result) {
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    }];
}

@end
