//
//  QMFriendsDetailsController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 28/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFriendsDetailsController.h"
#import "QMChatViewController.h"
#import "QMUsersUtils.h"
#import "QMImageView.h"
#import "QMAlertsFactory.h"
#import "REAlertView.h"
#import "SVProgressHUD.h"
#import "QMServicesManager.h"

typedef NS_ENUM(NSUInteger, QMCallType) {
    QMCallTypePhone,
    QMCallTypeVideo,
    QMCallTypeAudio,
    QMCallTypeChat
};

@interface QMFriendsDetailsController () <UIActionSheetDelegate, QMContactListServiceDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *videoChatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *audioChatCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *chatCell;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteContactButton;
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
    
    self.tableView.tableFooterView =
    [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.selectedUser.phone.length == 0) {
        
        [self.phoneLabel setText:NSLocalizedString(@"QM_STR_NONE", nil)];
    }
    else {
        self.phoneLabel.text = self.selectedUser.phone;
    }
    
    self.fullName.text = self.selectedUser.fullName;
    self.userDetails.text = self.selectedUser.status;
    self.userAvatar.imageViewType = QMImageViewTypeCircle;
    
    NSURL *url = [QMUsersUtils userAvatarURL:self.selectedUser];
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    
    [self.userAvatar setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageHighPriority
                            progress:
     ^(NSInteger receivedSize, NSInteger expectedSize) {
         
     }
     
                      completedBlock:
     ^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
         
     }];
    
    [QM.contactListService addDelegate:self];
    
    [self updateUserStatus];
    [self disableDeleteContactButtonIfNeeded];
    
#if !QM_AUDIO_VIDEO_ENABLED
    
    UITableViewCell *videoChatCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UITableViewCell *audioChatCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    [self cells:@[videoChatCell, audioChatCell] setHidden:YES];
    
#endif
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    [self updateUserStatus];
    [self disableDeleteContactButtonIfNeeded];
}

- (void)updateUserStatus {
    
//    QBContactListItem *item = [[QMApi instance] contactItemWithUserID:self.selectedUser.ID];
    
//    if (item) { //friend if YES
//        self.status.text = NSLocalizedString(item.online ? @"QM_STR_ONLINE": @"QM_STR_OFFLINE", nil);
//        self.onlineCircle.hidden = item.online ? NO : YES;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kVideoCallSegueIdentifier]) {
        
//        QMVideoCallController *videoCallVC = segue.destinationViewController;
//        [videoCallVC setOpponent:self.selectedUser];
        
    } else if ([segue.identifier isEqualToString:kAudioCallSegueIdentifier]) {
        
//        QMVideoCallController *audioCallVC = segue.destinationViewController;
//        [audioCallVC setOpponent:self.selectedUser];
        
    } else if ([segue.identifier isEqualToString:kChatViewSegueIdentifier]) {
        
        QMChatViewController *chatController = segue.destinationViewController;
        chatController.dialog = sender;
        
        NSAssert([sender isKindOfClass:QBChatDialog.class], @"Need update this case");
    }
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case QMCallTypePhone: break;
            
#if QM_AUDIO_VIDEO_ENABLED
        case QMCallTypeVideo:[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:nil]; break;
        case QMCallTypeAudio: [self performSegueWithIdentifier:kAudioCallSegueIdentifier sender:nil]; break;
        case QMCallTypeChat: {
#else
        case QMCallTypeVideo: {
#endif
            __weak __typeof(self)weakSelf = self;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
//            [[QMApi instance] createPrivateChatDialogIfNeededWithOpponent:self.selectedUser completion:^(QBChatDialog *chatDialog) {
//                
//                if (chatDialog) {
//                    [weakSelf performSegueWithIdentifier:kChatViewSegueIdentifier sender:chatDialog];
//                }
//                [SVProgressHUD dismiss];
//            }];
            
        } break;
            
        default:break;
        }
    }
    
#pragma mark - Actions
    
    - (IBAction)removeFromFriends:(id)sender {
        
        __weak __typeof(self)weakSelf = self;
        [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView)
         {
             alertView.message =
             [NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_DELETE_CONTACT", @"{User Full Name}"), self.selectedUser.fullName];
             
             [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                            andActionBlock:^{}];
             
             [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil)
                            andActionBlock:^
              {
                  [QM.contactListService removeUserFromContactListWithUserID:weakSelf.selectedUser.ID
                                                                  completion:^(BOOL success)
                   {
                       [weakSelf.navigationController popViewControllerAnimated:YES];
                   }];
              }];
         }];
    }
    
    
    - (void)disableDeleteContactButtonIfNeeded
    {
        QBContactListItem *item = [QM.contactListService.contactListMemoryStorage contactListItemWithUserID:self.selectedUser.ID];
        
        self.deleteContactButton.enabled = item ? YES : NO;
    }
    
    @end
