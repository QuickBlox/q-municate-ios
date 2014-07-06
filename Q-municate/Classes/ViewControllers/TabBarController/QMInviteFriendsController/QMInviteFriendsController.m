//
//  QMInviteFriendsController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 04/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "QMInviteFriendsController.h"
#import "QMUsersService.h"
#import "QMAddressBook.h"
#import "QMInviteFriendsCell.h"
#import "QMInviteFriendsStaticCell.h"
#warning update person
//#import "QMPerson.h"
#import "QMUtilities.h"

#import "QMFacebookService.h"
#import "QMInviteFriendsDataSource.h"
#import "QMAuthService.h"


@interface QMInviteFriendsController () <QBActionStatusDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) QMInviteFriendsDataSource *dataSource;

@property (assign, nonatomic) BOOL facebookCellChecked;
@property (assign, nonatomic) BOOL contactsCellChecked;

@end

@implementation QMInviteFriendsController



#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self _initialize];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_initialize) name:kInviteFriendsDataSourceShouldRefreshNotification object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_initialize
{
	self.dataSource = nil;
	self.dataSource = [QMInviteFriendsDataSource new];
	[self.tableView reloadData];
}

#pragma mark - Actions

- (IBAction)sendButtonClicked:(id)sender
{
	//share to Facebook:
    if ([self.dataSource.checkedFacebookUsers count] > 0) {
        
        NSString *tags = [self.dataSource emailsFromFacebookPersons];
        
        QMFacebookService *fbService = [[QMFacebookService alloc] init];

        [fbService connectToFacebook:^(NSString *sessionToken) {
            
            [self shareApplicationToFriends:tags];
        }];
        return;
    }
    // share via Email:
    if ([self.dataSource.checkedABContacts count] > 0) {
		if ([MFMailComposeViewController canSendMail]) {
			[self showEmailController];
		} else {
			[[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:kAlertBodySetUpYourEmailClientString delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
		}
	}
}

- (void)shareApplicationToFriends:(NSString *)friendsListString
{
#warning me.iD
#warning QMContactList shared
//    QMFacebookService *fbService = [[QMFacebookService alloc] init];
//    [fbService shareToFacebookUsersWithIDs:friendsListString withCompletion:^(BOOL success, NSError *error) {
//        if (!success) {
//            NSString *errorMessageString = [NSString stringWithFormat:@"%@", error];
//            [self showAlertWithMessage:errorMessageString];
//            return;
//        }
//        [self.dataSource emptyCheckedFBUsersArray];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlertTitleSuccessString message:kAlertBodyRecordPostedString delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil];
//        [alert show];
//    }];
}

- (void)showEmailController
{
    NSArray *emails = [self.dataSource emailsFromContactListPersons];
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setToRecipients:emails];
        [mailController setSubject:kMailSubjectString];
        [mailController setMessageBody:kMailBodyString isHTML:YES];
        [self presentViewController:mailController animated:YES completion:^{
            ILog(@"Mail Controller presented");
        }];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return [self.dataSource.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
       QMInviteFriendsStaticCell *cell = [self cellForTableView:tableView andIndexPath:indexPath];
        if ([cell.cellType isEqualToString:kFacebookFriendStatus]) {
            if (self.facebookCellChecked) {
                cell.activeCheckBox.hidden = NO;
            } else {
                cell.activeCheckBox.hidden = YES;
            }
            cell.badgeCounter.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.dataSource.checkedFacebookUsers count]];
        } else if ([cell.cellType isEqualToString:kAddressBookUserStatus]) {
            if (self.contactsCellChecked) {
                cell.activeCheckBox.hidden = NO;
            } else {
                cell.activeCheckBox.hidden = YES;
            }
            cell.badgeCounter.text = [NSString stringWithFormat:@"%lu", (unsigned long)[self.dataSource.checkedABContacts count]];
        }
        return cell;
    }
    QMInviteFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:kInviteFriendCellIdentifier];
    QMPerson *user = [self.dataSource.users objectAtIndex:indexPath.row];
    
    [cell configureCellWithParams:user];
    
    return cell;
}

- (QMInviteFriendsStaticCell *)cellForTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath
{
    QMInviteFriendsStaticCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kFacebookCellIdentifier];
        cell.cellType = kFacebookFriendStatus;
    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:kContactListCellIdentifier];
        cell.cellType = kAddressBookUserStatus;
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			[self loadFriendsFromFacebook];
		} else {
			[self loadFriendsFromAddressBook];
		}
	} else {
		QMInviteFriendsCell *cell = (QMInviteFriendsCell *) [tableView cellForRowAtIndexPath:indexPath];
		[self makeChangesForCell:cell];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self performSelector:@selector(deselectCellForIndexPath:) withObject:indexPath afterDelay:0.3f];
}

- (void)deselectCellForIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView reloadData];
}

- (IBAction)markFacebookUsersList:(UIButton *)sender
{
	[self.dataSource changeStateForFacebookUsers];
	[self checkForFacebookSetCompleteness];
	[self.tableView reloadData];
}

- (IBAction)markContactUsersList:(UIButton *)sender
{
	[self.dataSource changeStateForContactUsers];
	[self checkForContactsSetCompleteness];
	[self.tableView reloadData];
}

- (IBAction)markUser:(UIButton *)sender
{
	QMInviteFriendsCell *cell = (QMInviteFriendsCell *) [[[sender superview]  superview] superview];
	[self makeChangesForCell:cell];
	[self.tableView reloadData];
}

- (void)makeChangesForCell:(QMInviteFriendsCell *)cell
{
	[self.dataSource changeUserState:cell.user];
	[self checkForFriendsSetCompletenessForCell:cell];
}

- (void)checkForFriendsSetCompletenessForCell:(QMInviteFriendsCell *)cell
{
#warning update it
//	if (cell.user.isFacebookPerson) {
//		[self checkForFacebookSetCompleteness];
//	} else {
//		[self checkForContactsSetCompleteness];
//	}
}

- (void)checkForFacebookSetCompleteness
{
//	NSMutableArray *fbFriendsMArray = [[QMContactList shared].facebookFriendsToInvite mutableCopy];
	if ([self.dataSource.checkedFacebookUsers count] == 0) {
		self.facebookCellChecked = NO;
	} else {
		self.facebookCellChecked = YES;
	}
}

- (void)checkForContactsSetCompleteness
{
//	NSMutableArray *contactFriendsMArray = [[QMContactList shared].contactsToInvite mutableCopy];
	if ([self.dataSource.checkedABContacts count] == 0) {
		self.contactsCellChecked = NO;
	} else {
		self.contactsCellChecked = YES;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44;
    }
    return 60;
}

- (void)loadFriendsFromFacebook
{
	self.facebookCellChecked = NO;
	[self.dataSource emptyCheckedFBUsersArray];
	[self.dataSource updateFacebookDataSource:^(NSError *error) {
		if (error) {
			ILog(@"%@",error);
		} else {
			[self.tableView reloadData];
		}

	}];
}

- (void)loadFriendsFromAddressBook
{
	self.contactsCellChecked = NO;
	[self.dataSource emptyCheckedABUsersArray];
#warning me.iD
#warning QMContactList shared
//	[self.dataSource updateContactListDataSource:^(NSError *error) {
//		if (error) {
//			ILog(@"%@",error);
//		} else {
//			if (![[QMContactList shared].contactsToInvite count]) {
//				[self showAlertWithMessage:kAlertBodyNoContactsWithEmailsString];
//			} else {
//				[self.tableView reloadData];
//			}
//		}
//	}];
}


#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:message delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil];
    [alert show];
}

- (void)showAlertWithError:(NSError *)error
{
	NSString *errorString = [NSString stringWithFormat:@"%@", error];
	[self showAlertWithMessage:errorString];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.dataSource.checkedABContacts count] > 0) {
        [self showEmailController];
        return;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        ILog(@"Email Controller Dismissed");
    }];
}

#pragma mark - MFMailComposeViewController

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"%@", error];
        [self showAlertWithMessage:errorMessage];
        return;
    }
    
    if (result == MFMailComposeResultSent) {
        [self.dataSource.checkedABContacts removeAllObjects];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlertTitleSuccessString message:kAlertBodyRecordSentViaMailString delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil];
        [alert show];
    } else if (result == MFMailComposeResultCancelled || result == MFMailComposeResultSaved) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



@end
