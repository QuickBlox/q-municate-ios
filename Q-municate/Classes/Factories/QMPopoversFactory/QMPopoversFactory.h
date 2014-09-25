//
//  QMPopoversFactory.h
//  Q-municate
//
//  Created by Igor Alefirenko on 23.09.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QMChatViewController;

@interface QMPopoversFactory : NSObject

+ (QMChatViewController *)chatControllerWithDialogID:(NSString *)dialogID;

@end
