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
		[self updateDialogList];
    }
    return self;
}

- (void)updateDialogList
{
	NSArray *chatLocalHistoryArray = [[NSUserDefaults standardUserDefaults] objectForKey:kChatLocalHistory];
	if (!self.roomsListArray) {
		self.roomsListArray = [NSMutableArray new];
	}
	[self.roomsListArray setArray:chatLocalHistoryArray];
}

@end
