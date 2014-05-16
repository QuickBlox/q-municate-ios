//
//  QMChatDataSource.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"
#import "QMChatViewCell.h"


@implementation QMChatDataSource
@synthesize chatHistory;

- (id)initWithOpponentDictionary:(NSDictionary *)incomingOpponentDictionary
{
    self = [super init];
    if (self) {
		NSArray *opponentKeyArray = [incomingOpponentDictionary allKeys];
		NSDictionary *opponentDictionary = incomingOpponentDictionary[opponentKeyArray[0]];
		self.chatHistory = opponentDictionary[kChatOpponentHistory];
		self.chatNameString = opponentDictionary[kChatOpponentName];
		self.chatIDString = [NSString stringWithFormat:@"%@", opponentKeyArray[0]];
    }
    return self;
}

- (void)addMessageToHistory:(QBChatMessage *)chatMessage
{
	[self saveMessageLocally:chatMessage];
}

- (void)saveMessageLocally:(QBChatMessage *)chatMessage
{
	// getting history
	NSMutableArray *chatLocalHistoryMArray;
	if (![self.chatHistory count]) {
		chatLocalHistoryMArray = [[NSUserDefaults standardUserDefaults] objectForKey:kChatLocalHistory];
	}
	if (!chatLocalHistoryMArray) {
	    chatLocalHistoryMArray = [NSMutableArray new];
	}
	if (![self.chatHistory count]) {
		for (NSDictionary *dialogItemDictionary in chatLocalHistoryMArray) {
			NSArray *opponentsArray = [dialogItemDictionary allKeys];
			if ([opponentsArray[0] isEqualToString:self.chatIDString]) {
				self.chatHistory = dialogItemDictionary[opponentsArray[0]][kChatOpponentHistory];
			}
		}
	}
	NSDictionary *messageDictionary = [self dictionaryFromMessage:chatMessage];
	[self.chatHistory addObject:messageDictionary];
	NSMutableDictionary *opponentHistoryDictionary = [NSMutableDictionary new];
	[opponentHistoryDictionary setObject:self.chatNameString forKey:kChatOpponentName];
	[opponentHistoryDictionary setObject:[self.chatHistory copy] forKey:kChatOpponentHistory];
	NSDictionary *opponentDictionary = @{self.chatIDString : [opponentHistoryDictionary copy]};

	NSMutableArray *tempArray = [NSMutableArray new];
	for (NSDictionary *dialogItemDictionary in chatLocalHistoryMArray) {
		[tempArray addObject:dialogItemDictionary];
	}
	[tempArray addObject:opponentDictionary];
	[chatLocalHistoryMArray setArray:tempArray];

	NSArray *resultArray = [chatLocalHistoryMArray copy];
	id json;
	NSError *error = nil;
	// Dictionary convertable to JSON ?
	if ([NSJSONSerialization isValidJSONObject:resultArray])
	{
//		Serialize the dictionary
		json = [NSJSONSerialization dataWithJSONObject:resultArray options:NSJSONWritingPrettyPrinted error:&error];

		// If no errors, let's view the JSON
		if (json != nil && error == nil)
		{
			NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
			NSLog(@"JSON: %@", jsonString);
			NSArray *array = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&error];
		}
	}

	[[NSUserDefaults standardUserDefaults] setObject:resultArray forKey:kChatLocalHistory];
	[[NSUserDefaults standardUserDefaults] synchronize];
	/*
	* we have to update roomList page
	* after each message post
	* to catch not only new dialogs
	* but to refresh last message as well
	* */
	[[NSNotificationCenter defaultCenter] postNotificationName:kChatRoomListUpdateNotification object:nil];
}

- (NSDictionary *)dictionaryFromMessage:(QBChatMessage *)chatMessage
{
	NSDictionary *chatMessageDictionary = @{
			@"ID" 			: chatMessage.ID,
			@"senderID" 	: [NSNumber numberWithUnsignedInteger:chatMessage.senderID],
			@"senderNick" 	: chatMessage.senderNick,
			@"recipientID" 	: [NSNumber numberWithUnsignedInteger:chatMessage.recipientID],
//			@"datetime" 	: chatMessage.datetime,
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
