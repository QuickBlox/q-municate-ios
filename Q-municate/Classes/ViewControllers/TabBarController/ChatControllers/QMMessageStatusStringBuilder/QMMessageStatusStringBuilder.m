//
//  QMMessageStatusStringBuilder.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/26/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMMessageStatusStringBuilder.h"
#import "QMApi.h"

static const NSUInteger kQMStatusStringNamesLimit    = 5;
static NSString *const  kQMQBUUserFullNameKeyPathKey = @"fullName";

@implementation QMMessageStatusStringBuilder

- (NSString *)statusFromMessage:(QBChatMessage *)message forDialogType:(QBChatDialogType)dialogType
{
    NSNumber* currentUserID = @([QMApi instance].currentUser.ID);
    
    NSMutableArray* readIDs = [message.readIDs mutableCopy];
    [readIDs removeObject:currentUserID];
    
    NSMutableArray* deliveredIDs = [message.deliveredIDs mutableCopy];
    [deliveredIDs removeObject:currentUserID];
    
    if (dialogType == QBChatDialogTypePrivate) {
        // Private dialogs status
        if (readIDs.count > 0) return message.isMediaMessage ? NSLocalizedString(@"QM_STR_SEEN_STATUS", nil) : NSLocalizedString(@"QM_STR_READ_STATUS", nil);
        if (deliveredIDs.count > 0) return NSLocalizedString(@"QM_STR_DELIVERED_STATUS", nil);
    } else {
        // Group dialogs status
        [deliveredIDs removeObjectsInArray:readIDs];
        NSMutableString *statusString = [NSMutableString string];
        
        if (readIDs.count > 0) {
            // read/seen status text
            if (readIDs.count > kQMStatusStringNamesLimit) {
                
                NSString *localizedString = NSLocalizedString(message.isMediaMessage ? @"QM_STR_SEEN_BY_AMOUNT_PEOPLE_STATUS" : @"QM_STR_READ_BY_AMOUNT_PEOPLE_STATUS", nil);
                [statusString appendFormat:localizedString, readIDs.count];
            } else {
                
                NSArray *users = [[QMApi instance].usersService.usersMemoryStorage usersWithIDs:readIDs];
                NSMutableArray *readNames = [users valueForKeyPath:kQMQBUUserFullNameKeyPathKey];
                
                NSString *localizedString = NSLocalizedString(message.isMediaMessage ? @"QM_STR_SEEN_BY_NAMES_STATUS" : @"QM_STR_READ_BY_NAMES_STATUS", nil);
                [statusString appendFormat:localizedString, [readNames componentsJoinedByString:@", "]];
            }
        }
        
        if (deliveredIDs.count > 0) {
            // delivered status text
            if (readIDs.count > 0) [statusString appendString:@"\n"];
            
            if (deliveredIDs.count > kQMStatusStringNamesLimit) {
                
                [statusString appendFormat:NSLocalizedString(@"QM_STR_DELIVERED_TO_AMOUNT_PEOPLE_STATUS", nil), deliveredIDs.count];
            } else {
                
                NSArray *users = [[QMApi instance].usersService.usersMemoryStorage usersWithIDs:deliveredIDs];
                NSMutableArray *deliveredNames = [users valueForKeyPath:kQMQBUUserFullNameKeyPathKey];
                
                [statusString appendFormat:NSLocalizedString(@"QM_STR_DELIVERED_TO_NAMES_STATUS", nil), [deliveredNames componentsJoinedByString:@", "]];
            }
        }
        
        if ([statusString length] > 0) return [statusString copy];
    }
    
    return NSLocalizedString(@"QM_STR_SENT_STATUS", nil);
}

@end
