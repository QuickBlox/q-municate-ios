//
//  QMDialogsDataSource.h
//  Q-municate
//
//  Created by Injoit on 1/13/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>
#import "QMTableViewDataSource.h"

@class QMDialogsDataSource;

@protocol QMDialogsDataSourceDelegate <NSObject>

- (void)dialogsDataSource:(QMDialogsDataSource *)dialogsDataSource commitDeleteDialog:(QBChatDialog *)chatDialog;

@end

@interface QMDialogsDataSource : QMTableViewDataSource

@property (weak, nonatomic) id<QMDialogsDataSourceDelegate> delegate;

@end
