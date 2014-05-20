//
//  QMNewChatDataSource.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMNewChatDataSource.h"
#import "QMContactList.h"

@implementation QMNewChatDataSource

- (id)init
{
	self = [super init];
	if (self) {
		self.friendListArray = [[[QMContactList shared].friendsAsDictionary allValues] mutableCopy];
		self.friendsSelectedMArray = [[NSMutableArray alloc] init];
	}
	return self;
}

@end
