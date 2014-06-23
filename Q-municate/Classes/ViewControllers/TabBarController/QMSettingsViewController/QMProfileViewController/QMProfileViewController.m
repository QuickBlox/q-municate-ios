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


static NSUInteger const QM_MAX_STATUS_TEXT_LENGTH = 44;

// text field tags:
static NSUInteger const kFullNameFieldTag = 11;
static NSUInteger const kPhoneNumberFieldTag = 12;


@interface QMProfileViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet AsyncImageView *avatarView;
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
@synthesize me;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureAvatarView];
    
    me = [QMContactList shared].me;
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

- (void)configureAvatarView
{
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    self.avatarView.layer.borderWidth = 2.0f;
    self.avatarView.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.crossfadeDuration = 0.0f;
}

- (void)updateProfileView
{
    // avatar:
    [self.avatarView setImageURL:[NSURL URLWithString:me.website]];
    
    // full name:
    [self.fullNameField setText:me.fullName];
    
    // email:
    [self.emailField setText:me.email];
    
    // phone number:
    [self.phoneNumberField setText:me.phone];
    
    // status:
    if (me.customData != nil) {
        [self.statusField setText:me.customData];
    } else {
        [self.statusField setText:@"Add status..."];
    }
}

- (IBAction)changeAvatar:(id)sender
{
    if (me.facebookID != nil) {
        [[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:@"You can not change avatar. Go to facebook, and change avatar there." delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;

    [self presentViewController:picker animated:YES completion:nil];
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
    if (_avatarImage != nil) {
        [QMUtilities createIndicatorView];
        
        QMContent *manager = [[QMContent alloc] init];
        [manager uploadImage:_avatarImage withCompletion:^(QBCBlob *blob, BOOL success, NSError *error) {
            if (!success) {
                [QMUtilities removeIndicatorView];
                [[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:error.description delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
                return;
            }
            [self updateUsersProfile];
        }];
    }
    
    [self updateUsersProfile];
}

- (BOOL)profileWasChanged
{
    BOOL profileChanged = NO;
    
    // verifying all fields:
    if (_avatarImage != nil) {
        profileChanged = YES;
    }
    if (_fullNameFieldCache != nil && ![_fullNameFieldCache isEqualToString:me.fullName] ) {
        
        me.fullName = _fullNameFieldCache;
        profileChanged = YES;
    }
    if (_phoneFieldCache != nil && ![_phoneFieldCache isEqualToString:me.phone]) {
        
        me.phone = _phoneFieldCache;
        profileChanged = YES;
    }
    if (_statusFieldCache != nil && ![_statusFieldCache isEqualToString:me.customData]) {
        profileChanged = YES;
        
        if (_statusFieldCache.length > QM_MAX_STATUS_TEXT_LENGTH) {
            NSRange range = NSMakeRange(0, QM_MAX_STATUS_TEXT_LENGTH);
            NSString *statusText = [_statusFieldCache substringWithRange:range];
            me.customData = statusText;
        } else {
            me.customData = _statusFieldCache;
        }
    }
    return profileChanged;
}

- (void)updateUsersProfile
{
    // delete password before update and cache:
    NSString *password = me.password;
    me.password = nil;
    
    [[QMAuthService shared] updateUser:me withCompletion:^(QBUUser *user, BOOL success, NSError *error) {
        [QMUtilities removeIndicatorView];
        
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:error.description delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
            return;
        }
        user.password = password;
        self.me = user;
        
        // show alert:
        [[[UIAlertView alloc] initWithTitle:kAlertTitleSuccessString message:@"Profile was updated" delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
        [self updateProfileView];
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    self.avatarImage = [selectedImage imageByScalingProportionallyToMinimumSize:CGSizeMake(1000.0f, 1000.0f)];
    self.avatarView.image = self.avatarImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.avatarImage = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
