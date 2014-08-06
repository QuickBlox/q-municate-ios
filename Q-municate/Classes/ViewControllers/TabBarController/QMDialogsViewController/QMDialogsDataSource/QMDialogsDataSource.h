//
//  QMDialogsDataSource.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 13.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QMDialogsDataSourceDelegate <NSObject>

- (void)didChangeUnreadDialogCount:(NSUInteger)unreadDialogsCount;

@end

@interface QMDialogsDataSource : NSObject

@property(weak, nonatomic) id <QMDialogsDataSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView;
- (QBChatDialog *)dialogAtIndexPath:(NSIndexPath *)indexPath;
- (void)fetchUnreadDialogsCount;

@end
