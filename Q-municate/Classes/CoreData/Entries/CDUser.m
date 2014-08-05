#import "CDUser.h"


@interface CDUser ()

// Private interface goes here.

@end


@implementation CDUser

- (QBUUser *)toQBUUser {
    
    QBUUser *qbUser = [QBUUser user];
    
    qbUser.ID = self.id.intValue;
    qbUser.fullName = self.fullName;
    qbUser.email = self.email;
    qbUser.phone = self.phone;
    
    return qbUser;
}

- (void)updateWithQBUser:(QBUUser *)user {
    
    self.fullName = user.fullName;
    self.id = @(user.ID);
    self.email = user.email;
    self.phone = user.phone;
}


@end
