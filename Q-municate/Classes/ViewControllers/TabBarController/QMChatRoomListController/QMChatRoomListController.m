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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#warning Testing!
//- (IBAction)createNewDialog:(id)sender
//{
//    QBChatDialog *newDialog = [[QBChatDialog alloc] init];
//    newDialog.type = QBChatDialogTypeGroup;
//    newDialog.name = @"LALLIPOP";
//    newDialog.occupantIDs = @[[@([QMContactList shared].me.ID) stringValue], @"921692"];
//    
//    [[QBChat instance] createDialog:newDialog delegate:self];
//}
//
//#pragma mark - QBActionStatusDelegate
//
//- (void)completedWithResult:(Result *)result
//{
//    if (result.success && [result isKindOfClass:[QBChatDialogResult class]]) {
//        QBChatDialogResult *dialogResult = (QBChatDialogResult *)result;
//        QBChatDialog *returnedDialog = dialogResult.dialog;
//        NSLog(@"Returned dialog: %@", [returnedDialog description]);
//    }
//}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource.roomsListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QMChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatListCellIdentifier];
    
    NSDictionary *chatInfo = self.dataSource.roomsListArray[indexPath.row];
    cell.name.text = chatInfo[@"name"];
    cell.lastMessage.text = chatInfo[@"last_msg"];
    cell.groupMembersNumb.text = chatInfo[@"group_count"];
    cell.unreadMsgNumb.text = chatInfo[@"unread_count"];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *chat = self.dataSource.roomsListArray[indexPath.row];
    NSString *chatName = chat[@"name"];
    [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:chatName];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[QMChatViewController class]]) {
        QMChatViewController *childController = (QMChatViewController *)segue.destinationViewController;
        childController.chatName = (NSString *)sender;
    }
}

@end
