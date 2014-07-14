//
//  QMInviteFriendsCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 24.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMUserCell.h"
#import "QMCheckBoxProtocol.h"

@class QMInviteFriendCell;

@interface QMInviteFriendCell : QMUserCell

@property (strong, nonatomic) id userData;
@property (assign, nonatomic, getter = isChecked) BOOL check;
@property (weak, nonatomic) id <QMCheckBoxProtocol> delegate;

@end
