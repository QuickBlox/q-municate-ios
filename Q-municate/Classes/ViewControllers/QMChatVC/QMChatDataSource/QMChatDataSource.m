//
//  QMChatDataSource.m
//  Q-municate
//
//  Created by Andrey on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"
#import "QMChatService.h"
#import "QMDBStorage+Messages.h"

@interface QMChatDataSource() <UITableViewDataSource>

@property (weak, nonatomic) UITableView *tableView;
@property (strong, nonatomic) QBUUser *opponent;
@property (strong, nonatomic) QBChatRoom *chatRoom;
@end

@implementation QMChatDataSource

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView {
    
    self = [super init];
    
    if (self) {
        self.chatDialog = dialog;
        self.tableView = tableView;
        tableView.dataSource = self;
        
        QMChatService *chatService = [QMChatService shared];
        NSString *identifier = [self messagesIdentifier];
        
        self.history = [chatService historyWithIdentifier:identifier].mutableCopy;
    }
    
    return self;
}

- (void)reloadTableViewData {
    
    [self.tableView reloadData];
}

- (void)loadHistory:(void(^)(void))finish {
    
    void(^reloadDataAfterGetMessages) (NSArray *messages) = ^(NSArray *messages) {
        
        if (messages.count > 0) {
            
            QMChatService *chatService = [QMChatService shared];
            NSString *identifier = [self messagesIdentifier];
            
            NSAssert(identifier, @"check it");
            
            [chatService setHistory:messages forIdentifier:identifier];
        }
    };
    
    [[QMChatService shared] getMessageHistoryWithDialogID:self.chatDialog.ID withCompletion:^(NSArray *messages, BOOL success, NSError *error) {
        reloadDataAfterGetMessages(messages);
    }];
}

#pragma mark - Abstract methods

#define CHECK_OVERRIDE()\
@throw\
[NSException exceptionWithName:NSInternalInconsistencyException \
                        reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]\
                      userInfo:nil]

- (NSArray *)cachedHistory {
    
    CHECK_OVERRIDE();
    return nil;
}

- (void)sendMessageWithText:(NSString *)text {
    
    CHECK_OVERRIDE();
}

- (NSString *)messagesIdentifier {
    
    CHECK_OVERRIDE();
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CHECK_OVERRIDE();
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    CHECK_OVERRIDE();
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CHECK_OVERRIDE();
    return nil;
}

#pragma mark - Notifications

- (void)subscribeToChatNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(chatDidReceiveMessageNotification:)
                               name:kChatDidReceiveMessageNotification
                             object:nil];
    
	[notificationCenter addObserver:self
                           selector:@selector(chatRoomListUpdateNotification:)
                               name:kChatRoomListUpdateNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(chatDialogsDidLoadedNotification:)
                               name:kChatDialogsDidLoadedNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(chatRoomDidReceiveMessageNotification:)
                               name:kChatRoomDidReceiveMessageNotification
                             object:nil];
}

- (void)unsubsicribeAlltNotifications {
    
    NSNotificationCenter *notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter removeObserver:self];
}

#pragma mark -

- (void)chatDidReceiveMessageNotification:(NSNotification *)notificaiton {
    
}

- (void)chatRoomListUpdateNotification:(NSNotification *)notification {
    
}

- (void)chatDialogsDidLoadedNotification:(NSNotification *)notification {
    
}

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification {
    
}

@end
