//
//  QMChatListCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatListCell.h"
#import "QMContactList.h"

@implementation QMChatListCell


- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellWithDialog:(QBChatDialog *)chatDialog
{
    // avatar:
    if (chatDialog.type != QBChatDialogTypePrivate) {
        [self.avatar setImage:[UIImage imageNamed:@"group_placeholder"]];
        
        if (chatDialog.name != nil) {
            [self.name setText:chatDialog.name];
        } else {
            [self.name setText:@"Group Dialog"];
            
//            NSMutableString *nameString = [NSMutableString new];
//            for (QBUUser *user in [QMContactList shared].friends) {
//                for (int i = 0; i<[chatDialog.occupantIDs count]; i++) {
//                    if (<#condition#>) {
//                        <#statements#>
//                    }
//                }
//            }
        }
        
        self.groupMembersNumb.hidden = NO;
        self.groupNumbBackground.hidden = NO;
        self.groupMembersNumb.text = [@(chatDialog.unreadMessageCount) stringValue];
        
    } else{
        //Private:
        [self.avatar setImage:[UIImage imageNamed:@"upic_placeholderr"]];
        self.groupMembersNumb.hidden = YES;
        self.groupNumbBackground.hidden = YES;
        
        // name:
        [self.name setText:@"Private Chat"];
    }
    
    // unread messages:
    if (chatDialog.unreadMessageCount > 0) {
        self.unreadMsgBackground.hidden = NO;
        self.unreadMsgNumb.hidden = NO;
        self.unreadMsgNumb.text = [@(chatDialog.unreadMessageCount) stringValue];
    } else {
        self.unreadMsgBackground.hidden = YES;
        self.unreadMsgNumb.hidden = YES;
    }
    
    // last message text:
    [self.lastMessage setText:chatDialog.lastMessageText];
}

@end































