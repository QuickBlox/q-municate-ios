//
//  QBUpdateUserParameters+CustomParameters.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/22/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUpdateUserParameters (CustomParameters)

@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) BOOL imported;

@end
