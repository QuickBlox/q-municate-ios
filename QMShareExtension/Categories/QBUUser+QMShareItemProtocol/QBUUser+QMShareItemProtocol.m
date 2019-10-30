//
//  QBUUser+QMShareItemProtocol.m
//  QMShareExtension
//
//  Created by Injoit on 10/12/17.
//  Copyright © 2017 QuickBlox. All rights reserved.
//

#import "QBUUser+QMShareItemProtocol.h"
#import "QBUUser+CustomData.h"

@implementation QBUUser (QMShareItemProtocol)

- (NSString *)imageURL {
    return self.avatarUrl;
}

- (NSString *)title {
    
    if (self.fullName != nil) {
        return self.fullName;
    }
    else {
        return @"Unknown user";
    }
}

@end
