//
//  QMErrorsFactory.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMErrorsFactory.h"

@implementation QMErrorsFactory

+ (NSError *)errorNotLoggedInREST {
    
    return [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                               code:-1000
                           userInfo:@{NSLocalizedRecoverySuggestionErrorKey : @"You are not authorized in REST."}];
}

+ (NSError *)validationErrorWithLocalizedDescription:(NSString *)localizedDescription {
    
    return [NSError errorWithDomain:[NSBundle mainBundle].bundleIdentifier
                              code:0
                          userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
}

@end
