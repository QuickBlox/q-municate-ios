//
//  QMApi+Messages.m
//  Qmunicate
//
//  Created by Andrey on 03.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMApi.h"
#import "QMMessagesService.h"

@interface QMApi()

@property (strong, nonatomic) NSMutableDictionary *messages;

@end

@implementation QMApi (Messages)

- (void)fetchMessageWithDialog:(QBChatDialog *)chatDialog complete:(void(^)(BOOL success))complete {
    
    [self.messagesService messageWithDialogID:chatDialog.ID completion:^(QBChatHistoryMessageResult *result) {
        if ([self checkResult:result]) {
            [self addMessages:result.messages withDialog:chatDialog];
        }
        complete (result.success);
    }];
}

- (void)addMessages:(NSArray *)messages withDialog:(QBChatDialog *)dialog {
    
    self.messages[dialog.ID] = messages;
}

- (NSArray *)messagesWithDialog:(QBChatDialog *)chatDialog {

    NSArray *messages = self.messages[chatDialog.ID];
    return messages;
}

- (void)sendText:(NSString *)text {

//    QM
//    self.messagesService sendChatMessage:<#(QBChatMessage *)#> toRoom:<#(QBChatRoom *)#>
}

@end
