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
#import "QMShadowView.h"
#import "QMTasks.h"
#import "QMNavigationController.h"
#import "NSString+QMValidation.h"
#import "QMValidationCell.h"

static const NSUInteger kQMFullNameFieldMinLength = 3;
static const NSUInteger kQMFullNameFieldMaxLength = 50;
static const NSUInteger kQMCellMinHeight = 44;

static NSString *const kQMNotAcceptableCharacters = @"<>;";

@interface QMUpdateUserViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) NSString *cachedValue;
@property (copy, nonatomic) NSString *bottomText;
@property (weak, nonatomic) BFTask *task;

@property (copy, nonatomic) NSString *validationErrorText;

@end

@implementation QMUpdateUserViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    
    // removing left bar button item that is responsible for split view
    // display mode managing. Not removing it will cause item update
    // for deallocated navigation item
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidLoad {
    
    NSAssert(_updateUserField != QMUpdateUserFieldNone, @"Must be a valid update field.");
    [super viewDidLoad];
    
    // automatic self-sizing cells
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kQMCellMinHeight;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.textField.delegate = self;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [QMValidationCell registerForReuseInTableView:self.tableView];
    // configure appearance
    [self configureAppearance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (void)configureAppearance {
    
    QBUUser *currentUser = QMCore.instance.currentProfile.userData;
    
    switch (self.updateUserField) {
            
        case QMUpdateUserFieldFullName:
            [self configureWithKeyPath:@keypath(QBUUser.new, fullName)
                                 title:NSLocalizedString(@"QM_STR_FULLNAME", nil)
                                  text:currentUser.fullName
                            bottomText:nil];
            
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            break;
            
        case QMUpdateUserFieldEmail:
            [self configureWithKeyPath:@keypath(QBUUser.new, email)
                                 title:NSLocalizedString(@"QM_STR_EMAIL", nil)
                                  text:currentUser.email
                            bottomText:NSLocalizedString(@"QM_STR_EMAIL_DESCRIPTION", nil)];
            self.textField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
            
        case QMUpdateUserFieldStatus:
            [self configureWithKeyPath:@keypath(QBUUser.new, status)
                                 title:NSLocalizedString(@"QM_STR_STATUS", nil)
                                  text:currentUser.status
                            bottomText:NSLocalizedString(@"QM_STR_STATUS_DESCRIPTION", nil)];
            self.textField.keyboardType = UIKeyboardTypeAlphabet;
            break;
            
        case QMUpdateUserFieldNone:
            break;
    }
}

- (void)configureWithKeyPath:(NSString *)keyPath
                       title:(NSString *)title
                        text:(NSString *)text
                  bottomText:(NSString *)bottomText {
    
    self.keyPath = keyPath;
    self.title =
    self.textField.placeholder = title;
    self.cachedValue =
    self.textField.text = text;
    self.bottomText = bottomText;
}

//MARK: - Actions

- (IBAction)saveButtonPressed:(UIBarButtonItem *)__unused sender {
    
    if (self.task != nil) {
        // task is in progress
        return;
    }
    
    QBUpdateUserParameters *updateUserParams = [QBUpdateUserParameters new];
    updateUserParams.customData = QMCore.instance.currentProfile.userData.customData;
    [updateUserParams setValue:self.textField.text forKeyPath:self.keyPath];
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                                                          message:NSLocalizedString(@"QM_STR_LOADING", nil)
                                                                         duration:0];
    
    __weak QMNavigationController *navigationController = (QMNavigationController *)self.navigationController;
    
    @weakify(self);
    [[QMTasks taskUpdateCurrentUser:updateUserParams] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
        
        @strongify(self);
        [navigationController dismissNotificationPanel];
        
        if (!task.isFaulted) {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return nil;
    }];
}

- (IBAction)textFieldEditingChanged:(UITextField *)sender {
    
    NSString *text = sender.text;
    
    if ([text isEqualToString:self.cachedValue]) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self hideValidationError];
    }
    else {
        
        NSError *validationError = nil;
        BOOL textIsValid = [self validateText:text
                                        error:&validationError];
        
        if (!textIsValid) {
            [self showValidationErrorWithText:validationError.localizedDescription
                                     duration:0];
        }
        else {
            [self hideValidationError];
        }
        
        self.navigationItem.rightBarButtonItem.enabled = textIsValid;
    }
}

//MARK: - UITextFieldDelegate

- (BOOL)textField:(UITextField *)__unused textField
shouldChangeCharactersInRange:(NSRange)__unused range
replacementString:(NSString *)string  {
    
    if (self.updateUserField == QMUpdateUserFieldFullName) {
        NSError *validationError = nil;
        BOOL textIsValid = [string qm_validateForNotAcceptableCharacters:kQMNotAcceptableCharacters
                                                                   error:&validationError];
        if (!textIsValid) {
            [self showValidationErrorWithText:validationError.localizedDescription
                                     duration:1.5];
            return NO;
        }
    }
    
    return YES;
}

//MARK: - Helpers

- (void)showValidationErrorWithText:(NSString *)text
                           duration:(NSTimeInterval)duration {
    
    self.validationErrorText = text;
    
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    BOOL alreadyExpanded = [self numberOfExpandedRowsForSection:0] > 0;
    
    if (alreadyExpanded) {
        [self reloadExpandedCellForIndexPath:cellIndexPath
                                    duration:duration
                            withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        [self expandCellForIndexPath:cellIndexPath
                            duration:duration
                    withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)hideValidationError {
    
    [self hideCellForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.validationErrorText = nil;
}

- (BOOL)validateText:(NSString *)text
               error:(NSError **)error {
    
    if (self.updateUserField == QMUpdateUserFieldFullName) {
        
        return [text qm_validateForCharactersCountWithMinLength:kQMFullNameFieldMinLength
                                                      maxLength:kQMFullNameFieldMaxLength
                                                          error:error];
    }
    else if (self.updateUserField == QMUpdateUserFieldEmail) {
        
        return [text qm_validateForEmailFormat:error];
    }
    
    return YES;
}

//MARK: - UITableViewDataSource

- (NSString *)tableView:(UITableView *)__unused tableView
titleForFooterInSection:(NSInteger)__unused section {
    return self.bottomText;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isExpandedCell:indexPath]) {
        
        QMValidationCell *cell = [tableView dequeueReusableCellWithIdentifier:[QMValidationCell cellIdentifier]
                                                                 forIndexPath:indexPath];
        [cell setValidationErrorText:self.validationErrorText];
        return cell;
    }
    else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger numberOfRows =
    [super tableView:tableView numberOfRowsInSection:section] + [self numberOfExpandedRowsForSection:section];
    
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)__unused tableView
heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    return UITableViewAutomaticDimension;
}


@end
