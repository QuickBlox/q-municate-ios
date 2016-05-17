//
//  QMDialogsDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDialogsDataSource.h"
#import "QMDialogCell.h"
#import "QMCore.h"
#import <QMDateUtils.h>
#import "REAlertView.h"

#import <SVProgressHUD.h>

@implementation QMDialogsDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return [QMDialogCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMDialogCell cellIdentifier] forIndexPath:indexPath];
    QBChatDialog *chatDialog = self.items[indexPath.row];
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *recipient = [[QMCore instance].usersService.usersMemoryStorage userWithID:chatDialog.recipientID];
        
        if (recipient != nil) {
            NSParameterAssert(recipient.fullName);
            
            [cell setTitle:recipient.fullName placeholderID:chatDialog.recipientID avatarUrl:recipient.avatarUrl];
        }
        else {
            
            [cell setTitle:NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil) placeholderID:chatDialog.recipientID avatarUrl:nil];
        }
    } else {
        
        [cell setTitle:chatDialog.name placeholderID:chatDialog.ID.hash avatarUrl:chatDialog.photo];
    }
    
    NSString *time = [QMDateUtils formattedShortDateString:chatDialog.updatedAt];
    [cell setTime:time];
    [cell setBody:chatDialog.lastMessageText];
    [cell setBadgeNumber:chatDialog.unreadMessagesCount];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)__unused tableView canEditRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)__unused tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        @weakify(self);
        [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
            
            @strongify(self);
            
            QBChatDialog *chatDialog = self.items[indexPath.row];
            alertView.message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_DELETE_DIALOG", nil), chatDialog.name];
            [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{
                
                [tableView setEditing:NO animated:YES];
            }];
            
            [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil) andActionBlock:^{
                
                BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull __unused task) {
                    
                    [SVProgressHUD dismiss];
                    return nil;
                };
                
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                if (chatDialog.type == QBChatDialogTypeGroup) {
                    
                    chatDialog.occupantIDs = [[QMCore instance].contactManager occupantsWithoutCurrentUser:chatDialog.occupantIDs];
                    [[[QMCore instance].chatManager leaveChatDialog:chatDialog] continueWithBlock:completionBlock];
                } else {
                    // private and public group chats
                    [[[QMCore instance].chatService deleteDialogWithID:chatDialog.ID] continueWithBlock:completionBlock];
                }
            }];
        }];
    }
}

- (NSMutableArray *)items {
    
    return [[QMCore instance].chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO].mutableCopy;
}

@end
