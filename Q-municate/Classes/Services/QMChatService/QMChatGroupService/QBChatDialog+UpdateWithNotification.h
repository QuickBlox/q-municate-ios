//
//  QBChatDialog+UpdateWithNotification.h
//  Q-municate
//
//  Created by Igor Alefirenko on 17.10.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBChatDialog (UpdateWithNotification)

- (void)updateLastMessageInfoWithMessage:(QBChatMessage *)message isMine:(BOOL)isMine;

@end
