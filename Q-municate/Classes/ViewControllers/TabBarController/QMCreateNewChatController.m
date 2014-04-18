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
static CGFloat const rowHeight = 60.0;


@interface QMCreateNewChatController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *createGroupButton;

@property (strong, nonatomic) NSArray *friendList;
@property (strong, nonatomic) NSMutableArray *friendsSelected;

@end

@implementation QMCreateNewChatController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureCreateButtonWithShadow];
    self.friendList = [[QMContactList shared].friends mutableCopy];
    
    self.friendsSelected = [[NSMutableArray alloc] init];
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
    if ([self.friendsSelected count] > 0) {
        [self.friendsSelected removeAllObjects];
        self.title = [NSString stringWithFormat:@"%li Selected", (unsigned long)[self.friendsSelected count]];
        [self.tableView reloadData];
    }
}
- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createGroupChat:(id)sender
{
    NSString *chatName = [self chatNameFromUserNames:self.friendsSelected];
    [self performSegueWithIdentifier:kChatViewSegueIdentifier sender:chatName];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friendList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QMInviteFriendsCell *cell = (QMInviteFriendsCell *) [tableView dequeueReusableCellWithIdentifier:kCreateChatCellIdentifier];
    QBUUser *person = self.friendList[indexPath.row];
    
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
    QBUUser *checkedUser = self.friendList[indexPath.row];
    
    BOOL checked = [self isChecked:checkedUser];
    if (checked) {
        [self.friendsSelected removeObject:checkedUser];
    } else {
        [self.friendsSelected addObject:checkedUser];
    }
    
    self.title  = [NSString stringWithFormat:@"%li Selected", (unsigned long)[self.friendsSelected count]];
    [self.tableView reloadData];
}


#pragma mark - Options

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    QMChatViewController *childController = (QMChatViewController *)segue.destinationViewController;
    childController.chatName = (NSString *)sender;
}

- (BOOL)isChecked:(QBUUser *)user
{
    for (QBUUser *person in self.friendsSelected) {
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

@end
