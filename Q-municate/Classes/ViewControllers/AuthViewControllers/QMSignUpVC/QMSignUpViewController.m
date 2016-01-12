//
//  QMSignUpController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSignUpViewController.h"
#import "QMLicenseAgreement.h"
#import "UIImage+Cropper.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "QMImagePicker.h"
#import "REActionSheet.h"

#import <QMImageView.h>
#import "QMCore.h"
#import "QMProfile.h"
#import "QMContent.h"

@interface QMSignUpViewController ()

<QMImagePickerResultHandler>

@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet QMImageView *userImage;

@property (strong, nonatomic) UIImage *selectedImage;

@end

@implementation QMSignUpViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userImage.imageViewType = QMImageViewTypeCircle;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Actions

- (IBAction)chooseUserPicture:(id)sender {
    
    // hiding keyboard
    [self.view endEditing:YES];
    
    [REActionSheet presentActionSheetInView:self.view configuration:^(REActionSheet *actionSheet) {
        
        [actionSheet addButtonWithTitle:@"Take image" andActionBlock:^{
            [QMImagePicker takePhotoInViewController:self resultHandler:self];
        }];
        
        [actionSheet addButtonWithTitle:@"Choose from library" andActionBlock:^{
            [QMImagePicker choosePhotoInViewController:self resultHandler:self];
        }];
    }];
}

- (IBAction)pressentUserAgreement:(id)sender {
    
    [QMLicenseAgreement presentUserAgreementInViewController:self completion:nil];
}

- (IBAction)done:(id)sender {
    
    NSString *fullName = self.fullNameField.text;
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    if (fullName.length == 0 || password.length == 0 || email.length == 0 || [[fullName stringByTrimmingCharactersInSet:whiteSpaceSet] length] == 0) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
        return;
    }

    @weakify(self);
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL userAgreementSuccess) {
        @strongify(self);
        if (userAgreementSuccess) {
            QBUUser *newUser = [QBUUser user];
            newUser.fullName = fullName;
            newUser.email    = email;
            newUser.password = password;
            newUser.tags = @[@"ios"].mutableCopy;
            
            void (^presentTabBar)(void) = ^(void) {
                
                [SVProgressHUD dismiss];
                [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            };
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [QMCore instance].currentProfile.userAgreementAccepted = userAgreementSuccess;
            
            [[[[QMCore instance].authService signUpAndLoginWithUser:newUser] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
                //
                if (!task.isFaulted) {
                    [QMCore instance].currentProfile.rememberMe = YES;
                    
                    if (self.selectedImage != nil) {
                        [SVProgressHUD showProgress:0.f status:nil maskType:SVProgressHUDMaskTypeClear];
                        return [[QMCore instance].currentProfile updateUserImage:self.selectedImage progress:^(float progress) {
                            //
                            [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
                        }];
                    } else {
                        [[QMCore instance].currentProfile synchronizeWithUserData:task.result];
                        presentTabBar();
                    }
                }
                return nil;
            }] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
                // saving picture to the cache
                [self.userImage sd_setImage:self.selectedImage withKey:task.result.avatarUrl];
                presentTabBar();
                return nil;
            }];
        }
    }];
}

#pragma mark - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    self.selectedImage = photo;
    [self.userImage setImage:photo];
}

@end
