//
//  QMSettingsViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 06/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSettingsViewController.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

@interface QMSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *changePasswordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileCell;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;

@end

@implementation QMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([FBSession activeSession].state == FBSessionStateOpen) {
        [self cell:self.changePasswordCell setHidden:YES];
    }
    
    [self configureSettingsViewController];
}

- (void)configureSettingsViewController {
    
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:kSettingsCellBundleVersion];
    self.versionLabel.text = appVersion;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.logoutCell) {
        
        __weak __typeof(self)weakSelf = self;
        [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
            alertView.message = kAlertTitleAreYouSureString;
            [alertView addButtonWithTitle:kAlertButtonTitleLogOutString andActionBlock:^{
                [[QMApi instance] logout:^(BOOL success) {
                    [weakSelf performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
                }];
            }];
            
            [alertView addButtonWithTitle:kAlertButtonTitleCancelString andActionBlock:^{}];
        }];
    }
}

@end