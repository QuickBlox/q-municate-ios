//
//  QMGroupOccupantsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupOccupantsViewController.h"
#import "QMGroupOccupantsDataSource.h"
#import "QMGroupAddUsersViewController.h"
#import "QMTableSectionHeaderView.h"
#import "QMContactCell.h"
#import "QMColors.h"
#import "QMCore.h"
#import "QMAlert.h"
#import "QMNavigationController.h"
#import "QMUserInfoViewController.h"
#import "NSArray+Intersection.h"
#import <SVProgressHUD.h>
#import "QMSplitViewController.h"

static const CGFloat kQMSectionHeaderHeight = 32.0f;

@interface QMGroupOccupantsViewController ()

<
QMChatServiceDelegate,
QMChatConnectionDelegate,
QMContactListServiceDelegate,
QMUsersServiceDelegate
>

@property (strong, nonatomic) QMGroupOccupantsDataSource *dataSource;

@property (weak, nonatomic) BFTask *leaveTask;
@property (weak, nonatomic) BFTask *addUserTask;

@end

@implementation QMGroupOccupantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNibs];
    
    // Set tableview background color
    self.tableView.backgroundColor = QMTableViewBackgroundColor();
    
    // configure data sources
    [self configureDataSource];
    
    // subscribe for delegates
    [QMCore.instance.chatService addDelegate:self];
    [QMCore.instance.contactListService addDelegate:self];
    [QMCore.instance.usersService addDelegate:self];
    
    // configure data
    [self updateOccupants];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // smooth rows deselection
    [self qm_smoothlyDeselectRowsForTableView:self.tableView];
}

- (void)configureDataSource {
    
    self.dataSource = [[QMGroupOccupantsDataSource alloc] init];
    self.tableView.dataSource = self.dataSource;
    
    @weakify(self);
    self.dataSource.didAddUserBlock = ^(UITableViewCell *cell) {
        
        @strongify(self);
        if (self.addUserTask) {
            // task in progress
            return;
        }
        
        [SVProgressHUD show];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSUInteger userIndex = [self.dataSource userIndexForIndexPath:indexPath];
        QBUUser *user = self.dataSource.items[userIndex];
        
        self.addUserTask = [[QMCore.instance.contactManager addUserToContactList:user]
                            continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                                
                                [SVProgressHUD dismiss];
                                
                                if (!task.isFaulted) {
                                    
                                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                }
                                else {
                                    
                                    if (![QBChat instance].isConnected) {
                                        
                                        [QMAlert showAlertWithMessage:NSLocalizedString(@"QM_STR_CHAT_SERVER_UNAVAILABLE", nil) actionSuccess:NO inViewController:self];
                                    }
                                }
                                
                                return nil;
                            }];
    };
}

//MARK: - Methods

- (void)updateOccupants {
    
    [[QMCore.instance.usersService getUsersWithIDs:self.chatDialog.occupantIDs]
     continueWithBlock:^id _Nullable(BFTask<NSArray<QBUUser *> *> * _Nonnull t)
     {
         if (t.result) {
             
             NSArray *sortedItems = [t.result sortedArrayUsingComparator:
                                     ^NSComparisonResult(QBUUser *u1, QBUUser *u2) {
                                         return [u1.fullName caseInsensitiveCompare:u2.fullName];
                                     }];
             
             [self.dataSource replaceItems:sortedItems];
             [self.tableView reloadData];
         }
         
         return nil;
     }];
}

//MARK: - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUserInfo]) {
        
        QMUserInfoViewController *userInfoVC = segue.destinationViewController;
        userInfoVC.user = sender;
    }
    else if ([segue.identifier isEqualToString:kQMSceneSegueGroupAddUsers]) {
        
        QMGroupAddUsersViewController *addUsersVC = segue.destinationViewController;
        addUsersVC.chatDialog = sender;
    }
}

//MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.dataSource.addMemberCellIndex) {
        
        [self performSegueWithIdentifier:kQMSceneSegueGroupAddUsers sender:self.chatDialog];
    }
    else if (indexPath.row == self.dataSource.leaveChatCellIndex) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (self.leaveTask) {
            // task in progress
            return;
        }
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:nil
                                              message:[NSString stringWithFormat:NSLocalizedString(@"QM_STR_CONFIRM_LEAVE", nil), self.chatDialog.name]
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
                                                              
                                                          }]];
        
        __weak UINavigationController *navigationController = self.navigationController;
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LEAVE", nil)
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction * _Nonnull __unused action)
                                    {
                                        
                                        [(QMNavigationController *)navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                                                                                         message:NSLocalizedString(@"QM_STR_LOADING", nil)
                                                                                                        duration:0];
                                        self.leaveTask =
                                        [[QMCore.instance.chatManager leaveChatDialog:self.chatDialog]
                                         continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                                             
                                             [(QMNavigationController *)navigationController dismissNotificationPanel];
                                             
                                             if (!task.isFaulted) {
                                                 
                                                 if (self.splitViewController.isCollapsed) {
                                                     [navigationController popToRootViewControllerAnimated:YES];
                                                 }
                                                 else {
                                                     [(QMSplitViewController *)self.splitViewController showPlaceholderDetailViewController];
                                                 }
                                             }
                                             
                                             return nil;
                                         }];
                                    }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        
        NSUInteger userIndex = [self.dataSource userIndexForIndexPath:indexPath];
        QBUUser *user = self.dataSource.items[userIndex];
        
        if (user.ID == QMCore.instance.currentProfile.userData.ID) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        [self performSegueWithIdentifier:kQMSceneSegueUserInfo sender:user];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)__unused section {
    
    QMTableSectionHeaderView *headerView =
    [[QMTableSectionHeaderView alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               CGRectGetWidth(tableView.frame),
                                                               kQMSectionHeaderHeight)];
    
    headerView.title = [NSString stringWithFormat:@"%tu %@", self.chatDialog.occupantIDs.count, NSLocalizedString(@"QM_STR_MEMBERS", nil)];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)__unused section {
    
    return kQMSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

// MARK: - Overrides

- (void)setAdditionalNavigationBarHeight:(CGFloat)__unused additionalNavigationBarHeight {
    // do not set for this controller
}

//MARK: - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if ([chatDialog isEqual:self.chatDialog]) {
        
        [self updateOccupants];
        [self.tableView reloadData];
    }
}

- (void)chatService:(QMChatService *)__unused chatService
didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)dialogs {
    
    if ([dialogs containsObject:self.chatDialog]) {
        
        [self updateOccupants];
    }
}

//MARK: - QMContactListService

- (void)contactListServiceDidLoadCache {
    
    [self updateOccupants];
}

- (void)contactListService:(QMContactListService *)__unused contactListService contactListDidChange:(QBContactList *)__unused contactList {
    
    [self updateOccupants];
}

//MARK: - QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didLoadUsersFromCache:(NSArray<QBUUser *> *)__unused users {
    
    [self updateOccupants];
}

- (void)usersService:(QMUsersService *)__unused usersService didAddUsers:(NSArray<QBUUser *> *)user {
    
    NSArray *idsOfUsers = [user valueForKeyPath:qm_keypath(QBUUser, ID)];
    
    if ([self.chatDialog.occupantIDs qm_containsObjectFromArray:idsOfUsers]) {
        
        [self updateOccupants];
    }
}

// MARK: QMUsersServiceDelegate

- (void)usersService:(QMUsersService *)__unused usersService didUpdateUsers:(NSArray<QBUUser *> *)users {
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:users.count];
    for (QBUUser *user in users) {
        NSIndexPath *indexPath = [self.dataSource indexPathForObject:user];
        if (indexPath != nil) {
            [indexPaths addObject:indexPath];
        }
    }
    if (indexPaths.count > 0) {
        [self.tableView reloadRowsAtIndexPaths:[indexPaths copy] withRowAnimation:UITableViewRowAnimationNone];
    }
}

//MARK: - register nibs

- (void)registerNibs {
    
    [QMContactCell registerForReuseInTableView:self.tableView];
}

@end
