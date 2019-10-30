//
//  NSString+QMSiriUtils.h
//  Q-municate
//
//  Created by Injoit on 1/5/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QMSiriUtils)

- (NSString *)qm_displayNameForChat;
- (NSString *)qm_toPersonCustomID;
- (NSString *)qm_toChatID;
- (BOOL)qm_isChatIdentifier;

@end
