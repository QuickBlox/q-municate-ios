//
//  QMChatListCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatListCell.h"
#import "QMContactList.h"
#import "UIImageView+ImageWithBlobID.h"

@implementation QMChatListCell


- (void)awakeFromNib
{
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2;
    self.avatar.layer.borderWidth = 2.0f;
    self.avatar.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
    self.avatar.layer.masksToBounds = YES;
    self.avatar.crossfadeDuration = 0.0f;
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
        
        
        QBUUser *friend = [[QMContactList shared] searchFriendFromChatDialog:chatDialog];
        // load image:
        if (friend.website != nil) {
            [self.avatar setImageURL:[NSURL URLWithString:friend.website]];
        } else if (friend.blobID > 0) {
            [self.avatar loadImageWithBlobID:friend.blobID];
        }
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
    if (chatDialog.lastMessageText != nil) {
        [self.lastMessage setText:chatDialog.lastMessageText];
        return;
    } else if (chatDialog.lastMessageDate > 0) {
        [self.lastMessage setText:@"Attachment"];
        return;
    }
    [self.lastMessage setText:@""];
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
            friend = [QMContactList shared].allUsersAsDictionary[ID];
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

