//
//  QMUpdateUserViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/6/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMUpdateUserViewController.h"
#import "QMCore.h"
#import "QMProfile.h"
#import "QMColors.h"
#import "QMShadowView.h"
#import "QMTasks.h"
#import "QMNotification.h"

@interface QMUpdateUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *infoField;

@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) NSString *cachedValue;
@property (weak, nonatomic) BFTask *task;

@end

@implementation QMUpdateUserViewController

- (void)viewDidLoad {
    NSAssert(_updateUserField != QMUpdateUserFieldNone, @"Must be a valid update field.");
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // Set tableview background color
    self.tableView.backgroundColor = QMTableViewBackgroundColor();
    
    // configure appearance
    [self configureAppearance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (void)configureAppearance {
    
    QBUUser *currentUser = [QMCore instance].currentProfile.userData;
    
    switch (self.updateUserField) {
            
        case QMUpdateUserFieldFullName:
            self.keyPath = @keypath(QBUUser.new, fullName);
            self.title =
            self.textField.placeholder = NSLocalizedString(@"QM_STR_FULLNAME", nil);
            self.cachedValue =
            self.textField.text = currentUser.fullName;
            self.infoField.text = NSLocalizedString(@"QM_STR_FULLNAME_DESCRIPTION", nil);
            break;
            
        case QMUpdateUserFieldEmail:
            self.keyPath = @keypath(QBUUser.new, email);
            self.title =
            self.textField.placeholder = NSLocalizedString(@"QM_STR_EMAIL", nil);
            self.cachedValue =
            self.textField.text = currentUser.email;
            self.infoField.text = NSLocalizedString(@"QM_STR_EMAIL_DESCRIPTION", nil);
            break;
            
        case QMUpdateUserFieldStatus:
            self.keyPath = @keypath(QBUUser.new, status);
            self.title =
            self.textField.placeholder = NSLocalizedString(@"QM_STR_STATUS", nil);
            self.cachedValue =
            self.textField.text = currentUser.status;
            self.infoField.text = NSLocalizedString(@"QM_STR_STATUS_DESCRIPTION", nil);
            break;
            
        case QMUpdateUserFieldNone:
            break;
    }
}

#pragma mark - Actions

- (IBAction)saveButtonPressed:(UIBarButtonItem *)__unused sender {
    
    if (self.task != nil) {
        // task is in progress
        return;
    }
    
    QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
    [updateUserParams setValue:self.textField.text forKeyPath:self.keyPath];
    
    [QMNotification showNotificationPanelWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) timeUntilDismiss:0];
    
    @weakify(self);
    [[QMTasks taskUpdateCurrentUser:updateUserParams] continueWithSuccessBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull __unused task) {
        
        @strongify(self);
        [QMNotification dismissNotificationPanel];
        [self.navigationController popViewControllerAnimated:YES];
        
        return nil;
    }];
}

- (IBAction)textFieldEditingChanged:(UITextField *)sender {
    
    self.navigationItem.rightBarButtonItem.enabled = ![sender.text isEqualToString:self.cachedValue];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    QMShadowView *topShadow = [[QMShadowView alloc]
                               initWithFrame:CGRectMake(0,
                                                        0,
                                                        CGRectGetWidth(cell.frame),
                                                        kQMShadowViewHeight)];
    QMShadowView *bottomShadow = [[QMShadowView alloc]
                                  initWithFrame:CGRectMake(0,
                                                           CGRectGetHeight(cell.frame) - kQMShadowViewHeight,
                                                           CGRectGetWidth(cell.frame),
                                                           kQMShadowViewHeight)];
    
    [cell.contentView addSubview:topShadow];
    [cell.contentView addSubview:bottomShadow];
    
    return cell;
}

@end
