//
//  QMSearchCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMBaseCell.h"

@interface QMSearchCell : QMBaseCell

- (void)setTitle:(NSString *)title;
- (void)highlightText:(NSString *)text;

@end
