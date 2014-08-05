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
#import "SVProgressHUD.h"

@interface QMInviteViewController ()

<QBActionStatusDelegate, MFMailComposeViewControllerDelegate, QMCheckBoxStateDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
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

    __weak __typeof(self)weakSelf = self;
    void (^inviteWithEmail)(void) =^{
        
        NSArray *abEmails = [weakSelf.dataSource emailsToInvite];
        if (abEmails.count > 0) {
            
            [REMailComposeViewController present:^(REMailComposeViewController *mailVC) {

                [mailVC setToRecipients:abEmails];
                [mailVC setSubject:kMailSubjectString];
                [mailVC setMessageBody:kMailBodyString isHTML:YES];
                [weakSelf presentViewController:mailVC animated:YES completion:nil];
                
            } finish:^(MFMailComposeResult result, NSError *error) {
                
                if (!error && result != MFMailComposeResultFailed && result != MFMailComposeResultCancelled) {

                    [weakSelf.dataSource clearABFriendsToInvite];
                    [weakSelf.dataSource clearFBFriendsToInvite];
                }
                else {
                    if (result == MFMailComposeResultFailed && !error) {
                        
                        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_PLEASE_CHECK_YOUR_EMAIL_SETTINGS", nil)];
                    }
                }
            }];
        }
    };
    
    NSArray *fbIDs = [self.dataSource facebookIDsToInvite];

    if (fbIDs.count > 0) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
        
        [[QMApi instance] fbInviteUsersWithIDs:fbIDs copmpletion:^(NSError *error) {

            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }else {
                [weakSelf.dataSource clearFBFriendsToInvite];

                [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_INVITATION_WAS_POSTED_TO_WALL", nil)];
            }
            inviteWithEmail();
        }];
        
    } else {
        inviteWithEmail();
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
