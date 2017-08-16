//
//  QMChatButtonsFactory.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 9/25/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMChatButtonsFactory.h"

@implementation QMChatButtonsFactory

+ (UIButton *)audioCall {
    
    UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    audioButton.frame = CGRectMake(0, 0, 30, 40);
    [audioButton setImage:[UIImage imageNamed:@"ic_audio_call"] forState:UIControlStateNormal];
    return audioButton;
}

+ (UIButton *)videoCall {
    
    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    videoButton.frame = CGRectMake(0, 0, 30, 40);
    [videoButton setImage:[UIImage imageNamed:@"ic_video_call"] forState:UIControlStateNormal];
    return videoButton;
}

@end
