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
    
    _contactListItem = contactListItem;
    
    BOOL isFriend = contactListItem ? YES : NO;
    self.addFriendButton.hidden = isFriend;
    
    if (isFriend) {
        
        BOOL isOnline = contactListItem.online;
        self.onlineCircle.hidden = !isOnline;
    }
}

#pragma mark - action

- (IBAction)didTapAddButton:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(contactCell:didTapAddButton:)]) {
        
        [self.delegate contactCell:self didTapAddButton:sender];
    }
}

@end
