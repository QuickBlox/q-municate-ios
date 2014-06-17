//
//  QMChatViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatViewController.h"
//#import "QMVideoCallController.h"
//#import "QMChatViewCell.h"
//#import "QMContactList.h"
#import "QMChatService.h"
//#import "QMUtilities.h"
#import "QMContent.h"
//#import "QMChatInvitationCell.h"
//#import "QMPrivateChatCell.h"
//#import "QMPrivateContentCell.h"
//#import "QMUploadAttachCell.h"
//#import "QMChatUploadingMessage.h"
//#import "UIImage+Cropper.h"
//#import "QMContentPreviewController.h"
//#import "QMGroupDetailsController.h"
//#import "QMGroupContentCell.h"
#import "QMPrivateChatDataSource.h"
#import "QMGroupChatDataSource.h"

@interface QMChatViewController ()

<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) QMContent *uploadManager;

@end

@implementation QMChatViewController

- (void)setupPrivateChatWithChatDialog:(QBChatDialog *)chatDialog andOpponent:(QBUUser *)opponent {
    
    self.dataSource = [[QMPrivateChatDataSource alloc] initWithChatDialog:chatDialog
                                                                 opponent:opponent
                                                             forTableView:self.tableView];
}

- (void)setupGroupChatWithChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(chatDialog.roomJID, @"Check it");
    
    QMChatService *chatService = [QMChatService shared];
    QBChatRoom *chatRoom = [chatService chatRoomWithRoomJID:chatDialog.roomJID];
    
    self.dataSource = [[QMGroupChatDataSource alloc ] initWithChatDialog:chatDialog
                                                                chatRoom:chatRoom
                                                            forTableView:self.tableView];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

//- (void)viewDidLoad
//{
//
//    NSString *opponentID = [@(self.opponent.ID) stringValue];
//    // if dialog is group chat:
//    if (self.chatDialog.type != QBChatDialogTypePrivate) {
//
//        // if user is joined, return
//        if (![self userIsJoinedRoomForDialog:self.chatDialog]) {
//
//            // enter chat room:
//            [QMUtilities showActivityView];
//            [[QMChatService shared] joinRoomWithRoomJID:self.chatDialog.roomJID];
//        }
//        self.chatRoom = [QMChatService shared].allChatRoomsAsDictionary[self.chatDialog.roomJID];
//        // load history:
//        self.chatHistory = [QMChatService shared].allConversations[self.chatDialog.roomJID];
//        if (self.chatHistory == nil) {
//            [self loadHistory];
//        }
//        return;
//    }
//    // for private chat:
//    // retrieve chat history:
//    self.chatHistory = [QMChatService shared].allConversations[opponentID];
//    if (self.chatHistory == nil) {
//
//        // if new chat dialog (not from server):
//        if ([self.chatDialog.occupantIDs count] == 1) {    // created now:
//            NSMutableArray *emptyHistory = [NSMutableArray new];
//            [QMChatService shared].allConversations[opponentID] = emptyHistory;
//            return;
//        }
//        // load history:
//        [self loadHistory];
//    }
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    // update unread message count:
//    [self updateChatDialog];
//
//    [self resetTableView];
//
//    [super viewWillAppear:NO];
//}
//
//- (void)updateChatDialog
//{
//    self.chatDialog.unreadMessageCount = 0;
//}
//
//- (void)loadHistory
//{
//    // load history:
//
//
//    void(^reloadDataAfterGetMessages) (NSArray *messages) = ^(NSArray *messages) {
//
//        [QMUtilities hideActivityView];
//
////        if (messages.count > 0) {
////
////            if (self.chatDialog.type == QBChatDialogTypePrivate) {
////                [QMChatService shared].allConversations[[@(self.opponent.ID)stringValue]] = [messages mutableCopy];
////            } else {
////                [QMChatService shared].allConversations[self.chatDialog.roomJID] = [messages mutableCopy];
////            }
////        }
//
//        [self resetTableView];
//    };
//
//
//    //TODO:TEMP
//    [self.dbStorage cachedQBChatMessagesWithDialogId:self.chatDialog.ID qbMessages:^(NSArray *collection) {
//        reloadDataAfterGetMessages(collection);
//    }];
//    [[QMChatService shared] getMessageHistoryWithDialogID:self.chatDialog.ID withCompletion:^(NSArray *messages, BOOL success, NSError *error) {
//        reloadDataAfterGetMessages(messages);
//    }];
//
//}

- (void)configureNavigationBarForPrivateChat {

    UIButton *groupInfoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [groupInfoButton setFrame:CGRectMake(0, 0, 30, 40)];
    
    [groupInfoButton setImage:[UIImage imageNamed:@"ic_info_top"] forState:UIControlStateNormal];
    [groupInfoButton addTarget:self action:@selector(groupInfoNavButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *groupInfoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupInfoButton];
    self.navigationItem.rightBarButtonItems = @[groupInfoBarButtonItem];
    
}

- (void)configureNavigationBarForGroupChat {
    
    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoButton setFrame:CGRectMake(0, 0, 30, 40)];
    [audioButton setFrame:CGRectMake(0, 0, 30, 40)];
    
    [videoButton setImage:[UIImage imageNamed:@"ic_camera_top"] forState:UIControlStateNormal];
    [videoButton addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    [audioButton setImage:[UIImage imageNamed:@"ic_phone_top"] forState:UIControlStateNormal];
    [audioButton addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *videoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:videoButton];
    UIBarButtonItem *audioCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    self.navigationItem.rightBarButtonItems = @[videoCallBarButtonItem,  audioCallBarButtonItem];
}

- (IBAction)back:(id)sender
{
    
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showMediaFiles:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

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
//- (void)resetTableView
//{
////    if (self.chatDialog.type == QBChatDialogTypePrivate) {
////         self.chatHistory = [QMChatService shared].allConversations[[@(self.opponent.ID) stringValue]];
////    } else {
////        self.chatHistory = [QMChatService shared].allConversations[self.chatDialog.roomJID];
////    }
//
//    [self.tableView reloadData];
//    if ([self.chatHistory count] >2) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.chatHistory count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
//}
//

//#pragma mark - Nav Buttons Actions
- (void)audioCallAction
{
	[[[UIAlertView alloc] initWithTitle:@"No Audio Calls yet" message:@"Coming soon" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)videoCallAction
{
	[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:nil];
}

- (void)groupInfoNavButtonAction
{
	[self performSegueWithIdentifier:kGroupDetailsSegueIdentifier sender:nil];
}

#pragma mark - Chat Notifications

- (void)localChatDidReceiveMessage:(NSNotification *)notification
{
    //    [self updateChatDialog];
    //    [self resetTableView];
}
//
//// ************************** CHAT ROOM **********************************
//- (void)chatRoomDidEnterNotification
//{
////    self.chatRoom = [QMChatService shared].allChatRoomsAsDictionary[self.chatDialog.roomJID];
//
//    if (self.chatHistory != nil) {
//        [QMUtilities hideActivityView];
//        return;
//    }
//
//    // load history:
//    [self loadHistory];
//}
//
//- (void)chatRoomDidReveiveMessage
//{
//    // update unread message count:
//    [self updateChatDialog];
//
//    [self resetTableView];
//}
//
//
//#pragma mark -
//- (IBAction)sendMessageButtonClicked:(UIButton *)sender
//{
//	if (self.inputMessageTextField.text.length) {
//		QBChatMessage *chatMessage = [QBChatMessage new];
//		chatMessage.text = self.inputMessageTextField.text;
//
//		if (self.chatDialog.type == QBChatDialogTypePrivate) { // private chat
//            chatMessage.recipientID = self.opponent.ID;
//            chatMessage.senderID = [QMContactList shared].me.ID;
//			[[QMChatService shared] sendMessage:chatMessage];
//
//		} else { // group chat
//            [[QMChatService shared] sendMessage:chatMessage toRoom:self.chatRoom];
//		}
//        self.inputMessageTextField.text = @"";
//        [self resetTableView];
//	}
//}
////
////- (BOOL)userIsJoinedRoomForDialog:(QBChatDialog *)dialog
////{
////    QBChatRoom *currentRoom = [QMChatService shared].allChatRoomsAsDictionary[dialog.roomJID];
////    if (currentRoom == nil || !currentRoom.isJoined) {
////        return NO;
////    }
////    return YES;
////}
//
//
//#pragma mark -
//- (void)showAlertWithErrorMessage:(NSString *)messageString
//{
//	[[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:messageString delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
//}
//
//
//#pragma mark - UIImagePickerControllerDelegate
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    __block UIImage *currentImage = info[UIImagePickerControllerOriginalImage];
////    currentImage = [currentImage imageByScalingProportionallyToMinimumSize:CGSizeMake(625, 400)];
//
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//
////    [self dismissViewControllerAnimated:YES completion:^{
////
////        // Create  uploading message
////        QMChatUploadingMessage *chatMessage = [QMChatUploadingMessage new];
////		chatMessage.content = currentImage;
//////        chatMessage.text = @"Content";
////		if (self.chatDialog.type == QBChatDialogTypePrivate) {
////            chatMessage.recipientID = self.opponent.ID;
////
////            //add private upload message to history
////            NSMutableArray *messages = [QMChatService shared].allConversations[[@(self.opponent.ID) stringValue]];
////            [messages addObject:chatMessage];
////            [self resetTableView];
////            return;
////        }
////        chatMessage.roomJID = self.chatDialog.roomJID;                      //room jid for caching message in QMChatService
////        //add group upload message to history
////        NSMutableArray *messages = [QMChatService shared].allConversations[self.chatDialog.roomJID];
////        [messages addObject:chatMessage];
////
////        [self resetTableView];
////    }];
//}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
