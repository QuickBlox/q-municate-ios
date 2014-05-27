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
#import "QMContactList.h"
#import "QMChatService.h"
#import "QMChatRoomListDataSource.h"
#import "QMCreateNewChatController.h"
#import "QMUtilities.h"

static NSString *const ChatListCellIdentifier = @"ChatListCell";

@interface QMChatRoomListController () <QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UITableView *chatsTableView;
@property (strong, nonatomic) QMChatRoomListDataSource *dataSource;

@property (strong, nonatomic) NSArray *chatDialogs;
@end

@implementation QMChatRoomListController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.dataSource = [QMChatRoomListDataSource new];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localChatDidReceiveMessage:) name:kChatDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localChatAddedNewRoom:) name:kChatRoomListUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dialogsLoaded) name:kChatDialogsDidLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dialogsLoaded) name:kChatRoomDidReceiveMessageNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadTableView];
    
    [super viewWillAppear:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chatDialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QMChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatListCellIdentifier];

    QBChatDialog *dialog = self.chatDialogs[indexPath.row];
    
    [cell configureCellWithDialog:dialog];

    return cell;
}

- (void)reloadTableView
{
    self.chatDialogs = [[[QMChatService shared].allDialogsAsDictionary allValues] mutableCopy];
    [self.chatsTableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

	QBChatDialog *chatDialog = self.chatDialogs[indexPath.row];
    [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:chatDialog];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[QMChatViewController class]]) {
        QMChatViewController *childController = (QMChatViewController *)segue.destinationViewController;
        QBChatDialog *dialog = (QBChatDialog *)sender;
        childController.chatDialog = dialog;
        if (dialog.type == QBChatDialogTypePrivate) {
            QBUUser *opponent = [[QMContactList shared] searchFriendFromChatDialog:dialog];
            childController.opponent = opponent;
            childController.chatName = opponent.fullName;
        } else {
            childController.chatName = dialog.name;
        }
    } else if ([segue.destinationViewController isKindOfClass:[QMCreateNewChatController class]]) {
        
    }
}


#pragma mark - Notifications

- (void)localChatDidReceiveMessage:(NSNotification *)notification
{
    [self reloadTableView];
}

- (void)localChatAddedNewRoom:(NSNotification *)notification
{
	NSLog(@"userInfo: %@", notification.userInfo);
	[self.dataSource updateDialogList];
	[self.chatsTableView reloadData];
}

- (void)dialogsLoaded
{
    [QMUtilities removeIndicatorView];
    [self reloadTableView];
}


#pragma mark - Actions

- (IBAction)createNewDialog:(id)sender
{
    [self performSegueWithIdentifier:@"CreateNewChatSegue" sender:nil];
}

@end
