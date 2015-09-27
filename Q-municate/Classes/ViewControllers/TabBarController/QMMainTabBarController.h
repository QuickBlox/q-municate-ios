//
//  QMMainTabBarController.h
//  Q-municate
//
//  Created by Igor Alefirenko on 21/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QMFriendsTabDelegate <NSObject>
@optional
- (void)friendsListTabWasTapped:(UITabBarItem *)tab;
@end


@interface QMMainTabBarController : UITabBarController
<
QMTabBarChatDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate
>

@property (nonatomic, weak) id <QMTabBarChatDelegate> chatDelegate;
@property (nonatomic, weak) id <QMFriendsTabDelegate> tabDelegate;

@end
