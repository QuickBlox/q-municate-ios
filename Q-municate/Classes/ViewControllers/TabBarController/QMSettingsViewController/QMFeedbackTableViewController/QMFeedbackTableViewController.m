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
    NSString *modelIdentifier = [device modelIdentifier];
    NSString *deviceInfo = [NSString stringWithFormat:@"\n\n\nModel: %@,\n Identifier: %@,\n", modelName, modelIdentifier];
    
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
    [self showMailComposer];
}

- (void)showMailComposer
{
    NSString *recipient = @"q-municate@quickblox.com";
    NSString *subject = ((UITableViewCell *)[self.tableView cellForRowAtIndexPath:self.lastIndexPath]).reuseIdentifier;
    NSString *messageBody = [self deviceInfo];
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    
    [mailController setSubject:subject];
    [mailController setToRecipients:@[recipient]];
    [mailController setMessageBody:messageBody isHTML:NO];
    
    [self presentViewController:mailController animated:YES completion:nil];
}

#pragma mark - Mail composer delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        [[[UIAlertView alloc] initWithTitle:kAlertTitleSuccessString message:@"Thanks for your feedback!" delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
    } else if (result == MFMailComposeResultFailed) {
        [[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:error.localizedDescription delegate:nil cancelButtonTitle:kAlertButtonTitleCancelString otherButtonTitles:nil] show];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];

}

@end
