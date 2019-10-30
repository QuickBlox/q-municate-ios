//
//  QMChatNotificationCell.h
//  QMChatViewController
//
//  Created by Injoit on 03.06.15.
//  Copyright © 2015 QuickBlox. All rights reserved.
//

#import "QMChatCell.h"

/**
 *  Chat message cell typically used for system notifications.
 */
@interface QMChatNotificationCell : QMChatCell

@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;

@end
