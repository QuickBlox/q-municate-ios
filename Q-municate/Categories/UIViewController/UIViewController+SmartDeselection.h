//
//  UIViewController+SmartDeselection.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/31/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SmartDeselection)

- (void)qm_smoothlyDeselectRowsForTableView:(UITableView *)tableView;

@end
