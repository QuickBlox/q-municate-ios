//
//  QMAddUsersAbstractController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddUsersAbstractController.h"
#import "QMInviteFriendCell.h"
#import "QMApi.h"

@interface QMAddUsersAbstractController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *performButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation QMAddUsersAbstractController

- (id)initWithChatDialog:(QBChatDialog *)chatDialog {
    
    if (self = [super init]) {
        
        self.selectedFriends = [NSMutableArray array];
        self.friends = [QMApi instance].friends;
        
//        NSMutableArray *sortedUsers = [self sortUsersByFullname:unsortedUsers];
//
//        NSMutableArray *usersToDelete = [NSMutableArray new];
//        for (NSString *participantID in chatDialog.occupantIDs) {
//
//            QBUUser *user = [QMContactList shared].friendsAsDictionary[participantID];
//            if (user != nil) {
//                [usersToDelete addObject:user];
//            }
//        }
//        [sortedUsers removeObjectsInArray:usersToDelete];
//
//        _friendListArray = sortedUsers;
    }
    return self;
}

- (NSMutableArray *)sortUsersByFullname:(NSArray *)users
{
    NSArray *sortedUsers = nil;
    NSSortDescriptor *fullNameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
    sortedUsers = [users sortedArrayUsingDescriptors:@[fullNameDescriptor]];
    return [sortedUsers mutableCopy];
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.selectedFriends = [NSMutableArray array];
    self.friends = [QMApi instance].friends;
    // Do any additional setup after loading the view.
    [self configurePerformButtonBorder];
    [self updateNavTitle];
    
    [self applyChangesForResetButton];
    [self applyChangesForPerformButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Configurations

- (void)updateNavTitle {
    
    self.title  = [NSString stringWithFormat:@"%d Selected", self.selectedFriends.count];
}

- (void)configurePerformButtonBorder {
    
    self.performButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.performButton.layer.borderWidth = 0.5;
}

- (void)applyChangesForPerformButton {
    
    [self.performButton setEnabled:!self.selectedFriends.count == 0];
}

- (void)applyChangesForResetButton
{
    self.resetButton.enabled = [self.selectedFriends count] > 0;
}

#pragma mark - Actions

/** Override this methods */
- (IBAction)performAction:(id)sender
{
   CHECK_OVERRIDE();
}

- (IBAction)cancelSelection:(id)sender {
    
    if ([self.selectedFriends count] > 0) {
        [self.selectedFriends removeAllObjects];
        
        [self updateNavTitle];
        [self applyChangesForPerformButton];
        [self.tableView reloadData];
    }
    [self applyChangesForResetButton];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMInviteFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kCreateChatCellIdentifier];
    
    QBUUser *friend = self.friends[indexPath.row];
    cell.check = [self.selectedFriends containsObject:friend];
    cell.userData = friend;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QBUUser *checkedUser = self.friends[indexPath.row];
    
    BOOL contains = [self.selectedFriends containsObject:checkedUser];
    contains ? [self.selectedFriends removeObject:checkedUser] : [self.selectedFriends addObject:checkedUser];
    
    // update navigation title:
    [self updateNavTitle];
	[self applyChangesForPerformButton];
    [self applyChangesForResetButton];
	[self.tableView reloadData];
}

@end
