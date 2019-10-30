//
//  QMDialogsDataSource.m
//  Q-municate
//
//  Created by Injoit on 1/13/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMDialogsDataSource.h"
#import "QMDialogCell.h"
#import "QMCore.h"
#import "QBChatDialog+OpponentID.h"
#import "QMDateUtils.h"

@implementation QMDialogsDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [QMDialogCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * identifier = @"QMDialogCell";
    
    QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    QBChatDialog *chatDialog = self.items[indexPath.row];
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *recipient = [QMCore.instance.usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
        
        if (recipient.fullName != nil) {
            
            [cell setTitle:recipient.fullName avatarUrl:recipient.avatarUrl];
        }
        else {
            
            [cell setTitle:NSLocalizedString(@"QM_STR_UNKNOWN_USER", nil) avatarUrl:nil];
        }
    } else {
        
        [cell setTitle:chatDialog.name avatarUrl:chatDialog.photo];
    }
    
    // there was a time when updated at didn't exist
    // in order to support old dialogs, showing their date as last message date
    NSDate *date = chatDialog.updatedAt ?: chatDialog.lastMessageDate;
    
    NSString *time = [QMDateUtils formattedShortDateString:date];
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
        
        QBChatDialog *chatDialog = self.items[indexPath.row];
        [self.delegate dialogsDataSource:self commitDeleteDialog:chatDialog];
    }
}

- (NSMutableArray *)items {
    
    return [[QMCore.instance.chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO] mutableCopy];
}

@end
