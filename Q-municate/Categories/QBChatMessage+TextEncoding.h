//
//  QBChatMessage+TextEncoding.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/22/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBChatMessage (TextEncoding)

@property (strong, nonatomic, readonly) NSString *encodedText;

@end
