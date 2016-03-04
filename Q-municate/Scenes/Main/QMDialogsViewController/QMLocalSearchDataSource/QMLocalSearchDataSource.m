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
#import "QMNoResultsCell.h"
#import "QMCore.h"
#import "QMLocalSearchDataProvider.h"

@interface QMLocalSearchDataSource ()

@end

@implementation QMLocalSearchDataSource

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && self.contacts.count > 0) {
        
        return [QMContactCell height];
    }
    else if (indexPath.section == 1 && self.dialogs.count > 0) {
        
        return [QMDialogCell height];
    }
    else {
        
        return [QMNoResultsCell height];
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0 && self.contacts.count > 0) {
        
        QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMContactCell cellIdentifier] forIndexPath:indexPath];
        
        QBUUser *user = self.contacts[indexPath.row];
        
        [cell setTitle:user.fullName placeholderID:user.ID avatarUrl:user.avatarUrl];
        
        QBContactListItem *item = [[QMCore instance].contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
        [cell setContactListItem:item];
        
        return cell;
    }
    else if (indexPath.section == 1 && self.dialogs.count > 0) {
        
        QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMDialogCell cellIdentifier] forIndexPath:indexPath];
        QBChatDialog *chatDialog = self.dialogs[indexPath.row];
        
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
    else {
        
        QMNoResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoResultsCell cellIdentifier] forIndexPath:indexPath];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            
            return self.contacts.count > 0 ? self.contacts.count : 1;
            
        case 1:
            
            return self.dialogs.count > 0 ? self.dialogs.count : 1;
            
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
