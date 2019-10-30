//
//  QBUpdateUserParameters+CustomData.h
//  Q-municate
//
//  Created by Injoit on 9/28/15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBUpdateUserParameters (CustomData)

@property (copy, nonatomic) NSString *avatarUrl;
@property (copy, nonatomic) NSString *status;
@property (assign, nonatomic) BOOL isImport;

@end
