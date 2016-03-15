//
//  QMContactCell.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/1/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSearchCell.h"

@interface QMSearchCell ()

@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

@end

@implementation QMSearchCell

+ (NSString *)cellIdentifier {
    
    return @"QMSearchCell";
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
    
    if ([self.delegate respondsToSelector:@selector(searchCell:didTapAddButton:)]) {
        
        [self.delegate searchCell:self didTapAddButton:sender];
    }
}

@end
