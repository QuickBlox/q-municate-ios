//
//  QMInviteFriendsStaticCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 25.03.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMInviteFriendsStaticCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *badgeCounter;
@property (weak, nonatomic) IBOutlet UIImageView *activeCheckBox;
@property (weak, nonatomic) NSString *cellType;

@end
