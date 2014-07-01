//
//  QMSettingsViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 06/03/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSettingsViewController.h"
#import "QMChatService.h"
#import "QMContactList.h"
#import "QMAuthService.h"
#import "REAlertView+QMSuccess.h"
#import "QMSettingsManager.h"
#import "QMFacebookService.h"
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
    
    [[QMApi shared].authService destroySessionWithCompletion:^(QBAAuthResult *result) {
        
        if (result.success) {
            
            QMFacebookService *fbService = [[QMFacebookService alloc] init];
            QMSettingsManager *settingsManager = [[QMSettingsManager alloc] init];
            
            [settingsManager clearSettings];
            [[QMChatService shared] logOut];
            [[QMContactList shared] clearData];
            [fbService logout];
            
            [self performSegueWithIdentifier:kSplashSegueIdentifier sender:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kInviteFriendsDataSourceShouldRefreshNotification object:nil];
        }
    }];
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
                [weakSelf logOut];
            }];
            
            [alertView addButtonWithTitle:kAlertButtonTitleCancelString andActionBlock:^{}];
        }];
    }
}

@end