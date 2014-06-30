//
//  QMVideoCallController.h
//  Q-municate
//
//  Created by Igor Alefirenko on 19/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMVideoCallController : UIViewController

@property (nonatomic, assign) BOOL isOpponentCall;

- (void)setOpponent:(QBUUser *)opponent callType:(QMVideoChatType)callType;

@end
