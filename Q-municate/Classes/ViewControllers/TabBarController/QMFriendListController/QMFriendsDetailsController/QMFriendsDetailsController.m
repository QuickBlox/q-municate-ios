//
//  QMFriendsDetailsController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsDetailsController.h"
#import "QMVideoCallController.h"
#import "QMChatViewController.h"
#import "QMUsersService.h"
#import "QMChatService.h"
#import "QMImageView.h"
#import "REAlertView.h"

@interface QMFriendsDetailsController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *videoChatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *audioChatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *chatCell;

@property (weak, nonatomic) IBOutlet QMImageView *userAvatar;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *userDetails;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onlineCircle;

@end

@implementation QMFriendsDetailsController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.selectedUser.phone.length == 0) {
        [self cell:self.phoneCell setHidden:YES];
    } else {
        self.phoneLabel.text = self.selectedUser.phone;
    }
    
    self.fullName.text = self.selectedUser.fullName;
    self.userDetails.text = self.selectedUser.customData;

    self.userAvatar.imageViewType = QMImageViewTypeCircle;
    NSURL *url = [NSURL URLWithString:self.selectedUser.website];
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    [self.userAvatar setImageWithURL:url placeholderImage:placeholder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserStatus) name:kFriendsReloadedNotification object:nil];
    [self updateUserStatus];
}

- (void)updateUserStatus {
#warning me.iD
#warning QMContactList shared
    // online status
//    QBContactListItem *contactItem = [[QMContactList shared] contactItemFromContactListForOpponentID:self.selectedUser.ID];
//    BOOL isOnline = contactItem.online;
//    
//    self.status.text = isOnline ? kStatusOnlineString : kStatusOfflineString;
//    self.onlineCircle.hidden = isOnline ? NO : YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kVideoCallSegueIdentifier]) {
        
        QMVideoCallController *videoCallVC = segue.destinationViewController;
        [videoCallVC setOpponent:self.selectedUser];
        
    } else if ([segue.identifier isEqualToString:kAudioCallSegueIdentifier]) {
        
        QMVideoCallController *audioCallVC = segue.destinationViewController;
        [audioCallVC setOpponent:self.selectedUser];

    } else if ([segue.identifier isEqualToString:kChatViewSegueIdentifier]) {
#warning comment        
//        QMChatViewController *chatController = (QMChatViewController *)segue.destinationViewController;
//        QBChatDialog *dialog = [[QMChatService shared] chatDialogForFriendWithID:self.selectedUser.ID];
//        [chatController setupPrivateChatWithChatDialog:dialog andOpponent:self.selectedUser];
    }
}

#pragma mark - Actions

- (IBAction)removeFromFriends:(id)sender {
#warning me.iD
#warning QMContactList shared
//    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
//        
//        alertView.title = @"Are you sure?";
//        [alertView addButtonWithTitle:@"Cancel" andActionBlock:^{}];
//        
//        [alertView addButtonWithTitle:@"Delete" andActionBlock:^{
//            
//            NSString *opponentID = [@(self.selectedUser.ID) stringValue];
//            [[QMContactList shared].friendsAsDictionary removeObjectForKey:opponentID];
//            [[QMChatService shared] removeContactFromFriendsWithID:self.selectedUser.ID];
//            [self.navigationController popViewControllerAnimated:YES];
//        }];
//    }];
}

@end
