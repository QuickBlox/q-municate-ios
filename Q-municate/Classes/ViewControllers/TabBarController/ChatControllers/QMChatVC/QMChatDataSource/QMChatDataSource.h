//
//  QMChatDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMChatDataSourceDelegate <NSObject>

- (void)message:(QBChatMessage *)message forOtherOtherDialog:(QBChatDialog *)otherDialog;

@end

@interface QMChatDataSource : NSObject

@property (strong, nonatomic) QBChatDialog *chatDialog;
@property (strong, nonatomic, readonly) NSMutableArray *messages;
@property (weak, nonatomic) id <QMChatDataSourceDelegate> delegate;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)sendImage:(UIImage *)image;
- (void)sendMessage:(NSString *)text;

@end
