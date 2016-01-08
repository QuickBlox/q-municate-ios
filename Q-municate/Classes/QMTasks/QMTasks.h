//
//  QMTasks.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  This class provides Q-municate tasks.
 */
@interface QMTasks : NSObject

+ (BFTask QB_GENERIC(QBUUser *) *)taskUpdateCurrentUser:(QBUpdateUserParameters *)updateParameters;

@end
