//
//  QMDialogsSearchDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 2/29/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDialogsSearchDataSource.h"
#import "QMDialogCell.h"
#import "QMNoResultsCell.h"
#import "QMCore.h"
#import <QMDateUtils.h>
#import "QBChatDialog+OpponentID.h"

@implementation QMDialogsSearchDataSource

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.items[indexPath.row];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return self.items.count > 0 ? [QMDialogCell height] : [QMNoResultsCell height];
}

//MARK: - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (self.items.count == 0) {
        
        QMNoResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoResultsCell cellIdentifier] forIndexPath:indexPath];
        return cell;
    }
    
    QMDialogCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMDialogCell cellIdentifier] forIndexPath:indexPath];
    QBChatDialog *chatDialog = self.items[indexPath.row];
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *recipient = [QMCore.instance.usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
        
        if (recipient != nil) {
            NSParameterAssert(recipient.fullName);
            
            [cell setTitle:recipient.fullName avatarUrl:recipient.avatarUrl];
        }
    }
    else {
        
        [cell setTitle:chatDialog.name avatarUrl:chatDialog.photo];
    }
    
    NSString *time = [QMDateUtils formattedShortDateString:chatDialog.updatedAt];
    [cell setTime:time];
    [cell setBody:chatDialog.lastMessageText];
    [cell setBadgeNumber:chatDialog.unreadMessagesCount];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)__unused tableView numberOfRowsInSection:(NSInteger)__unused section {
    
    return self.items.count > 0 ? self.items.count : 1;
}

@end
