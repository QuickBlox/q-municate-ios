//
//  QMContactCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 03.04.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchCell.h"
#import "QMAddContactProtocol.h"

@interface QMContactCell : QMSearchCell

@property (weak, nonatomic) id <QMAddContactProtocol> delegate;

@property (strong, nonatomic) QBUUser *contact;

@end
