//
//  QMChatInputView.h
//  Q-municate
//
//  Created by Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QMChatInputDelegate <NSObject>


@end

@interface QMChatInputView : UIToolbar

- (instancetype)initWithTableView:(UITableView *)tableView delegate:(id <QMChatInputDelegate>)delegate;

@end
