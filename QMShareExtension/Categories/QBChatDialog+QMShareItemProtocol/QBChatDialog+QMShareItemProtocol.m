//
//  QBChatDialog+QMShareItemProtocol.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/12/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QBChatDialog+QMShareItemProtocol.h"
#import "QBUUser+QMShareItemProtocol.h"
#import "QMExtensionCache+QMShareExtension.h"
#import <objc/runtime.h>

@implementation QBChatDialog (QMShareItemProtocol)
@dynamic recipient;

- (NSString *)title {
    
    if (self.type == QBChatDialogTypePrivate) {
        
        QBUUser *recipient = [self recipient];
        
        return recipient.title;
    }
    else {
        return self.name;
    }
}

- (NSString *)imageURL {
    
    NSString *imageURL = nil;
    
    if (self.type == QBChatDialogTypePrivate) {
        imageURL = self.recipient.imageURL;
    }
    else {
        imageURL = self.photo;
    }
    
    return imageURL;
}

- (QBUUser *)recipient {
    return objc_getAssociatedObject(self,@selector(recipient));
}

- (void)setRecipient:(QBUUser *)recipient {
    objc_setAssociatedObject(self, @selector(recipient), recipient, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)opponentID {
    
    if (self.type != QBChatDialogTypePrivate) {
        return NSNotFound;
    }
    
    for (NSNumber *userID in self.occupantIDs) {
        
        NSUInteger userIntID = userID.unsignedIntegerValue;
        
        if (userIntID != QBSession.currentSession.currentUser.ID) {
            return userIntID;
        }
    }
    
    return NSNotFound;
}

- (NSDate *)updateDate {
    return self.updatedAt;
}

@end
