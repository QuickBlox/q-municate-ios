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
#import "QMPlaceholderDataSource.h"
#import "QMDialogsSearchDataSource.h"
#import "QMDialogCell.h"
#import "QMNoResultsCell.h"
#import "QMSearchDataProvider.h"
#import "QMDialogsSearchDataProvider.h"
#import "QMChatVC.h"
#import "QMCore.h"
#import "QMNotification.h"

@interface QMDialogsViewController ()

<
QMUsersServiceDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate,

UITableViewDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating,

QMSearchResultsControllerDelegate
>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

/**
 *  Data sources
 */
@property (strong, nonatomic) QMDialogsDataSource *dialogsDataSource;
@property (strong, nonatomic) QMPlaceholderDataSource *placeholderDataSource;
@property (strong, nonatomic) QMDialogsSearchDataSource *dialogsSearchDataSource;

@property (weak, nonatomic) BFTask *addUserTask;

@end

@implementation QMDialogsViewController

#pragma mark - Life cycle

+ (instancetype)dialogsViewController {
    
    return [[UIStoryboard storyboardWithName:kQMMainStoryboard bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
}

- (void)dealloc {
    
    [self.searchController.view removeFromSuperview];
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0,
                                                   0,
                                                   CGRectGetHeight(self.tabBarController.tabBar.frame),
                                                   0);
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // search implementation
    [self configureSearch];
    
    // Data sources init
    [self configureDataSources];
    
    // registering nibs for current VC and search results VC
    [self registerNibs];
    
    // Subscribing delegates
    [[QMCore instance].chatService addDelegate:self];
    [[QMCore instance].usersService addDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.searchController.isActive) {
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.searchController.isActive) {
        
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
}

#pragma mark - Init methods

- (void)configureSearch {
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    self.searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)configureDataSources {
    
    self.dialogsDataSource = [[QMDialogsDataSource alloc] init];
    self.placeholderDataSource  = [[QMPlaceholderDataSource alloc] init];
    
    self.tableView.dataSource = self.placeholderDataSource;
    
    QMDialogsSearchDataProvider *searchDataProvider = [[QMDialogsSearchDataProvider alloc] init];
    searchDataProvider.delegate = self.searchResultsController;
    
    self.dialogsSearchDataSource = [[QMDialogsSearchDataSource alloc] initWithSearchDataProvider:searchDataProvider];
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
    
    return self.dialogsDataSource.items.count > 0 ? [self.dialogsDataSource heightForRowAtIndexPath:indexPath] : CGRectGetHeight(tableView.bounds) - tableView.contentInset.top - tableView.contentInset.bottom;
}

- (NSString *)tableView:(UITableView *)__unused tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    
    return NSLocalizedString(@"QM_STR_DELETE", nil);
}

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMChatVC *chatViewController = segue.destinationViewController;
        chatViewController.chatDialog = sender;
    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)__unused searchController {
    
    self.searchResultsController.tableView.dataSource = self.dialogsSearchDataSource;
    
    self.tabBarController.tabBar.hidden = YES;
}

- (void)willDismissSearchController:(UISearchController *)__unused searchController {
    
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    [self.dialogsSearchDataSource.searchDataProvider performSearch:searchController.searchBar.text];
}

#pragma mark - QMSearchResultsControllerDelegate

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController willBeginScrollResults:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController didSelectObject:(id)object {
    
    [self performSegueWithIdentifier:kQMSceneSegueChat sender:object];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didAddChatDialogsToMemoryStorage:(NSArray *)__unused chatDialogs {
    
    [self checkIfDialogsDataSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [self checkIfDialogsDataSource];
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didAddMessagesToMemoryStorage:(NSArray<QBChatMessage *> *)__unused messages forDialogID:(NSString *)__unused dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didAddMessageToMemoryStorage:(QBChatMessage *)__unused message forDialogID:(NSString *)__unused dialogID {
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)__unused chatDialogID {
    
    if (self.dialogsDataSource.items.count == 0) {
        self.tableView.dataSource = self.placeholderDataSource;
    }
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didLoadChatDialogsFromCache:(NSArray *)dialogs withUsers:(NSSet *)__unused dialogsUsersIDs {
    
    if (dialogs.count > 0) {
        self.tableView.dataSource = self.dialogsDataSource;
    }
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)__unused dialog {
    
    if (message.messageType == QMMessageTypeContactRequest) {
        
        [[QMCore instance].usersService getUserWithID:message.senderID];
    }
    else if (message.addedOccupantsIDs.count > 0) {
        
        [[QMCore instance].usersService getUsersWithIDs:message.addedOccupantsIDs];
    }
    
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)__unused chatDialog {
    
    [self.tableView reloadData];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        
        [self.tableView reloadData];
    }
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)__unused user {
    
    if ([self.tableView.dataSource isKindOfClass:[QMDialogsDataSource class]]) {
        
        [self.tableView reloadData];
    }
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
    [QMDialogCell registerForReuseInTableView:self.searchResultsController.tableView];
    
    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
}

@end
