//
//  QMContactsViewController.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/16/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QMSearchProtocols.h"

@interface QMContactsViewController : UITableViewController <QMSearchProtocol>

+ (instancetype)contactsViewController;

@end
