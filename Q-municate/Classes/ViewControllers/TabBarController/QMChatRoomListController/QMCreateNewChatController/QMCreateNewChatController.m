//
//  QMCreateNewChatController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 31/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMCreateNewChatController.h"
#import "QMChatViewController.h"
#import "QMInviteFriendsCell.h"
#import "UIImageView+ImageWithBlobID.h"

#import "QMContactList.h"
#import "QMNewChatDataSource.h"
#import "QMChatService.h"

static CGFloat const rowHeight = 60.0;


@interface QMCreateNewChatController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *createGroupButton;

@property (strong, nonatomic) QMNewChatDataSource *dataSource;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (assign, nonatomic) BOOL searchBarIsShowed;
@property (assign, nonatomic) BOOL searchIsActive;

@end

@implementation QMCreateNewChatController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [QMNewChatDataSource new];
	[self configureCreateButtonWithShadow];
	[self configureCreateChatButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCreateButtonWithShadow
{
    self.createGroupButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.createGroupButton.layer.borderWidth = 0.5;
}

- (IBAction)cancelSelection:(id)sender
{
    if ([self.dataSource.friendsSelectedMArray count] > 0) {
        [self.dataSource.friendsSelectedMArray removeAllObjects];
        self.title = [NSString stringWithFormat:@"%li Selected", (unsigned long)[self.dataSource.friendsSelectedMArray count]];
        [self.tableView reloadData];
    }
}
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createGroupChat:(id)sender
{
	NSMutableArray *selectedUsersMArray = self.dataSource.friendsSelectedMArray;
    NSString *chatName = [self chatNameFromUserNames:selectedUsersMArray];
	NSArray *usersIdArray = [self usersIDFromSelectedUsers:selectedUsersMArray];
        
    // create new dialog entity:
    QBChatDialog *chatDialog = [QBChatDialog new];
    chatDialog.name = chatName;
    chatDialog.occupantIDs = usersIdArray;
    chatDialog.type = QBChatDialogTypeGroup;
    [[QMChatService shared] createNewDialog:chatDialog withCompletion:^(QBChatDialog *dialog, NSError *error) {
        // save to dialogs dictionary:
        [QMChatService shared].allDialogsAsDictionary[dialog.roomJID] = dialog;
        
        // send invitation to users:
        [[QMChatService shared] sendInviteMessageToUsers:selectedUsersMArray withChatDialog:dialog];
        
        [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:dialog];
    }];
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
    
    self.title  = [NSString stringWithFormat:@"%li Selected", (unsigned long)[self.dataSource.friendsSelectedMArray count]];
	[self configureCreateChatButton];
	[self.tableView reloadData];
}


#pragma mark - Options

- (void)configureCreateChatButton
{
	if ([self.dataSource.friendsSelectedMArray count] <=1) {
		[self.createGroupButton setEnabled:NO];
		[self.createGroupButton setAlpha:0.5f];
        return;
	}
    [self.createGroupButton setEnabled:YES];
    [self.createGroupButton setAlpha:1.0f];
}

- (void)setGroupChatTitle
{
	[self.createGroupButton setTitle:kButtonTitleCreateGroupChatString forState:UIControlStateNormal];
	[self.createGroupButton setTitle:kButtonTitleCreateGroupChatString forState:UIControlStateHighlighted];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    QMChatViewController *childController = (QMChatViewController *)segue.destinationViewController;
    if ([self.dataSource.friendsSelectedMArray count] > 1) {
        QBChatDialog *dialog = (QBChatDialog *)sender;
		childController.chatDialog = dialog;
        childController.chatName = dialog.name;
        childController.createdJustNow = YES;
	}
}

- (BOOL)isChecked:(QBUUser *)user
{
    for (QBUUser *person in self.dataSource.friendsSelectedMArray) {
        if ([person isEqual:user]) {
            return YES;
        }
    }
    return NO;
}

// title for chat view:
- (NSString *)chatNameFromUserNames:(NSMutableArray *)users
{
    NSMutableString *chatName = nil;
    for (QBUUser *user in users) {
        if ([user isEqual:[users firstObject]]) {
            chatName = [user.fullName mutableCopy];
            continue;
        }
        [chatName appendString:@", "];
        [chatName appendString:user.fullName];
    }
    return chatName;
}

- (NSArray *)usersIDFromSelectedUsers:(NSMutableArray *)users
{
	NSMutableArray *usersIDMArray = [NSMutableArray new];
	for (QBUUser *user in users) {
		[usersIDMArray addObject:[NSNumber numberWithLong:user.ID]];
	}
    // also add me:
    NSNumber *myID = @([QMContactList shared].me.ID);
    [usersIDMArray addObject:myID];
    
	return usersIDMArray;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton:NO animated:YES];
	return YES;
}

// search bar find text
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//	[self.dataSource emptyOtherUsersArray];
//	self.searchIsActive = YES;
//
//	if ([searchText isEqualToString:kEmptyString]) {
//		self.searchIsActive = NO;
//		[self reloadFriendsList];
//		return;
//	}
//	[self.dataSource updateFriendsArrayForSearchPhrase:searchText];
//	[self.tableView reloadData];
//}

@end
