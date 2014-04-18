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
#import "QMUtilities.h"
#import "QMSettingsDataSource.h"


typedef NS_ENUM(NSUInteger, QMPasswordCheckState) {
    QMPasswordCheckStateNone,
    QMPasswordCheckStateInputed,
    QMPasswordCheckStateConfirmed
};

@interface QMSettingsViewController () <UIActionSheetDelegate, UIAlertViewDelegate>{

    QMPasswordCheckState passwordCheckState;
    NSString *oldPassword;
    NSString *newPassword;
}
@property (weak, nonatomic) IBOutlet UITableViewCell *changePasswordCell;
@property (nonatomic, strong) QMSettingsDataSource *dataSource;
@property (nonatomic, strong) UISwitch *notificationsSwitch;
@end

@implementation QMSettingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [QMSettingsDataSource new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([FBSession activeSession].state == FBSessionStateOpen) {
        self.cellViewMode = SettingsViewControllerModeCustom;
    } else {
        self.cellViewMode = SettingsViewControllerModeNormal;
    }
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logOut
{
    [[FBSession activeSession] closeAndClearTokenInformation];          // close fb session
    [[QMChatService shared] logOut];                                      // close chat
    [[QMContactList shared] clearData];                                   // clear all information about me and my data
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kDidLogout];
    [[NSUserDefaults standardUserDefaults] setObject:kEmptyString forKey:kUserStatusText];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[QMAuthService shared] destroySessionWithCompletion:^(BOOL success) {
        if (success) {
            self.tabBarController.selectedIndex = 0;
            [self.tabBarController performSegueWithIdentifier:kWelcomeScreenSegueIdentifier sender:nil];
        }
    }];
}

- (void)changePassword
{
    // first stage:
    [self showAlertWithTitle:kAlertTitleEnterPasswordString message:nil];
}


#pragma mark - UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == QMSettingsNormalCellRowProfile) {
        [self performSegueWithIdentifier:kProfileSegueIdentifier sender:self];
    } else {
        if (self.cellViewMode == SettingsViewControllerModeNormal) {
            [self serveNormalModeCellsForRow:indexPath.row];
        } else {
            [self serveCustomModeCellsForRow:indexPath.row];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource countForDataSourceWithMode:self.cellViewMode];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSettingsVCCellIdentifier];
    if (!cell) {
        cell = [self configureCellForIndexPath:indexPath];
    }

    return cell;
}

#pragma mark - work with cell

- (void)serveNormalModeCellsForRow:(NSInteger)row
{
	if (row == QMSettingsNormalCellRowChangePassword) {
		[self changePassword];
	} else if (row == QMSettingsNormalCellRowLogOut) {
		[self showLogoutActionSheet];
	}
}

- (void)serveCustomModeCellsForRow:(NSInteger)row
{
	if (row == QMSettingsCustomCellRowLogOut) {
		[self showLogoutActionSheet];
	}
}

- (UITableViewCell *)configureCellForIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [UITableViewCell new];
	if (indexPath.row == QMSettingsNormalCellRowProfile) {
		cell.textLabel.text = kSettingsCellTitleProfile;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else if (indexPath.row == QMSettingsNormalCellRowPushNotifications) {
		cell.textLabel.text = kSettingsCellTitlePushNotifications;
		self.notificationsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(256, 9, 0, 0)];
		[self.notificationsSwitch addTarget:self action:@selector(triggerNotificationsState) forControlEvents:UIControlEventValueChanged];
		[cell.contentView addSubview:self.notificationsSwitch];
	} else {
		if (self.cellViewMode == SettingsViewControllerModeNormal) {
			cell = [self configureNormalModeCell:cell withIndexPath:indexPath];
		} else {
			cell = [self configureCustomModeCell:cell withIndexPath:indexPath];
		}
	}

	return cell;
}

- (UITableViewCell *)configureVersionCell:(UITableViewCell *)cell
{
	cell.textLabel.text = kSettingsCellTitleVersion;
	cell.textLabel.textColor = [UIColor grayColor];
	cell.userInteractionEnabled = NO;

	return cell;
}

- (UITableViewCell *)configureNormalModeCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == QMSettingsNormalCellRowChangePassword) {
		cell.textLabel.text = kSettingsCellTitleChangePassword;
	} else if (indexPath.row == QMSettingsNormalCellRowLogOut) {
		cell.textLabel.text = kAlertButtonTitleLogOutString;
	} else if (indexPath.row == QMSettingsNormalCellRowVersion) {
		cell = [self configureVersionCell:cell];
	}

	return cell;
}

- (UITableViewCell *)configureCustomModeCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == QMSettingsCustomCellRowLogOut) {
		cell.textLabel.text = kAlertButtonTitleLogOutString;
	} else if (indexPath.row == QMSettingsCustomCellRowVersion) {
		cell = [self configureVersionCell:cell];
	}

	return cell;
}

#pragma mark - Switching Notifications
- (void)triggerNotificationsState
{
    if (self.notificationsSwitch.on) {
        [[QMAuthService shared] subscribeToPushNotifications];
    } else {
        [[QMAuthService shared] unSubscribeFromPushNotifications];
    }
}

- (void)showLogoutActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:kAlertTitleAreYouSureString
                                                             delegate:self
                                                    cancelButtonTitle:kAlertButtonTitleCancelString
                                               destructiveButtonTitle:kAlertButtonTitleLogOutString
                                                    otherButtonTitles:nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self logOut];
    }
}


#pragma mark - Alert

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)messageString
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:messageString delegate:self cancelButtonTitle:kAlertButtonTitleCancelString otherButtonTitles:kAlertButtonTitleOkString, nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alert show];
}

- (void)showErrorAlertWithMessage:(NSString *)alertMessage
{
    [[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:alertMessage delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
}

// delegate:
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *password = [alertView textFieldAtIndex:0].text;
    if (buttonIndex == 0) {
        [self clearPasswordFields];
        passwordCheckState = QMPasswordCheckStateNone;
        return;
    }
    if (passwordCheckState == QMPasswordCheckStateNone) {
        NSString *oldPasswordString = [[NSUserDefaults standardUserDefaults] objectForKey:kPassword];
		if ([oldPasswordString isEqualToString:password]) {
			oldPassword = password;
			passwordCheckState = QMPasswordCheckStateInputed;
			[self showAlertWithTitle:kAlertTitleEnterNewPasswordString message:nil];
		} else {
			[self showErrorAlertWithMessage:kAlertBodyWrongPasswordString];
		}
        
    } else if (passwordCheckState == QMPasswordCheckStateInputed) {
        newPassword = password;
        passwordCheckState = QMPasswordCheckStateConfirmed;
        [self showAlertWithTitle:kAlertTitleConfirmNewPasswordString message:nil];
    } else if (passwordCheckState == QMPasswordCheckStateConfirmed) {
        passwordCheckState = QMPasswordCheckStateNone;
        // all check
        if (![oldPassword isEqualToString:[QMContactList shared].me.password]) {
            [self showErrorAlertWithMessage:kAlertBodyWrongPasswordString];
        } else if (![password isEqualToString:newPassword]) {
            [self showErrorAlertWithMessage:kAlertBodyPasswDoesNotMatchString];
        } else if (password.length <=7 || newPassword.length <= 7) {
            [self showErrorAlertWithMessage:kAlertBodyPasswordIsShortString];
        } else {
            [QMUtilities createIndicatorView];
            // update user's password:
            QBUUser *me = [QMContactList shared].me;
            NSString *passwordToChange = me.password;
            me.password = password;
            me.oldPassword = passwordToChange;
            [[QMAuthService shared] updateUser:me withCompletion:^(QBUUser *user, BOOL success, NSError *error) {
                if (success) {
                    // save user password locally:
                    user.password = password;
                    [[QMContactList shared] setMe:user];
                    
                    [QMUtilities removeIndicatorView];
                    [[[UIAlertView alloc] initWithTitle:kAlertTitleSuccessString message:kAlertBodyPasswordChangedString delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
                }
            }];
        }
        [self clearPasswordFields];
    }
}

- (void)clearPasswordFields
{
    oldPassword = nil;
    newPassword = nil;
}

@end
