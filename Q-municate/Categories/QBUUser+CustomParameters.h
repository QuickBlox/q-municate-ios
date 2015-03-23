//
//  QBUUser+CustomParameters.h
//  Q-municate
//
//  Created by Igor Alefirenko on 29.09.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUUser (CustomParameters)

@property (nonatomic, copy) NSString *avatarURL;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) BOOL imported;

@end
