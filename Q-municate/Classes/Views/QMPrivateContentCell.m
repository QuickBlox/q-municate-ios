//
//  QMPrivateContentCell.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/05/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMPrivateContentCell.h"
#import "QMContactList.h"
#import "QMUtilities.h"
#import "UIImageView+ImageWithBlobID.h"
#import "NSDateFormatter+SinceDateFormat.h"

@interface QMPrivateContentCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoCenterConstraint;

@end

@implementation QMPrivateContentCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    
//    self.myAvatar.layer.cornerRadius = self.myAvatar.frame.size.width / 2;
//    self.myAvatar.layer.borderWidth = 2.0f;
//    self.myAvatar.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
//    self.myAvatar.layer.masksToBounds = YES;
//    self.myAvatar.crossfadeDuration = 0.0f;
//    
//    self.opponentAvatar.layer.cornerRadius = self.opponentAvatar.frame.size.width / 2;
//    self.opponentAvatar.layer.borderWidth = 2.0f;
//    self.opponentAvatar.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
//    self.opponentAvatar.layer.masksToBounds = YES;
//    self.opponentAvatar.crossfadeDuration = 0.0f;
}

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message forUser:(QBUUser *)user isMe:(BOOL)isMe
{
//    // if message is mine:
//    if (isMe) {
//        
//        self.photoCenterConstraint.constant = 35.0f;
//        
//        self.myAvatar.hidden = NO;
//        self.opponentAvatar.hidden = YES;
//        self.myAvatar.image = [UIImage imageNamed:@"upic-placeholder"];
//        self.datetimeLabel.textAlignment = NSTextAlignmentLeft;
//        
//        if (user.website != nil) {
//            [self.myAvatar setImageURL:[NSURL URLWithString:user.website]];
//        } else if (user.blobID > 0) {
//            [self.myAvatar loadImageWithBlobID:user.blobID];
//        }
//        self.backgroundColor = [UIColor whiteColor];
//    } else {
//        self.photoCenterConstraint.constant = -31.0f;
//        
//        self.myAvatar.hidden = YES;
//        self.opponentAvatar.hidden = NO;
//        self.opponentAvatar.image = [UIImage imageNamed:@"upic-placeholder"];
//        self.datetimeLabel.textAlignment = NSTextAlignmentRight;
//        
//        if (user.website != nil) {
//            [self.opponentAvatar setImageURL:[NSURL URLWithString:user.website]];
//        } else if (user.blobID > 0) {
//            [self.opponentAvatar loadImageWithBlobID:user.blobID];
//        }
//        self.backgroundColor = [UIColor colorWithRed:62/255.0 green:136/255.0 blue:203/255.0 alpha:0.09];
//    }
//    // date time:
//    self.datetimeLabel.text = [[QMUtilities shared].dateFormatter fullFormatPassedTimeFromDate:message.datetime];
//    //
//    QBChatAttachment *attach = message.attachments[0];
//    if ([attach.type isEqualToString:@"photo"]) {
//        if (attach.url != nil) {
//            [self.sharedImageView setImageURL:[NSURL URLWithString:attach.url]];
//        } else if (attach.ID != nil) {
//            [self.sharedImageView loadImageWithBlobID:[attach.ID integerValue]];
//        }
//    }
}

@end
