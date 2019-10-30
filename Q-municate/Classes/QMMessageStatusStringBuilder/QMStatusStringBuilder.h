//
//  QMStatusStringBuilder.h
//  Q-municate
//
//  Created by Injoit on 9/26/15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

/**
 *  Responsible for building string for message status.
 */
@interface QMStatusStringBuilder : NSObject

- (NSString *)statusFromMessage:(QBChatMessage *)message forDialogType:(QBChatDialogType)dialogType;
- (NSString *)messageTextForNotification:(QBChatMessage *)notification;

@end
