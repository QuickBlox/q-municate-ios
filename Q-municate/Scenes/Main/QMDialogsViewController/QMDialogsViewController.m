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
#import "QMCore.h"
#import "QMTasks.h"
#import "QMProfile.h"
#import "QMTitleView.h"

#import <SVProgressHUD.h>

@interface QMDialogsViewController ()

<
QMUsersServiceDelegate,
QMChatServiceDelegate,
QMChatConnectionDelegate,
UITableViewDelegate
>

/**
 *  Data sources
 */
@property (strong, nonatomic) QMDialogsDataSource *dialogsDataSource;
@property (strong, nonatomic) QMPlaceholderDataSource *placeholderDataSource;

@property (weak, nonatomic) IBOutlet QMTitleView *titleView;

@end

@implementation QMDialogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Data sources init
    self.dialogsDataSource = [[QMDialogsDataSource alloc] init];
    self.placeholderDataSource  = [[QMPlaceholderDataSource alloc] init];
    self.tableView.delegate = self;
    
    // Subscribing delegates
    [[QMCore instance].chatService addDelegate:self];
    [[QMCore instance].usersService addDelegate:self];
    
    // Profile title view
    QBUUser *currentUser = [QMCore instance].currentProfile.userData;
    [self.titleView setText:currentUser.fullName];
    self.titleView.placeholderID = currentUser.ID;
    [self.titleView setAvatarUrl:currentUser.avatarUrl];
    
    // auto login user
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
        return nil;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.dialogsDataSource.items.count > 0 ? 76 : tableView.frame.size.height - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height;
}

#pragma mark - Actions

- (IBAction)didPressProfileTitle:(id)sender {
    
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

@end
