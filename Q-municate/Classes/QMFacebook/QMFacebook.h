//
//  QMFacebook.h
//  Q-municate
//
//  Created by Andrey Ivanov on 27.02.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QMFacebook : NSObject

@property (strong, nonatomic) NSString *lastErrorMessage;

- (void)openSession:(void(^)(NSString *sessionToken))completion;
- (void)logout;

- (void)inviteFriendsWithCompletion:(void(^)(BOOL success))completion;

@end
