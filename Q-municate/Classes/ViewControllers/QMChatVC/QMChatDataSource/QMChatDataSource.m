//
//  QMChatDataSource.m
//  Q-municate
//
//  Created by Andrey on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatDataSource.h"

@interface QMChatDataSource()

@property (strong, nonatomic) QBUUser *opponent;
@property (strong, nonatomic) QBChatDialog *chatDialog;

@end

@implementation QMChatDataSource

- (instancetype)initWithChatDialog:(QBChatDialog *)chatDialog {
    
    self = [super init];
    
    if (self) {
        self.chatDialog = chatDialog;
    }
    
    return self;
}

- (void) a{
    
    if (self.chatDialog.type != QBChatDialogTypePrivate) {
        
        // if user is joined, return
        if (![self userIsJoinedRoomForDialog:self.chatDialog]) {
            
            // enter chat room:
            [QMUtilities showActivityView];
            [[QMChatService shared] joinRoomWithRoomJID:self.chatDialog.roomJID];
        }
        self.chatRoom = [QMChatService shared].allChatRoomsAsDictionary[self.chatDialog.roomJID];
        // load history:
        self.chatHistory = [QMChatService shared].allConversations[self.chatDialog.roomJID];
        if (self.chatHistory == nil) {
            [QMUtilities showActivityView];
            [self loadHistory];
        }
        return;
    }
    
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
