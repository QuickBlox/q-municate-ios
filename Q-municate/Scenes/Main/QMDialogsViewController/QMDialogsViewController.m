//
//  QMDialogsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 1/13/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMDialogsViewController.h"
#import "QMDialogsDataSource.h"
#import "QMPlaceholderDataSource.h"
#import "QMLocalSearchDataSource.h"
#import "QMGlobalSearchDataSource.h"
#import "QMSearchResultsController.h"
#import "QMDialogCell.h"
#import "QMContactCell.h"
#import "QMSearchDataProvider.h"
#import "QMLocalSearchDataProvider.h"
#import "QMGlobalSearchDataProvider.h"
#import "QMChatVC.h"

#import "QMCore.h"
#import "QMTasks.h"
#import "QMProfile.h"
#import "QMTitleView.h"

#import <SVProgressHUD.h>

typedef NS_ENUM(NSUInteger, QMSearchScopeButtonIndex) {
    
    QMSearchScopeButtonIndexLocal,
    QMSearchScopeButtonIndexGlobal
};

@interface QMDialogsViewController ()

<
QMUsersServiceDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate,
UITableViewDelegate,
UISearchControllerDelegate,
UISearchBarDelegate,
UISearchResultsUpdating
>

/**
 *  Data sources
 */
@property (strong, nonatomic) QMDialogsDataSource *dialogsDataSource;
@property (strong, nonatomic) QMPlaceholderDataSource *placeholderDataSource;
@property (strong, nonatomic) QMLocalSearchDataSource *localSearchDataSource;
@property (strong, nonatomic) QMGlobalSearchDataSource *globalSearchDataSource;

@property (weak, nonatomic) IBOutlet QMTitleView *titleView;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

@end

@implementation QMDialogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Data sources init
    [self configureDataSources];
    
    // search implementation
    [self configureSearch];
    
    // Subscribing delegates
    [[QMCore instance].chatService addDelegate:self];
    [[QMCore instance].usersService addDelegate:self];
    
    // Profile title view
    [self configureProfileTitleView];
    
    // auto login user
    [self performAutoLoginAndFetchData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init methods

- (void)configureDataSources {
    
    self.dialogsDataSource = [[QMDialogsDataSource alloc] init];
    self.placeholderDataSource  = [[QMPlaceholderDataSource alloc] init];
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    
    QMLocalSearchDataProvider *localSearchDataProvider = [[QMLocalSearchDataProvider alloc] init];
    localSearchDataProvider.delegate = self.searchResultsController;
    
    QMGlobalSearchDataProvider *globalSearchDataProvider = [[QMGlobalSearchDataProvider alloc] init];
    globalSearchDataProvider.delegate = self.searchResultsController;
    
    self.localSearchDataSource = [[QMLocalSearchDataSource alloc] initWithSearchDataProvider:localSearchDataProvider];
    self.globalSearchDataSource = [[QMGlobalSearchDataSource alloc] initWithSearchDataProvider:globalSearchDataProvider];
    
    self.tableView.delegate = self;
}

- (void)configureSearch {
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"QM_STR_LOCAL_SEARCH", nil), NSLocalizedString(@"QM_STR_GLOBAL_SEARCH", nil)];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)configureProfileTitleView {
    
    QBUUser *currentUser = [QMCore instance].currentProfile.userData;
    [self.titleView setText:currentUser.fullName];
    self.titleView.placeholderID = currentUser.ID;
    [self.titleView setAvatarUrl:currentUser.avatarUrl];
}

- (void)performAutoLoginAndFetchData {
    
    @weakify(self);
    [[[[QMTasks taskAutoLogin] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        @strongify(self);
        
        if (task.isFaulted) {
            [[[QMCore instance] logout] continueWithBlock:^id _Nullable(BFTask * _Nonnull logoutTask) {
                
                [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
                return nil;
            }];
            
            return [BFTask cancelledTask];
        } else {
            
            return [[QMCore instance].chatService connect];
        }
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        return [QMTasks taskFetchAllData];
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        @strongify(self);
        self.tableView.dataSource = self.dialogsDataSource.items.count > 0 ? self.dialogsDataSource : self.placeholderDataSource;
        [self.tableView reloadData];
        return nil;
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        
        QBChatDialog *chatDialog = self.dialogsDataSource.items[indexPath.row];
        [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.dialogsDataSource.items.count > 0 ? [QMDialogCell height] : tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NSLocalizedString(@"QM_STR_DELETE", nil);
}

#pragma mark - Actions

- (IBAction)didPressProfileTitle:(id)sender {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMChatVC *chatViewController = segue.destinationViewController;
        chatViewController.chatDialog = sender;
    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    
    self.searchResultsController.tableView.dataSource = self.localSearchDataSource;
    [self.searchResultsController.tableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    
    if (selectedScope == QMSearchScopeButtonIndexLocal) {
        
        self.searchResultsController.tableView.dataSource = self.localSearchDataSource;
    }
    else if (selectedScope == QMSearchScopeButtonIndexGlobal) {
        
        self.searchResultsController.tableView.dataSource = self.globalSearchDataSource;
    }
    else {
        
        NSAssert(nil, @"Unknown selected scope");
    }
    
    [self.searchResultsController.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    [self.searchResultsController performSearch:searchController.searchBar.text];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
    
    [self checkIfDialogsDataSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    
    [self checkIfDialogsDataSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray<QBChatMessage *> *)messages forDialogID:(NSString *)dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    
    if (self.dialogsDataSource.items.count == 0) {
        self.tableView.dataSource = self.placeholderDataSource;
    }
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didLoadChatDialogsFromCache:(NSArray *)dialogs withUsers:(NSSet *)dialogsUsersIDs {
    
    if (dialogs.count > 0) {
        self.tableView.dataSource = self.dialogsDataSource;
    }
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    [self.tableView reloadData];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)users {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        [self.tableView reloadData];
    }
}

- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray<QBUUser *> *)user {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        [self.tableView reloadData];
    }
}

#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_CHAT_CONNECTED", nil) maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_CHAT_RECONNECTED", nil) maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatService:(QMChatService *)chatService chatDidNotConnectWithError:(NSError *)error
{
    //    if ([[QMApi instance] isInternetConnected]) {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CHAT_FAILED_TO_CONNECT_WITH_ERROR", nil), error.localizedDescription]];
    //    }
}

- (void)chatServiceChatDidFailWithStreamError:(NSError *)error
{
    //    if ([[QMApi instance] isInternetConnected]) {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CHAT_FAILED_TO_CONNECT_WITH_STREAM_ERROR", nil), error.localizedDescription]];
    //    }
}

#pragma mark - Helpers

- (void)checkIfDialogsDataSource {
    
    if (![self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        self.tableView.dataSource = self.dialogsDataSource;
    }
}

#pragma mark - Register nibs

- (void)registerNibs {
    
    [QMDialogCell registerForReuseInTableView:self.tableView];
    [QMContactCell registerForReuseInTableView:self.tableView];
}

@end
