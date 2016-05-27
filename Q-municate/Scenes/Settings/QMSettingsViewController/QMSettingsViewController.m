//
//  QMSettingsViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/4/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMSettingsViewController.h"
#import "QMTableSectionHeaderView.h"
#import "QMColors.h"
#import "QMUpdateUserViewController.h"
#import "QMImagePicker.h"
#import "QMTasks.h"
#import "QMCore.h"
#import "QMProfile.h"
#import <QMImageView.h>
#import "UINavigationController+QMNotification.h"

static const CGFloat kQMDefaultSectionHeaderHeight = 24.0f;
static const CGFloat kQMStatusSectionHeaderHeight = 40.0f;

typedef NS_ENUM(NSUInteger, QMSettingsSection) {
    
    QMSettingsSectionFullName,
    QMSettingsSectionStatus,
    QMSettingsSectionPhone,
    QMSettingsSectionEmailAccountInfo,
    QMSettingsSectionExtra,
    QMSettingsSectionSocial,
    QMSettingsSectionLogout
};

typedef NS_ENUM(NSUInteger, QMEmailAccountInfoSection) {
    
    QMEmailAccountInfoSectionEmail,
    QMEmailAccountInfoSectionPassword
};

typedef NS_ENUM(NSUInteger, QMSocialSection) {
    
    QMSocialSectionTellFriend,
    QMSocialSectionGiveFeedback
};

@interface QMSettingsViewController ()

<
QMProfileDelegate,
QMImageViewDelegate,
QMImagePickerResultHandler
>

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *pushNotificationSwitch;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) BFTask *subscribeTask;
@property (weak, nonatomic) BFTask *logoutTask;

@property (strong, nonatomic) NSMutableIndexSet *hiddenSections;

@end

@implementation QMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hiddenSections = [NSMutableIndexSet indexSet];
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    
    // Hide empty separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Set tableview background color
    self.tableView.backgroundColor = QMTableViewBackgroundColor();
    
    // configure user data
    [self configureUserData:[QMCore instance].currentProfile.userData];
    self.pushNotificationSwitch.on = [QMCore instance].currentProfile.pushNotificationsEnabled;
    
    // determine account type
    if ([QMCore instance].currentProfile.accountType != QMAccountTypeEmail) {
        
        [self.hiddenSections addIndex:QMSettingsSectionEmailAccountInfo];
    }
    
    // subscribe to delegates
    [QMCore instance].currentProfile.delegate = self;
    self.avatarImageView.delegate = self;
}

- (void)configureUserData:(QBUUser *)userData {
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:userData.avatarUrl]
                              placeholder:[UIImage imageNamed:@"upic_avatarholder"]
                                  options:SDWebImageHighPriority
                                 progress:nil
                           completedBlock:nil];
    
    self.fullNameLabel.text = userData.fullName;
    
    if (userData.phone.length > 0) {
        
        self.phoneLabel.text = userData.phone;
    }
    else {
        
        [self.hiddenSections addIndex:QMSettingsSectionPhone];
    }
    
    self.emailLabel.text = userData.email.length > 0 ? userData.email : NSLocalizedString(@"QM_STR_NONE", nil);
    
    self.statusLabel.text = userData.status.length > 0 ? userData.status : NSLocalizedString(@"QM_STR_NONE", nil);
}

#pragma mark - Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueUpdateUser]) {
        
        QMUpdateUserViewController *updateUserVC = segue.destinationViewController;
        updateUserVC.updateUserField = [sender unsignedIntegerValue];
    }
}

- (IBAction)pushNotificationSwitchPressed:(UISwitch *)sender {
    
    if (self.subscribeTask) {
        // task is in progress
        return;
    }
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    BFContinuationBlock completionBlock = ^id _Nullable(BFTask * _Nonnull __unused task) {
        
        [navigationController dismissNotificationPanel];
        
        return nil;
    };
    
    if (sender.isOn) {
        
        self.subscribeTask = [[[QMCore instance].pushNotificationManager subscribeForPushNotifications] continueWithBlock:completionBlock];
    }
    else {
        
        self.subscribeTask = [[[QMCore instance].pushNotificationManager unSubscribeFromPushNotifications] continueWithBlock:completionBlock];
    }
}

- (void)logout {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:NSLocalizedString(@"QM_STR_LOGOUT_CONFIRMATION", nil)
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                      }]];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_LOGOUT", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          @strongify(self);
                                                          if (self.logoutTask) {
                                                              // task is in progress
                                                              return;
                                                          }
                                                          
                                                          [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
                                                          
                                                          self.logoutTask = [[[QMCore instance] logout] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused logoutTask) {
                                                              
                                                              [navigationController dismissNotificationPanel];
                                                              [self performSegueWithIdentifier:kQMSceneSegueAuth sender:nil];
                                                              return nil;
                                                          }];
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.hiddenSections containsIndex:section]) {
        
        return 0;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
            
        case QMSettingsSectionFullName:
            [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldFullName)];
            break;
            
        case QMSettingsSectionStatus:
            [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldStatus)];
            break;
            
        case QMSettingsSectionPhone:
            break;
            
        case QMSettingsSectionEmailAccountInfo:
            
            switch (indexPath.row) {
                    
                case QMEmailAccountInfoSectionEmail:
                    [self performSegueWithIdentifier:kQMSceneSegueUpdateUser sender:@(QMUpdateUserFieldEmail)];
                    break;
                    
                case QMEmailAccountInfoSectionPassword:
                    [self performSegueWithIdentifier:kQMSceneSeguePassword sender:nil];
                    break;
            }
            
            break;
            
        case QMSettingsSectionExtra:
            break;
            
        case QMSettingsSectionSocial:
            
            switch (indexPath.row) {
                    
                case QMSocialSectionTellFriend: {
                    
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    [self showShareControllerInCell:cell];
                    break;
                }
                    
                case QMSocialSectionGiveFeedback:
                    [self performSegueWithIdentifier:kQMSceneSegueFeedback sender:nil];
                    break;
            }
            
            break;
            
        case QMSettingsSectionLogout:
            
            [self logout];
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == QMSettingsSectionStatus) {
        
        QMTableSectionHeaderView *headerView = [[QMTableSectionHeaderView alloc]
                                                initWithFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(tableView.frame),
                                                                         kQMStatusSectionHeaderHeight)];
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        headerView.title = [NSLocalizedString(@"QM_STR_STATUS", nil) uppercaseString];;
        
        return headerView;
    }
    
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForHeaderInSection:(NSInteger)section {
    
    if (![self shouldHaveHeaderForSection:section]) {
        
        return CGFLOAT_MIN;
    }
    
    if (section == QMSettingsSectionStatus) {
        
        return kQMStatusSectionHeaderHeight;
    }
    
    return kQMDefaultSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)__unused tableView heightForFooterInSection:(NSInteger)__unused section {
    
    return CGFLOAT_MIN;
}

#pragma mark - QMProfileDelegate

- (void)profile:(QMProfile *)__unused currentProfile didUpdateUserData:(QBUUser *)userData {
    
    [self configureUserData:userData];
}

#pragma mark - QMImageViewDelegate

- (void)imageViewDidTap:(QMImageView *)imageView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker takePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_FROM_LIBRARY", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker choosePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = imageView;
        alertController.popoverPresentationController.sourceRect = imageView.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    [[QMTasks taskUpdateCurrentUserImage:photo progress:nil] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        @strongify(self);
        
        [navigationController dismissNotificationPanel];
        
        if (!task.isFaulted) {
            
            [self.avatarImageView setImage:photo withKey:task.result.avatarUrl];
        }
        
        return nil;
    }];
}

#pragma mark - Share View Controller

- (void)showShareControllerInCell:(UITableViewCell *)cell {
    
    NSArray *items = @[NSLocalizedString(@"QM_STR_SHARE_TEXT", nil)];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAirDrop, UIActivityTypeCopyToPasteboard];
    
    if (activityViewController.popoverPresentationController) {
        // iPad support
        activityViewController.popoverPresentationController.sourceView = cell;
        activityViewController.popoverPresentationController.sourceRect = cell.bounds;
    }
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - Helper

- (BOOL)shouldHaveHeaderForSection:(NSInteger)section {
    
    if (section == QMSettingsSectionFullName) {
        
        return NO;
    }
    
    if (section == QMSettingsSectionPhone
        && [self.hiddenSections containsIndex:QMSettingsSectionPhone]) {
        
        return NO;
    }
    
    if (section == QMSettingsSectionEmailAccountInfo
        && [self.hiddenSections containsIndex:QMSettingsSectionEmailAccountInfo]) {
        
        return NO;
    }
    
    return YES;
}

@end
