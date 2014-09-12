//
//  QMContactRequestCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"

@interface QMContactRequestCell : QMTableViewCell

@property (nonatomic, weak) id <QMUsersListCellDelegate> delegate;

@end
