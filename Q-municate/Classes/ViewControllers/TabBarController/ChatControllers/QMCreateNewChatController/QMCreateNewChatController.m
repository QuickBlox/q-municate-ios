//
//  QMCreateNewChatController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCreateNewChatController.h"
#import "QMChatViewController.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

NSString *const QMChatViewControllerID = @"QMChatViewController";

@implementation QMCreateNewChatController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    NSArray *unsortedFriends = [[QMApi instance] friends];
    self.friends = [QMUsersUtils sortUsersByFullname:unsortedFriends];
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

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] createGroupChatDialogWithName:chatName occupants:self.selectedFriends completion:^(QBChatDialogResult *result) {
        
        if (result.success) {
            
            QMChatViewController *chatVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:QMChatViewControllerID];
            chatVC.dialog = result.dialog;
            
            NSMutableArray *controllers = weakSelf.navigationController.viewControllers.mutableCopy;
            [controllers removeLastObject];
            [controllers addObject:chatVC];
            
            [weakSelf.navigationController setViewControllers:controllers animated:YES];
        }
        
        [SVProgressHUD dismiss];
    }];
}

- (NSString *)chatNameFromUserNames:(NSMutableArray *)users {
    
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [names addObject:user.fullName];
    }
    
    [names addObject:[QMApi instance].currentUser.fullName];
    return [names componentsJoinedByString:@", "];
}

@end
