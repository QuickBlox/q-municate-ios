//
//  QBUUser+CustomParameters.h
//  Q-municate
//
//  Created by Igor Alefirenko on 29.09.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBUUser (CustomParameters)

@property (strong, nonatomic) NSString *avatarURL;
@property (strong, nonatomic) NSString *status;
@property (assign, nonatomic) BOOL imported;

- (BOOL)customDataChanged;
- (void)syncronize;

@end
