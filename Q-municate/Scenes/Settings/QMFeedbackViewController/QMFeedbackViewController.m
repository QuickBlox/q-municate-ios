//
//  QMFeedbackViewController.m
//  Q-municate
//
//  Created by Injoit on 5/20/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMFeedbackViewController.h"
#import "QMColors.h"
#import "REMessageUI.h"
#import "SVProgressHUD.h"
#import "QMSLog.h"

#import <UIDevice_Hardware/UIDevice-Hardware.h>

static const CGFloat kQMTextCellMinHeight = 64.0f;
static NSString *const kQMBundleVersion = @"CFBundleVersion";

typedef NS_ENUM(NSUInteger, QMFeedbackSection) {
    
    QMFeedbackSectionText,
    QMFeedbackSectionSelection,
    QMFeedbackSectionButton
};

typedef NS_ENUM(NSUInteger, QMFeedbackSelection) {
    
    QMFeedbackSelectionBug,
    QMFeedbackSelectionImprovement,
    QMFeedbackSelectionSuggestion
};

@interface QMFeedbackViewController ()

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSArray *titles;

@end

@implementation QMFeedbackViewController

- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    
    // removing left bar button item that is responsible for split view
    // display mode managing. Not removing it will cause item update
    // for deallocated navigation item
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Set tableview background color
    self.tableView.backgroundColor = QMTableViewBackgroundColor();
    
    // automatic self-sizing cells (used for text cell)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kQMTextCellMinHeight;
    
    // configuring properties
    self.selectedIndexPath = [NSIndexPath indexPathForRow:QMFeedbackSelectionBug inSection:QMFeedbackSectionSelection];
    
    self.titles = @[NSLocalizedString(@"QM_STR_BUG", nil),
                    NSLocalizedString(@"QM_STR_IMPROVEMENT", nil),
                    NSLocalizedString(@"QM_STR_SUGGESTION", nil)];
}

//MARK: - Methods

- (void)writeEmail {
    
    @weakify(self);
    [REMailComposeViewController present:^(REMailComposeViewController *mailVC) {
        
        @strongify(self);
        NSString *recipient = @"q-municate@quickblox.com";
        
        NSString *subject = self.titles[self.selectedIndexPath.row];
        NSString *messageBody = [self deviceInfo];
        
        [mailVC setSubject:subject];
        [mailVC setToRecipients:@[recipient]];
        [mailVC setMessageBody:messageBody isHTML:NO];
        
        [self presentViewController:mailVC animated:YES completion:nil];
        
    } finish:^(MFMailComposeResult result, NSError *  error) {
        
        if (result == MFMailComposeResultSent) {
            
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"QM_STR_THANKS", nil)];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else if (result == MFMailComposeResultFailed) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"QM_STR_MAIL_COMPOSER_ERROR_DESCRIPTION", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull  action) {
                
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

//MARK: - Helpers

- (NSString *)deviceInfo {
    
    UIDevice *device = [UIDevice currentDevice];
    NSString *modelName = [device modelName];
    
    NSString *systemVersion = device.systemVersion;
    NSString *buildVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:kQMBundleVersion];
    
    NSString *deviceInfo = [NSString stringWithFormat:@"\n\n\nModel: %@,\nSystem version: %@,\nBuild version: %@,\n", modelName, systemVersion, buildVersion];
    
    return deviceInfo;
}

//MARK: - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
            
        case QMFeedbackSectionText:
            break;
            
        case QMFeedbackSectionSelection: {
            
            if (self.selectedIndexPath.row == indexPath.row) {
                // row already selected
                break;
            }
            
            UITableViewCell *previousSelectedCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            
            previousSelectedCell.accessoryType = UITableViewCellAccessoryNone;
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            self.selectedIndexPath = indexPath;
            
            break;
        }
            
        case QMFeedbackSectionButton:
            [self writeEmail];
            break;
    }
}

//MARK: - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == QMFeedbackSectionText) {
        // automatically resizing text cell
        return UITableViewAutomaticDimension;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

@end
