//
//  QMExtensionCache.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/5/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//


#import "QMExtensionCache.h"

static NSString *const kQMContactListCacheNameKey = @"q-municate-contacts";
static NSString *const kQMChatCacheNameKey = @"sample-cache";
static NSString *const kQMUsersCacheNameKey = @"qb-users-cache";
static NSString * const kQMAppGroupIdentifier = @"group.com.quickblox.qmunicate";

@implementation QMExtensionCache

+ (void)setLogsEnabled:(BOOL)enabled {
    enabled ?
    [QMCDRecord setLoggingLevel:QMCDRecordLoggingLevelVerbose] :
    [QMCDRecord setLoggingLevel:QMCDRecordLoggingLevelOff];
}

+ (NSString *)appGroupIdentifier {
    return kQMAppGroupIdentifier;
}

+ (QMContactListCache *)contactsCache {
    
    static QMContactListCache *contactsCache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [QMContactListCache setupDBWithStoreNamed:kQMContactListCacheNameKey
                       applicationGroupIdentifier:[self appGroupIdentifier]];
        contactsCache = QMContactListCache.instance;
    });
    
    return contactsCache;
}

+ (QMChatCache *)chatCache {
    
    static QMChatCache *chatCache = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [QMChatCache setupDBWithStoreNamed:kQMChatCacheNameKey
                applicationGroupIdentifier:[self appGroupIdentifier]];
        chatCache = QMChatCache.instance;
    });
    
    return chatCache;
}

+ (QMUsersCache *)usersCache {
    
    static QMUsersCache *usersCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [QMUsersCache setupDBWithStoreNamed:kQMUsersCacheNameKey
                 applicationGroupIdentifier:[self appGroupIdentifier]];
        usersCache =  QMUsersCache.instance;
    });
    
    return usersCache;
}

@end
