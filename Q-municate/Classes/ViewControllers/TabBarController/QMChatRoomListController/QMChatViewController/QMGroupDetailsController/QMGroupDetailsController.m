//
//  QMGroupDetailsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 12/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsController.h"
#import <AsyncImageView.h>
#import "QMGroupDetailsDataSource.h"


@interface QMGroupDetailsController () <UITableViewDelegate>

@property (weak, nonatomic) IBOutlet AsyncImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) QMGroupDetailsDataSource *dataSource;

@end

@implementation QMGroupDetailsController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self subscribeToChatNotifications];
    
    // init data source for tableview:
    self.dataSource = [[QMGroupDetailsDataSource alloc] initWithChatDialog:self.chatDialog tableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    
    // request online users statuses:
    [self.chatRoom requestOnlineUsers];
    
    // show chat dialog getails on view:
    [self showQBChatDialogDetails:self.chatDialog];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showQBChatDialogDetails:(QBChatDialog *)chatDialog
{
    if (chatDialog != nil && chatDialog.type == QBChatDialogTypeGroup) {
        
        // set group name:
        self.groupNameLabel.text = chatDialog.name;
        
        // numb of participants:
        NSString *occupantsCountText = [NSString stringWithFormat:@"%lu participants", (unsigned long)[self.chatDialog.occupantIDs count]];
        self.occupantsCountLabel.text = occupantsCountText;
        
        // default online participants counts:
        NSString *onlineUsersCountText = [NSString stringWithFormat:@"0/%lu online", (unsigned long)[self.chatDialog.occupantIDs count]];
        self.onlineOccupantsCountLabel.text = onlineUsersCountText;
    }
}

- (void)subscribeToChatNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineUsersListChanged:) name:kChatRoomDidChangeOnlineUsersList object:nil];
}


#pragma mark - Notifications

- (void)onlineUsersListChanged:(NSNotification *)notification
{
    NSArray *onlineUsrList = notification.userInfo[@"online_users"];
    
    // update online participants count:
    NSString *onlineUsersCountText = [NSString stringWithFormat:@"%lu/%lu online", (unsigned long)[onlineUsrList count], (unsigned long)[self.chatDialog.occupantIDs count]];
    self.onlineOccupantsCountLabel.text = onlineUsersCountText;
}

@end
