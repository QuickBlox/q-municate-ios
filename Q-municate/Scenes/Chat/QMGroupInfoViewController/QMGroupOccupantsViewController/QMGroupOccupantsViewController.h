//
//  QMGroupOccupantsViewController.h
//  Q-municate
//
//  Created by Injoit on 4/5/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMTableViewController.h"
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMGroupOccupantsViewController : QMTableViewController

@property (strong, nonatomic) QBChatDialog *chatDialog;

@end

NS_ASSUME_NONNULL_END
