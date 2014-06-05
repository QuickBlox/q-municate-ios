//
//  CDUser+QBUUser.m
//  Q-municate
//
//  Created by Andrey on 04.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "CDUser+QBUUser.h"

@implementation CDUser (QBUUser)

- (QBUUser *)toQBUUser {
    
    QBUUser *qbUser = [QBUUser user];
    
    qbUser.fullName = self.fullName;
    qbUser.email = self.email;
    qbUser.externalUserID = self.userId.integerValue;
    qbUser.phone = self.phone;
    qbUser.blobID = self.avatarId.integerValue;
    
    return qbUser;
}

- (void)updateWithQBUser:(QBUUser *)user {
    
    self.fullName = user.fullName;
    self.email = user.email;
    self.userId = @(user.externalUserID);
    self.phone = user.phone;
    self.avatarId = @(user.blobID);
}

@end
