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

    [[QMAuthService shared] signUpUser:newUser completion:^(QBUUserResult *result) {

        [SVProgressHUD dismiss];
        
        if (result.success) {
            // load image and update user with blob ID:
            if (self.cachedPicture != nil) {
                [self loginWithUser:result.user afterLoadingImage:self.cachedPicture];
            }
            [self loginWithUserWithoutImage:result.user];
        }
        else {
            [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
        }
        
    }];
}

- (void)loginWithUser:(QBUUser *)user afterLoadingImage:(UIImage *)image {
    
    [[QMAuthService shared] logInWithEmail:user.email password:self.passwordField.text completion:^(QBUUserLogInResult *result) {
        
        if (result.success) {
            [self updateUser:user withAvatar:image];
        }
        else {
            [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
        }
    }];
}

- (void)loginWithUserWithoutImage:(QBUUser *)user {

    QMChatService *chatService = [QMChatService shared];
    QMAuthService *authService = [QMAuthService shared];
    QMContactList *contactList = [QMContactList shared];
    
    [authService logInWithEmail:user.email password:self.passwordField.text completion:^(QBUUserLogInResult *result) {
        
        if (result.success) {
            // save me:
            user.password = self.passwordField.text;
            contactList.me = user;
            
            // subscribe to push notification:
            [authService subscribeToPushNotifications];
            
            [chatService loginWithUser:user completion:^(BOOL success) {
                if (success) {
                    [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
                }
                else {
                    [REAlertView showAlertWithMessage:@"" actionSuccess:NO];
                }
            }];
        }
        else {
            [REAlertView showAlertWithMessage:result.errors.lastObject actionSuccess:NO];
        }
    }];
}

- (void)updateUser:(QBUUser *)user withAvatar:(UIImage *)image {
    
    QMContent *content = [[QMContent alloc] init];
    [content uploadImage:image named:user.email completion:^(QBCFileUploadTaskResult *result) {
        
        [[QMAuthService shared] updateUser:user withBlob:result.uploadedBlob completion:^(QBUUserResult *updateResult) {
            
            if (updateResult.success) {
                
                user.password = self.passwordField.text;
                [QMContactList shared].me = user;
                
                // subscribe to push notification:
                [[QMAuthService shared] subscribeToPushNotifications];
                
                // login to chat:
                [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
                    if (success) {
                        // go to tab bar:
                        [self performSegueWithIdentifier:kTabBarSegueIdnetifier sender:nil];
                    }
                }];

            }
            else {
                [REAlertView showAlertWithMessage:updateResult.errors.lastObject actionSuccess:NO];
            }
        }];
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
