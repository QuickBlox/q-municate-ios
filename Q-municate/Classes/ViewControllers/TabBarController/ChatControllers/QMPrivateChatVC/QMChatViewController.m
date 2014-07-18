//
//  QMChatViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 01/04/2014.
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
    (self.dialog.type == QBChatDialogTypeGroup) ? [self configureNavigationBarForGroupChat] : [self configureNavigationBarForPrivateChat];
 
}

- (void)configureNavigationBarForPrivateChat {

    UIButton *audioButton = [QMChatButtonsFactory audioCall];
    [audioButton addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoButton = [QMChatButtonsFactory videoCall];
    [videoButton addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *videoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:videoButton];
    UIBarButtonItem *audioCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    
    [self.navigationItem setRightBarButtonItems:@[videoCallBarButtonItem,  audioCallBarButtonItem] animated:YES];
}

- (void)configureNavigationBarForGroupChat {
    
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
    
	[self performSegueWithIdentifier:kAudioCallSegueIdentifier sender:nil];
}

- (void)videoCallAction {
    
	[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:nil];
}

- (void)groupInfoNavButtonAction {
    
	[self performSegueWithIdentifier:kGroupDetailsSegueIdentifier sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
//    if ([segue.identifier isEqualToString:kVideoCallSegueIdentifier]) {
//
//    } else if ([segue.identifier isEqualToString:kAudioCallSegueIdentifier]) {
//        
//    } else
    if ([segue.identifier isEqualToString:kGroupDetailsSegueIdentifier]) {
    
        QMGroupDetailsController *groupDetailVC = segue.destinationViewController;
        groupDetailVC.chatDialog = self.dialog;
    } else {
        QBUUser *opponent = [self.dataSource opponent];
        QMBaseCallsController *callsController = segue.destinationViewController;
        [callsController setOpponent:opponent];
    }
}

@end