//
//  QMChatDataSource.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"
#import "QMChatViewCell.h"
#import "QMChatService.h"


@implementation QMChatDataSource
@synthesize chatHistory;


- (id)initWithHistoryArray:(NSArray *)chatDialogHistoryArray
{
	self = [super init];
	if (self) {
		self.chatHistory = [chatDialogHistoryArray mutableCopy];
	}
	return self;
}

@end
