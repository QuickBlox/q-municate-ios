//
//  QMContactCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactCell.h"

@interface QMContactCell ()

@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;

@end

@implementation QMContactCell

+ (NSString *)cellIdentifier {
    
    return @"QMChatCell";
}

+ (CGFloat)height {
    
    return 50.0f;
}

#pragma mark - setters

- (void)setIsUserFriend:(BOOL)isUserFriend {
    
    self.addFriendButton.hidden = isUserFriend;
}

#pragma mark - action

@end
