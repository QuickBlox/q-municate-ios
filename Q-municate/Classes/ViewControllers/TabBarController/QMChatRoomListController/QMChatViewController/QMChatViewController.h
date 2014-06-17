//
//  QMChatViewController.h
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMChatVC.h"

@interface QMChatViewController : QMChatVC <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *chatName;
@property (nonatomic, strong) QBUUser *opponent;  // If not p2p chat, opponent will be nil.

@property (nonatomic, strong) NSArray  *usersRecipientsIdArray;
@property (nonatomic, strong) QBChatDialog *chatDialog;
@property (nonatomic, strong) QBChatRoom *chatRoom;

/** Flag for create new chat controller. If you create new dialog - set YES. */
@property (nonatomic, assign) BOOL createdJustNow;

@end
