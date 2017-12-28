//
//  QMShareTableViewController.m
//  Q-municate
//
//  Created by Vitaliy Gurkovsky on 11/4/17.
//  Copyright © 2017 Quickblox. All rights reserved.
//

#import "QMShareTableViewController.h"
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
#import "UIAlertController+QM.h"

@interface QMShareTableViewController () <
QMSearchDataProviderDelegate,
QMSearchResultsControllerDelegate,
UISearchControllerDelegate,
UISearchResultsUpdating,
UISearchBarDelegate,
QMShareContactsDelegate>

@property (strong, nonatomic, readwrite) QMShareDataSource *shareDataSource;
@property (strong, nonatomic, readwrite) QMShareSearchControllerDataSource *searchDataSource;

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMSearchResultsController *searchResultsController;

@property (nonatomic, weak) UIAlertController *alertController;
@property (nonatomic, strong) NSArray <QBUUser *> *contactsToShare;
@property (nonatomic, strong) NSArray <QBChatDialog *> *dialogsToShare;

@end


@implementation QMShareTableViewController

+ (instancetype)qm_shareTableViewControllerWithDialogs:(NSArray *)dialogs
                                              contacts:(NSArray *)contacts {
    
    QMShareTableViewController *shareViewController =
    [[QMShareTableViewController alloc] initWithNibName:NSStringFromClass([self class]) bundle:nil];
    
    shareViewController.dialogsToShare = dialogs;
    shareViewController.contactsToShare = contacts;
    
    return shareViewController;
}

//MARK: - View Life Cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureAppereance];
    [self configureSearch];
    [self configureDataSource];
    
    [QMShareTableViewCell registerForReuseInView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
    
    self.tableView.tableFooterView = [UIView new];
}

//MARK: - Public Interface

- (void)selectShareItem:(id<QMShareItemProtocol>)shareItem {
    [self selectShareItems:@[shareItem]];
}

- (void)deselectShareItem:(id<QMShareItemProtocol>)shareItem {
    [self deselectShareItems:@[shareItem]];
}

- (void)selectShareItems:(NSArray <id<QMShareItemProtocol>> *)shareItems {
    [self updateSelectionForShareItems:shareItems
                                select:YES];
}

- (void)deselectShareItems:(NSArray <id<QMShareItemProtocol>> *)shareItems {
    [self updateSelectionForShareItems:shareItems
                                select:NO];
}

- (void)deselectAll {
    [self updateSelectionForShareItems:self.shareDataSource.items
                                select:NO];
}

- (void)selectAll {
    [self updateSelectionForShareItems:self.shareDataSource.items
                                select:YES];
}


- (void)presentLoadingAlertControllerWithStatus:(NSString *)status
                                       animated:(BOOL)animated
                                 withCompletion:(dispatch_block_t)completionBlock {
    
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alertController = [UIAlertController qm_loadingAlertControllerWithStatus:status
                                                                                    cancelBlock:^{
                                                                                        __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                                        [strongSelf.shareControllerDelegate didCancelSharing];
                                                                                    }];
    
    [self presentViewController:alertController
                       animated:animated
                     completion:completionBlock];
    
    self.alertController = alertController;
}

- (void)dismissLoadingAlertControllerAnimated:(BOOL)animated
                               withCompletion:(dispatch_block_t)completion {
    
    [self.alertController dismissViewControllerAnimated:animated
                                             completion:completion];
}

//MARK: - Actions

- (void)dismiss {
    [self.shareControllerDelegate didTapCancelBarButton];
}

- (void)shareAction {
    NSArray *selectedItems = [self.shareDataSource.selectedItems.allObjects copy];
    [self.shareControllerDelegate didTapShareBarButtonWithSelectedItems:selectedItems];
}

//MARK: - Configuration

- (void)configureDataSource {
    
    NSMutableArray *dialogsDataSource = [NSMutableArray array];
    
    NSPredicate *privateDialogsPredicate = [NSPredicate predicateWithFormat:@"SELF.type == %@", @(QBChatDialogTypePrivate)];
    NSArray *privateDialogs = [self.dialogsToShare filteredArrayUsingPredicate:privateDialogsPredicate];
    
    for (QBChatDialog *dialog in privateDialogs) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.ID == %@",@(dialog.recipientID)];
        QBUUser *recipient = [self.contactsToShare filteredArrayUsingPredicate:predicate].firstObject;
        
        if (recipient) {
            recipient.updatedAt = dialog.updatedAt;
            [dialogsDataSource addObject:recipient];
        }
    }
    
    NSPredicate *groupDialogsPredicate = [NSPredicate predicateWithFormat:@"SELF.type == %@ AND SELF.name.length > 0", @(QBChatDialogTypeGroup)];
    
    NSArray *groupDialogs = [self.dialogsToShare filteredArrayUsingPredicate:groupDialogsPredicate];
    [dialogsDataSource addObjectsFromArray:groupDialogs];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:^NSComparisonResult(id <QMShareItemProtocol> _Nonnull obj1, id  <QMShareItemProtocol>_Nonnull obj2) {
        return [obj2.updatedAt compare:obj1.updatedAt];
    }];
    
    //Main data source
    self.shareDataSource = [[QMShareDataSource alloc] initWithShareItems:dialogsDataSource
                                                         sortDescriptors:@[sortDescriptor]
                                                  alphabetizedDataSource:NO];
    
    self.tableView.dataSource = self.shareDataSource;
    
    //Search data source
    self.searchDataSource = ({
        
        QMShareSearchControllerDataSource *searchDataSource = [[QMShareSearchControllerDataSource alloc] initWithShareItems:groupDialogs
                                                                                                            sortDescriptors:nil
                                                                                                     alphabetizedDataSource:YES];
        
        QMShareItemsDataProvider *itemsSearchProvider = [[QMShareItemsDataProvider alloc] initWithShareItems:groupDialogs];
        itemsSearchProvider.delegate = self.searchResultsController;
        searchDataSource.searchDataProvider = itemsSearchProvider;
        searchDataSource.contactsDelegate = self;
        searchDataSource;
    });
    
    //Contacts data source
    self.searchDataSource.contactsDataSource = ({
        
        QMShareItemsDataProvider *contactsProvider = [[QMShareItemsDataProvider alloc] initWithShareItems:self.contactsToShare.copy];
        contactsProvider.delegate = self;
        
        QMShareDataSource *contactsDataSource = [[QMShareDataSource alloc] initWithShareItems:(NSArray <id <QMShareItemProtocol>> *)self.contactsToShare.copy
                                                                              sortDescriptors:@[sortDescriptor]
                                                                       alphabetizedDataSource:NO];
        contactsDataSource.searchDataProvider = contactsProvider;
        contactsDataSource;
    });
    
}
- (void)configureSearch {
    
    self.searchResultsController = [[QMSearchResultsController alloc] init];
    self.searchResultsController.delegate = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsController];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
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

- (void)configureAppereance {
    
    [[UISearchBar appearance] setBarTintColor:QMSecondaryApplicationColor()];
    [[UISearchBar appearance] setSearchBarStyle:UISearchBarStyleMinimal];
    
    [[UISearchBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UISearchBar appearance] setBackgroundImage:QMStatusBarBackgroundImage() forBarPosition:0 barMetrics:UIBarMetricsDefault];
    
    
    [[UITextField appearance] setTintColor:QMSecondaryApplicationColor()];
    [UITextField appearance].keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(dismiss)];
    
    self.navigationItem.leftBarButtonItem.tintColor =
    QMSecondaryApplicationColor();
    self.navigationController.navigationItem.leftBarButtonItem.tintColor =
    QMSecondaryApplicationColor();
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"QM_EXT_SHARE_BAR_BUTTON_TITLE", nil)
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(shareAction)];
    self.navigationItem.rightBarButtonItem.tintColor = QMSecondaryApplicationColor();
    
    [self updateShareButton];
}


//MARK: - Helpers

- (void)updateSelectionForShareItems:(NSArray <id<QMShareItemProtocol>> *)shareItems
                              select:(BOOL)shouldBeSelected {
    
    for (id <QMShareItemProtocol> shareItem in shareItems) {
        BOOL isSelected =
        [self.shareDataSource.selectedItems containsObject:shareItem];
        
        if (isSelected == shouldBeSelected) {
            continue;
        }
        
        NSIndexPath *indexPath = [self.shareDataSource indexPathForObject:shareItem];
        if (indexPath) {
            id <QMShareViewProtocol> view = [self.tableView cellForRowAtIndexPath:indexPath];
            [self.shareDataSource selectItem:shareItem
                                     forView:view];
        }
    }
}

- (void)updateShareButton {
    
    self.navigationItem.rightBarButtonItem.enabled =
    self.shareDataSource.selectedItems.count > 0;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
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
    id <QMShareItemProtocol> item = [self.shareDataSource objectAtIndexPath:indexPath];
    
    [self.shareDataSource selectItem:item
                             forView:view];
    
    [self updateShareButton];
}


//MARK: - UISearchControllerDelegate

- (void)willDismissSearchController:(UISearchController *)__unused searchController {
    
    [self updateShareButton];
    [self.tableView reloadData];
}


- (void)willPresentSearchController:(UISearchController *)searchController {
    
    [self.searchDataSource.selectedItems removeAllObjects];
    [self.searchDataSource.selectedItems addObjectsFromArray:self.shareDataSource.selectedItems.allObjects];
    
    self.searchResultsController.tableView.dataSource = self.searchDataSource;
    
    searchController.searchResultsController.view.hidden = NO;
}

- (void)searchDataProvider:(QMSearchDataProvider *)__unused searchDataProvider
             didUpdateData:(NSArray *)__unused data {
    
}


- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)__unused searchDataProvider {
    
    if (self.searchDataSource.showContactsSection) {
        QMShareContactsTableViewCell *contactsCell =
        [self.searchResultsController.tableView cellForRowAtIndexPath:
         [NSIndexPath indexPathForRow:0
                            inSection:0]];
        contactsCell ? [contactsCell.contactsCollectionView reloadData] : nil;
    }
}


//MARK: - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    searchController.searchResultsController.view.hidden = NO;
    
    if (searchController.isActive) {
        [self.searchDataSource performSearch:searchController.searchBar.text];
    }
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
    
    [self.shareDataSource selectItem:object
                             forView:[self.tableView cellForRowAtIndexPath:[self.shareDataSource indexPathForObject:object]]];
    [self updateShareButton];
    
    self.searchController.active = NO;
}


- (void)dismissViewControllerAnimated:(BOOL)flag
                           completion:(void (^)(void))completion {
    
    dispatch_block_t alertControllerCompletion = ^{
        [super dismissViewControllerAnimated:flag
                                  completion:completion];
    };
    
    if (self.alertController) {
        [self dismissLoadingAlertControllerAnimated:NO
                                     withCompletion:alertControllerCompletion];
    }
    else {
        alertControllerCompletion();
    }
}


- (void)dealloc {
    [self.searchController.view removeFromSuperview];
}

#ifdef __IPHONE_11_0
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull __unused context) {
        if (@available(iOS 11.0, *)) {
            if (self.searchController.isActive) {
                self.searchController.active = NO;
            }
            NSLog(@"Search controller");
        }
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
#endif

//MARK: - QMShareContactsDelegate

- (void)contactsDataSource:(nonnull QMShareDataSource *)__unused contactsDataSource
        didSelectRecipient:(nonnull id<QMShareItemProtocol>)__unused recipient {
    
    [self.shareDataSource selectItem:recipient
                             forView:[self.tableView cellForRowAtIndexPath:[self.shareDataSource indexPathForObject:recipient]]];
    
    if (self.searchController.active) {
        self.searchController.active = NO;
    }
}

@end
