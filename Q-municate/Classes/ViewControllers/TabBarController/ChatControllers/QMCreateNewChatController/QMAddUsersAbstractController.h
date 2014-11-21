//
//  QMAddUsersAbstractController.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QMAddUsersAbstractController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (strong, nonatomic) NSArray *contacts;

/** Actions */
- (IBAction)performAction:(UIButton *)sender;

@end
