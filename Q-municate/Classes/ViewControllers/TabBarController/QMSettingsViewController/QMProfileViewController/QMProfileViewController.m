//
//  QMProfileViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMProfileViewController.h"
#import "QMPlaceholderTextView.h"
#import "QMApi.h"
#import "REAlertView+QMSuccess.h"
#import "QMImageView.h"
#import "SVProgressHUD.h"
#import "QMContentService.h"

@interface QMProfileViewController ()

<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet QMImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet QMPlaceholderTextView *statusField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateProfileButton;

@property (strong, nonatomic) NSString *fullNameFieldCache;
@property (copy, nonatomic) NSString *phoneFieldCache;
@property (copy, nonatomic) NSString *statusTextCache;


@property (nonatomic, strong) UIImage *avatarImage;
@property (strong, nonatomic) QBUUser *currentUser;

@end

@implementation QMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.avatarView.imageViewType = QMImageViewTypeCircle;
    self.statusField.placeHolder = @"Add status...";
    
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

    self.
    self.currentUser = [QMApi instance].currentUser;
    
    self.fullNameFieldCache = self.currentUser.fullName;
    self.phoneFieldCache = self.currentUser.phone;
    self.statusTextCache = self.currentUser.customData;
    
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    NSURL *url = [NSURL URLWithString:self.currentUser.website];
    [self.avatarView sd_setImageWithURL:url placeholderImage:placeholder];
    
    self.fullNameField.text = self.currentUser.fullName;
    self.emailField.text = self.currentUser.email;
    self.phoneNumberField.text = self.currentUser.phone;
    self.statusField.text = self.currentUser.customData;
}

- (IBAction)changeAvatar:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)setUpdateButtonActivity {
    
    BOOL activity = [self fieldsWereChanged];
    self.updateProfileButton.enabled = activity;
}

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)saveChanges:(id)sender {
    
    [self.view endEditing:YES];
    
    __weak __typeof(self)weakSelf = self;
    
    QBUUser *user = weakSelf.currentUser;
    user.fullName = weakSelf.fullNameFieldCache;
    user.phone = weakSelf.phoneFieldCache;
    user.customData = weakSelf.statusTextCache;
    
    [SVProgressHUD showProgress:0.f status:@""];
    [[QMApi instance] updateUser:user image:self.avatarImage progress:^(float progress) {
        [SVProgressHUD showProgress:progress status:@"Upload image..."];
    } completion:^(BOOL success) {

        if (success) {
            weakSelf.avatarImage = nil;
            [weakSelf updateProfileView];
            [weakSelf setUpdateButtonActivity];
        }
        [SVProgressHUD dismiss];
    }];
}

- (BOOL)fieldsWereChanged {
    
    if (self.avatarImage != nil) return YES;
    if (![self.fullNameFieldCache isEqualToString:self.currentUser.fullName]) return YES;
    if ( (self.phoneFieldCache != nil && ![self.phoneFieldCache isEqualToString:@""])  &&  ![self.phoneFieldCache isEqualToString:self.currentUser.phone]) return YES;
    if ((self.statusTextCache != nil) && ![self.statusTextCache isEqualToString:self.currentUser.customData]) return YES;
    
    return NO;
}

- (NSString *)userPhone {
    return self.currentUser.phone ?: @"";
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.fullNameField) {
        self.fullNameFieldCache = str;
    } else if (textField == self.phoneNumberField) {
        self.phoneFieldCache = str;
    }
    
    [self setUpdateButtonActivity];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.statusTextCache = textView.text;
    [self setUpdateButtonActivity];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    self.avatarImage = selectedImage;
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
