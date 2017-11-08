//
//  QMExtensionCache+QMShareExtension.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/12/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMExtensionCache.h"

@interface QMExtensionCache (QMShareExtension)

+ (QBUUser *)userWithID:(NSUInteger)userID;

@end
