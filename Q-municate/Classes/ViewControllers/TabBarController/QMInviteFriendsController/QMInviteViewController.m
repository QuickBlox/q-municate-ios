//
//  QMInviteViewController.m
//  Q-municate
//
//  Created by Andrey Ivanov on 04/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMInviteViewController.h"
#import "QMInviteFriendsDataSource.h"
#import "QMApi.h"
#import "REMessageUI.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"

@interface QMInviteViewController ()

<MFMailComposeViewControllerDelegate, QMCheckBoxStateDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (strong, nonatomic) QMInviteFriendsDataSource *dataSource;

@end

@implementation QMInviteViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = nil;
	self.dataSource = [[QMInviteFriendsDataSource alloc] initWithTableView:self.tableView];
    self.dataSource.checkBoxDelegate = self;
    
    [self changeSendButtonEnableForCheckedUsersCount:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)sendButtonClicked:(id)sender {
    
    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    NSArray *abEmails = [weakSelf.dataSource emailsToInvite];
    if (abEmails.count > 0) {
        
        [REMailComposeViewController present:^(REMailComposeViewController *mailVC) {
            
            [mailVC setToRecipients:abEmails];
            [mailVC setSubject:kMailSubjectString];
            [mailVC setMessageBody:kMailBodyString isHTML:YES];
            [weakSelf presentViewController:mailVC animated:YES completion:nil];
            
        } finish:^(MFMailComposeResult result, NSError *error) {
            
            if (!error && result == MFMailComposeResultSent) {
                
                [weakSelf.dataSource clearABFriendsToInvite];
                [SVProgressHUD showSuccessWithStatus:@"Success!"];
            }
// TODO: Reachability case
            else if (result == MFMailComposeResultFailed && !error) {
                [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"QM_STR_MAIL_COMPOSER_ERROR_DESCRIPTION_FOR_INVITE", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) otherButtonTitles:nil] show];
                
            } else if (result == MFMailComposeResultFailed && error) {
                [SVProgressHUD showErrorWithStatus:@"Error"];
            }
        }];
    }
    
}

- (void)changeSendButtonEnableForCheckedUsersCount:(NSInteger)checkedUsersCount
{
    self.sendButton.enabled = checkedUsersCount > 0;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.dataSource didSelectRowAtIndexPath:indexPath];
}


#pragma mark - QMCheckBoxStatusDelegate

- (void)checkListDidChangeCount:(NSInteger)checkedCount {
      [self changeSendButtonEnableForCheckedUsersCount:checkedCount];
}

@end
