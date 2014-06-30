//
//  QMAddUsersAbstractController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 17/06/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMAddUsersAbstractController.h"
#import "QMInviteFriendsCell.h"
#import "QMContactList.h"

@interface QMAddUsersAbstractController ()

@end


@implementation QMAddUsersAbstractController


#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configurePerformButtonBorder];
    [self updateNavTitle];
    
    [self applyChangesForPerformButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI Configurations

- (void)updateNavTitle
{
    self.title  = [NSString stringWithFormat:@"%li Selected", (unsigned long)[self.dataSource.friendsSelectedMArray count]];
}

- (void)configurePerformButtonBorder
{
    self.performButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.performButton.layer.borderWidth = 0.5;
}

- (void)applyChangesForPerformButton
{
    // Override:
}


#pragma mark - Actions

/** Override this methods */
- (IBAction)performAction:(id)sender
{
   CHECK_OVERRIDE();
}

- (IBAction)cancelSelection:(id)sender
{
    if ([self.dataSource.friendsSelectedMArray count] > 0) {
        [self.dataSource.friendsSelectedMArray removeAllObjects];
        
        [self updateNavTitle];
        [self applyChangesForPerformButton];
        [self.tableView reloadData];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource.friendListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QMInviteFriendsCell *cell = (QMInviteFriendsCell *) [tableView dequeueReusableCellWithIdentifier:kCreateChatCellIdentifier];
    QBUUser *person = self.dataSource.friendListArray[indexPath.row];
    
    BOOL checked = [self isChecked:person];
    [cell configureCellWithParamsForQBUser:person checked:checked];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QBUUser *checkedUser = self.dataSource.friendListArray[indexPath.row];
    
    BOOL checked = [self isChecked:checkedUser];
    if (checked) {
        [self.dataSource.friendsSelectedMArray removeObject:checkedUser];
    } else {
        [self.dataSource.friendsSelectedMArray addObject:checkedUser];
    }
    
    // update navigation title:
    [self updateNavTitle];
    
	[self applyChangesForPerformButton];
	[self.tableView reloadData];
}


#pragma mark - Options

- (BOOL)isChecked:(QBUUser *)user
{
    for (QBUUser *person in self.dataSource.friendsSelectedMArray) {
        if ([person isEqual:user]) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableArray *)usersIDFromSelectedUsers:(NSMutableArray *)users
{
	NSMutableArray *usersIDMArray = [NSMutableArray new];
	for (QBUUser *user in users) {
		[usersIDMArray addObject:[NSString stringWithFormat:@"%lu", (unsigned long)user.ID]];
	}
	return usersIDMArray;
}



@end
