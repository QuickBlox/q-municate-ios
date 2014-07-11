//
//  QMChatListCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatListCell.h"
#import "QMApi.h"
#import "QMImageView.h"

@interface QMChatListCell()

@property (strong, nonatomic) IBOutlet UILabel *unreadMsgNumb;
@property (strong, nonatomic) IBOutlet UILabel *groupMembersNumb;

@property (strong, nonatomic) IBOutlet UIImageView *groupNumbBackground;
@property (strong, nonatomic) IBOutlet UIImageView *unreadMsgBackground;

@end

@implementation QMChatListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setDialog:(QBChatDialog *)dialog {
    _dialog = dialog;
}

- (void)configureCellWithDialog:(QBChatDialog *)chatDialog {
    
    BOOL isGroup = (chatDialog.type == QBChatDialogTypeGroup);

    self.groupMembersNumb.hidden = self.groupNumbBackground.hidden = !isGroup;
    self.unreadMsgBackground.hidden = self.unreadMsgNumb.hidden = !(chatDialog.unreadMessageCount > 0);
    self.unreadMsgNumb.text = [@(chatDialog.unreadMessageCount) stringValue];
    self.titleLabel.text = [self chatNameWithDialog:chatDialog];
    self.descriptionLabel.text = chatDialog.lastMessageText.length > 0 ? chatDialog.lastMessageText : @"Attachment";
    
    if (isGroup) {
        self.groupMembersNumb.text = [@([chatDialog.occupantIDs count]) stringValue];
    } else {

        QBUUser *friend;// = [[QMContactList shared] searchFriendFromChatDialog:chatDialog];
        NSURL *url = [NSURL URLWithString:friend.website];
        [self setUserImageWithUrl:url];
    }
}

- (NSString *)chatNameWithDialog:(QBChatDialog *)chatDialog {
#warning me.iD
#warning QMContactList shared
//
//    if (chatDialog.type == QBChatDialogTypePrivate) {
//        QBUUser *friend = [[QMContactList shared] searchFriendFromChatDialog:chatDialog];
//        return friend ? friend.fullName : @"Unknown user";
//    }
    
    return chatDialog.name;
}

@end