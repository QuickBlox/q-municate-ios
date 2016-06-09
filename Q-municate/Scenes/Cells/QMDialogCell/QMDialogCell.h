//
//  QMDialogCell.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMTableViewCell.h"

@interface QMDialogCell : QMTableViewCell

- (void)setTime:(NSString *)time;
- (void)setBadgeNumber:(NSUInteger)badgeNumber;

@end
