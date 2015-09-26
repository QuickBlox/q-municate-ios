//
//  QMMessageStatusStringBuilder.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/26/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMMessageStatusStringBuilder.h"
#import "QMApi.h"

@implementation QMMessageStatusStringBuilder

- (NSString *)statusFromMessage:(QBChatMessage *)message
{
    NSNumber* currentUserID = @([QMApi instance].currentUser.ID);
    
    NSMutableArray* readIDs = [message.readIDs mutableCopy];
    [readIDs removeObject:currentUserID];
    
    NSMutableArray* deliveredIDs = [message.deliveredIDs mutableCopy];
    [deliveredIDs removeObject:currentUserID];
    
    [deliveredIDs removeObjectsInArray:readIDs];
    
    if (readIDs.count > 0 || deliveredIDs.count > 0) {
        NSMutableString* statusString = [NSMutableString string];

        if (message.attachments.count > 0) {
            readIDs.count > 1 ? [statusString appendFormat:@"Seen: %lu", (unsigned long)readIDs.count] : [statusString appendFormat:@"Seen"];
        } else {
            readIDs.count > 1 ? [statusString appendFormat:@"Read: %lu", (unsigned long)readIDs.count] : [statusString appendFormat:@"Read"];
        }

        if (deliveredIDs.count > 0) {
            if (readIDs.count > 0) [statusString appendString:@"\n"];
            deliveredIDs.count > 1 ? [statusString appendFormat:@"Delivered: %lu", (unsigned long)deliveredIDs.count] : [statusString appendFormat:@"Delivered"];
        }
        
        return [statusString copy];
    }
    return @"Sent";
}

@end
