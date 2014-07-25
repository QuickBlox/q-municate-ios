//
//  QMChatViewController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 01/04/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatViewController.h"
#import "QMChatDataSource.h"
#import "QMChatButtonsFactory.h"
#import "QMGroupDetailsController.h"
#import "QMBaseCallsController.h"
#import "QMApi.h"

@interface QMChatViewController ()

@end

@implementation QMChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = [[QMChatDataSource alloc] initWithChatDialog:self.dialog forTableView:self.tableView];
    self.dialog.type == QBChatDialogTypeGroup ? [self configureNavigationBarForGroupChat] : [self configureNavigationBarForPrivateChat];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.dialog.unreadMessagesCount = 0;
}

- (void)configureNavigationBarForPrivateChat {

    NSUInteger oponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
    QBUUser *opponent = [[QMApi instance] userWithID:oponentID];

    self.title = opponent.fullName;
    
    UIButton *audioButton = [QMChatButtonsFactory audioCall];
    [audioButton addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoButton = [QMChatButtonsFactory videoCall];
    [videoButton addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *videoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:videoButton];
    UIBarButtonItem *audioCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    
    [self.navigationItem setRightBarButtonItems:@[videoCallBarButtonItem,  audioCallBarButtonItem] animated:YES];
}

- (void)configureNavigationBarForGroupChat {

    self.title = self.dialog.name;
    UIButton *groupInfoButton = [QMChatButtonsFactory groupInfo];
    [groupInfoButton addTarget:self action:@selector(groupInfoNavButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *groupInfoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupInfoButton];
    self.navigationItem.rightBarButtonItems = @[groupInfoBarButtonItem];
}

- (void)back:(id)sender {
    
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Nav Buttons Actions

- (void)audioCallAction {
    
    [[[UIAlertView alloc]initWithTitle:@"Coming soon." message:nil delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
//	[self performSegueWithIdentifier:kAudioCallSegueIdentifier sender:nil];
}

- (void)videoCallAction {
    
    [[[UIAlertView alloc]initWithTitle:@"Coming soon." message:nil delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
//	[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:nil];
}

- (void)groupInfoNavButtonAction {
    
	[self performSegueWithIdentifier:kGroupDetailsSegueIdentifier sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kGroupDetailsSegueIdentifier]) {
    
        QMGroupDetailsController *groupDetailVC = segue.destinationViewController;
        groupDetailVC.chatDialog = self.dialog;
    }
    else {
        
        NSUInteger opponentID = [[QMApi instance] occupantIDForPrivateChatDialog:self.dialog];
        QBUUser *opponent = [[QMApi instance] userWithID:opponentID];
        
        QMBaseCallsController *callsController = segue.destinationViewController;
        [callsController setOpponent:opponent];
    }
}

@end