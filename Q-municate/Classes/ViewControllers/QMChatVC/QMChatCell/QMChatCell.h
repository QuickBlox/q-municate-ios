//
//  QMChatCell.h
//  Q-municate
//
//  Created by Andrey on 11.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMMessage;

@interface QMChatCell : UITableViewCell

@property (weak, nonatomic) QMMessage *message;
@property (nonatomic) UIEdgeInsets contentInsets;

@end
