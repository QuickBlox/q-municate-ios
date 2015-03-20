//
//  QMChatHistoryCell.h
//  Q-municate
//
//  Created by Andrey Ivanov on 11.03.15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMChatHistoryCell : UITableViewCell

- (void)setTitle:(NSString *)title;
- (void)setSubTitle:(NSString *)subTitle;
- (void)setTime:(NSString *)time;
- (void)setImageWithUrl:(NSString *)url;
- (void)highlightText:(NSString *)text;

@end
