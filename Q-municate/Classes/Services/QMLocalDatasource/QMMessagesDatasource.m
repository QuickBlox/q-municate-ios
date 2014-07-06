//
//  QMMessagesDatasource.m
//  Qmunicate
//
//  Created by Andrey on 06.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMMessagesDatasource.h"
#import "QMApi.h"

@interface QMMessagesDatasource()

@property (strong, nonatomic) NSMutableDictionary *datasource;

@end

@implementation QMMessagesDatasource

- (instancetype)initWithCurrentUser:(QBUUser *)currentUser {
    
    self = [super init];
    if (self) {
        NSString *strintID = [NSString stringWithFormat:@"%d", currentUser.ID];
        self.datasource = @{strintID: currentUser}.mutableCopy;
    }
    
    return self;
}

- (void)fetchUsersInformantionIfNeedeWithIDs:(NSArray *)ids {
    
    // participants to fetch from QB Server:
    NSMutableArray *idsToFetchFomQBServer = [NSMutableArray new];
    
    // find participants in friends list:
    
    for (NSString *userID in ids) {
  
        QBUUser *user = self.datasource[userID];
        if (!user) {
            [idsToFetchFomQBServer addObject:userID];
        }
    }

    if (idsToFetchFomQBServer.count > 0) {
        
//        [[QMApi instance] retrieveUsersWithIDs:participantsToFetchFomDB usingBlock:^(NSArray *users, BOOL success, NSError *error) {
//            if (!success) {
//                return;
//            }
//            // add requested users to participants array:
//            [_participants addObjectsFromArray:users];
//            [_tableView reloadData];
//        }];
    }
}
@end
