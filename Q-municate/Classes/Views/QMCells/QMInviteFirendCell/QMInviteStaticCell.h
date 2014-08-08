//
//  QMInviteFriendsStaticCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 25.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMCheckBoxProtocol.h"

@interface QMInviteStaticCell : UITableViewCell

@property (assign, nonatomic) NSUInteger badgeCount;
@property (assign, nonatomic, getter = isChecked) BOOL check;
@property (weak, nonatomic) id <QMCheckBoxProtocol> delegate;

@end
