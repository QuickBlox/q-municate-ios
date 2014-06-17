//
//  QMGroupChatDataSource.m
//  Qmunicate
//
//  Created by Andrey on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupChatDataSource.h"
#import "QMContactList.h"
#import "QMChatService.h"

@interface QMGroupChatDataSource()

@property (strong, nonatomic) QBChatRoom *chatRoom;

@end

@implementation QMGroupChatDataSource

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog chatRoom:(QBChatRoom *)chatRoom forTableView:(UITableView *)tableView {

    NSAssert(!self.chatRoom, @"Check it");
    
    self.chatRoom = chatRoom;
    QMGroupChatDataSource *groupDataSoruce = [super initWithChatDialog:dialog forTableView:tableView];
    
    return groupDataSoruce;
}

- (void)setChatDialog:(QBChatDialog *)chatDialog {
    
    [super setChatDialog:chatDialog];
    
    if (self.history == nil) {
        
        __weak __typeof(self)weakSelf = self;
        [self loadHistory:^{
            [weakSelf reloadTableViewData];
        }];
        
    } else {
        
        [self reloadTableViewData];
    }
}

- (void)sendMessageWithText:(NSString *)text {
    
    if (text.length > 0) {
        
        QBChatMessage *chatMessage = [QBChatMessage new];
		chatMessage.text = text;
        chatMessage.senderID = [QMContactList shared].me.ID;
        
        NSAssert(!self.chatRoom, @"Check it");
        [[QMChatService shared] sendMessage:chatMessage toRoom:self.chatRoom];
    }
}

- (NSString *)messagesIdentifier {
    
    return self.chatDialog.roomJID;
}

@end
