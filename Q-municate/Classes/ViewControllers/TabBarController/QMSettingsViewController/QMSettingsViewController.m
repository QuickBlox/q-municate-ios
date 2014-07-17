//
//  QMSettingsViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 06/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSettingsViewController.h"
//#import "QMChatService.h"
//#import "QMUsersService.h"
//#import "QMAuthService.h"
#import "REAlertView+QMSuccess.h"
//#import "QMSettingsManager.h"
//#import "QMFacebookService.h"
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

- (void)logOut {
    
    [[QMApi instance] logout];
    @weakify(self)
    [[QMApi instance] destroySessionWithCompletion:^(BOOL success) {
        @strongify(self)
        if (success) {
            [self performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
        }
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.logoutCell) {
        @weakify(self)
        [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
            @strongify(self)
            alertView.message = kAlertTitleAreYouSureString;
            [alertView addButtonWithTitle:kAlertButtonTitleLogOutString andActionBlock:^{
                [self logOut];
            }];
            
            [alertView addButtonWithTitle:kAlertButtonTitleCancelString andActionBlock:^{}];
        }];
    }
}

@end