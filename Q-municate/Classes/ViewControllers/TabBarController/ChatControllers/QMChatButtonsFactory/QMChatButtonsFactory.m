//
//  QMChatButtonsFactory.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMChatButtonsFactory.h"
#import "UIImage+TintColor.h"


@implementation QMChatButtonsFactory

+ (UIButton *)sendButton {
    
    NSString *sendTitle = @"Send";
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    
    [sendButton setTitleColor:[UIColor colorWithWhite:0.340 alpha:1.000] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor colorWithWhite:0.604 alpha:1.000] forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    sendButton.contentMode = UIViewContentModeCenter;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = [UIColor grayColor];
    
    return sendButton;
}

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

+ (UIButton *)cameraButton {
    
    UIImage *cameraImage = [UIImage imageNamed:@"ic_camera"];
    UIImage *cameraNormal = [cameraImage tintImageWithColor:[UIColor lightGrayColor]];
    UIImage *cameraHighlighted = [cameraImage tintImageWithColor:[UIColor darkGrayColor]];
    
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [cameraButton setImage:cameraNormal forState:UIControlStateNormal];
    [cameraButton setImage:cameraHighlighted forState:UIControlStateHighlighted];
    
    cameraButton.contentMode = UIViewContentModeScaleAspectFit;
    cameraButton.backgroundColor = [UIColor clearColor];
    cameraButton.tintColor = [UIColor lightGrayColor];
    
    return cameraButton;
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
