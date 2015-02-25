//
//  QMFeedbackTableViewController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 09/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFeedbackTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "REMessageUI.h"
#import "REAlertView+QMSuccess.h"
#import <SVProgressHUD.h>

@interface QMFeedbackTableViewController ()

@property (nonatomic, strong) NSIndexPath *lastIndexPath;
@property (strong,nonatomic) NSArray *titles;

@end


@implementation QMFeedbackTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // first tapped by default:
    self.titles = @[NSLocalizedString(@"QM_STR_BUG", nil),
                    NSLocalizedString(@"QM_STR_IMPROVEMENT", nil),
                    NSLocalizedString(@"QM_STR_SUGGESTION", nil)];
    
    self.lastIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
}

- (NSString *)deviceInfo {
    
    UIDevice *device = [UIDevice currentDevice];
//    NSString *modelName = [device modelName];

    NSString *systemVersion = [device systemVersion];
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:kSettingsCellBundleVersion];
    
    NSString *deviceInfo = [NSString stringWithFormat:@"\n\n\nModel: %@,\nSystem version: %@,\nBuild version: %@,\n", modelName, systemVersion, buildVersion];

    return deviceInfo;
}

- (NSString *)titleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row > 0 && indexPath.section == 0) {
        return  self.titles[indexPath.row - 1];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row > 0 && indexPath.section == 0) {
        cell.textLabel.text = self.titles[indexPath.row - 1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0) return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *lastSelectedCell = [tableView cellForRowAtIndexPath:self.lastIndexPath];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.lastIndexPath = indexPath;
}

- (IBAction)writeAnEmailTapped:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    [REMailComposeViewController present:^(REMailComposeViewController *mailVC) {
        
        NSString *recipient = @"q-municate@quickblox.com";
        
        NSString *subject = [weakSelf titleForRowAtIndexPath:weakSelf.lastIndexPath];
        NSString *messageBody = [weakSelf deviceInfo];
        
        [mailVC setSubject:subject];
        [mailVC setToRecipients:@[recipient]];
        [mailVC setMessageBody:messageBody isHTML:NO];
        
        [weakSelf presentViewController:mailVC animated:YES completion:nil];
        
    } finish:^(MFMailComposeResult result, NSError *error) {
        
        if (result == MFMailComposeResultSent) {
            
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_THANKS", nil)];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
        } else if (result == MFMailComposeResultFailed) {
            
            [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"QM_STR_MAIL_COMPOSER_ERROR_DESCRIPTION", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) otherButtonTitles:nil] show];
        }
    }];
}

@end
