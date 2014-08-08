//
//  QMDBStorage+Users.h
//  Q-municate
//
//  Created by Andrey Ivanov on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDBStorage.h"

@interface QMDBStorage (Users)

- (void)cacheUsers:(NSArray *)users finish:(QMDBFinishBlock)finish;
- (void)cachedQbUsers:(QMDBCollectionBlock)qbUsers;

@end
