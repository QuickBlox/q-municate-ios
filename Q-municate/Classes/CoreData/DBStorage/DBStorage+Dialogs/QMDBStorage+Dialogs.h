//
//  QMDBStorage+Dialogs.h
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDBStorage.h"

@interface QMDBStorage (Dialogs)

- (void)cachedQBChatDialogs:(QMDBCollectionBlock)qbDialogs;
- (void)cacheQBDialogs:(NSArray *)dialogs finish:(QMDBFinishBlock)finish;

@end
