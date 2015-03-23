//
//  QMDialogsViewController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 30/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMDialogsViewController.h"
#import "QMChatViewController.h"
#import "QMCreateNewChatController.h"
#import "QMDialogsDataSource.h"
#import "QMChatReceiver.h"
#import "REAlertView+QMSuccess.h"
#import "QMApi.h"

static NSString *const ChatListCellIdentifier = @"ChatListCell";

@interface QMDialogsViewController ()

<UITableViewDelegate, QMDialogsDataSourceDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) QMDialogsDataSource *dataSource;

@end

@implementation QMDialogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.dataSource = [[QMDialogsDataSource alloc] initWithTableView:self.tableView];
    self.dataSource.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.dataSource fetchUnreadDialogsCount];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QBChatDialog *dialog = [self.dataSource dialogAtIndexPath:indexPath];
    if (dialog) {
        [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kChatViewSegueIdentifier]) {
        
        QMChatViewController *chatController = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        QBChatDialog *dialog = [self.dataSource dialogAtIndexPath:indexPath];
        chatController.dialog = dialog;
        
    } else if ([segue.destinationViewController isKindOfClass:[QMCreateNewChatController class]]) {
        
    }
}

#pragma mark - Actions

- (IBAction)createNewDialog:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    if ([[QMApi instance].contactsOnly count] == 0) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_ERROR_WHILE_CREATING_NEW_CHAT", nil) actionSuccess:NO];
        return;
    }
    [self performSegueWithIdentifier:kCreateNewChatSegueIdentifier sender:nil];
}

#pragma mark - QMDialogsDataSourceDelegate

- (void)didChangeUnreadDialogCount:(NSUInteger)unreadDialogsCount {
    
    NSUInteger idx = [self.tabBarController.viewControllers indexOfObject:self.navigationController];
    if (idx != NSNotFound) {
        UITabBarItem *item = self.tabBarController.tabBar.items[idx];
        item.badgeValue = unreadDialogsCount > 0 ? [NSString stringWithFormat:@"%zd", unreadDialogsCount] : nil;
    }
}

@end
