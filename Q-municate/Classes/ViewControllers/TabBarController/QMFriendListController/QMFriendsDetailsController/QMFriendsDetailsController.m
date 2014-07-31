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
#import "QMImageView.h"
#import "REAlertView.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

typedef NS_ENUM(NSUInteger, QMCallType) {
    QMCallTypePhone,
    QMCallTypeVideo,
    QMCallTypeAudio,
    QMCallTypeChat
    
};

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
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationItem.rightBarButtonItem = nil;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.selectedUser.phone.length == 0) {
        //        [self cell:self.phoneCell setHidden:YES];
        [self.phoneLabel setText:@"(none)"];
    } else {
        self.phoneLabel.text = self.selectedUser.phone;
    }
    
    self.fullName.text = self.selectedUser.fullName;
    self.userDetails.text = self.selectedUser.customData;
    self.userAvatar.imageViewType = QMImageViewTypeCircle;
    
    NSURL *url = [NSURL URLWithString:self.selectedUser.website];
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    [self.userAvatar sd_setImageWithURL:url placeholderImage:placeholder];
    
    [self updateUserStatus];
}

- (void)updateUserStatus {
    
    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:self.selectedUser.ID];
    if (item) { //friend if YES
        self.status.text = item.online ? kStatusOnlineString : kStatusOfflineString;
        self.onlineCircle.hidden = item.online ? NO : YES;
    }
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
        
        QMChatViewController *chatController = segue.destinationViewController;
        chatController.dialog = sender;
        
        NSAssert([sender isKindOfClass:QBChatDialog.class], @"Need update this case");
    }
}

#define QM_AUDIO_VIDEO_ENABLED 0

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case QMCallTypePhone: break;
            
#if QM_AUDIO_VIDEO_ENABLED
        case QMCallTypeVideo:[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:nil]; break;
        case QMCallTypeAudio: [self performSegueWithIdentifier:kAudioCallSegueIdentifier sender:nil]; break;
#else
        case QMCallTypeVideo: {
            
            [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
                alertView.title = @"Coming soon.";
                [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:nil];
            }];
            
        } break;
            
        case QMCallTypeAudio:{
            
            [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
                alertView.title = @"Coming soon.";
                [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:nil];
            }];
            
        } break;
#endif
        case QMCallTypeChat: {
            
            __weak __typeof(self)weakSelf = self;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [[QMApi instance] createPrivateChatDialogIfNeededWithOpponent:self.selectedUser completion:^(QBChatDialog *chatDialog) {
                
                if (chatDialog) {
                    [weakSelf performSegueWithIdentifier:kChatViewSegueIdentifier sender:chatDialog];
                }
                [SVProgressHUD dismiss];
            }];
            
        } break;
            
        default:break;
    }
}

#pragma mark - Actions

- (IBAction)removeFromFriends:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        
        alertView.title = @"Are you sure?";
        [alertView addButtonWithTitle:@"Cancel" andActionBlock:^{}];
        [alertView addButtonWithTitle:@"Delete" andActionBlock:^{
            if ([[QMApi instance] removeUserFromContactListWithUserID:weakSelf.selectedUser.ID]) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
}

@end
