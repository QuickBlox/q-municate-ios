//
//  QMContactCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMContactCell.h"

@interface QMContactCell ()

@property (strong, nonatomic) QBContactListItem *contactListItem;

@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

@end

@implementation QMContactCell

+ (NSString *)cellIdentifier {
    
    return @"QMChatCell";
}

+ (CGFloat)height {
    
    return 50.0f;
}

#pragma mark - setters

- (void)setContactListItem:(QBContactListItem *)contactListItem {
    
    if (![_contactListItem isEqual:contactListItem]) {
        
        _contactListItem = contactListItem;
        
        BOOL isFriend = contactListItem ? YES : NO;
        self.addFriendButton.hidden = isFriend;
        
        if (isFriend) {
            
            BOOL isOnline = contactListItem.online;
            self.onlineCircle.hidden = !isOnline;
        }
    }
}

#pragma mark - action

@end
