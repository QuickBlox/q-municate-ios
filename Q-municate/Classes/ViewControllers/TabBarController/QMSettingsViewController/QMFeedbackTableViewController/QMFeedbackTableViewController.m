//
//  QMFeedbackTableViewController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 09/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMFeedbackTableViewController.h"
#import <UIDevice-Hardware.h>
#import <MessageUI/MessageUI.h>
#import "REMessageUI.h"
#import "REAlertView+QMSuccess.h"
#import <SVProgressHUD.h>

@interface QMFeedbackTableViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSIndexPath *lastIndexPath;

@end


@implementation QMFeedbackTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // first tapped by default:
    self.lastIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
}

- (NSString *)deviceInfo
{
    UIDevice *device = [UIDevice currentDevice];
    NSString *modelName = [device modelName];
    NSString *systemVersion = [device systemVersion];
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:kSettingsCellBundleVersion];
    
    NSString *deviceInfo = [NSString stringWithFormat:@"\n\n\nModel: %@,\nSystem version: %@,\nBuild version: %@,\n", modelName, systemVersion, buildVersion];
    return deviceInfo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *lastSelectedCell = [tableView cellForRowAtIndexPath:self.lastIndexPath];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    lastSelectedCell.accessoryType = UITableViewCellAccessoryNone;
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.lastIndexPath = indexPath;
}

- (IBAction)writeAnEmailTapped:(id)sender
{
    
    [REMailComposeViewController present:^(REMailComposeViewController *mailVC) {
        
        NSString *recipient = @"q-municate@quickblox.com";
        NSString *subject = ((UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.lastIndexPath]).reuseIdentifier;
        NSString *messageBody = [self deviceInfo];
        
//        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
//        mailController.mailComposeDelegate = self;
        
        [mailVC setSubject:subject];
        [mailVC setToRecipients:@[recipient]];
        [mailVC setMessageBody:messageBody isHTML:NO];
        
        [self presentViewController:mailVC animated:YES completion:nil];
        
    } finish:^(MFMailComposeResult result, NSError *error) {
        
       __weak typeof(self) weakself = self;
        
        if (result == MFMailComposeResultSent) {
            
            [SVProgressHUD showSuccessWithStatus:@"Thanks!"];
            [weakself.navigationController popViewControllerAnimated:YES];
            
        } else if (result == MFMailComposeResultFailed) {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
    }];
}


@end
