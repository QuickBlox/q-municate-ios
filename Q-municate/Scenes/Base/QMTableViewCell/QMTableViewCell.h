//
//  QMTableViewCell.h
//  Q-municate
//
//  Created by Injoit on 23.03.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMTableViewCell : UITableViewCell

+ (void)registerForReuseInTableView:(UITableView *)tableView;
+ (NSString *)cellIdentifier;
+ (CGFloat)height;

- (void)setTitle:(NSString *)title
       avatarUrl:(NSString *)avatarUrl;

- (void)setTitle:(NSString *)title;
- (void)setBody:(NSString *)body;

@end
