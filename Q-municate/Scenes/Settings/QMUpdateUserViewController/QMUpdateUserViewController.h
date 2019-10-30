//
//  QMUpdateUserViewController.h
//  Q-municate
//
//  Created by Injoit on 5/6/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMExpandableTableViewController.h"


typedef NS_ENUM(NSUInteger, QMUpdateUserField) {
    
    QMUpdateUserFieldNone,
    QMUpdateUserFieldFullName,
    QMUpdateUserFieldEmail,
    QMUpdateUserFieldStatus
};

@interface QMUpdateUserViewController : QMExpandableTableViewController

@property (assign, nonatomic) QMUpdateUserField updateUserField;

@end
