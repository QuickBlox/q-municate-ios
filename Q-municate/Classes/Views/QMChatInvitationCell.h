//
//  QMChatInvitationCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 22/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMChatInvitationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message;

@end
