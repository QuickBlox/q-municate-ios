//
//  QMInviteFriendsCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 24.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCheckBoxProtocol.h"
#import "QMTableViewCell.h"

@class QMInviteFriendCell;

@interface QMInviteFriendCell : QMTableViewCell

@property (assign, nonatomic, getter = isChecked) BOOL check;
@property (weak, nonatomic) id <QMCheckBoxProtocol> delegate;

@end
