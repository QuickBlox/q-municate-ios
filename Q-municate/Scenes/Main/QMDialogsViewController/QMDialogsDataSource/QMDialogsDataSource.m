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
#import "QMChatUtils.h"

#import <SVProgressHUD.h>

@implementation QMDialogsDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
    } else {
        
        [cell setTitle:chatDialog.name placeholderID:chatDialog.ID.hash avatarUrl:chatDialog.photo];
    }
    
    NSString *time = [self.dateFormatter stringFromDate:chatDialog.updatedAt];
    [cell setTime:time];
    [cell setBody:chatDialog.lastMessageText];
    [cell setBadgeNumber:chatDialog.unreadMessagesCount];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        QBChatDialog *chatDialog = self.items[indexPath.row];
        
        if (chatDialog.type == QBChatDialogTypeGroup) {
            
            chatDialog.occupantIDs = [QMChatUtils occupantsWithoutCurrentUser:chatDialog.occupantIDs];
            [[[QMCore instance] leaveChatDialog:chatDialog] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                
                [SVProgressHUD dismiss];
                return nil;
            }];
        } else {
            // private and public group chats
            [[[QMCore instance].chatService deleteDialogWithID:chatDialog.ID] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                
                [SVProgressHUD dismiss];
                return nil;
            }];
        }
    }
}

- (NSMutableArray *)items {
    
    return [[QMCore instance].chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO].mutableCopy;
}

#pragma mark - Helpers

- (NSDateFormatter *)dateFormatter {
    
    static dispatch_once_t onceToken;
    static NSDateFormatter *_dateFormatter = nil;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"dd.MM.yy";
        
    });
    
    return _dateFormatter;
}

@end
