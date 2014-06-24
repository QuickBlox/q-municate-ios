//
//  QMPrivateChatDataSource.m
//  Qmunicate
//
//  Created by Andrey on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMPrivateChatDataSource.h"
#import "QMMessage.h"
#import "QMChatService.h"
#import "QMContactList.h"

@interface QMPrivateChatDataSource()

@property (strong, nonatomic) QBUUser *opponent;

@end

@implementation QMPrivateChatDataSource

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog opponent:(QBUUser *)opponent forTableView:(UITableView *)tableView {
    
    self.opponent = opponent;
    QMPrivateChatDataSource *privateDataSource = [super initWithChatDialog:dialog forTableView:tableView];
    
    return privateDataSource;
}

- (void)setChatDialog:(QBChatDialog *)chatDialog {

    [super setChatDialog:chatDialog];
    
    if (self.qmChatHistory == nil) {
        
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
        chatMessage.recipientID = self.opponent.ID;
        chatMessage.senderID = [QMContactList shared].me.ID;
        
        [[QMChatService shared] sendMessage:chatMessage];
    }
}

- (NSString *)messagesIdentifier {
    
    return [NSString stringWithFormat:@"%d", self.opponent.ID];
}

@end
