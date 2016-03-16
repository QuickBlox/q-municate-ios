//
//  QMNewMessageViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNewMessageViewController.h"
#import "QMNewMessageDataSource.h"
#import "QMContactCell.h"
#import "QMCore.h"
#import "QMChatVC.h"

@interface QMNewMessageViewController ()

<
UITableViewDelegate,
QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) QMNewMessageDataSource *dataSource;
@property (weak, nonatomic) BFTask *dialogCreationTask;

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
    [[QMCore instance].contactListService addDelegate:self];
    [[QMCore instance].usersService addDelegate:self];
    
    // search implementation
    [self configureSearch];
    
    // setting up data source
    self.dataSource = [[QMNewMessageDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
    
    // filling data source
    [self updateItemsFromContactList];
}

- (void)configureSearch {
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self];
    self.searchController.searchBar.placeholder = NSLocalizedString(@"QM_STR_SEARCH_BAR_PLACEHOLDER", nil);
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.dialogCreationTask) {
        // dialog creating in progress
        return;
    }
    
    QBUUser *user = [self.dataSource userAtIndexPath:indexPath];
    
    if (user != nil) {
        
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
}

#pragma mark - Helpers

- (void)updateItemsFromContactList {
    
    NSArray *friendsUsers = [QMCore instance].friends;
    [self.dataSource replaceItems:friendsUsers];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMChatVC *chatViewController = segue.destinationViewController;
        chatViewController.chatDialog = sender;
    }
}

#pragma mark - QMContactListServiceDelegate

- (void)contactListServiceDidLoadCache {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

- (void)contactListService:(QMContactListService *)contactListService contactListDidChange:(QBContactList *)contactList {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

#pragma mark - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)usersService didAddUsers:(NSArray<QBUUser *> *)user {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

- (void)usersService:(QMUsersService *)usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)users {
    
    [self updateItemsFromContactList];
    [self.tableView reloadData];
}

#pragma mark - Nib registration

- (void)registerNibs {
    
    [QMContactCell registerForReuseInTableView:self.tableView];
}

@end
