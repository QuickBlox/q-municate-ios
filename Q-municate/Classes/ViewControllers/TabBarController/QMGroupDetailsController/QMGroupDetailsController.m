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
#import "UIImage+Cropper.h"
#import "REActionSheet.h"

@interface QMGroupDetailsController ()

<UITableViewDelegate, UIActionSheetDelegate, QMContactListServiceDelegate, QMChatServiceDelegate, QMChatConnectionDelegate>

@property (weak, nonatomic) IBOutlet QMImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) QMGroupDetailsDataSource *dataSource;

@property (nonatomic, assign) BOOL shouldNotUnsubFromServices;

@end

@implementation QMGroupDetailsController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeGroupAvatar:)];
    [self.groupAvatarView addGestureRecognizer:tap];
    self.groupAvatarView.layer.cornerRadius = self.groupAvatarView.frame.size.width / 2;
    self.groupAvatarView.layer.masksToBounds = YES;
    
    self.dataSource = [[QMGroupDetailsDataSource alloc] initWithTableView:self.tableView];
    [self updateGUIWithChatDialog:self.chatDialog];
}

- (void)requestOnlineUsers {
    __weak __typeof(self)weakSelf = self;
    [self.chatDialog setOnReceiveListOfOnlineUsers:^(NSMutableArray<NSNumber *> * _Nullable onlineUsers) {
        //
        [weakSelf updateOnlineStatus:onlineUsers.count];
    }];
    [self.chatDialog requestOnlineUsers];
}

- (void)updateOnlineStatus:(NSUInteger)online {
    
    NSString *onlineUsersCountText = [NSString stringWithFormat:@"%zd/%zd online", online, self.chatDialog.occupantIDs.count];
    self.onlineOccupantsCountLabel.text = onlineUsersCountText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.shouldNotUnsubFromServices = NO;

    [[QMApi instance].contactListService addDelegate:self];
    [[QMApi instance].chatService addDelegate:self];
}
  
- (void)viewWillDisappear:(BOOL)animated {
    
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
    
    if (!self.shouldNotUnsubFromServices) {
        [[QMApi instance].contactListService removeDelegate:self];
        [[QMApi instance].chatService removeDelegate:self];
    }
}

- (IBAction)changeDialogName:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    
    [[QMApi instance] changeChatName:self.groupNameField.text forChatDialog:self.chatDialog completion:^(QBChatDialog *updatedDialog) {
        //
        [SVProgressHUD dismiss];
    }];
}

- (void)changeGroupAvatar:(id)sender {
    [self.view endEditing:YES];

    __weak typeof(self)weakSelf = self;
    [QMImagePicker chooseSourceTypeInVC:self allowsEditing:YES result:^(UIImage *image) {
        __typeof(weakSelf)strongSelf = weakSelf;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        [[QMApi instance] changeAvatar:image forChatDialog:strongSelf.chatDialog completion:^(QBChatDialog *updatedDialog) {
            //
            if (updatedDialog != nil) {
                [strongSelf.groupAvatarView sd_setImage:image withKey:updatedDialog.photo];
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

- (void)updateGUI {
    [self.dataSource reloadUserData];
    [self requestOnlineUsers];
}

- (void)updateGUIWithChatDialog:(QBChatDialog *)chatDialog {
    
    NSAssert(self.chatDialog && chatDialog.type == QBChatDialogTypeGroup , @"chatDialog can't be nil and must be group type");
    self.groupNameField.text = chatDialog.name;
    if (chatDialog.photo) {
        [self.groupAvatarView setImageWithURL:[NSURL URLWithString:chatDialog.photo] placeholder:[UIImage imageNamed:@"upic_placeholder_details_group"] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {} completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}];
    }
    [self.dataSource reloadDataWithChatDialog:chatDialog];
    self.chatDialog = chatDialog;
    self.occupantsCountLabel.text = [NSString stringWithFormat:@"%zd participants", self.chatDialog.occupantIDs.count];
    [self requestOnlineUsers];
}

- (NSArray *)filteredIDs:(NSArray *)IDs forChatDialog:(QBChatDialog *)chatDialog
{
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:IDs];
    [newArray removeObjectsInArray:chatDialog.occupantIDs];
    return [newArray copy];
}

- (void)leaveGroupChat
{
    __weak typeof(self)weakSelf = self;
    [SVProgressHUD show];
    [[QMApi instance] leaveChatDialog:self.chatDialog completion:^(NSError * _Nullable error) {
        //
        [SVProgressHUD dismiss];
        if (error == nil) {
            [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        __weak typeof(self)weakSelf = self;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [REActionSheet presentActionSheetInView:tableView configuration:^(REActionSheet *actionSheet) {
            actionSheet.title = @"Are you sure?";
            [actionSheet addCancelButtonWihtTitle:@"Cancel" andActionBlock:^{}];
            [actionSheet addDestructiveButtonWithTitle:@"Leave chat" andActionBlock:^{
                // leave logic:
                [weakSelf leaveGroupChat];
            }];
        }];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMAddMembersToGroupControllerSegue]) {
        self.shouldNotUnsubFromServices = YES;
        
        QMAddMembersToGroupController *addMembersVC = segue.destinationViewController;
        addMembersVC.chatDialog = self.chatDialog;
    }
}

#pragma mark Contact List Serice Delegate

- (void)contactListService:(QMContactListService *)contactListService didReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    if ([self.chatDialog.occupantIDs containsObject:@(userID)]) {
        [self updateGUI];
    }
}

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    [self updateGUI];
}

#pragma mark Chat Service Delegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    if ([chatDialog.ID isEqualToString:self.chatDialog.ID]) {
        [self updateGUIWithChatDialog:chatDialog];
    }
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    if ([chatDialog.ID isEqualToString:self.chatDialog.ID]) {
        [self updateGUIWithChatDialog:chatDialog];
    }
}

@end
