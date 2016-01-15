//
//  QMTableViewCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 23.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMTableViewCell : UITableViewCell

@property (assign, nonatomic) NSUInteger placeholderID;

+ (void)registerForReuseInTableView:(UITableView *)tableView;
+ (NSString *)cellIdentifier;
+ (CGFloat)height;

- (void)setAvatarWithUrl:(NSString *)avatarUrl;
- (void)setTitle:(NSString *)title;
- (void)setBody:(NSString *)body;

@end
