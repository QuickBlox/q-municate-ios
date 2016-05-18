//
//  QMTableViewDataSource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMSearchDataProvider;

@interface QMTableViewDataSource : NSObject <UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *items;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)addItems:(NSArray *)items;
- (void)replaceItems:(NSArray *)items;

@end
