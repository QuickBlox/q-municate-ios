//
//  QBChatDialog+OpponentID.h
//  Q-municate
//
//  Created by Injoit on 5/25/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBChatDialog (OpponentID)

/**
 *  Opponent ID for private chat dialog.
 *
 *  @return opponent ID for private chat dialog,
 *  NSNotFound if dialog is not private or does not have any opponents
 */
- (NSUInteger)opponentID;

@end
