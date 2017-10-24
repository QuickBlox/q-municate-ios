//
//  QMDataSource.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 10/10/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMDataSource : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *items;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

- (void)addItems:(NSArray *)items;
- (void)replaceItems:(NSArray *)items;
- (void)updateItems:(NSArray *)items;

@end
