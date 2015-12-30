//
//  QMMessageStatusStringBuilder.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/26/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Responsible for building string for message status.
 */
@interface QMMessageStatusStringBuilder : NSObject

- (NSString *)statusFromMessage:(QBChatMessage *)message forDialogType:(QBChatDialogType)dialogType;

@end
