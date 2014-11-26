//
//  QMGroupDetailsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 12/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsController.h"
#import "QMAddMembersToGroupController.h"
#import "QMGroupDetailsDataSource.h"
#import "SVProgressHUD.h"
#import "QMImageView.h"
#import "QMImagePicker.h"
#import "QMApi.h"
#import "QMContentService.h"
#import "QMChatReceiver.h"
#import "UIImage+Cropper.h"

@interface QMGroupDetailsController ()

<UITableViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet QMImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) QMGroupDetailsDataSource *dataSource;

@end

@implementation QMGroupDetailsController

- (void)dealloc {
    
    [[QMChatReceiver instance] unsubscribeForTarget:self];
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeGroupAvatar:)];
    [self.groupAvatarView addGestureRecognizer:tap];
    self.groupAvatarView.layer.cornerRadius = self.groupAvatarView.frame.size.width / 2;
    self.groupAvatarView.layer.masksToBounds = YES;
    
    [self updateGUIWithChatDialog:self.chatDialog];
    
    self.dataSource = [[QMGroupDetailsDataSource alloc] initWithTableView:self.tableView];
    [self.dataSource reloadDataWithChatDialog:self.chatDialog];
    
    __weak __typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatRoomDidReceiveListOfOnlineUsersWithTarget:self block:^(NSArray *users, NSString *roomName) {
        
        QBChatRoom *chatRoom = weakSelf.chatDialog.chatRoom;
        if ([roomName isEqualToString:chatRoom.name]) {
            [weakSelf updateOnlineStatus:users.count];
        }
    }];
    
    [[QMChatReceiver instance] chatRoomDidChangeOnlineUsersWithTarget:self block:^(NSArray *onlineUsers, NSString *roomName) {
        
        QBChatRoom *chatRoom = weakSelf.chatDialog.chatRoom;
        if ([roomName isEqualToString:chatRoom.name]) {
            [weakSelf updateOnlineStatus:onlineUsers.count];
        }
    }];

    [[QMChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        if (message.delayed) {
            return;
        }
        if (message.cParamNotificationType == QMMessageNotificationTypeUpdateGroupDialog &&
            [message.cParamDialogID isEqualToString:weakSelf.chatDialog.ID]) {
            
            weakSelf.chatDialog = [[QMApi instance] chatDialogWithID:message.cParamDialogID];
            [weakSelf updateGUIWithChatDialog:weakSelf.chatDialog];
        }
    }];
}


- (void)updateOnlineStatus:(NSUInteger)online {
    
    NSString *onlineUsersCountText = [NSString stringWithFormat:@"%d/%d online", online, self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = onlineUsersCountText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (IBAction)changeDialogName:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] changeChatName:self.groupNameField.text forChatDialog:self.chatDialog completion:^(QBChatDialogResult *result) {
        [SVProgressHUD dismiss];
    }];
}

- (void)changeGroupAvatar:(id)sender {
    
    __weak typeof(self)weakSelf = self;
    [QMImagePicker chooseSourceTypeInVC:self allowsEditing:NO result:^(UIImage *image) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[QMApi instance] changeAvatar:[image imageByScaleAndCrop:CGSizeMake(900, 900)] forChatDialog:weakSelf.chatDialog completion:^(QBChatDialogResult *result) {
            if (result.success) {
                [weakSelf updateGUIWithChatDialog:result.dialog];
            }
            [SVProgressHUD dismiss];
        }];
    }];
}

- (IBAction)addFriendsToChat:(id)sender
{
    // check for friends:
    NSArray *friends = [[QMApi instance] contactsOnly];
    NSArray *usersIDs = [[QMApi instance] idsWithUsers:friends];
    NSArray *friendsIDsToAdd = [self filteredIDs:usersIDs forChatDialog:self.chatDialog];
    
    if ([friendsIDsToAdd count] == 0) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"QM_STR_CANT_ADD_NEW_FRIEND", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                          otherButtonTitles:nil] show];
        return;
    }
    
    [self performSegueWithIdentifier:kQMAddMembersToGroupControllerSegue sender:nil];
}

- (void)updateGUIWithChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(self.chatDialog && chatDialog.type == QBChatDialogTypeGroup , @"Need update this case");

    self.groupNameField.text = chatDialog.name;
    if (chatDialog.photo) {
        [self.groupAvatarView setImageWithURL:[NSURL URLWithString:chatDialog.photo] placeholder:[UIImage imageNamed:@"upic_placeholder_details_group"] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {} completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
    }
    self.occupantsCountLabel.text = [NSString stringWithFormat:@"%d participants", self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = [NSString stringWithFormat:@"0/%d online", self.chatDialog.occupantIDs.count];
    

    [self.dataSource reloadDataWithChatDialog:self.chatDialog];
    
    QBChatRoom *chatRoom = self.chatDialog.chatRoom;
    [chatRoom requestOnlineUsers];
}

- (NSArray *)filteredIDs:(NSArray *)IDs forChatDialog:(QBChatDialog *)chatDialog
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:IDs];
    [newArray removeObjectsInArray:chatDialog.occupantIDs];
    return [newArray copy];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMAddMembersToGroupControllerSegue]) {
        QMAddMembersToGroupController *addMembersVC = segue.destinationViewController;
        addMembersVC.chatDialog = self.chatDialog;
    }
}

@end
