//
//  QMChatVC.h
//  Q-municate
//
//  Created by Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMChatDataSource;

@interface QMChatVC : UIViewController

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) QMChatDataSource *dataSource;

@end
