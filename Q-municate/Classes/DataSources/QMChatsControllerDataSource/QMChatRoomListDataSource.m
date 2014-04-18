//
//  QMChatRoomListDataSource.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/7/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatRoomListDataSource.h"

@implementation QMChatRoomListDataSource

- (id)init
{
    self = [super init];
    if (self) {
        self.roomsListArray = @[
                @{@"name":@"Stieve Bosh, Luke McLeight, Jessika Alba",
                @"last_msg":@"I love u Jessicaaaa!",
                @"group_count":@"3",
                @"unread_count":@"7"
        },

                @{@"name":@"Colin Pharrel, Stieve Querk, Jack Default",
                        @"last_msg":@"What's the next show?",
                        @"group_count":@"5",
                        @"unread_count":@"2"
                }];
    }
    return self;
}

@end
