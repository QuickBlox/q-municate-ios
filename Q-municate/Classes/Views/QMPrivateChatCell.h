//
//  QMPrivateChatCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 27/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>

@interface QMPrivateChatCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet AsyncImageView *opponentAvatarView;
@property (weak, nonatomic) IBOutlet AsyncImageView *myAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *datetimeLabel;

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message fromUser:(QBUUser *)user;
+ (CGFloat)cellHeightForMessage:(QBChatAbstractMessage *)message;

@end
