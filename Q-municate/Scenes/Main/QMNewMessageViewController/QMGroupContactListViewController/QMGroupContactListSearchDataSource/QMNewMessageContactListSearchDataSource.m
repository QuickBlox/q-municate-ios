//
//  QMNewMessageContactListSearchDataSource.m
//  Q-municate
//
//  Created by Injoit on 3/20/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMNewMessageContactListSearchDataSource.h"
#import "QMNoResultsCell.h"
#import "QMSelectableContactCell.h"
#import "QMCore.h"

@interface QMNewMessageContactListSearchDataSource ()

@property (strong, nonatomic, readwrite) NSMutableSet *selectedUsers;

@end

@implementation QMNewMessageContactListSearchDataSource

//MARK: - Construction

- (instancetype)initWithKeyPath:(NSString *)keyPath {
    
    self = [super initWithKeyPath:keyPath];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithSearchDataProvider:(QMSearchDataProvider *)searchDataProvider usingKeyPath:(NSString *)keyPath {
    
    self = [super initWithSearchDataProvider:searchDataProvider usingKeyPath:keyPath];
    if (self) {
        
        [self configure];
    }
    
    return self;
}

- (void)configure {
    
    self.selectedUsers = [NSMutableSet set];
}

//MARK: - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.isEmpty) {
        
        QMNoResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoResultsCell cellIdentifier] forIndexPath:indexPath];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    QMSelectableContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMSelectableContactCell cellIdentifier] forIndexPath:indexPath];
    
    QBUUser *user = [self userAtIndexPath:indexPath];
    [cell setTitle:user.fullName avatarUrl:user.avatarUrl];
    
    [cell setBody:[QMCore.instance.contactManager onlineStatusForUser:user]];
    
    cell.checked = [self.selectedUsers containsObject:user];
    
    return cell;
}

//MARK: - Methods

- (BOOL)isSelectedUserAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *selectedUser = [self userAtIndexPath:indexPath];
    return [self.selectedUsers containsObject:selectedUser];
}

- (void)setSelected:(BOOL)selected userAtIndexPath:(NSIndexPath *)indexPath {
    
    QBUUser *selectedUser = [self userAtIndexPath:indexPath];
    
    if (selected) {
        
        [self.selectedUsers addObject:selectedUser];
    }
    else {
        
        [self.selectedUsers removeObject:selectedUser];
    }
}

- (void)deselectUser:(QBUUser *)user {
    
    if ([self.selectedUsers containsObject:user]) {
        
        [self.selectedUsers removeObject:user];
    }
}

@end
