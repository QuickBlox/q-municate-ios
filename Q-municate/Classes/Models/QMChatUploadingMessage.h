//
//  QMChatUploadingMessage.h
//  Q-municate
//
//  Created by Igor Alefirenko on 29/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QMChatUploadingMessage : QBChatMessage

@property (strong) id content;
@property (strong, nonatomic) NSString * roomJID;

@end
