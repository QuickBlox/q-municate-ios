//
//  QMChatHistoryCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMSearchCell.h"

@interface QMChatHistoryCell : QMSearchCell

- (void)setSubTitle:(NSString *)subTitle;
- (void)setTime:(NSString *)time;

@end
