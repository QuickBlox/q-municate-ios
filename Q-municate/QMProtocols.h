//
//  QMProtocols.h
//  Q-municate
//
//  Created by Igor Alefirenko on 18.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#ifndef Q_municate_Protocols_h
#define Q_municate_Protocols_h


@protocol QMTabBarChatDelegate <NSObject>
- (void)tabBarChatWithChatMessage:(QBChatMessage *)message chatDialog:(QBChatDialog *)dialog showTMessage:(BOOL)show;
@end


#endif
