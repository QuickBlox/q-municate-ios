//
//  IntentHandler.m
//  QMSiriExtension
//
//  Created by Injoit on 11/18/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "IntentHandler.h"
#import "QMMessageIntentHandler.h"

@interface IntentHandler ()

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {
    
    if ([intent isKindOfClass:[INSendMessageIntent class]]) {
        return [QMMessageIntentHandler new];
    }
    return nil;
}

@end
