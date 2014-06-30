//
//  QMAddUsersAbstractController.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMNewChatDataSource.h"

static CGFloat const rowHeight = 60.0;


@interface QMAddUsersAbstractController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *performButton;

/** Data Source */
@property (strong, nonatomic) QMNewChatDataSource *dataSource;

/** Updates navigation title */
- (void)updateNavTitle;

/** Override this method if needed. */
- (void)applyChangesForPerformButton;


/** Actions */
- (IBAction)performAction:(id)sender;
- (IBAction)cancelSelection:(id)sender;


/** Confrigurations */
- (NSMutableArray *)usersIDFromSelectedUsers:(NSMutableArray *)users;

@end
