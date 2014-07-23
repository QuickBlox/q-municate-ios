//
//  QMDialogsDataSource.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 13.07.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMDialogsDataSource : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView;
- (QBChatDialog *)dialogAtIndexPath:(NSIndexPath *)indexPath;

@end
