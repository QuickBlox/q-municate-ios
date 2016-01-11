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

@interface QMSignUpViewController ()

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

- (IBAction)pressentUserAgreement:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:nil];
}

- (IBAction)signUp:(id)sender
{
    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    [self fireSignUp];
}

- (void)fireSignUp
{
    NSString *fullName = self.fullNameField.text;
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    if (fullName.length == 0 || password.length == 0 || email.length == 0 || [[fullName stringByTrimmingCharactersInSet:whiteSpaceSet] length] == 0) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) actionSuccess:NO];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self completion:^(BOOL userAgreementSuccess) {
        
        if (userAgreementSuccess) {
            
            QBUUser *newUser = [QBUUser user];
            
            newUser.fullName = fullName;
            newUser.email = email;
            newUser.password = password;
            newUser.tags = [[NSMutableArray alloc] initWithObjects:@"ios", nil];
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            
            void (^presentTabBar)(void) = ^(void) {
                
                [SVProgressHUD dismiss];
                [weakSelf performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            };
            
            [[QMApi instance] signUpAndLoginWithUser:newUser rememberMe:YES completion:^(BOOL success) {
                
                if (success) {
                    
                    if (weakSelf.cachedPicture) {
                        
                        [SVProgressHUD showProgress:0.f status:nil maskType:SVProgressHUDMaskTypeClear];
                        [[QMApi instance] updateCurrentUser:nil image:weakSelf.cachedPicture progress:^(float progress) {
                            //
                            [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
                        } completion:^(BOOL succeed) {
                            //
                            presentTabBar();
                        }];
                    }
                    else {
                        presentTabBar();
                    }
                }
                else {
                    [SVProgressHUD dismiss];
                }
            }];
        }
    }];
}

@end
