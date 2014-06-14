//
//  QMGroupDetailsCell.h
//  Qmunicate
//
//  Created by Igor Alefirenko on 14/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>

@interface QMGroupDetailsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AsyncImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

- (void)configureCellWithUser:(QBUUser *)user online:(BOOL)isOnline;

@end
