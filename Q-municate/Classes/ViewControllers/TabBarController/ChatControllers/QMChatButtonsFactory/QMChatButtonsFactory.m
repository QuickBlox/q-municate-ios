//
//  QMChatButtonsFactory.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMChatButtonsFactory.h"

@implementation QMChatButtonsFactory

+ (UIButton *)groupInfo {
    
    UIButton *groupInfoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [groupInfoButton setFrame:CGRectMake(0, 0, 30, 40)];
    [groupInfoButton setImage:[UIImage imageNamed:@"ic_info_top"] forState:UIControlStateNormal];
    
    return groupInfoButton;
}

+ (UIButton *)audioCall {
    
    UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [audioButton setFrame:CGRectMake(0, 0, 30, 40)];
    [audioButton setImage:[UIImage imageNamed:@"ic_phone_top"] forState:UIControlStateNormal];
    return audioButton;
}

+ (UIButton *)videoCall {
    
    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoButton setFrame:CGRectMake(0, 0, 30, 40)];
    [videoButton setImage:[UIImage imageNamed:@"ic_camera_top"] forState:UIControlStateNormal];
    return videoButton;
}

+ (UIButton *)emojiButton {
    
    UIImage *buttonImage = [UIImage imageNamed:@"ic_smile"];
    
    UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [emojiButton setImage:buttonImage forState:UIControlStateNormal];
    emojiButton.contentMode = UIViewContentModeScaleAspectFit;
    emojiButton.backgroundColor = [UIColor clearColor];
    emojiButton.tintColor = [UIColor lightGrayColor];
    
    return emojiButton;
}

@end
