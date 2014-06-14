//
//  QMGroupDetailsController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 12/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMGroupDetailsController.h"
#import <AsyncImageView.h>

@interface QMGroupDetailsController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet AsyncImageView *groupAvatarView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *occupantsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *onlineOccupantsCountLabel;

@end

@implementation QMGroupDetailsController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self subscribeToChatNotifications];
    
    // request online users:
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
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
