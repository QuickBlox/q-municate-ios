//
//  QMInviteFriendsController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 04/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "QMInviteFriendsController.h"
#import "QMAddressBook.h"
#import "QMInviteFriendCell.h"
#import "QMInviteStaticCell.h"
#import "ABPerson.h"
#import "QMInviteFriendsDataSource.h"
#import "QMApi.h"


@interface QMInviteFriendsController ()

<QBActionStatusDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) QMInviteFriendsDataSource *dataSource;

@end

@implementation QMInviteFriendsController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = nil;
	self.dataSource = [[QMInviteFriendsDataSource alloc] initWithTableView:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//#pragma mark - Actions

- (IBAction)sendButtonClicked:(id)sender {
//    
////	//share to Facebook:
////    if ([self.dataSource.checkedFacebookUsers count] > 0) {
////        
////        NSString *tags = [self.dataSource emailsFromFacebookPersons];
////        [QMApi instance]
////
////        [fbService connectToFacebook:^(NSString *sessionToken) {
////            
////            [self shareApplicationToFriends:tags];
////        }];
////        return;
////    }
////    // share via Email:
////    if ([self.dataSource.checkedABContacts count] > 0) {
////		if ([MFMailComposeViewController canSendMail]) {
////			[self showEmailController];
////		} else {
////			[[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:kAlertBodySetUpYourEmailClientString delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
////		}
////	}
}

//- (void)shareApplicationToFriends:(NSString *)friendsListString {
//
////    QMFacebookService *fbService = [[QMFacebookService alloc] init];
////    [fbService shareToFacebookUsersWithIDs:friendsListString withCompletion:^(BOOL success, NSError *error) {
//}

//- (void)showEmailController
//{
//    NSArray *emails = [self.dataSource emailsFromContactListPersons];
//    if ([MFMailComposeViewController canSendMail]) {
//        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
//        mailController.mailComposeDelegate = self;
//        [mailController setToRecipients:emails];
//        [mailController setSubject:kMailSubjectString];
//        [mailController setMessageBody:kMailBodyString isHTML:YES];
//        [self presentViewController:mailController animated:YES completion:^{
//            ILog(@"Mail Controller presented");
//        }];
//    }
//}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.dataSource didSelectRowAtIndexPath:indexPath];
}

//- (IBAction)markContactUsersList:(UIButton *)sender
//{
//	[self.dataSource changeStateForContactUsers];
//	[self checkForContactsSetCompleteness];
//	[self.tableView reloadData];
//}



//- (void)makeChangesForCell:(QMInviteFriendsCell *)cell
//{
//	[self.dataSource changeUserState:cell.user];
//	[self checkForFriendsSetCompletenessForCell:cell];
//}
//

#pragma mark - MFMailComposeViewController

//- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
//{
//    if (error) {
//        NSString *errorMessage = [NSString stringWithFormat:@"%@", error];
//        [self showAlertWithMessage:errorMessage];
//        return;
//    }
//    
//    if (result == MFMailComposeResultSent) {
//        [self.dataSource.checkedABContacts removeAllObjects];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAlertTitleSuccessString message:kAlertBodyRecordSentViaMailString delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil];
//        [alert show];
//    } else if (result == MFMailComposeResultCancelled || result == MFMailComposeResultSaved) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//}



@end
