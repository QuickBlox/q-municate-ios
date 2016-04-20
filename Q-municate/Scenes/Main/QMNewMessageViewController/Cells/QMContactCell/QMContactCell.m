//
//  QMContactCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactCell.h"
#import "QMCore.h"
#import <QMDateUtils.h>

@implementation QMContactCell

+ (CGFloat)height {
    
    return 50.0f;
}

#pragma mark - setters

- (void)setUser:(QBUUser *)user {
    [super setUser:user];
    
    QBContactListItem *contactListItem = [[QMCore instance].contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
    NSString *status = nil;
    
    if (user.ID == [QMCore instance].currentProfile.userData.ID || contactListItem.isOnline) {
        
        status = NSLocalizedString(@"QM_STR_ONLINE", nil);
    }
    else {
        
        if (user.lastRequestAt) {
            
            status = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"QM_STR_LAST_SEEN", nil), [QMDateUtils formattedLastSeenString:user.lastRequestAt withTimePrefix:NSLocalizedString(@"QM_STR_TIME_PREFIX", nil)]];
        }
        else {
            
            status = NSLocalizedString(@"QM_STR_OFFLINE", nil);
        }
    }
    
    [self setBody:status];
}

@end
