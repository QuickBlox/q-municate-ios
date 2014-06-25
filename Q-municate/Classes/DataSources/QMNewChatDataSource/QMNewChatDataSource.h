//
//  QMNewChatDataSource.h
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//



@interface QMNewChatDataSource : NSObject

@property (strong, nonatomic, readonly) NSArray *friendListArray;
@property (strong, nonatomic, readonly) NSMutableArray *friendsSelectedMArray;

- (id)initWithChatDialog:(QBChatDialog *)chatDialog;

- (NSInteger)friendsListCount;
- (NSInteger)friendsSelectedCount;

@end
