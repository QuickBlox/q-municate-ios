//
//  QBChatDialog+OpponentID.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/25/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QBChatDialog+OpponentID.h"
#import "QMCore.h"

@implementation QBChatDialog (OpponentID)

- (NSUInteger)opponentID {
    
    if (self.type != QBChatDialogTypePrivate) {
        
        return NSNotFound;
    }
    
    NSParameterAssert(QMCore.instance.currentProfile.userData);
    
    for (NSNumber *userID in self.occupantIDs) {
        
        NSUInteger userIntID = userID.unsignedIntegerValue;
        if (userIntID != QMCore.instance.currentProfile.userData.ID) {
            
            return userIntID;
        }
    }
    
    return NSNotFound;
}

@end
