//
//  QMChatDataSource.h
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMChatDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *chatHistory;
@property (nonatomic, copy) NSString *chatNameString;
@property (nonatomic, copy) NSString *chatIDString;

- (id)initWithOpponentDictionary:(NSDictionary *)opponentDictionary;

- (void)addMessageToHistory:(QBChatMessage *)chatMessage;
@end
