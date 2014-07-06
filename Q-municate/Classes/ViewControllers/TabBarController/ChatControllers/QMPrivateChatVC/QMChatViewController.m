//
//  QMChatViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatViewController.h"
#import "QMPrivateChatDataSource.h"
#import "QMGroupChatDataSource.h"
#import "QMApi.h"

@interface QMChatViewController ()

<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation QMChatViewController

- (void)setupPrivateChatWithChatDialog:(QBChatDialog *)chatDialog andOpponent:(QBUUser *)opponent {
    self.dataSource = [[QMPrivateChatDataSource alloc] initWithChatDialog:chatDialog
                                                                 opponent:opponent
                                                             forTableView:self.tableView];
}

- (void)setupGroupChatWithChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(chatDialog.roomJID, @"Check it");
    QBChatRoom *chatRoom;// = [chatService chatRoomWithRoomJID:chatDialog.roomJID];
    
    self.dataSource = [[QMGroupChatDataSource alloc ] initWithChatDialog:chatDialog
                                                                chatRoom:chatRoom
                                                            forTableView:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyScrollsToMostRecentMessage = YES;
}

#pragma mark - InputView Button Actions

- (void)didPressAccessoryButton:(UIButton *)sender {
    [self presentImagePicker];
}

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                      date:(NSDate *)date {
    
    [self.dataSource sendMessage:text];
}

- (void)presentImagePicker {

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage]; //(NSString *) kUTTypeMovie
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *editImage = info[ UIImagePickerControllerEditedImage];
        [self.dataSource sendImage:editImage];
    
    }
}

//- (void)configureNavigationBarForPrivateChat {
//
//    UIButton *groupInfoButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [groupInfoButton setFrame:CGRectMake(0, 0, 30, 40)];
//
//    [groupInfoButton setImage:[UIImage imageNamed:@"ic_info_top"] forState:UIControlStateNormal];
//    [groupInfoButton addTarget:self action:@selector(groupInfoNavButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *groupInfoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupInfoButton];
//    self.navigationItem.rightBarButtonItems = @[groupInfoBarButtonItem];
//
//}
//
//- (void)configureNavigationBarForGroupChat {
//    
//    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [videoButton setFrame:CGRectMake(0, 0, 30, 40)];
//    [audioButton setFrame:CGRectMake(0, 0, 30, 40)];
//    
//    [videoButton setImage:[UIImage imageNamed:@"ic_camera_top"] forState:UIControlStateNormal];
//    [videoButton addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    [audioButton setImage:[UIImage imageNamed:@"ic_phone_top"] forState:UIControlStateNormal];
//    [audioButton addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *videoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:videoButton];
//    UIBarButtonItem *audioCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
//    self.navigationItem.rightBarButtonItems = @[videoCallBarButtonItem,  audioCallBarButtonItem];
//    // chat room:
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidEnterNotification) name:kChatRoomDidEnterNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReveiveMessage) name:kChatRoomDidReceiveMessageNotification object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNavTitleWithNotification:) name:kChatDialogUpdatedNotification object:nil];
//}
//
//- (void)back:(id)sender {
//    
//	[self.navigationController popViewControllerAnimated:YES];
//}


//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    QBChatAbstractMessage *message = self.chatHistory[indexPath.row];
//
//    // "User created a group chat" cell
//    if (message.customParameters[@"xmpp_room_jid"] != nil) {
//        QMChatInvitationCell *invitationCell = (QMChatInvitationCell *)[tableView dequeueReusableCellWithIdentifier:kChatInvitationCellIdentifier];
//        [invitationCell configureCellWithMessage:message];
//        return invitationCell;
//    }
//
//    BOOL isMe = NO;
//
//    QBUUser *currentMessageUser = nil;
//
//    if ([QMContactList shared].me.ID == message.senderID) {
//        currentMessageUser = [QMContactList shared].me;
//        isMe = YES;
//    } else {
//        currentMessageUser = [[QMContactList shared] findFriendWithID:message.senderID];
//    }
//
//    // Upload attach cell
//    //
//    if([message isKindOfClass:QMChatUploadingMessage.class]){
//        QMUploadAttachCell *cell = (QMUploadAttachCell *)[tableView dequeueReusableCellWithIdentifier:kChatUploadingAttachmentCellIdentitier];
//        [cell configureCellWithMessage:(QMChatUploadingMessage *)message];
//        return cell;
//    }
//
//    // Privae chat cell
//    if (self.chatDialog.type == QBChatDialogTypePrivate) {
//
//        // attachment cell
//        //
//        if ([message.attachments count]>0) {
//            QMPrivateContentCell *contentCell = (QMPrivateContentCell *)[tableView dequeueReusableCellWithIdentifier:kChatPrivateContentCellIdentifier];
//            [contentCell configureCellWithMessage:message forUser:currentMessageUser isMe:isMe];
//            return contentCell;
//        }
//
//        // message cell
//        //
//        QMPrivateChatCell *privateChatCell = (QMPrivateChatCell *)[tableView dequeueReusableCellWithIdentifier:kChatPrivateMessageCellIdentifier];
//        [privateChatCell configureCellWithMessage:message fromUser:currentMessageUser];
//        return privateChatCell;
//    }
//
//    // Group chat attachment cell
//    if ([message.attachments count] > 0) {
//        QMGroupContentCell *groupContentCell = (QMGroupContentCell *)[tableView dequeueReusableCellWithIdentifier:kChatGroupContentCellIdentifier];
//        [groupContentCell configureCellWithMessage:message fromUser:currentMessageUser];
//        return groupContentCell;
//    }
//
//    // Group chat message cell
//    //
//    QMChatViewCell *cell = (QMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:kChatViewCellIdentifier];
//    [cell configureCellWithMessage:message fromUser:currentMessageUser];
//
//    return cell;
//}
//

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *neededCell = [tableView cellForRowAtIndexPath:indexPath];
//
//    if ([neededCell isKindOfClass:QMPrivateContentCell.class]) {
//
//        // getting image:
//        UIImage *contentImage = ((QMPrivateContentCell *)neededCell).sharedImageView.image;
//        [self performSegueWithIdentifier:kContentPreviewSegueIdentifier sender:contentImage];
//        return;
//    }
//    if ([neededCell isKindOfClass:QMGroupContentCell.class]) {
//
//        // getting image:
//        UIImage *contentImage = ((QMGroupContentCell *)neededCell).contentImageView.image;
//        [self performSegueWithIdentifier:kContentPreviewSegueIdentifier sender:contentImage];
//    }
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.destinationViewController isKindOfClass:QMContentPreviewController.class]) {
//        QMContentPreviewController *contentController = (QMContentPreviewController *)segue.destinationViewController;
//        contentController.contentImage = (UIImage *)sender;
//        // needed public url also:
//#warning Need public url!
//    } else if ([segue.destinationViewController isKindOfClass:QMGroupDetailsController.class]) {
//
//        ((QMGroupDetailsController *)segue.destinationViewController).chatDialog = self.chatDialog;
//        ((QMGroupDetailsController *)segue.destinationViewController).chatRoom = self.chatRoom;
//
//    } else if ([segue.destinationViewController isKindOfClass:QMVideoCallController.class]) {
//        QMVideoCallController *videoCallVC = (QMVideoCallController *)segue.destinationViewController;
//        videoCallVC.videoEnabled = YES;         // video call
//        videoCallVC.opponent = self.opponent;
//
//    }
//
//}
//


#pragma mark - Nav Buttons Actions

- (void)audioCallAction {
    
	[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:@(QBVideoChatConferenceTypeAudio)];
}

- (void)videoCallAction {
    
	[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:@(QBVideoChatConferenceTypeAudioAndVideo)];
}

- (void)groupInfoNavButtonAction {
    
	[self performSegueWithIdentifier:kGroupDetailsSegueIdentifier sender:nil];
}

@end