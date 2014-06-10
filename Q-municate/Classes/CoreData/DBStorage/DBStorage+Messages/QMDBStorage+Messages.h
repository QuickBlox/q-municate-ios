//
//  QMDBStorage+Messages.h
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDBStorage.h"

@interface QMDBStorage (Messages)

- (void)cacheQBChatMessages:(NSArray *)messages finish:(QMDBFinishBlock)finish;

@end
