//
//  QMContactCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchCell.h"

@protocol QMContactCellDelegate;

@interface QMContactCell : QMSearchCell

@property (weak, nonatomic) IBOutlet id <QMContactCellDelegate> delegate;

@end

@protocol QMContactCellDelegate <NSObject>

- (void)contactCell:(QMContactCell *)contactCell onPressAddBtn:(id)sender;

@end