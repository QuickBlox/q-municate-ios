
#import "CDUsers.h"

@interface CDUsers ()

@end

@implementation CDUsers

- (QBUUser *)toQBUUser {
    
    QBUUser *qbUser = [QBUUser user];
    
    qbUser.fullName = self.fullName;
    qbUser.externalUserID = self.externalUserId.intValue;
    qbUser.email = self.email;
    qbUser.phone = self.phone;
    
    return qbUser;
}

- (void)updateWithQBUser:(QBUUser *)user {
    
    self.fullName = user.fullName;
    self.externalUserId = @(user.externalUserID);
    self.email = user.email;
    self.phone = user.phone;
}

@end
