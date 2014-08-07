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
#import "REAlertView.h"
#import "QMAlertsFactory.h"
#import "QMChatReceiver.h"
#import "TWMessageBarManager.h"
#import "QMMessageBarStyleSheetFactory.h"
#import "QMSoundManager.h"

@interface QMChatViewController () <QMChatDataSourceDelegate>

@end

@implementation QMChatViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[QMChatReceiver instance] unsubscribeForTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = [[QMChatDataSource alloc] initWithChatDialog:self.dialog forTableView:self.tableView];
    self.dataSource.delegate = self;
    
    self.dialog.type == QBChatDialogTypeGroup ? [self configureNavigationBarForGroupChat] : [self configureNavigationBarForPrivateChat];
    
    __weak __typeof(self)weakSelf = self;
    [[QMChatReceiver instance] chatAfterDidReceiveMessageWithTarget:self block:^(QBChatMessage *message) {
        
        if (message.cParamNotificationType == QMMessageNotificationTypeUpdateDialog && [message.cParamDialogID isEqualToString:weakSelf.dialog.ID]) {
            weakSelf.title = message.cParamDialogName;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    if (self.dialog.type == QBChatDialogTypeGroup) {
        self.title = self.dialog.name;
    }
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
#if QM_AUDIO_VIDEO_ENABLED == 0
    [QMAlertsFactory comingSoonAlert];
#else
	[self performSegueWithIdentifier:kAudioCallSegueIdentifier sender:nil];
#endif
}

- (void)videoCallAction {
#if QM_AUDIO_VIDEO_ENABLED == 0
    [QMAlertsFactory comingSoonAlert];
#else
	[self performSegueWithIdentifier:kVideoCallSegueIdentifier sender:nil];
#endif
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

#pragma mark - QMChatDataSourceDelegate

- (void)message:(QBChatMessage *)message forOtherOtherDialog:(QBChatDialog *)otherDialog {
    
    __block UIImage *img = nil;
    NSString *title = nil;
    
    if (otherDialog.type ==  QBChatDialogTypeGroup) {
        img = [UIImage imageNamed:@"upic_placeholder_details_group"];
        title = otherDialog.name;
    } else if (otherDialog.type == QBChatDialogTypePrivate) {
        NSUInteger occupantID = [[QMApi instance] occupantIDForPrivateChatDialog:otherDialog];
        QBUUser *user = [[QMApi instance] userWithID:occupantID];
        title = user.fullName;
        
        [QMImageView imageWithURL:[NSURL URLWithString:user.website]
                             size:CGSizeMake(50, 50)
                         progress:nil
                             type:QMImageViewTypeCircle
                       completion:^(UIImage *userAvatar) {
                                 img = userAvatar;
                             }];
        if (!img) {
            img = [UIImage imageNamed:@"upic-placeholder"];
        }
        
    }
    [QMSoundManager playMessageReceivedSound];
    [TWMessageBarManager sharedInstance].styleSheet = [QMMessageBarStyleSheetFactory defaultMsgBarWithImage:img];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:title
                                                   description:message.text
                                                          type:TWMessageBarMessageTypeSuccess];
}

@end
