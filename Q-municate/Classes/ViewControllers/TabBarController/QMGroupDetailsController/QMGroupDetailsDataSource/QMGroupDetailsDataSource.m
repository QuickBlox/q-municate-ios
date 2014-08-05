//
//  QMGroupDetailsDataSource.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 14/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsDataSource.h"
#import "QMFriendListCell.h"
#import "QMChatReceiver.h"
#import "QMApi.h"

NSString * const kFriendsListCellIdentifier = @"QMFriendListCell";

@interface QMGroupDetailsDataSource ()

<QMFriendListCellDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *participants;

@property (nonatomic, strong) QBChatDialog *chatDialog;

@end

@implementation QMGroupDetailsDataSource

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[QMChatReceiver instance] unsubscribeForTarget:self];
}

- (id)initWithChatDialog:(QBChatDialog *)chatDialog tableView:(UITableView *)tableView {

    if (self = [super init]) {
        
        _tableView = tableView;
        
        self.chatDialog = chatDialog;
        
        self.tableView.dataSource = nil;
        self.tableView.dataSource = self;
        
        [self reloadParticipants];
        __weak __typeof(self)weakSelf = self;
        void(^retrive)(void) = ^() {
            [[QMApi instance] retrieveFriendsIfNeeded:^(BOOL updated) {
                [weakSelf reloadParticipants];
            }];
        };
        
        [[QMChatReceiver instance] chatContactListWilChangeWithTarget:self block:retrive];
        
        [[QMChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
            if (message.cParamNotificationType == QMMessageNotificationTypeUpdateDialog && [message.cParamDialogID isEqualToString:self.chatDialog.ID]) {
                [weakSelf applyChangesWithMessageNotification:message];
            }
        }];
    }
    
    return self;
}

- (void)reloadParticipants {
    
    self.participants = [[QMApi instance] usersWithIDs:self.chatDialog.occupantIDs];
    [self.tableView reloadData];
}

- (void)applyChangesWithMessageNotification:(QBChatMessage *)messageNotification
{
    QBChatDialog *updatedDialog = [[QMApi instance] chatDialogWithID:messageNotification.cParamDialogID];
    if ([self.chatDialog.occupantIDs count] != [updatedDialog.occupantIDs count]) {
        self.chatDialog = updatedDialog;
        [self reloadParticipants];
    }
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.participants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMFriendListCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendsListCellIdentifier];

    QBUUser *user = self.participants[indexPath.row];
    
    cell.userData = user;
    cell.contactlistItem = [[QMApi instance] contactItemWithUserID:user.ID];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - QMFriendListCellDelegate

- (void)friendListCell:(QMFriendListCell *)cell pressAddBtn:(UIButton *)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    QBUUser *user = self.participants[indexPath.row];
    [[QMApi instance] addUserToContactListRequest:user.ID];
}

@end
