//
//  QMChangePasswordViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 5/20/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMChangePasswordViewController.h"
#import "UINavigationController+QMNotification.h"
#import "QMCore.h"
#import "QMTasks.h"

static const NSUInteger kQMPasswordMinChar = 8;

@interface QMChangePasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordOldField;
@property (weak, nonatomic) IBOutlet UITextField *passwordNewField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmField;

@end

@implementation QMChangePasswordViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // subscribing for delegate
    self.passwordOldField.delegate = self;
    self.passwordNewField.delegate = self;
    self.passwordConfirmField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.passwordOldField becomeFirstResponder];
}

#pragma mark - Actions

- (IBAction)changeButtonPressed:(UIBarButtonItem *)__unused sender {
    
    if (![self.passwordOldField.text isEqualToString:[QMCore instance].currentProfile.userData.password]) {
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_WRONG_OLD_PASSWORD", nil) duration:kQMDefaultNotificationDismissTime];
        
        return;
    }
    
    if (![self.passwordNewField.text isEqualToString:self.passwordConfirmField.text]) {
        
        [self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_PASSWORD_DONT_MATCH", nil) duration:kQMDefaultNotificationDismissTime];
        
        return;
    }
    
    QBUpdateUserParameters *params = [QBUpdateUserParameters new];
    params.oldPassword = self.passwordOldField.text;
    params.password = self.passwordNewField.text;
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    [[QMTasks taskUpdateCurrentUser:params] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        @strongify(self);
        [navigationController dismissNotificationPanel];
        
        if (!task.isFaulted) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return nil;
    }];
}

#pragma mark - Helpers

- (IBAction)passwordOldFieldChanged {
    
    [self updateChangeButtonState];
}

- (IBAction)passwordNewFieldChanged {
    
    [self updateChangeButtonState];
}

- (IBAction)passwordConfirmFieldChanged {
    
    [self updateChangeButtonState];
}

- (void)updateChangeButtonState {
    
    if (self.passwordOldField.text.length < kQMPasswordMinChar
        || self.passwordNewField.text.length < kQMPasswordMinChar
        || self.passwordConfirmField.text.length < kQMPasswordMinChar) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.passwordOldField) {
        
        [self.passwordNewField becomeFirstResponder];
    }
    else if (textField == self.passwordNewField) {
        
        [self.passwordConfirmField becomeFirstResponder];
    }
    else if (self.navigationItem.rightBarButtonItem.enabled) {
        
        [self changeButtonPressed:nil];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)__unused textField {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)__unused textField {
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)__unused tableView titleForFooterInSection:(NSInteger)__unused section {
    
    return NSLocalizedString(@"QM_STR_PASSWORD_DESCRIPTION", nil);
}

@end
