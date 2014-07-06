//
//  QMChatRoomListController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChatRoomListController.h"
#import "QMChatViewController.h"
#import "QMChatListCell.h"
#import "QMUsersService.h"
#import "QMChatService.h"
#import "QMChatRoomListDataSource.h"
#import "QMCreateNewChatController.h"
#import "QMUtilities.h"
#import "TWMessageBarManager.h"

static NSString *const ChatListCellIdentifier = @"ChatListCell";

@interface QMChatRoomListController () <QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UITableView *chatsTableView;
@property (strong, nonatomic) QMChatRoomListDataSource *dataSource;

@property (strong, nonatomic) NSArray *chatDialogs;

///** Controller's flag. If YES, CreateNewChatController was popped and dialog was created */
//@property (assign, getter = isCreateNewChatControllerLoaded) BOOL createNewChatControllerLoaded;

@end

@implementation QMChatRoomListController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.dataSource = [QMChatRoomListDataSource new];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localChatDidReceiveMessage:)
                                                 name:kChatDidReceiveMessageNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localChatAddedNewRoom:)
                                                 name:kChatRoomListUpdateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dialogsLoaded)
                                                 name:kChatDialogsDidLoadedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dialogsLoaded)
                                                 name:kChatRoomDidReceiveMessageNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // check for created now dialog:
//    QBChatDialog *newDialog = [QMChatService shared].lastCreatedDialog;
//    if (newDialog != nil) {
//        
//        //if dialog wasn't created:
//        QBChatDialog *createdNowDialog = [QMChatService shared].lastCreatedDialog;
//        [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:createdNowDialog];
//        
//        [QMChatService shared].lastCreatedDialog = nil;
//    }
    
    [self reloadTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.chatDialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatListCellIdentifier];

    QBChatDialog *dialog = self.chatDialogs[indexPath.row];
    
    [cell configureCellWithDialog:dialog];

    return cell;
}

- (void)reloadTableView {
#warning me.iD
#warning QMContactList shared
//    self.chatDialogs = [[[QMChatService shared].allDialogsAsDictionary allValues] mutableCopy];
    [self.chatsTableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

	QBChatDialog *chatDialog = self.chatDialogs[indexPath.row];
    [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:chatDialog];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[QMChatViewController class]]) {
        
        QMChatViewController *chatController = (QMChatViewController *)segue.destinationViewController;
        
        QBChatDialog *dialog = (QBChatDialog *)sender;
        
        if (dialog.type == QBChatDialogTypePrivate) {
#warning me.iD
#warning QMContactList shared
//            QBUUser *opponent = [[QMContactList shared] searchFriendFromChatDialog:dialog];
//            [chatController setupPrivateChatWithChatDialog:dialog andOpponent:opponent];
            
        } else {
            [chatController setupGroupChatWithChatDialog:dialog];
        }
        
    } else if ([segue.destinationViewController isKindOfClass:[QMCreateNewChatController class]]) {
        
    }
}

#pragma mark - Notifications

- (void)localChatDidReceiveMessage:(NSNotification *)notification {
    
    [self reloadTableView];
}

- (void)localChatAddedNewRoom:(NSNotification *)notification {
    
	NSLog(@"userInfo: %@", notification.userInfo);
	[self.dataSource updateDialogList];
	[self.chatsTableView reloadData];
}

- (void)dialogsLoaded {
    [self reloadTableView];
}

#pragma mark - Actions

- (IBAction)createNewDialog:(id)sender
{
    [self performSegueWithIdentifier:@"CreateNewChatSegue" sender:nil];
}

@end
