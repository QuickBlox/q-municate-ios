//
//  QMExtensionCache.h
//  QMShareExtension
//
//  Created by Injoit on 10/5/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//


//#import "QMServices.h"
#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>
#import "QMContactListCache.h"
#import "QMChatCache.h"
#import "QMUsersCache.h"

@interface QMExtensionCache : NSObject

+ (void)setLogsEnabled:(BOOL)enabled;

@property (class, readonly) QMContactListCache *contactsCache;
@property (class, readonly) QMChatCache *chatCache;
@property (class, readonly) QMUsersCache *usersCache;

@end
