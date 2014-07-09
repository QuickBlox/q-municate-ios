//
//  QMGroupDetailsDataSource.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 14/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsDataSource.h"
#import "QMGroupDetailsCell.h"
#import "QMUsersService.h"
#import "QMApi.h"

@interface QMGroupDetailsDataSource ()

@property (nonatomic, strong) NSArray *onlineParticipantsIDs;

@end

@implementation QMGroupDetailsDataSource


- (id)initWithChatDialog:(QBChatDialog *)chatDialog tableView:(UITableView *)tableView {
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineParticipantsListLoaded:) name:kChatRoomDidChangeOnlineUsersListNotification object:nil];
        _tableView = tableView;
        _participants = [NSMutableArray new];
        
        #warning check it
        //        [self findAllParticipantsForChatDialog:chatDialog];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)participantsCount {
    return [_participants count];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
