//
//  QMGroupDetailsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 12/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsController.h"
#import "QMAddMembersToGroupController.h"
#import "QMGroupDetailsDataSource.h"
#import "SVProgressHUD.h"
#import "QMApi.h"
#import "QMChatReceiver.h"

NSString *const kErrorAlertMessage = @"You can't add new friend, because all existing friends are added in this group chat";

@interface QMGroupDetailsController ()

<UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) QMGroupDetailsDataSource *dataSource;

@end

@implementation QMGroupDetailsController

- (void)dealloc {
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateGUIWithChatDialog:self.chatDialog];
    
    self.dataSource = [[QMGroupDetailsDataSource alloc] initWithChatDialog:self.chatDialog tableView:self.tableView];
    
    __weak __typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatRoomDidReceiveListOfOnlineUsersWithTarget:self block:^(NSArray *users, NSString *roomName) {
        
        QBChatRoom *chatRoom = [[QMApi instance] chatRoomWithRoomJID:weakSelf.chatDialog.roomJID];
        if ([roomName isEqualToString:chatRoom.name]) {
            [weakSelf updateOnlineStatus:users.count];
        }
    }];
    
    [[QMChatReceiver instance] chatRoomDidChangeOnlineUsersWithTarget:self block:^(NSArray *onlineUsers, NSString *roomName) {
        
        QBChatRoom *chatRoom = [[QMApi instance] chatRoomWithRoomJID:weakSelf.chatDialog.roomJID];
        if ([roomName isEqualToString:chatRoom.name]) {
            [weakSelf updateOnlineStatus:onlineUsers.count];
        }
    }];

    [[QMChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        
        if (message.cParamNotificationType == QMMessageNotificationTypeUpdateDialog && [message.cParamDialogID isEqualToString:weakSelf.chatDialog.ID]) {
            if (message.senderID != [QMApi instance].currentUser.ID) {                
                weakSelf.chatDialog = [[QMApi instance] chatDialogWithID:message.cParamDialogID];
            }
            [weakSelf updateGUIWithChatDialog:weakSelf.chatDialog];
        }
    }];
}

- (void)updateOnlineStatus:(NSUInteger)online {
    
    NSString *onlineUsersCountText = [NSString stringWithFormat:@"%d/%d online", online, self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = onlineUsersCountText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (IBAction)changeDialogName:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] changeChatName:self.groupNameField.text forChatDialog:self.chatDialog completion:^(QBChatDialogResult *result) {
        [SVProgressHUD dismiss];
    }];
}
- (IBAction)addFriendsToChat:(id)sender
{
    // check for friends:
    NSArray *friends = [[QMApi instance] friends];
    NSArray *usersIDs = [[QMApi instance] idsWithUsers:friends];
    NSArray *friendsIDsToAdd = [self filteredIDs:usersIDs forChatDialog:self.chatDialog];
    
    if ([friendsIDsToAdd count] == 0) {
        [[[UIAlertView alloc] initWithTitle:nil message:kErrorAlertMessage delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil] show];
        return;
    }
    [self performSegueWithIdentifier:kQMAddMembersToGroupControllerSegue sender:nil];
}

- (void)updateGUIWithChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(self.chatDialog && chatDialog.type == QBChatDialogTypeGroup , @"Need update this case");

    self.groupNameField.text = chatDialog.name;
    self.occupantsCountLabel.text = [NSString stringWithFormat:@"%d participants", self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = [NSString stringWithFormat:@"0/%d online", self.chatDialog.occupantIDs.count];

    QBChatRoom *chatRoom = [[QMApi instance] chatRoomWithRoomJID:self.chatDialog.roomJID];
    [chatRoom requestOnlineUsers];
}

- (NSArray *)filteredIDs:(NSArray *)IDs forChatDialog:(QBChatDialog *)chatDialog
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:IDs];
    [newArray removeObjectsInArray:chatDialog.occupantIDs];
    return [newArray copy];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMAddMembersToGroupControllerSegue]) {
        QMAddMembersToGroupController *addMembersVC = segue.destinationViewController;
        addMembersVC.chatDialog = self.chatDialog;
    }
}

@end
