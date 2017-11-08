//
//  QMShareTasks.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/20/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>

@class QBChatMessage;
@class QBChatAttachment;
@class QBChatDialog;
@class QBUUser;

@interface QMShareTasks : NSObject

+ (BFTask <QBChatMessage *> *)messageForItemProvider:(NSItemProvider *)provider;
+ (BFTask <NSArray <QBChatDialog *> *> *)taskFetchAllDialogsFromDate:(NSDate *)date;
+ (BFTask <NSString*> *)dialogIDForUser:(QBUUser *)user;

@end
