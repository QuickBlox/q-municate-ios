//
//  QMSignUpController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 13/02/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMSignUpController.h"
#import "QMLicenseAgreement.h"
#import "UIImage+Cropper.h"
#import "REAlertView+QMSuccess.h"
#import "SVProgressHUD.h"
#import "QMImagePicker.h"
#import "REActionSheet.h"
#import "QMServicesManager.h"

@interface QMSignUpController ()

@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (strong, nonatomic) UIImage *cachedPicture;

@end

@implementation QMSignUpController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
    self.userImage.layer.masksToBounds = YES;
    
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - Actions

- (IBAction)hideKeyboard:(id)sender {
    
    [sender resignFirstResponder];
}

- (IBAction)chooseUserPicture:(id)sender {
    
    __weak __typeof(self)weakSelf = self;
    
    [QMImagePicker chooseSourceTypeInVC:self
                          allowsEditing:YES
                                 result:^(UIImage *image)
     {
         [weakSelf.userImage setImage:image];
         weakSelf.cachedPicture = image;
     }];
}

- (IBAction)pressentUserAgreement:(id)sender {
    
    [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self
                                                        completion:nil];
}

- (IBAction)signUp:(id)sender {
    
    if (self.fullNameField.text.length == 0 ||
        self.passwordField.text.length == 0 ||
        self.emailField.text.length == 0) {
        
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil)
                            actionSuccess:NO];
    }
    else {
        
        [QMLicenseAgreement checkAcceptedUserAgreementInViewController:self
                                                            completion:^(BOOL userAgreementSuccess)
         {
             if (userAgreementSuccess) {
                 
                 QBUUser *newUser = [QBUUser user];
                 
                 newUser.fullName = self.fullNameField.text;
                 newUser.email = self.emailField.text;
                 newUser.password = self.passwordField.text;
                 newUser.tags = @[@"ios"].mutableCopy;
                 
                 [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
                 
                 [QM.authService signUpAndLoginWithUser:newUser
                                             completion:^(QBResponse *response, QBUUser *userProfile)
                  {
                      if (response.success) {
                          //Update password data
                          userProfile.password = newUser.password;
                          [QM.profile setUserAgreementAccepted:userAgreementSuccess];
                          //Synchronize user profile
                          [QM.profile synchronizeWithUserData:userProfile];
                          //Upload user image
                          [QM.profile updateUserWithImage:self.cachedPicture
                                                 progress:^(float progress)
                           {
                               
                           } completion:^(BOOL success) {
                               
                               [self performSegueWithIdentifier:kTabBarSegueIdnetifier
                                                         sender:nil];
                           }];
                          
                          [SVProgressHUD dismiss];
                      }
                  }];
             }
         }];
    }
}

@end
