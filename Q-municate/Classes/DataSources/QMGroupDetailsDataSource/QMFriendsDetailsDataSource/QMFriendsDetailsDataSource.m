//
//  QMFriendsDetailsDataSource.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 15/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsDetailsDataSource.h"
#import "QMFriendsDetailsController.h"

@implementation QMFriendsDetailsDataSource

- (id)initWithUser:(QBUUser *)user
{
    if (self = [super init]) {
        
        if (user.phone != nil) {
            _actionList = @[QMPhoneNumberCellIdentifier, QMVideoCallCellIdentifier, QMAudioCallCellIdentifier, QMChatCellIdentifier];
        } else {
            _actionList = @[QMVideoCallCellIdentifier, QMAudioCallCellIdentifier, QMChatCellIdentifier];
        }
    }
    return self;
}

- (NSInteger)cellIdentifiersCount
{
    return [_actionList count];
}

- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)indexPath
{
    return _actionList[indexPath.row];
}

@end
