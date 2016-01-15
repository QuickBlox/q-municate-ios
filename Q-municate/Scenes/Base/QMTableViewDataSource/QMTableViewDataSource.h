//
//  QMTableViewDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMTableViewDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *items;

- (void)addItems:(NSArray *)items;
- (void)replaceItems:(NSArray *)items;

@end
