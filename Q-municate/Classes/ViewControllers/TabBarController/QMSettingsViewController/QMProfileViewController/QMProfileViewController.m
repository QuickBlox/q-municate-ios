//
//  QMProfileViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMProfileViewController.h"
#import "UIImage+Cropper.h"
#import "QMContactList.h"
#import "QMContent.h"
#import "QMAuthService.h"
#import "QMUtilities.h"
#import "REAlertView+QMSuccess.h"
#import "QMApi.h"

static NSUInteger const QM_MAX_STATUS_TEXT_LENGTH = 44;

// text field tags:
static NSUInteger const kFullNameFieldTag = 11;
static NSUInteger const kPhoneNumberFieldTag = 12;


@interface QMProfileViewController ()

<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextView *statusField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateProfileButton;

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, strong) QBUUser *me;

/** Fields caches. */
@property (nonatomic, copy) NSString *fullNameFieldCache;
@property (nonatomic, copy) NSString *phoneFieldCache;
@property (nonatomic, copy) NSString *statusFieldCache;

/** Optional cache */
//@property (nonatomic, copy) NSString *emailFieldCache;

@end


@implementation QMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureAvatarView];
    self.me = [QMContactList shared].me;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // update profile screen:
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self updateProfileView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)configureAvatarView {
}

- (void)updateProfileView
{
    // avatar:
//    [self.avatarView setImageURL:[NSURL URLWithString:me.website]];
    
    // full name:
    [self.fullNameField setText:self.me.fullName];
    
    // email:
    [self.emailField setText:self.me.email];
    
    // phone number:
    [self.phoneNumberField setText:self.me.phone];
    
    // status:
    if (self.me.customData != nil) {
        [self.statusField setText:self.me.customData];
    } else {
        [self.statusField setText:@"Add status..."];
    }
}

- (IBAction)changeAvatar:(id)sender {
    
    if (self.me.facebookID.length == 0) {
    
        [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
            alertView.title = kAlertTitleErrorString;
            alertView.message = @"You can not change avatar. Go to facebook, and change avatar there.";
            [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{}];
        }];
    }
    else {
    
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
    
}

- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)saveChanges:(id)sender
{
    // resing all responders:
    [self.fullNameField resignFirstResponder];
    [self.phoneNumberField resignFirstResponder];
    [self.statusField resignFirstResponder];

    if (![self profileWasChanged]) {
        return;
    }
    
    if (self.avatarImage) {
        
        QMContent *manager = [[QMContent alloc] init];
        [manager uploadUserImageForUser:self.me image:self.avatarImage withCompletion:^(QBCFileUploadTaskResult *result) {
            
            if (result.success) {
                [self updateUsersProfile];
            }
            else {
                [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
            }
        }];

    }
    
    [self updateUsersProfile];
}

- (BOOL)profileWasChanged
{
    BOOL profileChanged = NO;
    
    // verifying all fields:
    if (self.avatarImage != nil) {
        profileChanged = YES;
    }
    if (_fullNameFieldCache != nil && ![_fullNameFieldCache isEqualToString:self.me.fullName] ) {
        
        self.me.fullName = _fullNameFieldCache;
        profileChanged = YES;
    }
    if (_phoneFieldCache != nil && ![_phoneFieldCache isEqualToString:self.me.phone]) {
        
        self.me.phone = _phoneFieldCache;
        profileChanged = YES;
    }
    if (_statusFieldCache != nil && ![_statusFieldCache isEqualToString:self.me.customData]) {
        profileChanged = YES;
        
        if (_statusFieldCache.length > QM_MAX_STATUS_TEXT_LENGTH) {
            NSRange range = NSMakeRange(0, QM_MAX_STATUS_TEXT_LENGTH);
            NSString *statusText = [_statusFieldCache substringWithRange:range];
            self.me.customData = statusText;
        } else {
            self.me.customData = _statusFieldCache;
        }
    }
    return profileChanged;
}

- (void)updateUsersProfile
{
    // delete password before update and cache:
    NSString *password = self.me.password;
    self.me.password = nil;
    
    [[QMApi shared].authService updateUser:self.me withCompletion:^(QBUUserResult *result) {
        if (result.success) {
            
            result.user.password = password;
            self.me = result.user;
            [QMContactList shared].me = result.user;
            
            [REAlertView showAlertWithMessage:@"Profile was updated" actionSuccess:YES];
            [self updateProfileView];
        }
        else {
            [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
        }
    }];
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == kFullNameFieldTag) {
        
        // save modified full name:
        _fullNameFieldCache = textField.text;
        
    } else if (textField.tag == kPhoneNumberFieldTag) {
        
        // save mofified phone number:
        _phoneFieldCache = textField.text;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _statusFieldCache = textView.text;
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    self.avatarImage = [selectedImage imageByScalingProportionallyToMinimumSize:CGSizeMake(1000.0f, 1000.0f)];
    self.avatarView.image = self.avatarImage;
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.avatarView.image = self.avatarImage;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    self.avatarImage = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
