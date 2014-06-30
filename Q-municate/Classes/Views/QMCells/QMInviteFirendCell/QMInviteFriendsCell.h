//
//  QMInviteFriendsCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 24.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMPerson;
@class QMImageView;

@interface QMInviteFriendsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet QMImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activeCheckbox;

@property (strong, nonatomic) QMPerson *user;

- (void)configureCellWithParams:(QMPerson *)user;
- (void)configureCellWithParamsForQBUser:(QBUUser *)user checked:(BOOL)checked;

@end
