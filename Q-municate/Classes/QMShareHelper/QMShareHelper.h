//
//  QMShareHelper.h
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/10/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMShareTableViewController.h"

typedef void(^QMShareHelperCompletionBlock)(NSError *error, BOOL completed);

@interface QMShareHelper : NSObject

- (void)forwardMessage:(QBChatMessage *)messageToForward
          toRecipients:(NSArray *)recipients
   withCompletionBlock:(QMShareHelperCompletionBlock)completionBlock;

- (void)cancelForwarding;

@end
