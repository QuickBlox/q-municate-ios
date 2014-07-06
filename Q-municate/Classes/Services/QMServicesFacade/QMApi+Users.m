//
//  QMApi+Users.m
//  Qmunicate
//
//  Created by Andrey on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"

@implementation QMApi (Users)

- (void)findAllParticipantsForChatDialog:(QBChatDialog *)chatDialog {
//    // participants, founded in friends list:
//    NSMutableArray *participants = [NSMutableArray new];
//    
//    // participants to fetch from QB Server:
//    NSMutableArray *participantsToFetchFomDB = [NSMutableArray new];
//    
//    // find participants in friends list:
//    NSArray *participantsIDs = chatDialog.occupantIDs;
//    
//    for (NSString *participantID in participantsIDs) {
//        // check for me:
//        if ([participantID integerValue] == me.ID) {
//            [participants addObject:me];
//            continue;
//        }
//        
//        QBUUser *participant = [QMContactList shared].friendsAsDictionary[participantID];
//        if (participant != nil) {
//            [participants addObject:participant];
//            continue;
//        } else {
//            [participantsToFetchFomDB addObject:participantID];
//        }
//    }
//    
//    // adding founded participants to array:
//    [_participants addObjectsFromArray:participants];
//    
//    if ([participantsToFetchFomDB count] > 0) {
//        [[QMContactList shared] retrieveUsersWithIDs:participantsToFetchFomDB usingBlock:^(NSArray *users, BOOL success, NSError *error) {
//            if (!success) {
//                return;
//            }
//            // add requested users to participants array:
//            [_participants addObjectsFromArray:users];
//            [_tableView reloadData];
//        }];
//    }
}


@end
