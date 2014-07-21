//
//  QMProfileViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMProfileViewController.h"
#import "UIImage+Cropper.h"
#import "QMApi.h"
#import "REAlertView+QMSuccess.h"
#import "QMImageView.h"
#import "QMContent.h"
#import "SVProgressHUD.h"

@interface QMProfileViewController ()

<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet QMImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextView *statusField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateProfileButton;

@property (nonatomic, strong) UIImage *avatarImage;

@property (nonatomic, copy) NSString *fullNameFieldCache;
@property (nonatomic, copy) NSString *phoneFieldCache;
@property (nonatomic, copy) NSString *statusFieldCache;

@property (strong, nonatomic) QBUUser *currentUser;

@end

@implementation QMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentUser = [QMApi instance].currentUser;
    self.avatarView.imageViewType = QMImageViewTypeCircle;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateProfileView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateProfileView {
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    NSURL *url = [NSURL URLWithString:self.currentUser.website];
    [self.avatarView sd_setImageWithURL:url placeholderImage:placeholder];
    
    self.fullNameField.text = self.currentUser.fullName;
    self.emailField.text = self.currentUser.email;
    self.phoneNumberField.text = self.currentUser.phone;

    self.statusField.text = self.currentUser.customData ? self.currentUser.customData : @"Add status";
}

- (IBAction)changeAvatar:(id)sender {
    
//    if (self.currentUser.facebookID.length > 0) {
//    
//        [REAlertView presentAlertViewWithConfiguration:^(REAlertView *alertView) {
//            alertView.title = kAlertTitleErrorString;
//            alertView.message = @"You can not change avatar. Go to facebook, and change avatar there.";
//            [alertView addButtonWithTitle:kAlertButtonTitleOkString andActionBlock:^{}];
//        }];
//    }
//    else {
    
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
//    }
}

- (void)setUpdateButtonActivity:(BOOL)isActive
{
    self.updateProfileButton.enabled = isActive;
}

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)saveChanges:(id)sender {
    
    [self.view endEditing:YES];
 
    if (![self profileWasChanged]) {
        return;
    }
    
    if (self.avatarImage) {
        
        QMContent *manager = [[QMContent alloc] init];
        [manager uploadUserImageForUser:self.currentUser image:self.avatarImage withCompletion:^(QBCFileUploadTaskResult *result) {
            
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

- (BOOL)profileWasChanged {
    
    BOOL profileChanged = NO;
    
    // verifying all fields:
    if (self.avatarImage != nil) {
        profileChanged = YES;
    }
    
    if (![self.fullNameFieldCache isEqualToString:self.currentUser.fullName] ) {
        
        self.currentUser.fullName = self.fullNameFieldCache;
        profileChanged = YES;
    }
    if (![_phoneFieldCache isEqualToString:self.currentUser.phone]) {
        
        self.currentUser.phone = _phoneFieldCache;
        profileChanged = YES;
    }
    if (![_statusFieldCache isEqualToString:self.currentUser.customData]) {
        
        profileChanged = YES;
        
        if (_statusFieldCache.length > 100) {
            NSRange range = NSMakeRange(0, 100);
            NSString *statusText = [_statusFieldCache substringWithRange:range];
            self.currentUser.customData = statusText;
        } else {
            self.currentUser.customData = self.statusFieldCache;
        }
    }
    return profileChanged;
}

- (void)updateUsersProfile {

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] updateUser:self.currentUser completion:^(BOOL success) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.fullNameField) {
        self.fullNameFieldCache = textField.text;
    } else if (textField == self.phoneNumberField) {
        self.phoneFieldCache = textField.text;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.statusFieldCache = textView.text;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    self.avatarImage = [selectedImage imageByScalingProportionallyToMinimumSize:CGSizeMake(1000.0f, 1000.0f)];
    self.avatarView.image = self.avatarImage;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        self.avatarView.image = self.avatarImage;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    self.avatarImage = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
