//
//  QMGroupDetailsDataSource.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 14/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsDataSource.h"
#import "QMUserCell.h"
#import "QMApi.h"

@interface QMGroupDetailsDataSource ()

@property (nonatomic, strong) NSArray *onlineParticipantsIDs;

@end

@implementation QMGroupDetailsDataSource

- (id)initWithChatDialog:(QBChatDialog *)chatDialog tableView:(UITableView *)tableView {

    if (self = [super init]) {
        
        _tableView = tableView;
        _participants = [NSMutableArray new];
        self.tableView.dataSource = self;
    }
    
    return self;
}

- (NSInteger)participantsCount {
    return [_participants count];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self participantsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMUserCell *cell = [tableView dequeueReusableCellWithIdentifier:kGroupDetailsCellIdentifier];
    
    QBUUser *user = self.participants[indexPath.row];
    cell.userData = user;
    
    return cell;
}


@end
