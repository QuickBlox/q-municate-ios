//
//  QMInviteFriendsDataSource.m
//  Q-municate
//
//  Created by Ivanov Andrey on 10/07/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMInviteFriendsDataSource.h"
#import "QMInviteFriendCell.h"
#import "QMInviteStaticCell.h"
#import "ABPerson.h"
#import "QMApi.h"
#import "QMFacebookService.h"
#import "QMAddressBook.h"
#import "SVProgressHUD.h"

typedef NS_ENUM(NSUInteger, QMInviteSecions) {
    
    QMInviteStaticSection = 0,
    QMInviteFriendsSection = 1,
    QMInviteNumberOfSection = 2
};

typedef NS_ENUM(NSUInteger, QMInviteFriendsSourceType) {
    QMInviteFriendsSourceTypeAddressBook,
    QMInviteFriendsSourceTypeFacebook
};

NSString *const kQMInviteFriendCellID = @"QMInviteFriendCell";
NSString *const kQMStaticFBCellID = @"QMStaticFBCell";
NSString *const kQMStaticABCellID = @"QMStaticABCell";

const CGFloat kQMInviteFriendCellHeight = 60;
const CGFloat kQMStaticCellHeihgt = 44;

@interface QMInviteFriendsDataSource()

<UITableViewDataSource, QMCheckBoxProtocol>

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableDictionary *collections;
@property (strong, nonatomic) QMInviteStaticCell *abStaticCell;
@property (strong, nonatomic) QMInviteStaticCell *fbStaticCell;

@end

@implementation QMInviteFriendsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    if (self) {
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.collections = [NSMutableDictionary dictionary];
        
        NSMutableArray *staticCells = [NSMutableArray array];
        self.abStaticCell = [self.tableView dequeueReusableCellWithIdentifier:kQMStaticABCellID];
        self.abStaticCell.delegate = self;
        
        self.fbStaticCell = [self.tableView dequeueReusableCellWithIdentifier:kQMStaticFBCellID];
        self.fbStaticCell.delegate = self;
        
        [staticCells insertObject:self.abStaticCell atIndex:QMInviteFriendsSourceTypeAddressBook];
        [staticCells insertObject:self.fbStaticCell atIndex:QMInviteFriendsSourceTypeFacebook];
        
        [self setCollection:staticCells toSecion:QMInviteStaticSection];
    }
    
    return self;
}

- (void)reloadFriendSection {
    
    [self.tableView beginUpdates];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex: QMInviteFriendsSection];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView endUpdates];
}

- (void)fetchFacebookFriends {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] fbFriends:^(NSArray *fbFriends) {
        
        [self setCollection:fbFriends toSecion:QMInviteFriendsSection];
        [self reloadFriendSection];
        [SVProgressHUD dismiss];
    }];
}

- (void)fetchAdressbookFriends {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [QMAddressBook getAllContactsFromAddressBook:^(NSArray *contacts, BOOL success, NSError *error) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.emails.@count > 0"];
        NSArray *emailExist = [contacts filteredArrayUsingPredicate:predicate];
        
        [self setCollection:emailExist toSecion:QMInviteFriendsSection];
        [self reloadFriendSection];
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - keys

- (NSString *)keyAtSection:(NSUInteger)section {
    
    NSString *sectionKey = [NSString stringWithFormat:@"section - %d", section];
    return sectionKey;
}

- (NSString *)chekedKey {
    
    NSString *chekedkey = @"Cheked";
    return chekedkey;
}

#pragma mark - collections

- (NSArray *)collectionAtSection:(NSUInteger)section {
    
    NSString *key = [self keyAtSection:section];
    NSArray *collection = self.collections[key];
    
    return collection;
}

- (void)setCollection:(NSArray *)collection toSecion:(NSUInteger)section {
    
    NSString *key = [self keyAtSection:section];
    self.collections[key] = collection;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *collection = [self collectionAtSection:indexPath.section];
    id item = collection[indexPath.row];
    
    return item;
}

- (BOOL)chekedAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *key = [self chekedKey];
    NSArray *collection = self.collections[key];
    BOOL cheked = [collection containsObject:indexPath];
    
    return cheked;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == QMInviteStaticSection) {
        QMInviteFriendsSourceType type = indexPath.row;
        switch (type) {
            case QMInviteFriendsSourceTypeAddressBook: [self fetchAdressbookFriends]; break;
            case QMInviteFriendsSourceTypeFacebook:[self fetchFacebookFriends]; break;
            default:NSAssert(nil, @"Update logic for this row"); break;
        }
    }
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMInviteStaticSection ) {
        return kQMStaticCellHeihgt;
    } else if (indexPath.section == QMInviteFriendsSection) {
        return kQMInviteFriendCellHeight;
    }
    
    return 0;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return QMInviteNumberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *collection = [self collectionAtSection:section];
    return collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMInviteStaticSection) {
        return [self itemAtIndexPath:indexPath];
    }
    
    QMInviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMInviteFriendCellID];
    cell.delegate = self;
    
    id item = [self itemAtIndexPath:indexPath];
    BOOL cheked = [self chekedAtIndexPath:indexPath];
    [cell setUserData:item checked:cheked];
    
    return cell;
}

#pragma mark - QMCheckBoxProtocol

- (void)containerView:(UIView *)containerView didChangeState:(id)sender {
    
    if (containerView == self.abStaticCell || containerView == self.fbStaticCell) {
        
        QMInviteStaticCell *cell = (QMInviteStaticCell *)containerView;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        cell.check ^= 1;
        
    } else {
        
        QMInviteFriendCell *cell = (QMInviteFriendCell *)containerView;
        cell.check ^= 1;
    }
}

@end
