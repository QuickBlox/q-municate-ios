//
//  QMLocalSearchDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMLocalSearchDataSource.h"
#import "QMDialogCell.h"
#import "QMContactCell.h"
#import "QMCore.h"

@interface QMLocalSearchDataSource ()

@end

@implementation QMLocalSearchDataSource

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMContactCell cellIdentifier] forIndexPath:indexPath];
        
        QBUUser *user = self.contacts[indexPath.row];
        
        [cell setAvatarWithUrl:user.avatarUrl];
        [cell setTitle:user.fullName];
        
        BOOL isFriend = [[QMCore instance] isFriendWithUser:user];
        [cell setIsUserFriend:isFriend];
        
        return cell;
    }
    else if (indexPath.section == 1) {
        
        QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMDialogCell cellIdentifier] forIndexPath:indexPath];
        QBChatDialog *chatDialog = self.dialogs[indexPath.row];
        
        if (chatDialog.type == QBChatDialogTypePrivate) {
            
            QBUUser *recipient = [[QMCore instance].usersService.usersMemoryStorage userWithID:chatDialog.recipientID];
            
            if (recipient != nil) {
                NSParameterAssert(recipient.fullName);
                
                [cell setTitle:recipient.fullName];
                cell.placeholderID = chatDialog.recipientID;
                [cell setAvatarWithUrl:recipient.avatarUrl];
            }
        } else {
            
            [cell setTitle:chatDialog.name];
            cell.placeholderID = chatDialog.ID.hash;
            [cell setAvatarWithUrl:chatDialog.photo];
        }
        
        NSString *time = [self.dateFormatter stringFromDate:chatDialog.updatedAt];
        [cell setTime:time];
        [cell setBody:chatDialog.lastMessageText];
        [cell setBadgeNumber:chatDialog.unreadMessagesCount];
        
        return cell;
    }
    else {
        
        NSAssert(nil, @"Unexpected section");
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            
            return self.contacts.count > 0 ? self.contacts.count : 0;
            
        case 1:
            
            return self.dialogs.count > 0 ? self.dialogs.count : 0;
            
        default:
            NSAssert(nil, @"Unexpected section");
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return @"Contacts";
            
        case 1:
            return @"Chats";
            
        default:
            NSAssert(nil, @"Unexpected section");
            return nil;
    }
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
