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
#import "QMChatRoomListDataSource.h"

static NSString *const ChatListCellIdentifier = @"ChatListCell";

@interface QMChatRoomListController () <QBActionStatusDelegate>

@property (strong, nonatomic) IBOutlet UITableView *chatsTableView;
@property (strong, nonatomic) QMChatRoomListDataSource *dataSource;

@end

@implementation QMChatRoomListController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [QMChatRoomListDataSource new];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localChatDidReceiveMessage:) name:kChatDidReceiveMessage object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localChatAddedNewRoom:) name:kChatRoomListUpdateNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource.roomsListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QMChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatListCellIdentifier];

    NSDictionary *chatInfo = self.dataSource.roomsListArray[indexPath.row];
	NSArray *opponentsArray = [chatInfo allKeys];

    cell.name.text = chatInfo[opponentsArray[0]][kChatOpponentName];
	NSDictionary *lastMessage = [chatInfo[opponentsArray[0]][kChatOpponentHistory]lastObject];
    cell.lastMessage.text = lastMessage[@"text"];

    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

	NSDictionary *chatInfo = self.dataSource.roomsListArray[indexPath.row];
    [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:chatInfo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.destinationViewController isKindOfClass:[QMChatViewController class]]) {
        QMChatViewController *childController = (QMChatViewController *)segue.destinationViewController;
        childController.opponentDictionary = (NSDictionary *)sender;
    }
}

#pragma mark -
- (void)localChatDidReceiveMessage:(NSNotification *)notification
{
	NSLog(@"userInfo: %@", notification.userInfo);
	/*
	* checking for room existence
	*  creating room for peer-to-peer
	* key(id) -> value(historyArray)
	* ну или как-то так
	* */
}

- (void)localChatAddedNewRoom:(NSNotification *)notification
{
	NSLog(@"userInfo: %@", notification.userInfo);
	[self.dataSource updateDialogList];
	[self.chatsTableView reloadData];
}

//- (BOOL)isRoomCreatedWith

@end
