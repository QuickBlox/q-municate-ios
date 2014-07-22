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
@property (strong, nonatomic) QBUUser *currentUser;

@end

@implementation QMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentUser = [QMApi instance].currentUser;
    self.avatarView.imageViewType = QMImageViewTypeCircle;
    
    [self updateProfileView];
    [self setUpdateButtonActivity];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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

- (IBAction)changeAvatar:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)setUpdateButtonActivity
{
    BOOL activity = [self fieldsWereChanged];
    self.updateProfileButton.enabled = activity;
}

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)saveChanges:(id)sender {
    
    [self.view endEditing:YES];
 
    if (![self fieldsWereChanged]) {
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

- (BOOL)fieldsWereChanged
{
    if (self.avatarImage != nil) return YES;
    if (![self.fullNameField.text isEqualToString:self.currentUser.fullName]) return YES;
    if (![self.phoneNumberField.text isEqualToString:self.userPhone]) return YES;
    if (![self.statusField.text isEqualToString:self.currentUser.customData]) return YES;
    
    return NO;
}

- (NSString *)userPhone {
    return self.currentUser.phone ? self.currentUser.phone : @"";
}

- (void)updateUsersProfile {

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] updateUser:self.currentUser completion:^(BOOL success) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    [self setUpdateButtonActivity];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self setUpdateButtonActivity];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    self.avatarImage = [selectedImage imageByScalingProportionallyToMinimumSize:CGSizeMake(1000.0f, 1000.0f)];
    self.avatarView.image = self.avatarImage;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        self.avatarView.image = self.avatarImage;
        [self setUpdateButtonActivity];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    self.avatarImage = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
