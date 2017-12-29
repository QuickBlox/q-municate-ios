//
//  QMUserInfoViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/23/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMUserInfoViewController.h"
#import "QMCore.h"
#import "QMNavigationController.h"
#import "QMChatVC.h"
#import <QMDateUtils.h>
#import <QMImageView.h>
#import "QBChatDialog+OpponentID.h"
#import <SVProgressHUD.h>
#import "QMSplitViewController.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import <NYTPhotoViewer/NYTPhotosViewController.h>

#import "QMImagePreview.h"
#import "QMCallManager.h"
#import "REMessageUI.h"

static const CGFloat kQMStatusCellMinHeight = 65.0f;

typedef NS_ENUM(NSUInteger, QMUserInfoSection) {
    
    QMUserInfoSectionStatus,
    QMUserInfoSectionInfoPhone,
    QMUserInfoSectionInfoEmail,
    QMUserInfoSectionContactInteractions,
    QMUserInfoSectionRemoveContact,
    QMUserInfoSectionAddAction
};

typedef NS_ENUM(NSUInteger, QMContactInteractions) {
    
    QMContactInteractionsSendMessage,
    QMContactInteractionsAudioCall,
    QMContactInteractionsVideoCall
};

@interface QMUserInfoViewController ()

<
QMContactListServiceDelegate,
QMUsersServiceListenerProtocol,

QMImageViewDelegate,
NYTPhotosViewControllerDelegate
>

@property (weak, nonatomic) BFTask *task;

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastSeenLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@property (strong, nonatomic) NSMutableIndexSet *hiddenSections;

@property (strong, nonatomic) NSIndexPath *selectedIndexPathForMenu;

@end

@implementation QMUserInfoViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    
    // removing left bar button item that is responsible for split view
    // display mode managing. Not removing it will cause item update
    // for deallocated navigation item
    self.navigationItem.leftBarButtonItem = nil;
    
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:UIMenuControllerWillShowMenuNotification
                                                object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:UIMenuControllerWillHideMenuNotification
                                                object:nil];
}

- (void)viewDidLoad {
    
    NSAssert(self.user.ID > 0, @"Must be a valid user ID!");
    
    [super viewDidLoad];
    
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(didReceiveMenuWillShowNotification:)
                                               name:UIMenuControllerWillShowMenuNotification
                                             object:nil];
    
    [NSNotificationCenter.defaultCenter  addObserver:self
                                            selector:@selector(didReceiveMenuWillHideNotification:)
                                                name:UIMenuControllerWillHideMenuNotification
                                              object:nil];
    
    if (self.navigationController.viewControllers.count == 1) {
        
        // showing split view display mode buttons
        // only if controller is first in stack
        self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        self.navigationItem.leftItemsSupplementBackButton = YES;
    }
    
    self.hiddenSections = [NSMutableIndexSet indexSet];
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    self.avatarImageView.delegate = self;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // automatic self-sizing cells (used for status cell, due to status label could be multiline)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kQMStatusCellMinHeight;
    
    // subscribing to delegates
    [[QMCore instance].contactListService addDelegate:self];
    [[QMCore instance].usersService addListener:self forUser:self.user];
    // update info table
    [self performDataUpdate];
    [self performLastSeenUpdate];
    
    if (self.user.lastRequestAt == nil) {
        
        [self loadUser];
    }
    
    // adding refresh control task
    if (self.refreshControl) {
        
        self.refreshControl.backgroundColor = [UIColor clearColor];
        [self.refreshControl addTarget:self
                                action:@selector(loadUser)
                      forControlEvents:UIControlEventValueChanged];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // smooth rows deselection
    [self qm_smoothlyDeselectRowsForTableView:self.tableView];
}

//MARK: - Methods

- (void)loadUser {
    
    // get user from server
    
    [[QMCore.instance.usersService getUserWithID:self.user.ID forceLoad:YES] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        [self.refreshControl endRefreshing];
        
        if (!task.isFaulted) {
            
            self.user = task.result;
            [self performDataUpdate];
            [self performLastSeenUpdate];
            [self.tableView reloadData];
        }
        
        return nil;
    }];
}

- (void)performDataUpdate {
    
    [self.hiddenSections removeAllIndexes];
    
    [self updateFullName];
    [self updateAvatarImage];
    [self updateUserIteractions];
    [self updateStatus];
    [self updateInfo];
}

- (void)performLastSeenUpdate {
    
    self.lastSeenLabel.text = [[QMCore instance].contactManager onlineStatusForUser:self.user];
}

- (void)updateFullName {
    
    // Full name
    self.fullNameLabel.text = self.user.fullName;
}

- (void)updateAvatarImage {
    // Avatar
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.user.avatarUrl]
                                    title:self.user.fullName
                           completedBlock:nil];
}

- (void)updateUserIteractions {
    
    BOOL isFriend = [QMCore.instance.contactManager isFriendWithUserID:self.user.ID];
    if (isFriend) {
        
        [self.hiddenSections addIndex:QMUserInfoSectionAddAction];
    }
    else {
        
        [self.hiddenSections addIndex:QMUserInfoSectionContactInteractions];
        
        BOOL isAwaitingForApproval = [QMCore.instance.contactManager isContactListItemExistentForUserWithID:self.user.ID];
        if (isAwaitingForApproval) {
            
            [self.hiddenSections addIndex:QMUserInfoSectionAddAction];
        }
        else {
            
            [self.hiddenSections addIndex:QMUserInfoSectionRemoveContact];
        }
    }
}

- (void)updateStatus {
    // Status
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    if ([self.user.status stringByTrimmingCharactersInSet:whiteSpaceSet].length > 0) {
        
        self.statusLabel.text = self.user.status;
    }
    else {
        
        [self.hiddenSections addIndex:QMUserInfoSectionStatus];
    }
}

- (void)updateInfo {
    // Phone
    if (self.user.phone.length > 0) {
        
        self.phoneLabel.text = self.user.phone;
    }
    else {
        
        [self.hiddenSections addIndex:QMUserInfoSectionInfoPhone];
    }
    
    // Email
    if (self.user.email.length > 0) {
        
        self.emailLabel.text = self.user.email;
    }
    else {
        
        [self.hiddenSections addIndex:QMUserInfoSectionInfoEmail];
    }
}

//MARK: - Actions

- (void)sendMessageAction {
    
    __block BOOL chatDialogFound = NO;
    
    @weakify(self);
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger __unused idx, BOOL * _Nonnull stop) {
        // enumerating through all view controllers due to
        // navigation stack could have more than one chat view controller
        @strongify(self);
        if ([obj isKindOfClass:[QMChatVC class]]) {
            
            QBChatDialog *chatDialog = [(QMChatVC *)obj chatDialog];
            if ([chatDialog opponentID] == self.user.ID) {
                
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
    
    QBChatDialog *privateChatDialog = [QMCore.instance.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:self.user.ID];
    
    if (privateChatDialog) {
        
        [self performSegueWithIdentifier:kQMSceneSegueChat sender:privateChatDialog];
    }
    else {
        
        if (self.task) {
            // task in progress
            return;
        }
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
        
        __weak UINavigationController *navigationController = self.navigationController;
        
        self.task = [[QMCore.instance.chatService createPrivateChatDialogWithOpponentID:self.user.ID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
            
            @strongify(self);
            [(QMNavigationController *)navigationController dismissNotificationPanel];
            
            if (!task.isFaulted) {
                
                [self performSegueWithIdentifier:kQMSceneSegueChat sender:task.result];
            }
            
            return nil;
        }];
    }
}

- (BOOL)callAllowed {
    
    if (![QMCore.instance isInternetConnected]) {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
        return NO;
    }
    
    if (![QBChat instance].isConnected) {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeFailed message:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) duration:kQMDefaultNotificationDismissTime];
        return NO;
    }
    
    return YES;
}

- (void)callActionWithConferenceType:(QBRTCConferenceType)conferenceType {
    
    if (![self callAllowed]) {
        return;
    }
    
    [QMCore.instance.callManager callToUserWithID:self.user.ID conferenceType:conferenceType];
}

- (void)audioCallAction {
    
    [self callActionWithConferenceType:QBRTCConferenceTypeAudio];
}

- (void)videoCallAction {
    
    [self callActionWithConferenceType:QBRTCConferenceTypeVideo];
}

- (void)cellularCallAction {
    
    NSParameterAssert(self.user.phone.length > 0);
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:self.user.phone
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    void (^makeCallAction)(UIAlertAction *action) = ^void(UIAlertAction * __unused action) {
        
        NSError *error = nil;
        
        if (![self canMakeAPhoneCall:&error]) {
            
            [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning
                                                                                  message:error.localizedDescription
                                                                                 duration:kQMDefaultNotificationDismissTime];
        }
        else {
            NSString *cleanedPhoneNumber = [self formatPhoneUrl:self.user.phone];
            NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", cleanedPhoneNumber]];
            [UIApplication.sharedApplication openURL:telURL];
        }
    };
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CALL", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:makeCallAction]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)removeContactAction {
    
    if (self.task) {
        // task in progress
        return;
    }
    
    if (![QMCore.instance isInternetConnected]) {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_DELETE_CONTACT", nil), self.user.fullName]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    void (^removeAction)(UIAlertAction *action) = ^void(UIAlertAction * __unused action) {
        
        [SVProgressHUD show];
        
        self.task = [[QMCore.instance.contactManager removeUserFromContactList:self.user]
                     continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task)
                     {
                         if (self.splitViewController.isCollapsed) {
                             [self.navigationController popViewControllerAnimated:YES];
                         }
                         else {
                             [(QMSplitViewController *)self.splitViewController showPlaceholderDetailViewController];
                         }
                         [SVProgressHUD dismiss];
                         
                         return nil;
                     }];
    };
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:removeAction]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)addUserAction {
    
    if (self.task) {
        // task in progress
        return;
    }
    
    if (![QMCore.instance isInternetConnected]) {
        
        [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
        return;
    }
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    
    self.task = [[QMCore.instance.contactManager addUserToContactList:self.user] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        [navigationController dismissNotificationPanel];
        return nil;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMChatVC *chatViewController = segue.destinationViewController;
        chatViewController.chatDialog = sender;
    }
}

//MARK: - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.hiddenSections containsIndex:section]) {
        
        return 0;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

//MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMUserInfoSectionInfoPhone) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self cellularCallAction];
    }
    else if (indexPath.section == QMUserInfoSectionInfoEmail) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if (indexPath.section == QMUserInfoSectionContactInteractions) {
        
        switch (indexPath.row) {
                
            case QMContactInteractionsSendMessage:
                [self sendMessageAction];
                break;
                
            case QMContactInteractionsAudioCall:
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self audioCallAction];
                break;
                
            case QMContactInteractionsVideoCall:
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self videoCallAction];
                break;
        }
    }
    else if (indexPath.section == QMUserInfoSectionRemoveContact) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self removeContactAction];
    }
    else if (indexPath.section == QMUserInfoSectionAddAction) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self addUserAction];
    }
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)section {
    
    if (![self shouldHaveHeaderForSection:section]) {
        
        return CGFLOAT_MIN;
    }
    
    return 24.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (![self shouldHaveHeaderForSection:section]) {
        
        return [super tableView:tableView viewForHeaderInSection:section];
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor whiteColor];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMUserInfoSectionStatus
        && indexPath.row == 0) {
        // due to status could be multiline, need to automatically resize it
        return UITableViewAutomaticDimension;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


- (void)tableView:(UITableView *)__unused tableView
    performAction:(SEL)action
forRowAtIndexPath:(NSIndexPath *)indexPath
       withSender:(id)__unused sender{
    
    if (action == @selector(copy:)) {
        
        NSString *textToCopy = nil;
        if (indexPath.section == QMUserInfoSectionInfoEmail) {
            textToCopy = self.user.email;
        }
        else if (indexPath.section == QMUserInfoSectionInfoPhone) {
            textToCopy = self.user.phone;
        }
        else if (indexPath.section == QMUserInfoSectionStatus) {
            textToCopy = self.user.status;
        }
        
        if (textToCopy) {
            UIPasteboard.generalPasteboard.string = textToCopy;
        }
    }
}

- (BOOL)tableView:(UITableView *)__unused tableView
shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedIndexPathForMenu = indexPath;
    
    return indexPath.section == QMUserInfoSectionInfoEmail
    || indexPath.section == QMUserInfoSectionInfoPhone
    || indexPath.section == QMUserInfoSectionStatus;
    
}

- (BOOL) tableView:(UITableView *)__unused tableView
  canPerformAction:(SEL)action
 forRowAtIndexPath:(NSIndexPath *)__unused indexPath
        withSender:(id)__unused sender{
    
    return action == @selector(copy:);
}



//MARK: - QMContactListServiceDelegate

- (void)contactListServiceDidLoadCache {
    
    [self performDataUpdate];
    [self performLastSeenUpdate];
    [self.tableView reloadData];
}

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self performDataUpdate];
    [self performLastSeenUpdate];
    [self.tableView reloadData];
}

//MARK: - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)__unused imageView {
    
    NSString *avatarURL = self.user.avatarUrl;
    if (avatarURL.length > 0) {
        
        [QMImagePreview previewImageWithURL:[NSURL URLWithString:avatarURL] inViewController:self];
    }
}

//MARK: - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.avatarImageView;
}

// MARK: - QMUsersServiceListenerProtocol

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUser:(QBUUser *)user {
    self.user = user;
    [self performDataUpdate];
    [self.tableView reloadData];
}

//MARK: - Helpers

- (BOOL)shouldHaveHeaderForSection:(NSInteger)section {
    
    if (section == QMUserInfoSectionStatus) {
        
        return NO;
    }
    
    if ([self.hiddenSections containsIndex:section]) {
        
        return NO;
    }
    
    if (section == QMUserInfoSectionInfoEmail
        && ![self.hiddenSections containsIndex:QMUserInfoSectionInfoPhone]
        && ![self.hiddenSections containsIndex:QMUserInfoSectionInfoEmail]) {
        
        return NO;
    }
    
    return YES;
}

- (BOOL)canMakeAPhoneCall:(NSError **)error {
    
    // Check if the device can place a phone call
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        // Device supports phone calls
        CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        NSString *mnc = [carrier mobileNetworkCode];
        
        if (([mnc length] == 0) || ([mnc isEqualToString:@"65535"])) {
            // The device can't place a call at this time.  SIM might be removed.
            *error =
            [self errorWithLocalizedDescription:NSLocalizedString(@"QM_STR_CELLULAR_ERROR_CAN_NOT_MAKE_CALL", nil)];
            
            return NO;
        }
        else {
            // Device can place a phone call
            return YES;
        }
    } else {
        // Device does not support phone calls
        *error =
        [self errorWithLocalizedDescription:NSLocalizedString(@"QM_STR_CELLULAR_ERROR_NOT_SUPPORTED",nil)];
        
        return  NO;
    }
}

- (NSString *)formatPhoneUrl:(NSString *)phone {
    
    unichar cleanPhone[phone.length];
    int cleanPhoneLength = 0;
    
    int length = (int)phone.length;
    for (int i = 0; i < length; i++) {
        unichar c = [phone characterAtIndex:i];
        if (!(c == ' ' || c == '(' || c == ')' || c == '-'))
            cleanPhone[cleanPhoneLength++] = c;
    }
    
    return [[NSString alloc] initWithCharacters:cleanPhone length:cleanPhoneLength];
}

- (NSError *)errorWithLocalizedDescription:(NSString *)localizedDescription {
    
    return [NSError errorWithDomain:@""
                               code:0
                           userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
}

//MARK:- Notifications

- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification {
    
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    UIMenuController *menu = [notification object];
    [menu setMenuVisible:NO animated:NO];
    
    NSInteger section = self.selectedIndexPathForMenu.section;
    
    UILabel *targetLabel;
    
    if (section == QMUserInfoSectionStatus) {
        targetLabel = self.statusLabel;
    }
    else if (section == QMUserInfoSectionInfoEmail) {
        targetLabel = self.emailLabel;
    }
    else if (section == QMUserInfoSectionInfoPhone) {
        targetLabel = self.phoneLabel;
    }
    
    NSParameterAssert(targetLabel);
    
    CGRect selectedCellFrame = CGRectZero;
    selectedCellFrame.origin.x = targetLabel.intrinsicContentSize.width/2;
    
    [menu setTargetRect:selectedCellFrame inView:targetLabel];
    [menu setMenuVisible:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
}

- (void)didReceiveMenuWillHideNotification:(NSNotification *)__unused notification {
    self.selectedIndexPathForMenu = nil;
}

@end
