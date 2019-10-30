//
//  QMExtensionCache+QMShareExtension.h
//  QMShareExtension
//
//  Created by Injoit on 10/12/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QMExtensionCache.h"
#import <Quickblox/Quickblox.h>

@interface QMExtensionCache (QMShareExtension)

+ (QBUUser *)userWithID:(NSUInteger)userID;

@end
