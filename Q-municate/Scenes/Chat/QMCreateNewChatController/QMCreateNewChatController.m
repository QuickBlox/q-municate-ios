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
#import "QMServicesManager.h"

NSString *const QMChatViewControllerID = @"QMChatViewController";

@implementation QMCreateNewChatController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    self.contacts = QM.contactListService.usersFromContactListSortedByFullName;
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

    [QM.chatService createGroupChatDialogWithName:chatName
                                        occupants:self.selectedFriends
                                       completion:^(QBResponse *response, QBChatDialog *createdDialog)
    {
        if (response.success) {
            
            QMChatViewController *chatViewController =
            [weakSelf.storyboard instantiateViewControllerWithIdentifier:QMChatViewControllerID];
            
            chatViewController.dialog = createdDialog;
            
            NSMutableArray *controllers =
            weakSelf.navigationController.viewControllers.mutableCopy;
            
            [controllers removeLastObject];
            [controllers addObject:chatViewController];
            
            [weakSelf.navigationController setViewControllers:controllers
                                                     animated:YES];
        } else {
            
        }
        
        [SVProgressHUD dismiss];
    }];
}

- (NSString *)chatNameFromUserNames:(NSMutableArray *)users {
    
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:users.count];
    
    for (QBUUser *user in users) {
        [names addObject:user.fullName];
    }
    
    [names addObject:QM.profile.userData.fullName];
    return [names componentsJoinedByString:@", "];
}

@end
