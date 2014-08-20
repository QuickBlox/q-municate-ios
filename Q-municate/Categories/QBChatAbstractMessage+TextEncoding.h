//
//  QBChatAbstractMessage+TextEncoding.h
//  Q-municate
//
//  Created by Igor Alefirenko on 20.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Quickblox/Quickblox.h>

@interface QBChatAbstractMessage (TextEncoding)

@property (strong, nonatomic, readonly) NSString *encodedText;

@end
