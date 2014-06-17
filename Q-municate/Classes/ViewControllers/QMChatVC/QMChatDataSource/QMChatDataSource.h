//
//  QMChatDataSource.h
//  Q-municate
//
//  Created by Andrey on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMChatDataSource : NSObject

@property (strong, nonatomic) QBChatDialog *chatDialog;
@property (strong, nonatomic) NSArray *history;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView;

- (void)reloadTableViewData;
- (void)loadHistory:(void(^)(void))finish;

/**
 Abstract method
 */
- (NSArray *)cachedHistory;
/**
 Abstract method
 */
- (NSString *)messagesIdentifier;
/**
 Abstract method
 */
- (void)sendMessageWithText:(NSString *)text;
/**
 Abstract method 
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 Abstract method
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
/**
 Abstract method
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
