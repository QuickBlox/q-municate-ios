//
//  IntentHandler.m
//  QMSiriExtension
//
//  Created by Vitaliy Gurkovsky on 11/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "IntentHandler.h"

#import <Quickblox/Quickblox.h>

#import "QMMessageIntentHandler.h"

static const NSUInteger kQMApplicationID = 36125;
static NSString * const kQMAuthorizationKey = @"gOGVNO4L9cBwkPE";
static NSString * const kQMAuthorizationSecret = @"JdqsMHCjHVYkVxV";
static NSString * const kQMAccountKey = @"6Qyiz3pZfNsex1Enqnp7";

@interface IntentHandler ()

@end

@implementation IntentHandler

- (id)handlerForIntent:(INIntent *)intent {
    
    // Quickblox settings
    [QBSettings setApplicationID:kQMApplicationID];
    [QBSettings setAuthKey:kQMAuthorizationKey];
    [QBSettings setAuthSecret:kQMAuthorizationSecret];
    [QBSettings setAccountKey:kQMAccountKey];
    [QBSettings setLogLevel:QBLogLevelNothing];
    
    if ([intent isKindOfClass:[INSendMessageIntent class]]) {
        return [QMMessageIntentHandler new];
    }
    return nil;
}


@end
