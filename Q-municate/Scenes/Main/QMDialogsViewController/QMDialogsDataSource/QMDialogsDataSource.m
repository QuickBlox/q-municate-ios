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

@implementation QMDialogsDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMDialogCell cellIdentifier] forIndexPath:indexPath];
    QBChatDialog *chatDialog = self.items[indexPath.row];
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *recipient = [[QMCore instance].usersService.usersMemoryStorage userWithID:chatDialog.recipientID];
        
        if (recipient != nil) {
            NSParameterAssert(recipient.fullName);
            
            [cell setTitle:recipient.fullName];
            [cell setAvatarWithUrl:recipient.avatarUrl];
        }
    } else {
        
        [cell setTitle:chatDialog.name];
        [cell setAvatarWithUrl:chatDialog.photo];
    }
    
    NSString *time = [self.dateFormatter stringFromDate:chatDialog.lastMessageDate];
    [cell setTime:time];
    [cell setBody:chatDialog.lastMessageText];
    [cell setBadgeText:[NSString stringWithFormat:@"%@",
                        chatDialog.unreadMessagesCount >= 99 ? @"99+" : @(chatDialog.unreadMessagesCount)]];
    
    return cell;
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
