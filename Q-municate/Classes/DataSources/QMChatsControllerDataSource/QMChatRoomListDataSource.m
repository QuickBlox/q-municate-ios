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
//	id json = [[NSUserDefaults standardUserDefaults] objectForKey:kChatLocalHistory];
//	NSArray *array=nil;
//	if (json) {
//		NSError *error = nil;
//		array = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&error];
//		self.roomsListMArray = [[NSMutableArray alloc] initWithArray:array];
//	} else {
//		self.roomsListMArray = [NSMutableArray new];
//	}
}

@end
