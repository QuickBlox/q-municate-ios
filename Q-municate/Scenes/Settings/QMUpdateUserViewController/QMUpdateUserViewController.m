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

static const NSUInteger kQMFullNameFieldMinLength = 3;
static NSString *const kQMNotAcceptableCharacters = @"<>;";

@interface QMUpdateUserViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *textField;


@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) NSString *cachedValue;
@property (copy, nonatomic) NSString *bottomText;
@property (weak, nonatomic) BFTask *task;
@property (assign, nonatomic) BOOL shouldShowValidationError;
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
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.textField.delegate = self;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
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
            break;
            
        case QMUpdateUserFieldEmail:
            [self configureWithKeyPath:@keypath(QBUUser.new, email)
                                 title:NSLocalizedString(@"QM_STR_EMAIL", nil)
                                  text:currentUser.email
                            bottomText:NSLocalizedString(@"QM_STR_EMAIL_DESCRIPTION", nil)];
            break;
            
        case QMUpdateUserFieldStatus:
            [self configureWithKeyPath:@keypath(QBUUser.new, status)
                                 title:NSLocalizedString(@"QM_STR_STATUS", nil)
                                  text:currentUser.status
                            bottomText:NSLocalizedString(@"QM_STR_STATUS_DESCRIPTION", nil)];
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
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
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

- (IBAction)textFieldEditingChanged:(UITextField *)__unused sender {
    
    BOOL allowed = [self updateAllowed];
    self.textField.textColor = allowed ? [UIColor blackColor] : [UIColor redColor];
    self.navigationItem.rightBarButtonItem.enabled = allowed;
    allowed ? [self hideValidationError] : [self showValidationErrorWithText:@"dfsdfsdf"];
}


- (BOOL)textField:(UITextField *)__unused textField
shouldChangeCharactersInRange:(NSRange)__unused range
replacementString:(NSString *)string  {
    
    NSCharacterSet *notAcceptableCharactersSet = [NSCharacterSet characterSetWithCharactersInString:kQMNotAcceptableCharacters];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:notAcceptableCharactersSet] componentsJoinedByString:@""];
    
    if ([filtered isEqualToString:string]) {
        return YES;
    }
    else {
        [self showValidationErrorWithText:@"Symbols not allowed"];
        return NO;
    }
 }
//MARK: - Helpers
- (void)showValidationErrorWithText:(NSString *)text {
    self.shouldShowValidationError = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)hideValidationError {
    self.shouldShowValidationError = NO;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}
- (BOOL)updateAllowed {
    
    if (self.updateUserField == QMUpdateUserFieldStatus) {
        return YES;
    }
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    
    if ([self.textField.text stringByTrimmingCharactersInSet:whiteSpaceSet].length < kQMFullNameFieldMinLength) {
        
        return NO;
    }
    
    if ([self.textField.text isEqualToString:self.cachedValue]) {
        
        return NO;
    }
    
    return YES;
}

//MARK: - UITableViewDataSource

- (NSString *)tableView:(UITableView *)__unused tableView titleForFooterInSection:(NSInteger)__unused section {
    
    return self.bottomText;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        if (!self.shouldShowValidationError) {
             return 0;
        }
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

@end
