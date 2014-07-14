//
//  QMInviteViewController.m
//  Q-municate
//
//  Created by Ivanov Andrey on 04/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMInviteViewController.h"
#import "QMInviteFriendsDataSource.h"
#import "QMApi.h"
#import "REMessageUI.h"

@interface QMInviteViewController ()

<QBActionStatusDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) QMInviteFriendsDataSource *dataSource;

@end

@implementation QMInviteViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.dataSource = nil;
	self.dataSource = [[QMInviteFriendsDataSource alloc] initWithTableView:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)sendButtonClicked:(id)sender {
    
    void (^inviteWithEmail)(void) =^{
        
        NSArray *abEmails = [self.dataSource emailsToInvite];
        if (abEmails.count > 0) {
            
            [REMailComposeViewController present:^(REMailComposeViewController *mailVC) {
                
                [mailVC setToRecipients:abEmails];
                [mailVC setSubject:kMailSubjectString];
                [mailVC setMessageBody:kMailBodyString isHTML:YES];
                [self presentViewController:mailVC animated:YES completion:nil];
                
            } finish:^(MFMailComposeResult result, NSError *error) {
                
            }];
        }
    };
    
    NSArray *fbIDs = [self.dataSource facebookIDsToInvite];
    if (fbIDs.count > 0) {
        [[QMApi instance] fbInviteUsersWithIDs:fbIDs copmpletion:inviteWithEmail];
    } else {
        inviteWithEmail();
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.dataSource heightForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.dataSource didSelectRowAtIndexPath:indexPath];
}

@end
