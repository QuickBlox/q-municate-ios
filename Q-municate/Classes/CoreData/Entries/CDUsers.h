#import "_CDUsers.h"

@interface CDUsers : _CDUsers {}

- (QBUUser *)toQBUUser;
- (void)updateWithQBUser:(QBUUser *)user;

@end
