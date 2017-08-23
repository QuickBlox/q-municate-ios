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
#import "QMTimeOut.h"

static const NSUInteger kQMFullNameFieldMinLength = 3;
static const NSUInteger kQMFullNameFieldMaxLength = 50;

static NSString *const kQMNotAcceptableCharacters = @"<>;";
static NSString *const kQMEmailRegex = @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?";

@interface NSString(QMValidation)

- (BOOL)validateForNotAcceptableCharacters:(NSString *)notAcceptableCharacters
                                     error:(NSError **)error;

@end

@implementation NSString(QMValidation)

- (BOOL)validateForNotAcceptableCharacters:(NSString *)notAcceptableCharacters
                                     error:(NSError **)error {
    
    NSCharacterSet *notAcceptableCharactersSet = [NSCharacterSet characterSetWithCharactersInString:notAcceptableCharacters];
    NSString *filtered = [[self componentsSeparatedByCharactersInSet:notAcceptableCharactersSet] componentsJoinedByString:@""];
    
    if (![filtered isEqualToString:self]) {
        
        NSMutableString *result = [NSMutableString new];
        
        for (NSUInteger i = 0; i < notAcceptableCharacters.length; i++) {
            
            unichar c = [notAcceptableCharacters characterAtIndex:i];
            if (i == 0) {
                [result appendFormat:@"%C",c];
            }
            else {
                [result appendFormat:@" %C",c];
            }
        }
        
        NSString *errorDescription = [NSString stringWithFormat:@"\"%@\" symbols are not allowed", result.copy];
        *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
        
        return NO;
    }
    
    return YES;
}

@end

@interface QMUpdateUserViewController () <UITextFieldDelegate> {
    QMTimeOut *_dismissTimeOut;
}

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *validationLabel;


@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) NSString *cachedValue;
@property (copy, nonatomic) NSString *bottomText;
@property (weak, nonatomic) BFTask *task;
@property (assign, nonatomic) BOOL validationErrorIsShown;
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
    
    self.textField.delegate = self;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.validationLabel.alpha = 0.0;
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
        BOOL textIsValid = [self validateText:text error:&validationError];
        
        if (textIsValid) {
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
        BOOL textIsValid = [string validateForNotAcceptableCharacters:kQMNotAcceptableCharacters
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
    
    if (self.validationErrorIsShown) {
        if (_dismissTimeOut) {
            [_dismissTimeOut cancelTimeout];
        }
    }
    if (duration > 0) {
        _dismissTimeOut = [[QMTimeOut alloc] initWithTimeInterval:duration
                                                            queue:dispatch_get_main_queue()];
        __weak typeof(self) weakSelf = self;
        [_dismissTimeOut startWithFireBlock:^{
            [weakSelf hideValidationError];
        }];
    }
    
    self.validationLabel.text = text;
    [self setShowValidationErrorCell:YES];
}

- (void)hideValidationError {
    
    if (!self.validationErrorIsShown) {
        return;
    }
    
    if (_dismissTimeOut) {
        [_dismissTimeOut cancelTimeout];
    }
    [self setShowValidationErrorCell:NO];
}

- (void)setShowValidationErrorCell:(BOOL)show {
    
    self.validationErrorIsShown = show;
    
    UITableViewCell *validationCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    [UIView animateWithDuration:0.3 animations:^{

        self.validationLabel.alpha = show ? 1.0 : 0.0;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [validationCell layoutIfNeeded];
    }];
}


- (BOOL)validateText:(NSString *)text
               error:(NSError **)error {
    
    if (self.updateUserField == QMUpdateUserFieldFullName) {
        
        NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
        NSUInteger textLength = [text stringByTrimmingCharactersInSet:whiteSpaceSet].length;
        
        if (textLength < kQMFullNameFieldMinLength) {
            *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Minimum symbols should be 3"}];
            return NO;
        }
        if (textLength > kQMFullNameFieldMaxLength) {
            *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Maximum symbols should be 50"}];
            return NO;
        }
    }
    else if (self.updateUserField == QMUpdateUserFieldEmail) {
        
        NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
        NSUInteger textLength = [text stringByTrimmingCharactersInSet:whiteSpaceSet].length;
        if (textLength < kQMFullNameFieldMinLength) {
            *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Minimum symbols should be 3"}];
            return NO;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", kQMEmailRegex];
        if (![predicate evaluateWithObject:text]) {
            *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey: @"Email format is incorrect"}];
            return NO;
        }
    }
    
    return YES;
}

//MARK: - UITableViewDataSource

- (NSString *)tableView:(UITableView *)__unused tableView
titleForFooterInSection:(NSInteger)__unused section {
    return self.bottomText;
}

- (CGFloat)tableView:(UITableView *)__unused tableView
heightForRowAtIndexPath:(NSIndexPath *)__unused indexPath {
    if (indexPath.row == 1) {
        return self.validationErrorIsShown ? 30.0 : 0;
    }
    
    return 44.0;
}


@end
