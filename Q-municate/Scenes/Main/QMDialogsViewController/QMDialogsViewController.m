//
//  QMDialogsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDialogsViewController.h"
#import "QMSearchResultsController.h"
#import "QMDialogsDataSource.h"
#import "QMDialogsSearchDataSource.h"
#import "QMDialogCell.h"
#import "QMNoResultsCell.h"
#import "QMSearchDataProvider.h"
#import "QMDialogsSearchDataProvider.h"
#import "QMChatVC.h"
#import "QMCore.h"
#import "QMTasks.h"
#import <SVProgressHUD.h>
#import "QBChatDialog+OpponentID.h"
#import "QMSplitViewController.h"
#import "QMNavigationController.h"
#import "QMNavigationBar.h"
#import <notify.h>

static BOOL isFacebookError(NSError *error) {
    return [error.userInfo[@"error"][@"type"] isEqualToString:@"OAuthException"];
}
static const NSInteger kQMNotAuthorizedInRest = -1000;
static const NSInteger kQMUnauthorizedErrorCode = -1011;

@interface QMDialogsViewController ()

<QMUsersServiceDelegate, QMChatServiceDelegate, QMChatConnectionDelegate,
UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating,
QMPushNotificationManagerDelegate, QMDialogsDataSourceDelegate,
QMSearchResultsControllerDelegate, QMContactListServiceDelegate>

@property (strong, nonatomic) IBOutlet UIView *placeholderView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;
// Data sources
@property (strong, nonatomic) QMDialogsDataSource *dialogsDataSource;
@property (strong, nonatomic) QMDialogsSearchDataSource *dialogsSearchDataSource;
@property (weak, nonatomic) BFTask *loginTask;

@property (strong, nonatomic) id observerWillEnterForeground;

@end

@implementation QMDialogsViewController

//MARK: - Life cycle

- (void)showLoadingWithStatus:(NSString *)status {
    
    if (status) {
        self.navigationItem.title = status;
    }
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    self.navigationItem.leftBarButtonItem = item;
}

- (void)dismissLoadingWithResultStatus:(NSString *)resultStatus {
    
    self.navigationItem.leftBarButtonItem = nil;
    if (resultStatus) {
        self.navigationItem.title = resultStatus;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kQMDefaultNotificationDismissTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.navigationItem.title = @"Chats";
        });
    }
    else {
        self.navigationItem.title = @"Chats";
    }
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillEnterForeground];
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Subscribing delegates
    [QMCore.instance.chatService addDelegate:self];
    [QMCore.instance.usersService addDelegate:self];
    [QMCore.instance.contactListService addDelegate:self];
    // search implementation
    [self configureSearch];
    // Data sources init
    [self configureDataSources];
    // registering nibs for current VC and search results VC
    [self registerNibs];
    
    CATransition *fadeTextAnimation = [CATransition animation];
    fadeTextAnimation.duration = 1.0;
    fadeTextAnimation.type = kCATransitionFade;
    [self.navigationController.navigationBar.layer addAnimation: fadeTextAnimation
                                                         forKey:@"fadeText"];
    [self performAutoLoginAndFetchData];
    // adding refresh control task
    if (self.refreshControl) {
        
        self.refreshControl.backgroundColor = [UIColor clearColor];
        [self.refreshControl addTarget:self
                                action:@selector(updateDataAndEndRefreshing)
                      forControlEvents:UIControlEventValueChanged];
    }
    
    @weakify(self);
    // adding notification for showing chat connection
    self.observerWillEnterForeground =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull __unused note)
     {
         
         if ([QBChat instance].isConnected) {
             // if chat was connected (e.g. we are in call) in background
             // we skip requests, so perform them now as app is active now
             [QMTasks taskFetchAllData];
             [QMTasks taskUpdateContacts];
         }
         else {
             [self performAutoLoginAndFetchData];
         }
     }];
    
    int t_token = 0;
    notify_register_dispatch(kQMDidUpdateDialogsNotification.UTF8String, &t_token, dispatch_get_main_queue(), ^(int __unused token) {
        
        NSDate *lastFetchDate =
        QMCore.instance.currentProfile.lastDialogsFetchingDate;
        @strongify(self);
        [[QMCore.instance.chatService syncLaterDialogsWithCacheFromDate:lastFetchDate] continueWithBlock:^id _Nullable(BFTask<NSArray<QBChatDialog *> *> * _Nonnull t)
         {
             if (t.result.count > 0) {
                 [self.tableView reloadData];
             }
             return nil;
         }];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.searchController.isActive) {
        
        self.tabBarController.tabBar.hidden = YES;
        // smooth rows deselection
        [self qm_smoothlyDeselectRowsForTableView:self.searchResultsController.tableView];
    }
    else {
        
        // smooth rows deselection
        [self qm_smoothlyDeselectRowsForTableView:self.tableView];
    }
    
    if (self.refreshControl.isRefreshing) {
        // fix for freezing refresh control after tab bar switch
        // if it is still active
        CGPoint offset = self.tableView.contentOffset;
        [self.refreshControl endRefreshing];
        [self.refreshControl beginRefreshing];
        self.tableView.contentOffset = offset;
    }
    
    [self.tableView reloadData];
}

- (void)performAutoLoginAndFetchData {
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground
        && !QBChat.instance.manualInitialPresence) {
        // connecting to chat with manual initial presence if in the background
        // this will not send online presence untill app comes foreground
        QBChat.instance.manualInitialPresence = YES;
    }
    
    if (self.loginTask) {
        return;
    }
    
    [self showLoadingWithStatus:NSLocalizedString(@"QM_STR_CONNECTING", nil)];
    
    self.loginTask = [[QMCore.instance login] continueWithBlock:^id(BFTask *task) {
        
        //Perform logout task in case user is not athorized or facebook session is invalidated
        if (task.isFaulted) {
            
            [self dismissLoadingWithResultStatus:nil];
            
            NSInteger errorCode = task.error.code;
            if (errorCode == kQMNotAuthorizedInRest
                || errorCode == kQMUnauthorizedErrorCode
                || isFacebookError(task.error)
                || (errorCode == kBFMultipleErrorsError
                    && ([task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][0] code] == kQMUnauthorizedErrorCode
                        || [task.error.userInfo[BFTaskMultipleErrorsUserInfoKey][1] code] == kQMUnauthorizedErrorCode))) {
                        
                        return [[QMCore.instance logout] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused t) {
                            [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
                            return nil;
                        }];
                    }
        }
        
        [QMTasks taskFetchAllData];
        [QMTasks taskUpdateContacts];
        
        if (QMCore.instance.pushNotificationManager.pushNotification != nil) {
            [QMCore.instance.pushNotificationManager handlePushNotificationWithDelegate:self];
        }
        
        if (QMCore.instance.currentProfile.pushNotificationsEnabled) {
            [QMCore.instance.pushNotificationManager registerAndSubscribeForPushNotifications];
        }
        
        return nil;
        
    }];
}

//MARK: - Init methods

- (void)configureSearch {
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    self.searchResultsController.delegate = self;
    
    self.searchController =
    [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
}

- (void)configureDataSources {
    
    self.dialogsDataSource = [[QMDialogsDataSource alloc] init];
    self.dialogsDataSource.delegate = self;
    self.tableView.dataSource = self.dialogsDataSource;
    
    QMDialogsSearchDataProvider *searchDataProvider = [[QMDialogsSearchDataProvider alloc] init];
    searchDataProvider.delegate = self.searchResultsController;
    
    self.dialogsSearchDataSource =
    [[QMDialogsSearchDataSource alloc] initWithSearchDataProvider:searchDataProvider];
    
    self.tableView.backgroundView = self.placeholderView;
    
    if (QMCore.instance.chatService.dialogsMemoryStorage.unsortedDialogs.count > 0) {
        [self removePlaceholder];
    }
}

//MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        
        QBChatDialog *chatDialog = self.dialogsDataSource.items[indexPath.row];
        if (![chatDialog.ID isEqualToString:QMCore.instance.activeDialogID]) {
            [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
        }
    }
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dialogsDataSource heightForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)__unused tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatDialog *chatDialog = self.dialogsDataSource.items[indexPath.row];
    
    return chatDialog.type == QBChatDialogTypePrivate ?
    NSLocalizedString(@"QM_STR_DELETE", nil) : NSLocalizedString(@"QM_STR_LEAVE", nil);
}

//MARK: - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMNavigationController *chatNavigationController = segue.destinationViewController;
        chatNavigationController.currentAdditionalNavigationBarHeight =
        [(QMNavigationController *)self.navigationController currentAdditionalNavigationBarHeight];
        
        QMChatVC *chatViewController = (QMChatVC *)chatNavigationController.topViewController;
        chatViewController.chatDialog = sender;
    }
}

// MARK: - Overrides

- (void)setAdditionalNavigationBarHeight:(CGFloat)additionalNavigationBarHeight {
    if (!self.searchController.isActive) {
        [super setAdditionalNavigationBarHeight:additionalNavigationBarHeight];
    }
}

//MARK: - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)__unused searchController {
    self.additionalNavigationBarHeight = 0;
    self.searchResultsController.tableView.dataSource = self.dialogsSearchDataSource;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)willDismissSearchController:(UISearchController *)__unused searchController {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)didDismissSearchController:(UISearchController *)__unused searchController {
    self.additionalNavigationBarHeight = [(QMNavigationController *)self.navigationController currentAdditionalNavigationBarHeight];
}

//MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.dialogsSearchDataSource.searchDataProvider performSearch:searchController.searchBar.text];
}

//MARK: - QMSearchResultsControllerDelegate

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController
         willBeginScrollResults:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController
                didSelectObject:(id)object {
    
    [self performSegueWithIdentifier:kQMSceneSegueChat sender:object];
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService
didAddChatDialogsToMemoryStorage:(NSArray *)__unused chatDialogs {
    
    [self removePlaceholder];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didAddChatDialogToMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [self removePlaceholder];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didAddMessagesToMemoryStorage:(NSArray<QBChatMessage *> *)__unused messages
        forDialogID:(NSString *)__unused dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didAddMessageToMemoryStorage:(QBChatMessage *)__unused message
        forDialogID:(NSString *)__unused dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)__unused chatDialogID {
    
    if (self.dialogsDataSource.items.count == 0) {
        self.tableView.backgroundView = self.placeholderView;
        
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            self.navigationItem.searchController = nil;
        }
        else {
            self.tableView.tableHeaderView = nil;
        }
#else
        self.tableView.tableHeaderView = nil;
#endif
        
    }
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService
didReceiveNotificationMessage:(QBChatMessage *)message
       createDialog:(QBChatDialog *)__unused dialog {
    
    if (message.addedOccupantsIDs.count > 0) {
        
        [QMCore.instance.usersService getUsersWithIDs:message.addedOccupantsIDs];
    }
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)__unused dialogs {
    
    [self.tableView reloadData];
}

//MARK: - QMPushNotificationManagerDelegate

- (void)pushNotificationManager:(QMPushNotificationManager *)__unused pushNotificationManager
       didSucceedFetchingDialog:(QBChatDialog *)chatDialog {
    
    [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
}

//MARK: - QMChatConnectionDelegate

- (void)chatServiceChatHasStartedConnecting:(QMChatService *)__unused chatService {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [QMTasks taskFetchAllData];
    }
}

- (void)chatServiceChatDidConnect:(QMChatService *)__unused chatService {
    [self dismissLoadingWithResultStatus:nil];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)__unused chatService {
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [QMTasks taskFetchAllData];
    }
    
    [self dismissLoadingWithResultStatus:nil];
}

- (void)contactListService:(QMContactListService *)__unused contactListService
      contactListDidChange:(QBContactList *)__unused contactList {
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        [QMTasks taskUpdateContacts];
    }
}

//MARK: - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService
didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        [self.tableView reloadData];
    }
}

- (void)usersService:(QMUsersService *)__unused usersService
         didAddUsers:(NSArray<QBUUser *> *)__unused users {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        [self.tableView reloadData];
    }
}

- (void)usersService:(QMUsersService *)__unused usersService
      didUpdateUsers:(NSArray<QBUUser *> *)__unused users {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        [self.tableView reloadData];
    }
}

//MARK: - QMDialogsDataSourceDelegate

- (void)dialogsDataSource:(QMDialogsDataSource *)__unused dialogsDataSource
       commitDeleteDialog:(QBChatDialog *)chatDialog {
    
    NSString *dialogName = chatDialog.name;
    
    if (chatDialog.type == QBChatDialogTypePrivate) {
        
        QBUUser *user = [QMCore.instance.usersService.usersMemoryStorage userWithID:[chatDialog opponentID]];
        dialogName = user.fullName;
    }
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_DELETE_DIALOG", nil), dialogName]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    
                                    [self.tableView setEditing:NO animated:YES];
                                }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_DELETE", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    
                                    BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull __unused task) {
                                        
                                        if ([QMCore.instance.activeDialogID isEqualToString:chatDialog.ID]) {
                                            
                                            [(QMSplitViewController *)self.splitViewController showPlaceholderDetailViewController];
                                        }
                                        
                                        [SVProgressHUD dismiss];
                                        return nil;
                                    };
                                    
                                    [SVProgressHUD show];
                                    if (chatDialog.type == QBChatDialogTypeGroup) {
                                        
                                        chatDialog.occupantIDs = [QMCore.instance.contactManager occupantsWithoutCurrentUser:chatDialog.occupantIDs];
                                        [[QMCore.instance.chatManager leaveChatDialog:chatDialog] continueWithSuccessBlock:completionBlock];
                                    }
                                    else {
                                        // private and public group chats
                                        [[QMCore.instance.chatService deleteDialogWithID:chatDialog.ID] continueWithSuccessBlock:completionBlock];
                                    }
                                }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//MARK: - Helpers

- (void)removePlaceholder {
    
    if (self.tableView.backgroundView) {
        
        self.tableView.backgroundView = nil;
        
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            self.navigationItem.searchController = self.searchController;
            [(QMNavigationBar *)self.navigationController.navigationBar setAdditionalBarShift:52.0f];
            self.navigationItem.hidesSearchBarWhenScrolling = NO;
        }
        else {
            self.tableView.tableHeaderView = self.searchController.searchBar;
        }
#else
        self.tableView.tableHeaderView = self.searchController.searchBar;
#endif
    }
}

- (void)updateDataAndEndRefreshing {
    
    BFTask *fetchAllDataTask = [QMTasks taskFetchAllData];
    BFTask *fetchContactsTask = [QMTasks taskUpdateContacts];
    [[BFTask taskForCompletionOfAllTasks:@[fetchAllDataTask, fetchContactsTask]]
     continueWithBlock:^id (BFTask * __unused t) {
         
         [self.refreshControl endRefreshing];
         
         return nil;
     }];
}

//MARK: - Register nibs

- (void)registerNibs {
    
    [QMDialogCell registerForReuseInTableView:self.tableView];
    [QMDialogCell registerForReuseInTableView:self.searchResultsController.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
}

@end
