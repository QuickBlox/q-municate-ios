//
//  QMChatButtonsFactory.h
//  Qmunicate
//
//  Created by Andrey Ivanov on 20.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMChatButtonsFactory : NSObject

+ (UIButton *)sendButton;
+ (UIButton *)cameraButton;
+ (UIButton *)emojiButton;
+ (UIButton *)groupInfo;
+ (UIButton *)audioCall;
+ (UIButton *)videoCall;

@end
