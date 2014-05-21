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
        
        self.groupMembersNumb.hidden = NO;
        self.groupNumbBackground.hidden = NO;
        self.groupMembersNumb.text = [@([chatDialog.occupantIDs count]) stringValue];
        
    } else{
        //Private:
        [self.avatar setImage:[UIImage imageNamed:@"upic_placeholderr"]];
        self.groupMembersNumb.hidden = YES;
        self.groupNumbBackground.hidden = YES;
    }
    
    // name:
    [self.name setText:[self chatNameForChatDialog:chatDialog]];
    
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

- (NSString *)chatNameForChatDialog:(QBChatDialog *)chatDialog
{
    if (chatDialog.type == QBChatDialogTypePrivate) {
        QBUUser *friend = nil;
        for (int i = 0; i< [chatDialog.occupantIDs count]; i++) {
            NSString *ID = chatDialog.occupantIDs[i];
            friend = [QMContactList shared].friendsAsDictionary[ID];
            if (friend != nil) {
                return friend.fullName;
            }
        }
        return @"Unknown user";
    }
    
    if (chatDialog.name != nil) {
        return chatDialog.name;
    }
    
    NSMutableString *chatName = [NSMutableString new];
    
    for (int i = 0; i< [chatDialog.occupantIDs count]; i++) {
        NSString *ID = chatDialog.occupantIDs[i];
        QBUUser *friend = [QMContactList shared].friendsAsDictionary[ID];
        if (friend != nil) {
            [chatName appendString:friend.fullName];
            [chatName appendString:@", "];
        }
    }
    NSRange stringRange = NSRangeFromString(chatName);
    [chatName deleteCharactersInRange:NSMakeRange(stringRange.location-2, 2)];
    
    return chatName;
}

@end

