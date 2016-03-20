//
//  QMNewMessageViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNewMessageViewController.h"
#import "QMNewMessageDataSource.h"
#import "QMNewMessageSearchDataSource.h"
#import "QMCore.h"
#import "QMChatVC.h"
#import "QMNewMessageSearchDataProvider.h"

#import "QMContactCell.h"
#import "QMNoContactsCell.h"
#import "QMNoResultsCell.h"

@interface QMNewMessageViewController ()

<
UITableViewDelegate,

QMSearchProtocol,
QMSearchDataProviderDelegate,

UISearchControllerDelegate,
UISearchResultsUpdating
>

@property (strong, nonatomic) UISearchController *searchController;

/**
 *  Data sources
 */
@property (strong, nonatomic) QMNewMessageDataSource *dataSource;
@property (strong, nonatomic) QMNewMessageSearchDataSource *contactsSearchDataSource;

@property (weak, nonatomic) BFTask *dialogCreationTask;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *createGroupButton;

@end

@implementation QMNewMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // setting up
    self.navigationItem.title = NSLocalizedString(@"QM_STR_NEW_MESSAGE_SCREEN", nil);
    
    // subscribing delegates
    self.tableView.delegate = self;
    
    // search implementation
    [self configureSearch];
    
    // setting up data source
    [self configureDataSources];
    
    // filling data source
    [self updateItemsFromContactList];
    
    
    // Back button style for next in navigation stack view controllers
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"QM_STR_BACK", nil)
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (void)configureSearch {
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

- (void)configureDataSources {
    
    self.dataSource = [[QMNewMessageDataSource alloc] initWithKeyPath:kQMQBUUserFullNameKeyPathKey];
    self.tableView.dataSource = self.dataSource;
    
    QMNewMessageSearchDataProvider *searchDataProvider = [[QMNewMessageSearchDataProvider alloc] init];
    searchDataProvider.delegate = self;
    
    self.contactsSearchDataSource = [[QMNewMessageSearchDataSource alloc] initWithSearchDataProvider:searchDataProvider usingKeyPath:kQMQBUUserFullNameKeyPathKey];
}

- (void)dealloc {
    
    [self.searchController.view removeFromSuperview];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.searchDataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.dialogCreationTask) {
        // dialog creating in progress
        return;
    }
    
    QBUUser *user = [self.dataSource userAtIndexPath:indexPath];
    
    QBChatDialog *privateDialog = [[QMCore instance].chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
    
    if (privateDialog != nil) {
        
        [self performSegueWithIdentifier:kQMSceneSegueChat sender:privateDialog];
    }
    else {
        
        @weakify(self);
        self.dialogCreationTask = [[[QMCore instance].chatService createPrivateChatDialogWithOpponent:user] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
            @strongify(self);
            [self performSegueWithIdentifier:kQMSceneSegueChat sender:task.result];
            
            return nil;
        }];
    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    
    self.tableView.dataSource = self.contactsSearchDataSource;
    [self.tableView reloadData];
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    
    self.tableView.dataSource = self.dataSource;
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    [self.searchDataSource.searchDataProvider performSearch:searchController.searchBar.text];
}

#pragma mark - Helpers

- (void)updateItemsFromContactList {
    
    NSArray *friends = [QMCore instance].friends;
    [self.dataSource replaceItems:friends];
    
    self.createGroupButton.enabled = friends.count > 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMChatVC *chatViewController = segue.destinationViewController;
        chatViewController.chatDialog = sender;
    }
}

#pragma mark - QMSearchDataProviderDelegate

- (void)searchDataProviderDidFinishDataFetching:(QMSearchDataProvider *)searchDataProvider {
    
    if ([self.tableView.dataSource conformsToProtocol:@protocol(QMNewMessageSearchDataSourceProtocol)]) {
        
        [self.tableView reloadData];
    }
}

- (void)searchDataProvider:(QMSearchDataProvider *)searchDataProvider didUpdateData:(NSArray *)data {
    
    if (![self.tableView.dataSource conformsToProtocol:@protocol(QMNewMessageSearchDataSourceProtocol)]) {
        
        [self updateItemsFromContactList];
    }
    
    [self.tableView reloadData];
}

#pragma mark - QMSearchProtocol

- (QMSearchDataSource *)searchDataSource {
    
    return (id)self.tableView.dataSource;
}

#pragma mark - Nib registration

- (void)registerNibs {
    
    [QMContactCell registerForReuseInTableView:self.tableView];
    [QMNoResultsCell registerForReuseInTableView:self.tableView];
}

@end
