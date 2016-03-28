//
//  QMUserInfoViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMUserInfoViewController.h"
#import "QMCore.h"
#import "QMPlaceholder.h"
#import "QMChatVC.h"
#import "REAlertView.h"
#import <QMDateUtils.h>
#import <QMImageView.h>

static const CGFloat kQMStatusCellMinHeight = 65.0f;

typedef NS_ENUM(NSUInteger, QMUserInfoSection) {
    
    QMUserInfoSectionStatus,
    QMUserInfoSectionInfo,
    QMUserInfoSectionContactInteractions,
    QMUserInfoSectionAddAction
};

@interface QMUserInfoViewController ()

<
QMContactListServiceDelegate
>

@property (weak, nonatomic) BFTask *task;

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastSeenLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (strong, nonatomic) NSMutableIndexSet *hiddenSections;

@end

@implementation QMUserInfoViewController

+ (instancetype)userInfoViewControllerWithUser:(QBUUser *)user {
    
    QMUserInfoViewController *userInfoViewController = [[UIStoryboard storyboardWithName:kQMChatStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    userInfoViewController.user = user;
    
    return userInfoViewController;
}

- (void)viewDidLoad {
    
    NSAssert(self.user.ID > 0, @"Must be a valid user ID!");
    
    [super viewDidLoad];
    
    self.hiddenSections = [NSMutableIndexSet indexSet];
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // automatic self-sizing cells (used for status cell, due to status label could be multiline)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kQMStatusCellMinHeight;
    
    // subscribing to delegates
    [[QMCore instance].contactListService addDelegate:self];
    
    // update info table
    [self updateInfo];
    
    if (self.user.lastRequestAt == nil) {
        
        // get user from server
        @weakify(self);
        [[[QMCore instance].usersService getUserWithID:self.user.ID] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
            
            @strongify(self);
            self.user = task.result;
            [self updateInfo];
            [self.tableView reloadData];
            
            return nil;
        }];
    }
}

#pragma mark - Helpers

- (void)updateInfo {
    
    [self.hiddenSections removeAllIndexes];
    
    // Full name
    self.fullNameLabel.text = self.user.fullName;
    
    // Avatar
    UIImage *placeholder = [QMPlaceholder placeholderWithFrame:self.avatarImageView.bounds title:self.user.fullName ID:self.user.ID];
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.user.avatarUrl]
                              placeholder:placeholder
                                  options:SDWebImageHighPriority
                                 progress:nil
                           completedBlock:nil];
    
    // contact list item
    QBContactListItem *contactListItem = [[QMCore instance].contactListService.contactListMemoryStorage contactListItemWithUserID:self.user.ID];
    
    BOOL isFriend = [[QMCore instance].contactManager isFriendWithUserID:self.user.ID];
    if (isFriend) {
        
        [self.hiddenSections addIndex:QMUserInfoSectionAddAction];
    }
    else {
        
        [self.hiddenSections addIndex:QMUserInfoSectionContactInteractions];
        
        BOOL isAwaitingForApproval = [[QMCore instance].contactManager isAwaitingForApprovalFromUserID:self.user.ID];
        if (isAwaitingForApproval) {
            
            [self.hiddenSections addIndex:QMUserInfoSectionAddAction];
        }
    }
    
    // Last seen
    if (contactListItem.isOnline) {
        
        self.lastSeenLabel.text = NSLocalizedString(@"QM_STR_ONLINE", nil);
    }
    else if (self.user.lastRequestAt) {
        
        self.lastSeenLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"QM_STR_LAST_SEEN", nil), [QMDateUtils formattedLastSeenString:self.user.lastRequestAt withTimePrefix:NSLocalizedString(@"QM_STR_TIME_PREFIX", nil)]];
    }
    else {
        
        self.lastSeenLabel.text = NSLocalizedString(@"QM_STR_OFFLINE", nil);
    }
    
    // Status
    if (self.user.status.length > 0) {
        
        self.statusLabel.text = self.user.status;
    }
    else {
        
        [self.hiddenSections addIndex:QMUserInfoSectionStatus];
    }
    
    if (self.user.email.length > 0 || self.user.phone.length > 0) {
        
        // Phone
        self.phoneLabel.text = self.user.phone.length > 0 ? self.user.phone : NSLocalizedString(@"QM_STR_NONE", nil);
        // Email
        self.emailLabel.text = self.user.email.length > 0 ? self.user.email : NSLocalizedString(@"QM_STR_NONE", nil);
    }
    else {
        
        // hide section
        [self.hiddenSections addIndex:QMUserInfoSectionInfo];
    }
}

#pragma mark - Actions

- (IBAction)sendMessageButtonPressed {
    
    __block BOOL chatDialogFound = NO;
    
    @weakify(self);
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull stop) {
        
        @strongify(self);
        if ([obj isKindOfClass:[QMChatVC class]]) {
            
            QBChatDialog *chatDialog = [(QMChatVC *)obj chatDialog];
            if (chatDialog.recipientID == (NSInteger)self.user.ID) {
                
                [self.navigationController popToViewController:obj animated:YES];
                *stop = YES;
                chatDialogFound = YES;
            }
        }
    }];
    
    if (chatDialogFound) {
        // chat dialog was found in navigation stack
        return;
    }
    
    QBChatDialog *privateChatDialog = [[QMCore instance].chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:self.user.ID];
    
    if (privateChatDialog) {
        
        [self performSegueWithIdentifier:kQMSceneSegueChat sender:privateChatDialog];
    }
    else {
        
        if (self.task) {
            // task in progress
            return;
        }
        
        self.task = [[[QMCore instance].chatService createPrivateChatDialogWithOpponentID:self.user.ID] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
            
            @strongify(self);
            [self performSegueWithIdentifier:kQMSceneSegueChat sender:task.result];
            return nil;
        }];
    }
}

- (IBAction)audioCallButtonPressed {
#warning TODO: audio call
}

- (IBAction)videoCallButtonPressed {
#warning TODO: video call
}

- (IBAction)deleteChatHistoryButtonPressed {
#warning TODO: delete all chat history from server and locally
}

- (IBAction)removeContactButtonPressed {
    
    @weakify(self);
    [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
        
        @strongify(self);
        alertView.message = [NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_DELETE_CONTACT", nil), self.user.fullName];
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{}];
        [alertView addButtonWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil) andActionBlock:^{
            
            [[[QMCore instance].contactManager removeUserFromContactList:self.user] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
                
                [self updateInfo];
                [self.tableView reloadData];
                return nil;
            }];
        }];
    }];
}

- (IBAction)addUserButtonPressed {
    
    if (self.task) {
        // task in progress
        return;
    }
    
    @weakify(self);
    self.task = [[[QMCore instance].contactManager addUserToContactList:self.user] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        @strongify(self);
        [self updateInfo];
        [self.tableView reloadData];
        return nil;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMChatVC *chatVC = segue.destinationViewController;
        chatVC.chatDialog = sender;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.hiddenSections containsIndex:section]) {
        
        return 0;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMUserInfoSectionStatus) {
        // due to status could be multiline, need to automatically resize it
        return UITableViewAutomaticDimension;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListServiceDidLoadCache {
    
    [self updateInfo];
    [self.tableView reloadData];
}

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self updateInfo];
    [self.tableView reloadData];
}

@end
