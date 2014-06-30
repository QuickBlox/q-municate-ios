//
//  QMAddMembersToGroupController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddMembersToGroupController.h"
#import "QMChatService.h"
#import "QMUtilities.h"


@interface QMAddMembersToGroupController ()

@end

@implementation QMAddMembersToGroupController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // set up data source:
    self.dataSource = [[QMNewChatDataSource alloc] initWithChatDialog:self.chatDialog];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overriden methods

- (void)applyChangesForPerformButton
{
    if ([self.dataSource.friendsSelectedMArray count] == 0) {
		[self.performButton setEnabled:NO];
		[self.performButton setAlpha:0.5f];
        return;
	}
    [self.performButton setEnabled:YES];
    [self.performButton setAlpha:1.0f];
}

- (IBAction)performAction:(id)sender
{
    //create indicator view:

    NSMutableArray *selectedUsersMArray = [self.dataSource friendsSelectedMArray];
    NSArray *usersIds = [self usersIDFromSelectedUsers:selectedUsersMArray];
    
    // update current dialog:
    [[QMChatService shared] addUsers:usersIds toChatDialog:self.chatDialog completion:^(QBChatDialog *dialog, NSError *error) {
        if (error) {
            return;
        }
        //send update dialog notifications to all participants of this group!
        [[QMChatService shared] sendChatDialogDidUpdateNotificationToUsers:[self.dataSource friendsSelectedMArray] withChatDialog:dialog];
        // and send create dialog notification to users that did added now:
        [[QMChatService shared] sendChatDialogDidCreateNotificationToUsers:selectedUsersMArray withChatDialog:dialog];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatDialogUpdatedNotification object:nil userInfo:@{@"room_jid":dialog.roomJID}];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
