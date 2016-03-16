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

+ (NSString *)cellIdentifier {
    
    return @"QMContactCell";
}

+ (CGFloat)height {
    
    return 50.0f;
}

#pragma mark - setters

- (void)setContactListItem:(QBContactListItem *)contactListItem {
    [super setContactListItem:contactListItem];
    
    NSString *status = nil;
    
    if (contactListItem.isOnline) {
        
        status = NSLocalizedString(@"QM_STR_ONLINE", nil);
    }
    else {
        
        QBUUser *user = [[QMCore instance].usersService.usersMemoryStorage userWithID:contactListItem.userID];
        if (user && user.lastRequestAt) {
            
            status = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"QM_STR_LAST_SEEN", nil), [QMDateUtils formattedLastSeenString:user.lastRequestAt withTimePrefix:NSLocalizedString(@"QM_STR_TIME_PREFIX", nil)]];
        }
        else {
            
            status = NSLocalizedString(@"QM_STR_OFFLINE", nil);
        }
    }
    
    [self setBody:status];
}

@end
