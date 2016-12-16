//
//  IntentHandler.m
//  QMSiriExtension
//
//  Created by Vitaliy Gurkovsky on 11/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
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
