//
//  QMDataSource.h
//  Q-municate
//
//  Created by Injoit on 10/10/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
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
