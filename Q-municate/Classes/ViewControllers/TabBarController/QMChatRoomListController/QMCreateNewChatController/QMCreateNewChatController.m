//
//  QMCreateNewChatController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCreateNewChatController.h"
#import "QMChatViewController.h"
#import "QMInviteFriendsCell.h"
#import "QMContactList.h"
#import "QMNewChatDataSource.h"
#import "QMChatService.h"


@interface QMCreateNewChatController ()

@end

@implementation QMCreateNewChatController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set up data source:
    self.dataSource = [QMNewChatDataSource new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/** OVERRIDEN */
- (void)applyChangesForPerformButton
{
	if ([self.dataSource.friendsSelectedMArray count] <=1) {
		[self.performButton setEnabled:NO];
		[self.performButton setAlpha:0.5f];
        return;
	}
    [self.performButton setEnabled:YES];
    [self.performButton setAlpha:1.0f];
}

- (NSMutableArray *)usersIDFromSelectedUsers:(NSMutableArray *)users
{
    NSMutableArray *usersIDs = [super usersIDFromSelectedUsers:users];
    // also add me:
    NSString *myID = [NSString stringWithFormat:@"%lu", (unsigned long)[QMContactList shared].me.ID];
    [usersIDs addObject:myID];
    return usersIDs;
}

#pragma mark - Overriden Actions

- (IBAction)performAction:(id)sender
{
	NSMutableArray *selectedUsersMArray = self.dataSource.friendsSelectedMArray;
    NSString *chatName = [self chatNameFromUserNames:selectedUsersMArray];
	NSArray *usersIdArray = [self usersIDFromSelectedUsers:selectedUsersMArray];
        
    // create new dialog entity:
    QBChatDialog *chatDialog = [QBChatDialog new];
    chatDialog.name = chatName;
    chatDialog.occupantIDs = usersIdArray;
    chatDialog.type = QBChatDialogTypeGroup;
    [[QMChatService shared] createChatDialog:chatDialog withCompletion:^(QBChatDialog *dialog, NSError *error) {
        // save to dialogs dictionary:
        [QMChatService shared].allDialogsAsDictionary[dialog.roomJID] = dialog;
        [QMChatService shared].lastCreatedDialog = dialog;
        // send invitation to users:
        [[QMChatService shared] sendChatDialogDidCreateNotificationToUsers:selectedUsersMArray withChatDialog:dialog];
        
        [self.navigationController popViewControllerAnimated:NO];
    }];
}

#pragma mark - Options

// title for chat view:
- (NSString *)chatNameFromUserNames:(NSMutableArray *)users
{
    NSMutableString *chatName = nil;
    for (QBUUser *user in users) {
        if ([user isEqual:[users firstObject]]) {
            chatName = [user.fullName mutableCopy];
            continue;
        }
        [chatName appendString:@", "];
        [chatName appendString:user.fullName];
    }
    return chatName;
}


@end
