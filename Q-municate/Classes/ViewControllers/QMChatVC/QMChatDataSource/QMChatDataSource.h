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
@property (strong, nonatomic) NSArray *qmChatHistory;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView;
/**
 Reload all cell in tableView
 */
- (void)reloadTableViewData;
- (void)loadHistory:(void(^)(void))finish;
- (void)sendImage:(UIImage *)image;
- (void)sendMessage:(NSString *)message;
/**
// Get Cell id at QMMessage
// */
//- (NSString *)cellIDAtQMMessage:(QMMessage *)message;
/**
 Abstract method
 */
- (NSString *)messagesIdentifier;
/**
 Abstract method
 */
- (void)sendMessageWithText:(NSString *)text;

@end
