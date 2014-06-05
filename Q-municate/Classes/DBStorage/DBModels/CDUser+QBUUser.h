//
//  CDUser+QBUUser.h
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "CDUser.h"

@class QBUUser;

@interface CDUser (QBUUser)

- (QBUUser *)toQBUUser;
- (void)updateWithQBUser:(QBUUser *)user;

@end
