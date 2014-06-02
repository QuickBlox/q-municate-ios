//
//  QMGroupContentCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 30/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>

@interface QMGroupContentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *datetimeLabel;
@property (weak, nonatomic) IBOutlet AsyncImageView *contentImageView;

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message fromUser:(QBUUser *)user;

@end
