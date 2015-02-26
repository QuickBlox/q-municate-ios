//
//  QMChatNotificationCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 07.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMMessage;

static NSString *const kChatNotificationCellID = @"QMContactNotificationCell";

@interface QMChatNotificationCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) QMMessage *notification;

@end
