//
//  QMSelectableContactCell.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactCell.h"

@interface QMSelectableContactCell : QMContactCell

@property (assign, nonatomic) BOOL checked;

- (void)setChecked:(BOOL)checked animated:(BOOL)animated;

@end
