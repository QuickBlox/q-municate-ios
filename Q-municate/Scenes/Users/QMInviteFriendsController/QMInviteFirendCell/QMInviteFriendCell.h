//
//  QMInviteFriendsCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 24.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"

@class QMInviteFriendCell;

@interface QMInviteFriendCell : QMTableViewCell

@property (strong, nonatomic) id userData;
@property (strong, nonatomic) QBContactListItem *contactlistItem;

@property (assign, nonatomic, getter = isChecked) BOOL check;

@end
