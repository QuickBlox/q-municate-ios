//
//  QMChatRoomListDataSource.h
//  Q-municate
//
//  Created by lysenko.mykhayl on 4/7/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//



@interface QMChatRoomListDataSource : NSObject

@property (nonatomic, strong) NSMutableArray *roomsListArray;

- (void)updateDialogList;
@end
