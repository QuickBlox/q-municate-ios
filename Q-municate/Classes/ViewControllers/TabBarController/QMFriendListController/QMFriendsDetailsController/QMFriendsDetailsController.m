//
//  QMFriendsDetailsController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsDetailsController.h"
#import "UIImageView+ImageWithBlobID.h"
#import "QMVideoCallController.h"
#import "QMChatViewController.h"
#import "QMFriendsDetailsDataSource.h"
#import "QMPhoneNumberCell.h"
#import "QMContactList.h"
#import "QMUtilities.h"
#import "QMChatService.h"


static CGFloat kCellHeight = 65.0f;

@interface QMFriendsDetailsController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *userDetails;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

@property (strong, nonatomic) QMFriendsDetailsDataSource *dataSource;

@end

@implementation QMFriendsDetailsController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserStatus) name:kFriendsReloadedNotification object:nil];
    
    [self configureUserAvatarView];
    
	self.userAvatar.image = self.userPhotoImage;
    self.fullName.text = self.currentFriend.fullName;
    
    self.dataSource = [[QMFriendsDetailsDataSource alloc] initWithUser:self.currentFriend];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUserStatus];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateUserStatus
{
    // online status
    QBContactListItem *contactItem = [[QMContactList shared] contactItemFromContactListForOpponentID:self.currentFriend.ID];
    BOOL isOnline = contactItem.online;
    if (isOnline) {
        self.status.text = kStatusOnlineString;
        self.onlineCircle.hidden = NO;
        return;
    }
    self.status.text = kStatusOfflineString;
    self.onlineCircle.hidden = YES;
}

- (void)configureUserAvatarView
{
    self.userAvatar.layer.cornerRadius = self.userAvatar.frame.size.width / 2;
    self.userAvatar.layer.borderWidth = 2.0f;
    self.userAvatar.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userAvatar.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource cellIdentifiersCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // getting current cell identifier:
    NSString *CellIdentifier = [self.dataSource cellIdentifierAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([cell isKindOfClass:QMPhoneNumberCell.class]) {
        ((QMPhoneNumberCell *)cell).phoneNumbLabel.text = self.currentFriend.phone;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *CellIdentifier = [self.dataSource cellIdentifierAtIndexPath:indexPath];
    
    if ([CellIdentifier isEqualToString:QMPhoneNumberCellIdentifier]) {
        //
    } else if ([CellIdentifier isEqualToString:QMVideoCallCellIdentifier]) {
        [self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:CellIdentifier];
    } else if ([CellIdentifier isEqualToString:QMAudioCallCellIdentifier]) {
        [self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:CellIdentifier];
    } else if ([CellIdentifier isEqualToString:QMChatCellIdentifier]) {
        [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:CellIdentifier];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *currentCellIdentifier = (NSString *)sender;
    
    if ([currentCellIdentifier isEqualToString:QMPhoneNumberCellIdentifier]) {
        return;
    }
    
    // if chat:
    if ([currentCellIdentifier isEqualToString:QMChatCellIdentifier]) {
        QMChatViewController *chatController = (QMChatViewController *)segue.destinationViewController;
        QBChatDialog *dialog = [[QMChatService shared] chatDialogForFriendWithID:self.currentFriend.ID];
        chatController.chatDialog = dialog;
        
        chatController.chatName = self.currentFriend.fullName;
        chatController.opponent = self.currentFriend;
        return;
    }
    
    // if audio or video call:
    if ([currentCellIdentifier isEqualToString:QMVideoCallCellIdentifier]) {
        ((QMVideoCallController *)segue.destinationViewController).callType = QMVideoChatTypeVideo;
    } else if ([currentCellIdentifier isEqualToString:QMAudioCallCellIdentifier]) {
        ((QMVideoCallController *)segue.destinationViewController).callType = QMVideoChatTypeAudio;
    }
    ((QMVideoCallController *)segue.destinationViewController).opponent = self.currentFriend;
    ((QMVideoCallController *)segue.destinationViewController).userImage = self.userAvatar.image;
}


#pragma mark - Actions

- (IBAction)removeFromFriends:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}


#pragma mark - UIActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Delete button tapped:
    if (buttonIndex == 0) {
        NSString *opponentID = [@(self.currentFriend.ID) stringValue];
        [[QMContactList shared].friendsAsDictionary removeObjectForKey:opponentID];
        [[QMChatService shared] removeContactFromFriendsWithID:self.currentFriend.ID];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsReloadedNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlertTitleInProgressString message:message delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil];
    [alert show];
}

@end
