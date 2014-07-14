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
#import "QMApi.h"

@interface QMChatViewController ()

@end

@implementation QMChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = [[QMChatDataSource alloc] initWithChatDialog:self.dialog forTableView:self.tableView];
    self.automaticallyScrollsToMostRecentMessage = YES;

    (self.dialog.type == QBChatDialogTypeGroup) ? [self configureNavigationBarForGroupChat] : [self configureNavigationBarForPrivateChat];
 
}

- (void)configureNavigationBarForPrivateChat {

    UIButton *groupInfoButton = [QMChatButtonsFactory groupInfo];
    [groupInfoButton addTarget:self action:@selector(groupInfoNavButtonAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *groupInfoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:groupInfoButton];
    self.navigationItem.rightBarButtonItems = @[groupInfoBarButtonItem];
}

- (void)configureNavigationBarForGroupChat {
    
    UIButton *audioButton = [QMChatButtonsFactory audioCall];
    [audioButton addTarget:self action:@selector(audioCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoButton = [QMChatButtonsFactory videoCall];
    [videoButton addTarget:self action:@selector(videoCallAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *videoCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:videoButton];
    UIBarButtonItem *audioCallBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:audioButton];
    
    [self.navigationItem setRightBarButtonItems:@[videoCallBarButtonItem,  audioCallBarButtonItem] animated:YES];
}

- (void)back:(id)sender {
    
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Nav Buttons Actions

- (void)audioCallAction {
    
	[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:@(QBVideoChatConferenceTypeAudio)];
}

- (void)videoCallAction {
    
	[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:@(QBVideoChatConferenceTypeAudioAndVideo)];
}

- (void)groupInfoNavButtonAction {
    
	[self performSegueWithIdentifier:kGroupDetailsSegueIdentifier sender:nil];
}

@end