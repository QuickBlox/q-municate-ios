//
//  QMDialogCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDialogCell.h"
#import "QMApi.h"
#import "QMImageView.h"

@interface QMDialogCell()

@property (strong, nonatomic) IBOutlet UILabel *unreadMsgNumb;
@property (strong, nonatomic) IBOutlet UILabel *groupMembersNumb;

@property (strong, nonatomic) IBOutlet UIImageView *groupNumbBackground;
@property (strong, nonatomic) IBOutlet UIImageView *unreadMsgBackground;

@end

@implementation QMDialogCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setDialog:(QBChatDialog *)dialog {
    
    self.descriptionLabel.text = dialog.lastMessageText.length > 0 ? dialog.lastMessageText : @"Attachment";
    
    if (_dialog != dialog) {
        _dialog = dialog;
        [self configureCellWithDialog:dialog];
    }
}

- (void)configureCellWithDialog:(QBChatDialog *)chatDialog {
    
    BOOL isGroup = (chatDialog.type == QBChatDialogTypeGroup);

    self.groupMembersNumb.hidden = self.groupNumbBackground.hidden = !isGroup;
    self.unreadMsgBackground.hidden = self.unreadMsgNumb.hidden = (chatDialog.unreadMessageCount == 0);
    self.unreadMsgNumb.text = [NSString stringWithFormat:@"%d", chatDialog.unreadMessageCount];
    
    if (!isGroup) {
        
        QBUUser *occupant = nil;
        
        for (NSString *ocupantID in chatDialog.occupantIDs) {
            QBUUser *friend = [[QMApi instance] userWithID:ocupantID.integerValue];
            if (friend) {
                occupant = friend;
                break;
            }
        }
        
        NSURL *url = [NSURL URLWithString:occupant.website];
        [self setUserImageWithUrl:url];
        
        self.titleLabel.text = occupant.fullName;
        
    } else {
        
        self.titleLabel.text = chatDialog.name;
        self.groupMembersNumb.text = [NSString stringWithFormat:@"%d", chatDialog.occupantIDs.count];
    }
}

@end