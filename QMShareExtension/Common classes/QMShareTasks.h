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

@interface QMItemProviderResult : NSObject

@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) QBChatAttachment *attachment;

@end

@interface QMShareTasks : NSObject

+ (BFTask <NSArray<QMItemProviderResult *>*> *)loadItemsForItemProviders:(NSArray <NSItemProvider *> *)providers;

+ (BFTask <QMItemProviderResult *> *)loadItemsForItemProvider:(NSItemProvider *)provider;
+ (BFTask <NSArray <QBChatDialog *> *> *)taskFetchAllDialogsFromDate:(NSDate *)date;
+ (BFTask <QBChatDialog*> *)dialogForUser:(QBUUser *)user;

@end
