//
//  QMTableDataSource.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTableDataSource.h"

@implementation QMTableDataSource

- (instancetype)initWithFriendsArray:(NSArray *)friendsArray otherUsersArray:(NSArray *)otherUsersArray
{
    if (self = [super init]) {
        _friends = friendsArray;
        _otherUsers = otherUsersArray;
    }
    return self;
}


#pragma mark - Table View Data Source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
