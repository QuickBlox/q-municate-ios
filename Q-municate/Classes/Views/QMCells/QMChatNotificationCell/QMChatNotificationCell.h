//
//  QMChatNotificationCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 07.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMChatNotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) QBChatMessage *notification;

@end
