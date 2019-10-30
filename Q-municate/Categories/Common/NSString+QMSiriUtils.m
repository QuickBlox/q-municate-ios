//
//  NSString+QMSiriUtils.m
//  Q-municate
//
//  Created by Injoit on 1/5/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "NSString+QMSiriUtils.h"

static NSString * const kGroupChatPrefix = @"chat: ";

@implementation NSString (QMSiriUtils)

- (NSString *)qm_displayNameForChat {
    return [NSString stringWithFormat:@"%@%@",kGroupChatPrefix,self];
}

- (NSString *)qm_toPersonCustomID {
    return [NSString stringWithFormat:@"%@%@",kGroupChatPrefix,self];
}

- (NSString *)qm_toChatID {
    
    if ([self qm_isChatIdentifier]) {
        return [self substringFromIndex:kGroupChatPrefix.length];
    }
    return nil;
}

- (BOOL)qm_isChatIdentifier {
    return [self hasPrefix:kGroupChatPrefix];
}

@end
