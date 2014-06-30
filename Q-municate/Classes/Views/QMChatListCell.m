//
//  QMChatListCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatListCell.h"
#import "QMContactList.h"
#import "QMImageView.h"

@interface QMChatListCell()

@property (strong, nonatomic) IBOutlet QMImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *lastMessage;

@property (strong, nonatomic) IBOutlet UILabel *unreadMsgNumb;
@property (strong, nonatomic) IBOutlet UILabel *groupMembersNumb;

@property (strong, nonatomic) IBOutlet UIImageView *groupNumbBackground;
@property (strong, nonatomic) IBOutlet UIImageView *unreadMsgBackground;

@end

@implementation QMChatListCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.avatar.imageViewType = QMImageViewTypeCircle;
}

- (void)configureCellWithDialog:(QBChatDialog *)chatDialog {
    
    BOOL isGroup = (chatDialog.type == QBChatDialogTypeGroup);

    self.groupMembersNumb.hidden = self.groupNumbBackground.hidden = !isGroup;
    self.unreadMsgBackground.hidden = self.unreadMsgNumb.hidden = !(chatDialog.unreadMessageCount > 0);
    self.unreadMsgNumb.text = [@(chatDialog.unreadMessageCount) stringValue];
    self.lastMessage.text = chatDialog.lastMessageText.length > 0 ? chatDialog.lastMessageText : @"Attachment";
    self.name.text = [self chatNameWithDialog:chatDialog];
    
    UIImage *placeholder = [UIImage imageNamed: isGroup ? @"group_placeholder" : @"upic_placeholderr"];
    
    if (isGroup) {
        self.groupMembersNumb.text = [@([chatDialog.occupantIDs count]) stringValue];
    } else {
        
        QBUUser *friend = [[QMContactList shared] searchFriendFromChatDialog:chatDialog];
        NSURL *url = [NSURL URLWithString:friend.website];
        [self.avatar setImageWithURL:url placeholderImage:placeholder];
    }
}

- (NSString *)chatNameWithDialog:(QBChatDialog *)chatDialog {
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        QBUUser *friend = [[QMContactList shared] searchFriendFromChatDialog:chatDialog];
        return friend ? friend.fullName : @"Unknown user";
    }
    
    return chatDialog.name;
}

@end