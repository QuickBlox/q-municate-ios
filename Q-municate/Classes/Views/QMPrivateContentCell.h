//
//  QMPrivateContentCell.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>

@interface QMPrivateContentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AsyncImageView *myAvatar;
@property (weak, nonatomic) IBOutlet AsyncImageView *opponentAvatar;
@property (weak, nonatomic) IBOutlet AsyncImageView *sharedImageView;
@property (weak, nonatomic) IBOutlet UILabel *datetimeLabel;

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message forUser:(QBUUser *)user isMe:(BOOL)isMe;

@end
