//
//  QMTableViewDatasource.h
//  Q-municate
//
//  Created by Andrey Ivanov on 01.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMTableViewDatasource : NSObject <UITableViewDataSource>

@property (strong, nonatomic, readonly) NSMutableArray *collection;
- (void)setObjects:(NSArray *)objects;

@end
