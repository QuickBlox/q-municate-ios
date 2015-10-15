//
//  QMMessageBarStyleSheetFactory.h
//  Q-municate
//
//  Created by Andrey Ivanov on 07.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPGNotification.h"

@interface QMMessageBarStyleSheetFactory : NSObject

+ (void)showMessageBarNotificationWithMessageText:(NSString *)messageText chatDialog:(QBChatDialog *)chatDialog completionBlock:(MPGNotificationButtonHandler)block;

@end
