//
//  QMGroupDetailsDataSource.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 14/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMGroupDetailsDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;


- (id)initWithChatDialog:(QBChatDialog *)chatDialog tableView:(UITableView *)tableView;

@end
