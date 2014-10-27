//
//  QMContactRequestCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/08/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QMChatCell.h"

@interface QMContactRequestCell : UITableViewCell

@property (nonatomic, weak) id <QMUsersListDelegate> delegate;

@property (nonatomic, strong) QMMessage *notification;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;

@end
