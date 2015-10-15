//
//  QMViewControllersFactory.h
//  Q-municate
//
//  Created by Igor Alefirenko on 23.09.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QMChatVC;

@interface QMViewControllersFactory : NSObject

+ (UIViewController *)chatControllerWithDialogID:(NSString *)dialogID;

+ (UIViewController *)chatControllerWithDialog:(QBChatDialog *)dialog;

@end
