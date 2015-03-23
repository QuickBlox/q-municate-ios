//
//  QMChatDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 16.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMChatDataSource;
@class QMChatInputToolbar;

@protocol QMChatDataSourceDelegate <NSObject>

- (void)chatDatasource:(QMChatDataSource *)chatDatasource prepareImageURLAttachement:(NSURL *)imageUrl;
- (void)chatDatasource:(QMChatDataSource *)chatDatasource prepareImageAttachement:(UIImage *)image fromView:(UIView *)fromView;

@end

@protocol QMChatInputBarLockingProtocol <NSObject>

@optional

- (void)inputBarShouldLock;
- (void)inputBarShouldUnlock;

@end


@interface QMChatDataSource : NSObject

@property (strong, nonatomic) QBChatDialog *chatDialog;
@property (strong, nonatomic, readonly) NSMutableArray *chatSections;

@property (weak, nonatomic) id <QMChatDataSourceDelegate> delegate;
@property (weak, nonatomic) id <QMChatInputBarLockingProtocol> inputBarDelegate;

- (id)init __attribute__((unavailable("init is not a supported initializer for this class.")));

- (instancetype)initWithChatDialog:(QBChatDialog *)dialog forTableView:(UITableView *)tableView inputBarDelegate:(id <QMChatInputBarLockingProtocol>)inputBarDelegate;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)sendImage:(UIImage *)image;
- (void)sendMessage:(NSString *)text;

@end
