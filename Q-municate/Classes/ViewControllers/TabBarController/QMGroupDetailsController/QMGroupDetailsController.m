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

NSString *const kQMAddMembersToGroupControllerID = @"QMAddMembersToGroupController";

@interface QMGroupDetailsController ()

<UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) QMGroupDetailsDataSource *dataSource;
@property (strong, nonatomic) QBChatRoom *chatRoom;

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
        
        if ([roomName isEqualToString:self.chatRoom.name]) {
            [weakSelf updateOnlineStatus:users.count];
        }
    }];
    
    [[QMChatReceiver instance] chatRoomDidChangeOnlineUsersWithTarget:self block:^(NSArray *onlineUsers, NSString *roomName) {
        
        if ([roomName isEqualToString:self.chatRoom.name]) {
            [weakSelf updateOnlineStatus:onlineUsers.count];
        }
    }];
    
    self.chatRoom = [[QMApi instance] chatRoomWithRoomJID:self.chatDialog.roomJID];
    [self.chatRoom requestOnlineUsers];
    
}

- (void)updateOnlineStatus:(NSUInteger)online {
    
    NSString *onlineUsersCountText = [NSString stringWithFormat:@"%d/%d online", online, self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = onlineUsersCountText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (IBAction)changeDialogName:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] changeChatName:self.groupNameField.text forChatDialog:self.chatDialog completion:^(QBChatDialogResult *result) {
        [SVProgressHUD dismiss];
    }];
}

- (void)updateGUIWithChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(self.chatDialog && chatDialog.type == QBChatDialogTypeGroup , @"Need update this case");

    self.groupNameField.text = chatDialog.name;
    self.occupantsCountLabel.text = [NSString stringWithFormat:@"%d participants", self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = [NSString stringWithFormat:@"0/%d online", self.chatDialog.occupantIDs.count];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMAddMembersToGroupControllerID]) {
        QMAddMembersToGroupController *addMembersVC = segue.destinationViewController;
        addMembersVC.chatDialog = self.chatDialog;
    }
}

@end
