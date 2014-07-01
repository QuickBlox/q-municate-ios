//
//  QMSignUpController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSignUpController.h"
#import "QMWelcomeScreenViewController.h"
#import "UIImage+Cropper.h"
#import "QMAuthService.h"
#import "QMChatService.h"
#import "QMContactList.h"
#import "QMContent.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "QMApi.h"

@interface QMSignUpController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (strong, nonatomic) UIImage *cachedPicture;

- (IBAction)chooseUserPicture:(id)sender;
- (IBAction)signUp:(id)sender;

@end

@implementation QMSignUpController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureAvatarImage];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - UI

- (void)configureAvatarImage {
    
    CALayer *imageLayer = self.userImage.layer;
    imageLayer.cornerRadius = self.userImage.frame.size.width / 2;
    imageLayer.masksToBounds = YES;
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)chooseUserPicture:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)signUp:(id)sender {
    
    NSString *fullName = self.fullNameField.text;
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    if (fullName.length == 0 || password.length == 0 || email.length == 0) {
        [REAlertView showAlertWithMessage:kAlertBodyFillInAllFieldsString actionSuccess:NO];
        return;
    }
    
    QBUUser *newUser = [QBUUser user];
    
    newUser.fullName = fullName;
    newUser.email = email;
    newUser.password = password;

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    [[QMApi shared] signUpAndLoginWithUser:newUser userAvatar:self.cachedPicture completion:^(QBUUserResult *result) {
        [SVProgressHUD dismiss];
        if(result.success)
            [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
    }];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    CGSize imgViewSize = CGSizeMake(self.userImage.frame.size.width * 2, self.userImage.frame.size.height * 2);
    UIImage *image =  info[UIImagePickerControllerOriginalImage];
    UIImage *scaledImage = [image imageByScalingProportionallyToMinimumSize:imgViewSize];
    [self.userImage setImage:scaledImage];
    self.cachedPicture = scaledImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
