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
#import "QMAddressBook.h"
#import "QMAuthService.h"
#import "QMChatService.h"
#import "QMContactList.h"
#import "QMContent.h"
#import "QMUtilities.h"

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


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureAvatarImage];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


#pragma mark - UI

- (void)configureAvatarImage
{
    CALayer *imageLayer = self.userImage.layer;
    imageLayer.cornerRadius = self.userImage.frame.size.width / 2;
    imageLayer.masksToBounds = YES;
}


#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)switchToLoginController:(id)sender
{
    UINavigationController *navController = [self.root.childViewControllers lastObject];
    [self.root logInToQuickblox];
    [navController removeFromParentViewController];
}

- (IBAction)chooseUserPicture:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)signUp:(id)sender
{
    if ([self.emailField.text isEqual:kEmptyString] || [self.fullNameField.text isEqual:kEmptyString] || [self.passwordField isEqual:kEmptyString]) {
        [self showAlertWithMessage:kAlertBodyFillInAllFieldsString success:NO];
        return;
    }
    
    [QMUtilities createIndicatorView];
    [[QMAuthService shared] signUpWithFullName:self.fullNameField.text email:self.emailField.text password:self.passwordField.text blobID:0 completion:^(QBUUser *user, BOOL success, NSError *error) {
        
        [QMUtilities removeIndicatorView];
        if (error) {
            [self showAlertWithMessage:error.domain success:NO];
            return;
        }
        
        // load image and update user with blob ID:
        if (self.cachedPicture != nil) {
            [self loginWithUser:user afterLoadingImage:self.cachedPicture];
            return;
        }
        [self loginWithUserWithoutImage:user];
    }];
}

// **************** 
- (void)loginWithUser:(QBUUser *)user afterLoadingImage:(UIImage *)image
{
    [QMUtilities createIndicatorView];
    [[QMAuthService shared] logInWithEmail:user.email password:self.passwordField.text completion:^(QBUUser *user, BOOL success, NSError *error) {
        [QMUtilities removeIndicatorView];
        [self updateUser:user withAvatar:image];
    }];
}

- (void)loginWithUserWithoutImage:(QBUUser *)user
{
    [QMUtilities createIndicatorView];
    [[QMAuthService shared] logInWithEmail:user.email password:self.passwordField.text completion:^(QBUUser *user, BOOL success, NSError *error) {
        [QMUtilities removeIndicatorView];
        if (!success) {
            return;
        }
        // save me:
        user.password = self.passwordField.text;
        [QMContactList shared].me = user;
        
        [QMUtilities createIndicatorView];
        [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
            [QMUtilities removeIndicatorView];
            if (success) {
                // go to tab bar:
                UIWindow *window = (UIWindow *)[[UIApplication sharedApplication].windows firstObject];
                UINavigationController *navigationController = (UINavigationController *)window.rootViewController;
                [navigationController popToRootViewControllerAnimated:NO];
                return;
            }
            [self showAlertWithMessage:error.description success:NO];
        }];
    }];
}

- (void)updateUser:(QBUUser *)user withAvatar:(UIImage *)image
{
    [QMUtilities createIndicatorView];
    QMContent *content = [[QMContent alloc] init];
    [content loadImageForBlob:image named:user.email completion:^(QBCBlob *blob) {
        [QMUtilities removeIndicatorView];
        //
        [QMUtilities createIndicatorView];
        [[QMAuthService shared] updateUser:user withBlob:blob completion:^(QBUUser *user, BOOL success, NSError *error) {
            [QMUtilities removeIndicatorView];
            if (!success) {
                return;
            }
            user.password = self.passwordField.text;
            [QMContactList shared].me = user;
            
            // login to chat:
            [QMUtilities createIndicatorView];
            [[QMChatService shared] loginWithUser:user completion:^(BOOL success) {
                [QMUtilities removeIndicatorView];
                if (success) {
                    // go to tab bar:
                    UIWindow *window = (UIWindow *)[[UIApplication sharedApplication].windows firstObject];
                    UINavigationController *navigationController = (UINavigationController *)window.rootViewController;
                    [navigationController popToRootViewControllerAnimated:NO];
                }
            }];
        }];
    }];
}


#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message success:(BOOL)success
{
    NSString *title = nil;
    if (success) {
        title = kEmptyString;
    } else {
        title = kAlertTitleErrorString;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:kAlertButtonTitleOkString
                                          otherButtonTitles: nil];
    [alert show];
}


#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    CGSize imgViewSize = CGSizeMake(self.userImage.frame.size.width * 2, self.userImage.frame.size.height * 2);
    UIImage *image =  info[UIImagePickerControllerOriginalImage];
    UIImage *scaledImage = [image imageByScalingProportionallyToMinimumSize:imgViewSize];
    [self.userImage setImage:scaledImage];
    self.cachedPicture = scaledImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
