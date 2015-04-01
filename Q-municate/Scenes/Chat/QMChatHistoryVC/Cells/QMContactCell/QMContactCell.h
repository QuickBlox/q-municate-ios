//
//  QMContactCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchCell.h"
#import "QMAddContactProtocol.h"

@protocol QMContactCellDelegate;

@interface QMContactCell : QMSearchCell

@property (strong, nonatomic) QBUUser *contact;
@property (weak, nonatomic) id <QMAddContactProtocol> delegate;

@end

