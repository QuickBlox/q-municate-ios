//
//  QMShareDialogsTableViewController.h
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BFTask.h>

@class QBUUser;
@class QBChatDialog;


@interface QMShareDialogsTableViewController : UITableViewController

@property (nonatomic, strong) NSArray <QBUUser *> *contactsToShare;
@property (nonatomic, strong) NSArray <QBChatDialog *> *dialogsToShare;

@end
