//
//  QBUpdateUserParameters+CustomData.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/28/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBUpdateUserParameters (CustomData)

@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *status;
@property (assign, nonatomic) BOOL isImport;

@end
