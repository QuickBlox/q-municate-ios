//
//  QMExtensionCache+QMShareExtension.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/12/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMExtensionCache+QMShareExtension.h"

@implementation QMExtensionCache (QMShareExtension)

+ (QBUUser *)userWithID:(NSUInteger)userID {
    
    __block QBUUser *user = nil;
    [[self.usersCache allUsers] enumerateObjectsUsingBlock:^(QBUUser * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull stop) {
        if (obj.ID == userID) {
            user = obj;
            *stop = YES;
        }
    }];
    
    return user;
}

@end
