//
//  QMMessagesMemoryStorage.m
//  QMServices
//
//  Created by Andrey on 28.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMMessagesMemoryStorage.h"

@interface QMMessagesMemoryStorage()

@property (strong, nonatomic) NSMutableDictionary *datasources;

@end

@implementation QMMessagesMemoryStorage

- (instancetype)init {
    
    self = [super init];
    if (self) {
        _datasources = [NSMutableDictionary dictionary];
    }
    return self;
}

//MARK: - Setters

- (void)addMessage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    [self addMessages:@[message] forDialogID:dialogID];
}

- (void)addMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *datasource = [self dataSourceWithDialogID:dialogID];
    
    for (QBChatMessage* message in messages) {
        
        NSUInteger indexOfMessage = [datasource indexOfObject:message];
        
        if (indexOfMessage != NSNotFound) {
            
            [datasource replaceObjectAtIndex:indexOfMessage withObject:message];
            
        } else {
            
            [datasource addObject:message];
        }
    }
    
    [self sortMessagesForDialogID:dialogID];
}

- (void)updateMessage:(QBChatMessage *)message {
    NSAssert(message.dialogID, @"Message must have a dialog ID.");
    
    [self addMessage:message forDialogID:message.dialogID];
}

- (QBChatMessage *)lastMessageFromDialogID:(NSString *)dialogID {
    
    NSArray *messages = [self messagesWithDialogID:dialogID];
    
    return [messages lastObject];
}

//MARK: - replace

- (void)replaceMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *datasource = [self dataSourceWithDialogID:dialogID];
    [datasource removeAllObjects];
    [datasource addObjectsFromArray:messages];
    
    [self sortMessagesForDialogID:dialogID];
}

//MARK: - Getters

- (NSMutableOrderedSet *)dataSourceWithDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *messages = self.datasources[dialogID];
    
    if (!messages) {
        messages = [NSMutableOrderedSet orderedSet];
        self.datasources[dialogID] = messages;
    }
    
    return messages;
}

- (NSArray *)messagesWithDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *messages = self.datasources[dialogID];
    
    if ([self.delegate respondsToSelector:@selector(localMessagesForDialogWithID:)]) {
        
        NSArray *localMessages = [self.delegate localMessagesForDialogWithID:dialogID];
        
        if (localMessages.count) {
            
            if (!messages) {
                messages = [NSMutableOrderedSet orderedSet];
            }
            
            [messages addObjectsFromArray:localMessages];
        }
    }
    
    return [messages array];
}

- (void)deleteMessage:(QBChatMessage *)message {
    NSAssert(message.dialogID, @"Message must have a dialog ID.");
    
    [self deleteMessages:@[message] forDialogID:message.dialogID];
}

- (void)deleteMessages:(NSArray *)messages forDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *dataSource = [self dataSourceWithDialogID:dialogID];
    [dataSource removeObjectsInArray:messages];
}

- (void)deleteMessagesWithDialogID:(NSString *)dialogID {
    
    [self.datasources removeObjectForKey:dialogID];
}

- (BOOL)isEmptyForDialogID:(NSString *)dialogID {
    
    NSArray *messages = self.datasources[dialogID];
    
    return !messages || [messages count] == 0;
}

- (QBChatMessage *)oldestMessageForDialogID:(NSString *)dialogID {
    
    NSArray *messages = [self messagesWithDialogID:dialogID];
    
    return [messages firstObject];
}

- (void)sortMessagesForDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *datasource = [self dataSourceWithDialogID:dialogID];
    
    NSSortDescriptor *dateSentDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateSent" ascending:YES];
    NSSortDescriptor *idDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ID" ascending:YES];
    
    [datasource sortUsingDescriptors:@[dateSentDescriptor, idDescriptor]];
}

- (QBChatMessage *)messageWithID:(NSString *)messageID fromDialogID:(NSString *)dialogID {
    NSParameterAssert(messageID != nil);
    NSParameterAssert(dialogID != nil);
    
    NSArray* messages = [self messagesWithDialogID:dialogID];
    
    for (QBChatMessage* message in messages) {
        
        if ([message.ID isEqualToString:messageID]) {
            
            return message;
        }
    }
    
    return nil;
}

- (BOOL)isMessageExistent:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    NSMutableOrderedSet *messages = self.datasources[dialogID];
    
    return [messages containsObject:message];
}

//MARK: - QMMemoryStorageProtocol

- (void)free {
    
    [self.datasources removeAllObjects];
}

- (BOOL)isEmpty {
    return self.datasources.count == 0;
}

@end
