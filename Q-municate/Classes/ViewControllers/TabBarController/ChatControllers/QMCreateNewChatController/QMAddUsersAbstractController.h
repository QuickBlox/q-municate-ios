//
//  QMAddUsersAbstractController.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat const rowHeight = 60.0;


@interface QMAddUsersAbstractController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (strong, nonatomic) NSMutableArray *friends;



/** Actions */
- (IBAction)performAction:(id)sender;
- (IBAction)cancelSelection:(id)sender;

@end
