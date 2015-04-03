//
//  QMSearchCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMTableViewCell.h"

@interface QMSearchCell : QMTableViewCell

- (void)setTitle:(NSString *)title;
- (void)setSubTitle:(NSString *)subTitle;
- (void)highlightTitle:(NSString *)title;

@end
