//
//  QMFriendListCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 25/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"


@interface QMFriendListCell : QMTableViewCell

@property (strong, nonatomic) NSString *searchText;

@property (weak, nonatomic) id <QMUsersListDelegate>delegate;

@end
