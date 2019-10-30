//
//  QMDialogCell.h
//  Q-municate
//
//  Created by Injoit on 1/13/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMTableViewCell.h"

@interface QMDialogCell : QMTableViewCell

/**
 Unread messages badge.
 
 @remark Pass 0 to hide the badge.
 */
@property (assign, nonatomic) NSUInteger badgeNumber;

- (void)setTime:(NSString *)time;

@end
