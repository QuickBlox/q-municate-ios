//
//  QMExtensionCache.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/5/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//


#import "QMServices.h"
#import <Foundation/Foundation.h>

@interface QMExtensionCache : NSObject

+ (void)setLogsEnabled:(BOOL)enabled;

@property (class, readonly) QMContactListCache *contactsCache;
@property (class, readonly) QMChatCache *chatCache;
@property (class, readonly) QMUsersCache *usersCache;

@end
