//
//  QMAddUsersAbstractController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddUsersAbstractController.h"
#import "QMInviteFriendCell.h"
#import "QMServicesManager.h"

NSString *const kCreateChatCellIdentifier = @"CreateChatCell";

@interface QMAddUsersAbstractController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *performButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation QMAddUsersAbstractController



#pragma mark - LifeCycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.selectedFriends = [NSMutableArray array];
    [self updateGUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateGUI {
    
    self.title = [NSString stringWithFormat:@"%d Selected", self.selectedFriends.count];
    BOOL enabled = self.selectedFriends.count > 0;
    self.performButton.enabled = enabled;
    self.resetButton.enabled = enabled;
    [self.tableView reloadData];
}

#pragma mark - Actions

/** Override this methods */
- (IBAction)performAction:(id)sender {
   CHECK_OVERRIDE();
}

- (IBAction)pressResetButton:(UIButton *)sender {
    
    [self.selectedFriends removeAllObjects];
    [self updateGUI];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMInviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kCreateChatCellIdentifier];
    
    QBUUser *friend = self.contacts[indexPath.row];
    
    cell.contactlistItem = [QM.contactListService.contactListMemoryStorage contactListItemWithUserID:friend.ID];
    cell.userData = friend;
    cell.check = [self.selectedFriends containsObject:friend];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QBUUser *checkedUser = self.contacts[indexPath.row];
    
    BOOL contains = [self.selectedFriends containsObject:checkedUser];
    contains ? [self.selectedFriends removeObject:checkedUser] : [self.selectedFriends addObject:checkedUser];
    [self updateGUI];
}

@end
