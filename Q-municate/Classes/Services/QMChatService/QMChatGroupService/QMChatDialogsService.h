//
//  QMChatGroupService.h
//  Qmunicate
//
//  Created by Andrey on 02.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMServiceProtocol.h"

@interface QMChatDialogsService : NSObject <QMServiceProtocol>

- (void)fetchAllDialogs:(QBDialogsPagedResultBlock)completion;
- (void)createChatDialog:(QBChatDialog *)chatDialog completion:(QBChatDialogResultBlock)completionl;
- (void)updateChatDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest completion:(QBChatDialogResultBlock)completion;

- (NSArray *)dialogHistory;
- (void)addDialogToHistory:(QBChatDialog *)chatDialog;
- (void)addDialogs:(NSArray *)dialogs;
- (QBChatDialog *)privateDialogWithOpponentID:(NSUInteger)opponentID;
- (QBChatDialog *)chatDialogWithID:(NSString *)dialogID;
- (QBChatRoom *)chatRoomWithRoomJID:(NSString *)roomJID;

@end
