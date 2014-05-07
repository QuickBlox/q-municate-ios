//
//  QMChatViewController.h
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *chatName;
@property (nonatomic, strong) NSArray  *usersRecipientsIdArray;

@end
