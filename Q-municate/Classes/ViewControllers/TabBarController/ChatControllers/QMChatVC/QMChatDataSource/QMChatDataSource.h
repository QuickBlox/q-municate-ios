//
//  QMChatDataSource.h
//  Q-municate
//
//  Created by Andrey on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMTextMessageCell.h"
#import "QMSystemMessageCell.h"
#import "QMAttachmentMessageCell.h"

@interface QMChatDataSource : NSObject

@property (strong, nonatomic) QBChatDialog *chatDialog;
@property (strong, nonatomic, readonly) NSArray *messages;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView;

- (void)sendImage:(UIImage *)image;
- (void)sendMessage:(NSString *)message;

- (void)sendMessageWithText:(NSString *)text;

@end
