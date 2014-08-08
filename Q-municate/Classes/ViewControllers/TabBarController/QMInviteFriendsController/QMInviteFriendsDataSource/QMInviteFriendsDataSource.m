//
//  QMInviteFriendsDataSource.m
//  Q-municate
//
//  Created by Andrey Ivanov on 07.04.14.
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

typedef NS_ENUM(NSUInteger, QMCollectionGroup) {
    
    QMStaticCellsSection = 0,
    QMFriendsListSection = 1,
    QMABFriendsToInviteSection = 3,
    QMFBFriendsToInviteSection = 4
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
const NSUInteger kQMNumberOfSection = 2;

@interface QMInviteFriendsDataSource()

<UITableViewDataSource, QMCheckBoxProtocol, QMCheckBoxStateDelegate>

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableDictionary *collections;

@property (strong, nonatomic) QMInviteStaticCell *abStaticCell;
@property (strong, nonatomic) QMInviteStaticCell *fbStaticCell;
@property (strong, nonatomic) NSArray *fbUsers;
@property (strong, nonatomic) NSArray *abUsers;

@end

@implementation QMInviteFriendsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView {
    
    self = [super init];
    if (self) {
        
        _collections = [NSMutableDictionary dictionary];
        _abUsers = @[];
        _fbUsers = @[];
        
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.checkBoxDelegate = self;
        
        NSMutableArray *staticCells = @[].mutableCopy;
        self.abStaticCell = [self.tableView dequeueReusableCellWithIdentifier:kQMStaticABCellID];
        self.abStaticCell.delegate = self;
        
        self.fbStaticCell = [self.tableView dequeueReusableCellWithIdentifier:kQMStaticFBCellID];
        self.fbStaticCell.delegate = self;
        
        [staticCells insertObject:self.abStaticCell atIndex:QMInviteFriendsSourceTypeAddressBook];
        [staticCells insertObject:self.fbStaticCell atIndex:QMInviteFriendsSourceTypeFacebook];

        [self setCollection:staticCells toSection:QMStaticCellsSection];
        [self setCollection:@[].mutableCopy toSection:QMABFriendsToInviteSection];
        [self setCollection:@[].mutableCopy toSection:QMFBFriendsToInviteSection];
    }
    
    return self;
}

#pragma mark - fetch user 

- (void)fetchFacebookFriends:(void(^)(void))completion {

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];

    __weak __typeof(self)weakSelf = self;
    [[QMApi instance] fbFriends:^(NSArray *fbFriends) {
        weakSelf.fbUsers = fbFriends;
        [SVProgressHUD dismiss];
        if (completion) completion();
    }];
}

- (void)fetchAdressbookFriends:(void(^)(void))completion {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    __weak __typeof(self)weakSelf = self;
    [QMAddressBook getAllContactsFromAddressBook:^(NSArray *contacts, BOOL success, NSError *error) {
        if (success) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.emails.@count > 0"];
            weakSelf.abUsers = [contacts filteredArrayUsingPredicate:predicate];
        }else {
            weakSelf.abUsers = @[];
        }
        [SVProgressHUD dismiss];
        if (completion) completion();
    }];
}

#pragma mark - setters

- (void)setFbUsers:(NSArray *)fbUsers {
    
    fbUsers = [self sortUsersByKey:@"first_name" users:fbUsers];
    if (![_fbUsers isEqualToArray:fbUsers]) {
        _fbUsers = fbUsers;
        [self updateDatasource];
    }
}

- (void)setAbUsers:(NSArray *)abUsers {
    
    abUsers = [self sortUsersByKey:@"fullName" users:abUsers];
    if (![_abUsers isEqualToArray:abUsers]) {
        _abUsers = abUsers;
        [self updateDatasource];
    }
}

- (NSArray *)sortUsersByKey:(NSString *)key users:(NSArray *)users {
    
    NSSortDescriptor *fullNameDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    NSArray *sortedUsers = [users sortedArrayUsingDescriptors:@[fullNameDescriptor]];
    
    return sortedUsers;
}

- (void)reloadFriendSectionWithRowAnimation:(UITableViewRowAnimation)animation {
    
    [self.tableView beginUpdates];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:QMFriendsListSection];
    [self.tableView reloadSections:indexSet withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)reloadRowPathAtIndexPath:(NSIndexPath *)indexPath withRowAnimation:(UITableViewRowAnimation)animation {
   
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    [self.tableView endUpdates];
}

- (void)updateDatasource {
    
    NSArray * friendsCollection = [self.fbUsers arrayByAddingObjectsFromArray:self.abUsers];
    [self setCollection:friendsCollection toSection:QMFriendsListSection];
    [self reloadFriendSectionWithRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kQMNumberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *collection = [self collectionAtSection:section];
    return collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMStaticCellsSection) {

        QMInviteStaticCell *staticCell = [self itemAtIndexPath:indexPath];
        NSArray *array = [self collectionAtSection:staticCell == self.fbStaticCell ? QMFBFriendsToInviteSection : QMABFriendsToInviteSection];
        staticCell.badgeCount = array.count;
        return staticCell;
    }
    
    QMInviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kQMInviteFriendCellID];

    id userData = [self itemAtIndexPath:indexPath];

    if ([userData isKindOfClass:[QBUUser class]]) {
        QBUUser *user = userData;
        cell.contactlistItem = [[QMApi instance] contactItemWithUserID:user.ID];
    }
    
    cell.userData = userData;
    cell.check = [self checkedAtIndexPath:indexPath];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - keys
/**
 Access key for collection At section
 */
- (NSString *)keyAtSection:(NSUInteger)section {
    
    NSString *sectionKey = [NSString stringWithFormat:@"section - %d", section];
    return sectionKey;
}

#pragma mark - collections

- (NSMutableArray *)collectionAtSection:(NSUInteger)section {
    
    NSString *key = [self keyAtSection:section];
    NSMutableArray *collection = self.collections[key];
    
    return collection;
}

- (void)setCollection:(NSArray *)collection toSection:(NSUInteger)section {
    
    NSString *key = [self keyAtSection:section];
    self.collections[key] = collection;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *collection = [self collectionAtSection:indexPath.section];
    id item = collection[indexPath.row];
    
    return item;
}

- (NSUInteger)sectionToInviteWihtUserData:(id)data {
    
    if ([data isKindOfClass:ABPerson.class]) {
        return QMABFriendsToInviteSection;
    } else if([data conformsToProtocol:@protocol(FBGraphUser)]) {
        return QMFBFriendsToInviteSection;
    }
    
    NSAssert(nil, @"Need update this case");
    return 0;
}

- (BOOL)checkedAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = [self itemAtIndexPath:indexPath];
    NSInteger sectionToInvite = [self sectionToInviteWihtUserData:item];
    NSArray *toInvite = [self collectionAtSection:sectionToInvite];
    BOOL checked = [toInvite containsObject:item];
    
    return checked;
}

#pragma mark - QMCheckBoxProtocol

- (void)containerView:(UIView *)containerView didChangeState:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(id)containerView];
   __weak __typeof(self)weakSelf = self;
    void (^update)(NSUInteger, NSArray*) = ^(NSUInteger collectionSection, NSArray *collection){
        
        QMInviteStaticCell *cell = (QMInviteStaticCell *)containerView;
        
        [weakSelf setCollection:cell.isChecked ? collection.mutableCopy : @[].mutableCopy toSection:collectionSection];
        [weakSelf reloadRowPathAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf reloadFriendSectionWithRowAnimation:UITableViewRowAnimationNone];
    };
    
    if (containerView == self.abStaticCell) {
        
        if (self.abUsers.count == 0) {
            [self fetchAdressbookFriends:^{
                update(QMABFriendsToInviteSection, weakSelf.abUsers);
            }];
        } else {
            update(QMABFriendsToInviteSection, self.abUsers);
        }
        
    } else if (containerView == weakSelf.fbStaticCell) {
        
        if (self.fbUsers.count == 0) {
            [self fetchFacebookFriends:^{
                update(QMFBFriendsToInviteSection, weakSelf.fbUsers);
            }];
        } else {
            update(QMFBFriendsToInviteSection, self.fbUsers);
        }
        
    } else {
        
        QMInviteFriendCell *cell = (QMInviteFriendCell *)containerView;
        
        id item = [self itemAtIndexPath:indexPath];
        
        NSUInteger section = [self sectionToInviteWihtUserData:item];
        NSMutableArray *toInvite = [self collectionAtSection:section];
        cell.isChecked ? [toInvite addObject:item] : [toInvite removeObject:item];
    
        NSUInteger row = (section == QMFBFriendsToInviteSection) ? QMInviteFriendsSourceTypeFacebook : QMInviteFriendsSourceTypeAddressBook;
        NSIndexPath *indexPathToReload = [NSIndexPath indexPathForRow:row inSection:QMStaticCellsSection];
        
        [self reloadRowPathAtIndexPath:indexPathToReload withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self checkListDidChange];
}

- (void)clearABFriendsToInvite  {
    
    [self setCollection:@[].mutableCopy toSection:QMABFriendsToInviteSection];
    [self.tableView reloadData];
    [self checkListDidChange];
}

- (void)clearFBFriendsToInvite {
    
    [self setCollection:@[].mutableCopy toSection:QMFBFriendsToInviteSection];
    [self.tableView reloadData];
    [self checkListDidChange];
}

- (void)checkListDidChange {
    
    NSArray *facebookUsersToInvite = self.collections[[self keyAtSection:QMFBFriendsToInviteSection]];
    NSArray *addressBookFriendsToInvite = self.collections [[self keyAtSection:QMABFriendsToInviteSection]];
    [self.checkBoxDelegate checkListDidChangeCount:(facebookUsersToInvite.count + addressBookFriendsToInvite.count)];
}

#pragma mark - Public methods
#pragma mark Invite Data

- (NSArray *)facebookIDsToInvite {
    
    NSMutableArray *result = [NSMutableArray array];
    NSArray *facebookUsersToInvite = [self collectionAtSection:QMFBFriendsToInviteSection];
    
    for (NSDictionary <FBGraphUser> *user in facebookUsersToInvite) {
        [result addObject:user.id];
    }
    
    return result;
}

- (NSArray *)emailsToInvite {
    
    NSMutableArray *result = [NSMutableArray array];
    
    NSArray *addressBookUsersToInvite = [self collectionAtSection:QMABFriendsToInviteSection];
    for (ABPerson *user in addressBookUsersToInvite) {
        [result addObject:user.emails.firstObject];
    }
    
    return result;
}

#pragma mark -

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMStaticCellsSection ) {
        return kQMStaticCellHeihgt;
    } else if (indexPath.section == QMFriendsListSection) {
        return kQMInviteFriendCellHeight;
    }
    
    NSAssert(nil, @"Need Update this case");
    return 0;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMStaticCellsSection) {
        QMInviteFriendsSourceType type = indexPath.row;
        switch (type) {
            case QMInviteFriendsSourceTypeAddressBook: [self fetchAdressbookFriends:nil]; break;
            case QMInviteFriendsSourceTypeFacebook:[self fetchFacebookFriends:nil]; break;
            default:NSAssert(nil, @"Need Update this case"); break;
        }
    }
}

@end