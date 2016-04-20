//
//  QMContactCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchCell.h"
#import "QMCore.h"

@interface QMSearchCell ()

@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;

@end

@implementation QMSearchCell

+ (CGFloat)height {
    
    return 50.0f;
}

#pragma mark - setters

- (void)setUser:(QBUUser *)user {
    
    if (![_user isEqual:user]) {
        
        _user = user;
        
        if (user.ID == [QMCore instance].currentProfile.userData.ID) {
            
            self.addFriendButton.hidden = YES;
            return;
        }
        
        QBContactListItem *contactListItem = [[QMCore instance].contactListService.contactListMemoryStorage contactListItemWithUserID:user.ID];
        
        BOOL isFriend = contactListItem ? YES : NO;
        self.addFriendButton.hidden = isFriend;
    }
}

#pragma mark - action

- (IBAction)didTapAddButton:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(searchCell:didTapAddButton:)]) {
        
        [self.delegate searchCell:self didTapAddButton:sender];
    }
}

@end
