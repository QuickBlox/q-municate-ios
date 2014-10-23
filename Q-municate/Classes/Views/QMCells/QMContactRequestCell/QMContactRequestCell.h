//
//  QMContactRequestCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMTableViewCell.h"


@interface QMContactRequestCell : QMTableViewCell

@property (nonatomic, weak) id <QMUsersListDelegate> delegate;

@property (strong, nonatomic) id userData;

@end
