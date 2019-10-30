//
//  QMShareHelper.h
//  Q-municate
//
//  Created by Injoit on 11/10/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMShareTableViewController.h"
#import "QMShareEtxentionOperation.h"

@interface QMShareHelper : NSObject

- (void)forwardMessage:(QBChatMessage *)messageToForward
          toRecipients:(NSArray *)recipients
   withCompletionBlock:(QMShareOperationCompletionBlock)completionBlock;

- (void)cancelForwarding;

@end
