//
//  QMFriendsDetailsController.h
//  Q-municate
//
//  Created by Igor Alefirenko on 28/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

// ********** FRIENDS DETAILS IDENTIFIERS *************
static NSString *const QMPhoneNumberCellIdentifier  = @"PhoneNumberCell";
static NSString *const QMVideoCallCellIdentifier    = @"VideoCallCell";
static NSString *const QMAudioCallCellIdentifier    = @"AudioCallCell";
static NSString *const QMChatCellIdentifier         = @"ChatCell";


@interface QMFriendsDetailsController : UITableViewController

@property (strong, nonatomic) QBUUser *currentFriend;
@property (strong, nonatomic) UIImage *userPhotoImage;

@end
