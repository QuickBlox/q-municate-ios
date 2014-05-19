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

- (id)initWithHistoryArray:(NSArray *)chatDialogHistoryArray;

- (void)addMessageToHistory:(QBChatMessage *)chatMessage;
@end
