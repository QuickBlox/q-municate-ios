//
//  QMNewMessageDataSource.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNewMessageDataSource.h"
#import "QMContactCell.h"
#import "QMNoContactsCell.h"
#import "QMCore.h"
#import "QMAlphabetizer.h"

NSString *const kQMQBUUserFullNameKeyPath = @"fullName";

@implementation QMNewMessageDataSource

#pragma mark - methods

- (QBUUser *)userAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *sectionIndexTitle = self.sectionIndexTitles[indexPath.section];
    return self.alphabetizedDictionary[sectionIndexTitle][indexPath.row];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return self.sectionIndexTitles.count > 0 ? self.sectionIndexTitles[section] : @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.sectionIndexTitles.count > 0 ? self.sectionIndexTitles.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.sectionIndexTitles.count == 0) {
        
        return 1;
    }
    
    NSString *sectionKey = self.sectionIndexTitles[section];
    NSArray *contacts = self.alphabetizedDictionary[sectionKey];
    
    return contacts.count;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.sectionIndexTitles.count > 0 ? [QMContactCell height] : [QMNoContactsCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sectionIndexTitles.count == 0) {
        
        QMNoContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMNoContactsCell cellIdentifier] forIndexPath:indexPath];
        [cell setTitle:NSLocalizedString(@"QM_STR_NO_CONTACTS", nil)];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return cell;
    }
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    QMContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMContactCell cellIdentifier] forIndexPath:indexPath];
    
    NSString *sectionKey = self.sectionIndexTitles[indexPath.section];
    NSArray *contacts = self.alphabetizedDictionary[sectionKey];
    QBUUser *user = contacts[indexPath.row];
    
    [cell setTitle:user.fullName placeholderID:user.ID avatarUrl:user.avatarUrl];
    
    QBContactListItem *item = [[QMCore instance].contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
    [cell setContactListItem:item];
    [cell setUserID:user.ID];
    
    return cell;
}

#pragma mark - setters

- (void)addItems:(NSArray *)items {
    
    [self replaceItems:items];
}

- (void)replaceItems:(NSArray *)items {
    
    self.alphabetizedDictionary = [QMAlphabetizer alphabetizedDictionaryFromObjects:items usingKeyPath:kQMQBUUserFullNameKeyPath];
    self.sectionIndexTitles = [QMAlphabetizer indexTitlesFromAlphabetizedDictionary:self.alphabetizedDictionary];
}

- (void)setItems:(NSMutableArray *)items {
    
    [self replaceItems:items.copy];
}

- (NSMutableArray *)items {
    
    return self.alphabetizedDictionary.allValues.mutableCopy;
}

#pragma mark - getters

- (BOOL)isEmpty {
    
    return self.sectionIndexTitles.count == 0;
}

@end
