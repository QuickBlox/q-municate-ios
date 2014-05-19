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

- (void)addMessageToHistory:(QBChatMessage *)chatMessage
{
	[self saveMessageLocally:chatMessage];
}

- (void)saveMessageLocally:(QBChatMessage *)chatMessage
{
	[[QMChatService shared] postMessage:chatMessage withRoom:[QMChatService shared].chatRoom withCompletion:^(QBChatDialog *dialog, NSError *error) {
		if (!error) {
		    //
		}
	}];

//	// getting history
//	NSMutableArray *chatLocalHistoryMArray;
//	id json = [[NSUserDefaults standardUserDefaults] objectForKey:kChatLocalHistory];
//	if (json) {
//		NSError *error = nil;
//		NSArray *array = nil;
//		array = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&error];
//		chatLocalHistoryMArray = [[NSMutableArray alloc] initWithArray:array];
//	} else {
//		chatLocalHistoryMArray = [NSMutableArray new];
//	}
//	for (NSDictionary *dialogItemDictionary in chatLocalHistoryMArray) {
//		NSArray *opponentsArray = [dialogItemDictionary allKeys];
//		if ([opponentsArray[0] isEqualToString:self.chatIDString]) {
//			self.chatHistory = [dialogItemDictionary[opponentsArray[0]][kChatOpponentHistory] mutableCopy];
//			break;
//		}
//	}
//	NSDictionary *messageDictionary = [self dictionaryFromMessage:chatMessage];
//	[self.chatHistory addObject:messageDictionary];
//	NSMutableDictionary *opponentHistoryDictionary = [NSMutableDictionary new];
//	[opponentHistoryDictionary setObject:self.chatNameString forKey:kChatOpponentName];
//	[opponentHistoryDictionary setObject:[self.chatHistory copy] forKey:kChatOpponentHistory];
//	NSDictionary *opponentDictionary = @{self.chatIDString : [opponentHistoryDictionary copy]};
//
//	NSMutableArray *tempArray = [NSMutableArray new];
//	for (NSDictionary *dialogItemDictionary in chatLocalHistoryMArray) {
//		NSArray *opponentsArray = [dialogItemDictionary allKeys];
//		if ([opponentsArray[0] isEqualToString:self.chatIDString]) {
//			[tempArray addObject:opponentDictionary];
//			continue;
//		}
//		[tempArray addObject:dialogItemDictionary];
//	}
//	[chatLocalHistoryMArray setArray:tempArray];
//
//	NSArray *resultArray = [chatLocalHistoryMArray copy];
//	id jsonToSave;
//	NSError *error = nil;
//	if ([NSJSONSerialization isValidJSONObject:resultArray]) {
//		jsonToSave = [NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:&error];
//	}
//
//	[[NSUserDefaults standardUserDefaults] setObject:jsonToSave forKey:kChatLocalHistory];
//	[[NSUserDefaults standardUserDefaults] synchronize];
//	/*
//	* we have to update roomList page
//	* after each message post
//	* to catch not only new dialogs
//	* but to refresh last message as well
//	* */
//	[[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomListUpdateNotification object:nil];
}

- (NSDictionary *)dictionaryFromMessage:(QBChatMessage *)chatMessage
{
	NSString *timestampString = [NSString stringWithFormat:@"%lu", (unsigned long) [chatMessage.datetime timeIntervalSince1970]];
	NSDictionary *chatMessageDictionary = @{
			@"ID" 			: chatMessage.ID,
			@"senderID" 	: [NSNumber numberWithUnsignedInteger:chatMessage.senderID],
			@"senderNick" 	: chatMessage.senderNick,
			@"recipientID" 	: [NSNumber numberWithUnsignedInteger:chatMessage.recipientID],
			@"datetime" 	: timestampString,
			@"delayed" 		: [NSNumber numberWithBool:chatMessage.delayed],
			@"text" 		: chatMessage.text
	};
	return chatMessageDictionary;
}

- (QBChatMessage *)chatMessageFromDictionary:(NSDictionary *)chatMessageDictionary
{
	QBChatMessage *chatMessage = [QBChatMessage new];
	chatMessage.ID = chatMessageDictionary[@"ID"];
	chatMessage.senderID = [chatMessageDictionary[@"senderID"] unsignedIntegerValue];
	chatMessage.senderNick = chatMessageDictionary[@"senderNick"];
	chatMessage.recipientID = [chatMessageDictionary[@"recipientID"] unsignedIntegerValue];
	chatMessage.datetime = chatMessageDictionary[@"datetime"];
	chatMessage.delayed = [chatMessageDictionary[@"delayed"] boolValue];
	chatMessage.text = chatMessageDictionary[@"text"];

	return chatMessage;
}

@end
