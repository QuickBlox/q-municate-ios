//
//  QMGroupDetailsDataSource.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 14/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsDataSource.h"
#import "QMGroupDetailsCell.h"
#import "QMContactList.h"

@interface QMGroupDetailsDataSource ()

@property (nonatomic, strong) NSArray *onlineParticipantsIDs;

@end

@implementation QMGroupDetailsDataSource


- (id)initWithChatDialog:(QBChatDialog *)chatDialog tableView:(UITableView *)tableView
{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineParticipantsListLoaded:) name:kChatRoomDidChangeOnlineUsersList object:nil];
        _tableView = tableView;
        _participants = [NSMutableArray new];
        [self findAllParticipantsForChatDialog:chatDialog];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)participantsCount
{
    return [_participants count];
}

- (void)findAllParticipantsForChatDialog:(QBChatDialog *)chatDialog
{
    QBUUser *me = [QMContactList shared].me;
    
    // participants, founded in friends list:
    NSMutableArray *participants = [NSMutableArray new];
    
    // participants to fetch from QB Server:
    NSMutableArray *participantsToFetchFomDB = [NSMutableArray new];
    
    // find participants in friends list:
    NSArray *participantsIDs = chatDialog.occupantIDs;
    for (NSString *participantID in participantsIDs) {
        // check for me:
        if ([participantID integerValue] == me.ID) {
            [participants addObject:me];
            continue;
        }
        
        QBUUser *participant = [QMContactList shared].friendsAsDictionary[participantID];
        if (participant != nil) {
            [participants addObject:participant];
            continue;
        } else {
            [participantsToFetchFomDB addObject:participantID];
        }
    }
    
    // adding founded participants to array:
    [_participants addObjectsFromArray:participants];
    [_tableView reloadData];
    
    if ([participantsToFetchFomDB count] > 0) {
        [[QMContactList shared] retrieveUsersWithIDs:participantsToFetchFomDB usingBlock:^(NSArray *users, BOOL success, NSError *error) {
            if (!success) {
                return;
            }
            // add requested users to participants array:
            [_participants addObjectsFromArray:users];
            [_tableView reloadData];
        }];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self participantsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QMGroupDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:kGroupDetailsCellIdentifier];
    
    QBUUser *user = self.participants[indexPath.row];
    
    BOOL userOnlineStatus = [self isUserOnline:user fromOnlineUsersList:self.onlineParticipantsIDs];
    
    [cell configureCellWithUser:user online:userOnlineStatus];
    
    return cell;
}


#pragma mark - Notifications

- (void)onlineParticipantsListLoaded:(NSNotification *)notification
{
    NSArray *onlineStatuses = notification.userInfo[@"online_users"];
    self.onlineParticipantsIDs = onlineStatuses;
    
    [self.tableView reloadData];
}


#pragma mark - Misc

- (BOOL)isUserOnline:(QBUUser *)user fromOnlineUsersList:(NSArray *)onlineUsersList
{
    for (NSNumber *ID in onlineUsersList) {
        if ([ID integerValue] == user.ID) {
            return YES;
        }
    }
    return NO;
}

@end
