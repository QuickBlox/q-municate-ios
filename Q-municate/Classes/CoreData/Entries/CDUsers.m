
#import "CDUsers.h"

@interface CDUsers ()

@end

@implementation CDUsers

- (QBUUser *)toQBUUser {
    
    QBUUser *qbUser = [QBUUser user];
    
    qbUser.fullName = self.fullName;
    qbUser.externalUserID = self.externalUserId.intValue;
    qbUser.email = self.email;
//    qbUser.externalUserID = self.userId.integerValue;
//    qbUser.phone = self.phone;
//    qbUser.blobID = self.avatarId.integerValue;
    
    return qbUser;
}

- (void)updateWithQBUser:(QBUUser *)user {
    
    self.fullName = user.fullName;
    self.externalUserId = @(user.externalUserID);
    self.email = user.email;
//    self.phone = user.phone;
//    self.avatarId = @(user.blobID);
}

@end
