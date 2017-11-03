//
//  QMShareDialogsTableViewController.m
//  QMShareExtension
//
//  Created by Vitaliy Gurkovsky on 10/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareDialogsTableViewController.h"
#import <Quickblox/Quickblox.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "QMShareTableViewCell.h"
#import "QMExtensionCache.h"
#import "QMColors.h"
#import <UIKit/UIKit.h>
#import "QMShareDataSource.h"
#import "QMShareItemsDataProvider.h"
#import "QMSearchResultsController.h"
#import "QMNoResultsCell.h"
#import "QMImages.h"
#import "QMShareContactsTableViewCell.h"
#import "QBChatDialog+QMShareItemProtocol.h"
#import "NSURL+QMShareExtension.h"
#import "QMShareTasks.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "QMLog.h"
#import <QMServicesDevelopment/QMServices.h>
#import "QMShareEtxentionOperation.h"
#import <Reachability/Reachability.h>
#import "QBSettings+Qmunicate.h"


//SVProgressHUD for extension
#define SV_APP_EXTENSIONS 1

@interface QMShareDialogsTableViewController () <
QMSearchDataProviderDelegate,
QMSearchResultsControllerDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating,
UISearchBarDelegate,
QMShareEtxentionOperationDelegate>

@property (strong, nonatomic) QMShareDataSource *tableViewDataSource;
@property (strong, nonatomic) QMShareSearchControllerDataSource *searchDataSource;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

@property (strong, nonatomic) QMShareEtxentionOperation *shareOperation;

@property (strong, nonatomic) id logoutObserver;

@property (strong, nonatomic) Reachability *internetConnection;

@end

@implementation QMShareDialogsTableViewController

- (BFTask <NSString*> *)dialogIDForUser:(QBUUser *)user {
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(QBChatDialog*_Nullable dialog, NSDictionary<NSString *,id> * _Nullable __unused bindings) {
        return dialog.type == QBChatDialogTypePrivate && [dialog.occupantIDs containsObject:@(user.ID)];
    }];
    
    QBChatDialog *dialog = [[QMExtensionCache.chatCache.allDialogs filteredArrayUsingPredicate:predicate] firstObject];
    
    if (dialog) {
        return [BFTask taskWithResult:dialog.ID];
    }
    else {
        return [[self createPrivateChatWithOpponentID:user.ID] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull t) {
            if (t.error) {
                return [BFTask taskWithError:t.error];
            }
            else {
                return [BFTask taskWithResult:t.result.ID];
            }
        }];
    }
}

- (BFTask <QBChatDialog *>*)createPrivateChatWithOpponentID:(NSUInteger)opponentID {
    
    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:nil
                                                                 type:QBChatDialogTypePrivate];
    chatDialog.occupantIDs = @[@(opponentID)];
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest createDialog:chatDialog successBlock:^(QBResponse *__unused response, QBChatDialog *createdDialog) {
            [source setResult:createdDialog];
            
        } errorBlock:^(QBResponse *__unused response) {
            [source setError:response.error.error];
        }];
    });
}


- (void)configure {
    
    // Quickblox settings
    [QBSettings setQmunicateSettings];
    
    QMLogSetEnabled(YES);
    QMLog(@"Configure extension");
    [[UISearchBar appearance] setBarTintColor:QMSecondaryApplicationColor()];
    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBackgroundImage:QMStatusBarBackgroundImage() forBarPosition:0 barMetrics:UIBarMetricsDefault];
    
    
    [[UITextField appearance] setTintColor:QMSecondaryApplicationColor()];
    [UITextField appearance].keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem.tintColor = QMSecondaryApplicationColor();
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(shareAction)];
    self.navigationItem.rightBarButtonItem.tintColor = QMSecondaryApplicationColor();
    
    [SVProgressHUD setViewForExtension:self.navigationController.view];
    
    [self updateShareButton];
    
    
    [self configureReachability];
}

- (void)configureReachability {
    
    _internetConnection = [Reachability reachabilityForInternetConnection];
    
    // setting unreachable block
    [_internetConnection setUnreachableBlock:^(Reachability __unused *reachability) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // reachability block could possibly be called in background thread
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil)];
        });
    }];
    
    [_internetConnection startNotifier];
}

- (void)dismiss {
    
    if (self.extensionContext) {
        [self hideExtensionControllerWithCompletion:^{
            [self.extensionContext completeRequestReturningItems:nil
                                               completionHandler:nil];
        }];
    }
    else {
        [self dismissViewControllerAnimated:YES
                                 completion:NULL];
    }
}



- (void)shareAction {
    
    if (!self.internetConnection.isReachable) {
         [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_LOST_INTERNET_CONNECTION", nil)];
          return;
    }
    
    if (self.shareOperation.isSending) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [self ativityAlertControllerWithStatus:@"Sharing..."
                                                                   cancelAction:^{
                                                                       [SVProgressHUD showInfoWithStatus:@"Cancelled"];
                                                                       [weakSelf.shareOperation cancel];
                                                                   }];
    
    NSItemProvider *provider;
    for (NSExtensionItem *extensionItem in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in extensionItem.attachments) {
            provider = itemProvider;
        }
    }
    
    
    [[QMShareTasks messageForItemProvider:provider] continueWithExecutor:BFExecutor.mainThreadExecutor
                                                               withBlock:^id _Nullable(BFTask<QBChatMessage *> * _Nonnull t)
     {
         
         if (t.result) {
             
             self.shareOperation =
             [QMShareEtxentionOperation operationWithID:@"ShareOperation"
                                                   text:t.result.text
                                             attachment:t.result.attachments.firstObject
                                             recipients:self.tableViewDataSource.selectedItems.allObjects
                                             completion:^(NSError *error, BOOL completed)
              {
                  [alertController dismissViewControllerAnimated:YES
                                                      completion:nil];
                  if (completed) {
                      [weakSelf completeShare:error];
                  }
                  NSLog(@"Error = %@, completed = %@", error, completed ? @"YES" : @"NO");
              }];
             
             self.shareOperation.operationDelegate = self;
             [self.shareOperation start];
         }
         else {
             NSString *errorText = t.error.localizedDescription ?: @"Something went wrong";
             NSError *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:0 userInfo:@{NSLocalizedDescriptionKey : errorText}];
             [alertController dismissViewControllerAnimated:YES
                                                 completion:^{
                                                     [self completeShare:error];
                                                 }];
         }
         return nil;
     }];
}

//MARK: - Helpers

- (void)updateShareButton {
    
    self.navigationItem.rightBarButtonItem.enabled =
    self.tableViewDataSource.selectedItems.count > 0;
}

- (void)configureSearch {
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    self.searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchBar.placeholder = @"Search";
    self.searchController.searchBar.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    [self.searchController.searchBar sizeToFit]; // iOS8 searchbar sizing
    
    [QMNoResultsCell registerForReuseInTableView:self.searchResultsController.tableView];
    [QMShareTableViewCell registerForReuseInView:self.searchResultsController.tableView];
    [QMShareContactsTableViewCell registerForReuseInTableView:self.searchResultsController.tableView];
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = self.searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    }
    else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
#else
    self.tableView.tableHeaderView = self.searchController.searchBar;
#endif
    
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (NSArray *)contactsToShare {
    
    if (!_contactsToShare) {
        
        NSMutableArray *userIDs = [NSMutableArray array];
        NSArray *allContactListItems = QMExtensionCache.contactsCache.allContactListItems;
        
        for (QBContactListItem *item in allContactListItems) {
            if (item.subscriptionState != QBPresenceSubscriptionStateNone) {
                [userIDs addObject:@(item.userID)];
            }
        }
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.ID IN %@",userIDs];
        
        _contactsToShare = [QMExtensionCache.usersCache.allUsers filteredArrayUsingPredicate:predicate];
    }
    
    return _contactsToShare;
}


- (NSArray *)dialogsToShare {
    
    if (!_dialogsToShare) {
        _dialogsToShare = QMExtensionCache.chatCache.allDialogs;
    }
    
    return _dialogsToShare;
}


- (void)configureDataSource {
    
    NSMutableArray *dialogsDataSource = [NSMutableArray array];
    
    NSPredicate *privateDialogsPredicate = [NSPredicate predicateWithFormat:@"SELF.type == %@", @(QBChatDialogTypePrivate)];
    NSArray *privateDialogs = [self.dialogsToShare filteredArrayUsingPredicate:privateDialogsPredicate];
    
    for (QBChatDialog *dialog in privateDialogs) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.ID == %@",@(dialog.recipientID)];
        QBUUser *recipient = [self.contactsToShare filteredArrayUsingPredicate:predicate].firstObject;
        if (recipient) {
            dialog.recipient = recipient;
            [dialogsDataSource addObject:recipient];
        }
    }
    
    NSPredicate *groupDialogsPredicate = [NSPredicate predicateWithFormat:@"SELF.type == %@ AND SELF.name.length > 0", @(QBChatDialogTypeGroup)];
    
    NSArray *groupDialogs = [self.dialogsToShare filteredArrayUsingPredicate:groupDialogsPredicate];
    [dialogsDataSource addObjectsFromArray:groupDialogs];
    
    NSArray *sortedByDateDialogs = [dialogsDataSource sortedArrayUsingComparator:^NSComparisonResult(id <QMShareItemProtocol> _Nonnull obj1, id  <QMShareItemProtocol>_Nonnull obj2) {
        return [obj2.updateDate compare:obj1.updateDate];
    }];
    
    //Main data source
    self.tableViewDataSource = [[QMShareDataSource alloc] initWithShareItems:sortedByDateDialogs
                                                      alphabetizedDataSource:NO];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:^NSComparisonResult(id <QMShareItemProtocol> _Nonnull obj1, id  <QMShareItemProtocol>_Nonnull obj2) {
        return [obj2.updateDate compare:obj1.updateDate];
    }];
    
    self.tableViewDataSource.sortDescriptors = @[sortDescriptor];
    self.tableView.dataSource = self.tableViewDataSource;
    
    //Search data source
    self.searchDataSource = ({
        
        QMShareSearchControllerDataSource *searchDataSource = [[QMShareSearchControllerDataSource alloc] initWithShareItems:groupDialogs
                                                                                                     alphabetizedDataSource:YES];
        
        QMShareItemsDataProvider *itemsSearchProvider = [[QMShareItemsDataProvider alloc] initWithShareItems:groupDialogs];
        itemsSearchProvider.delegate = self.searchResultsController;
        searchDataSource.searchDataProvider = itemsSearchProvider;
        
        searchDataSource;
    });
    
    //Contacts data source
    self.searchDataSource.contactsDataSource = ({
        
        NSArray *sortedByDateContacts = [self.contactsToShare sortedArrayUsingComparator:^NSComparisonResult(id <QMShareItemProtocol> _Nonnull obj1, id  <QMShareItemProtocol>_Nonnull obj2) {
            return [obj2.updateDate compare:obj1.updateDate];
        }];
        
        QMShareItemsDataProvider *contactsProvider = [[QMShareItemsDataProvider alloc] initWithShareItems:sortedByDateContacts];
        contactsProvider.delegate = self;
        
        QMShareDataSource *contactsDataSource = [[QMShareDataSource alloc] initWithShareItems:(NSArray <id <QMShareItemProtocol>> *)sortedByDateContacts
                                                                       alphabetizedDataSource:NO];
        contactsDataSource.searchDataProvider = contactsProvider;
        
        contactsDataSource;
    });
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configure];
    
    [self configureSearch];
    
    [QMShareTableViewCell registerForReuseInView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
    
    self.tableView.tableFooterView = [UIView new];
    
    [self configureDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
    
    [self updateDataSource];
    [self setNeedsStatusBarAppearanceUpdate];
    
    __weak typeof(self) weakSelf = self;
    self.logoutObserver = [[QBDarwinNotificationCenter defaultCenter] addObserverForName:kQBResetSessionNotification
                                                                              usingBlock:^{
                                                                                  [weakSelf completeShare:nil];
                                                                              }];
    
    if (!QBSession.currentSession.currentUser.ID) {
        
        NSString *errorText = @"You should be logged in to Q-Municate";
        NSError *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey : errorText}];
        [self completeShare:error];
        return;
    }
}

- (void)updateDataSource {
    [[QMShareTasks taskFetchAllDialogsFromDate:nil] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        [self.tableViewDataSource updateItems:t.result];
        [self.tableView reloadData];
        return nil;
    }];
}

//MARK: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)__unused
tableView heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    return [QMShareTableViewCell height];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id <QMShareViewProtocol> view = [tableView cellForRowAtIndexPath:indexPath];
    id <QMShareItemProtocol> item = [self.tableViewDataSource objectAtIndexPath:indexPath];
    
    [self.tableViewDataSource selectItem:item
                                 forView:view];
    
    [self updateShareButton];
}

- (void)completeShare:(nullable NSError *)error {
    
    if (error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
    else {
        [SVProgressHUD showInfoWithStatus:@"Sucessfully sent"];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismiss];
    });
}

- (void)hideExtensionControllerWithCompletion:(dispatch_block_t)completion {
    [UIView animateWithDuration:0.2 animations:^{
        
        self.navigationController.view.transform =
        CGAffineTransformMakeTranslation(0, self.navigationController.view.frame.size.height);
        
        completion ? completion() : nil;
    }];
    
}

//MARK: - UISearchControllerDelegate

- (void)willDismissSearchController:(UISearchController *)__unused searchController {
    
    [self.tableViewDataSource.selectedItems removeAllObjects];
    
    [self.tableViewDataSource.selectedItems addObjectsFromArray:^NSArray *{
        
        NSMutableSet *selectedItems = [NSMutableSet set];
        [selectedItems unionSet:self.searchDataSource.selectedItems];
        [selectedItems unionSet:self.searchDataSource.contactsDataSource.selectedItems];
        
        return selectedItems.allObjects;
    }()];
    
    [self updateShareButton];
    [self.tableView reloadData];
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    
    [self.searchDataSource.selectedItems removeAllObjects];
    [self.searchDataSource.selectedItems addObjectsFromArray:self.tableViewDataSource.selectedItems.allObjects];
    
    self.searchResultsController.tableView.dataSource = self.searchDataSource;
    
    searchController.searchResultsController.view.hidden = NO;
}

- (void)searchDataProvider:(QMSearchDataProvider *)__unused searchDataProvider
             didUpdateData:(NSArray *)__unused data {
    
}

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)__unused searchDataProvider {
    
    if (self.searchDataSource.showContactsSection) {
        QMShareContactsTableViewCell *contactsCell = [self.searchResultsController.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                                                                      inSection:0]];
        contactsCell ? [contactsCell.contactsCollectionView reloadData] : nil;
    }
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    searchController.searchResultsController.view.hidden = NO;
}

//MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    searchController.searchResultsController.view.hidden = NO;
    [self.searchDataSource performSearch:searchController.searchBar.text];
}

//MARK: - QMSearchResultsControllerDelegate

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController
         willBeginScrollResults:(UIScrollView *)__unused scrollView {
    
    [self.searchController.searchBar endEditing:YES];
}

- (void)searchResultsController:(QMSearchResultsController *)__unused searchResultsController
                didSelectObject:(id)object {
    
    NSIndexPath *indexPath = [self.searchDataSource indexPathForObject:object];
    UITableViewCell *cell = [self.searchResultsController.tableView cellForRowAtIndexPath:indexPath];
    
    [self.searchDataSource selectItem:object
                              forView:(id <QMShareViewProtocol>)cell];
    
    [self.tableViewDataSource selectItem:object
                                 forView:[self.tableView cellForRowAtIndexPath:[self.tableViewDataSource indexPathForObject:object]]];
    [self updateShareButton];
}


- (UIAlertController *)ativityAlertControllerWithStatus:(NSString *)status
                                           cancelAction:(dispatch_block_t)cancelAction {
    
    NSString *message = [NSString stringWithFormat:@"%@\n",status];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action)
                                {
                                    cancelAction ? cancelAction() : nil;
                                }]];
    
    
    UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setUserInteractionEnabled:NO];
    [indicator startAnimating];
    indicator.color = QMSecondaryApplicationColor();
    
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    [alertController.view addSubview:indicator];
    
    NSDictionary *views = @{@"alertController" : alertController.view,
                            @"indicator" : indicator};
    
    NSArray *constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(45)-|" options:0 metrics:nil views:views];
    NSArray *constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
    NSArray *constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
    
    [alertController.view addConstraints:constraints];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
    return alertController;
}

@end
