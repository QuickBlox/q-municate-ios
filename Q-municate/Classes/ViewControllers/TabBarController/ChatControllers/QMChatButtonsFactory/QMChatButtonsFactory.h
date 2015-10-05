//
//  QMChatButtonsFactory.h
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMChatButtonsFactory : NSObject

+ (UIButton *)emojiButton;
+ (UIButton *)groupInfo;
+ (UIButton *)audioCall;
+ (UIButton *)videoCall;

@end
