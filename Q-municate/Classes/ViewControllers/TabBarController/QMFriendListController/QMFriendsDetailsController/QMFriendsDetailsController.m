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
#import "QMContactList.h"
#import "QMUtilities.h"
#import "QMChatService.h"

@interface QMFriendsDetailsController ()

@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *userDetails;

@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

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


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        [self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:indexPath];
    } else if (indexPath.row == 2) {
        [self showAlertWithMessage:@"Comming soon"];
    } else if (indexPath.row == 3) {
        [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:indexPath];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *currentPath = (NSIndexPath *)sender;
    
    // if chat
    if (currentPath.row == 3) {
        QMChatViewController *chatController = (QMChatViewController *)segue.destinationViewController;
        QBChatDialog *dialog = [[QMChatService shared] chatDialogForFriendWithID:self.currentFriend.ID];
        chatController.chatDialog = dialog;
        
        chatController.chatName = self.currentFriend.fullName;
        chatController.opponent = self.currentFriend;
        return;
    }
    
    if (currentPath.row == 1) {
        ((QMVideoCallController *)segue.destinationViewController).videoEnabled = YES;
    } else if (currentPath.row == 2) {
        ((QMVideoCallController *)segue.destinationViewController).videoEnabled = NO;
    }
    ((QMVideoCallController *)segue.destinationViewController).opponent = self.currentFriend;
    ((QMVideoCallController *)segue.destinationViewController).userImage = self.userAvatar.image;
}


#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)removeFromFriends:(id)sender
{
    NSString *opponentID = [@(self.currentFriend.ID) stringValue];
    [[QMContactList shared].friendsAsDictionary removeObjectForKey:opponentID];
    [[QMChatService shared] removeContactFromFriendsWithID:self.currentFriend.ID];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendsReloadedNotification object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlertTitleInProgressString message:message delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil];
    [alert show];
}

@end
