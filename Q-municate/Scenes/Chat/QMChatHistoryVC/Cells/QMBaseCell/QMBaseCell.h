//
//  QMBaseCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMBaseCell : UITableViewCell

+ (void)registerForReuseInTableView:(UITableView *)tableView;
+ (NSString *)cellIdentifier;

@end
