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
#import "QMImagePicker.h"
#import "REActionSheet.h"

#import <QMImageView.h>
#import "QMCore.h"
#import "QMNotification.h"
#import "QMContent.h"

@interface QMSignUpViewController ()

<
QMImagePickerResultHandler,
QMImageViewDelegate
>

@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet QMImageView *userImage;

@property (strong, nonatomic) UIImage *selectedImage;
@property (weak, nonatomic) BFTask *task;

@end

@implementation QMSignUpViewController

- (void)dealloc {
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.userImage.imageViewType = QMImageViewTypeCircle;
    self.userImage.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - Actions

- (void)avatarPressAction {
    
    @weakify(self);
    [REActionSheet presentActionSheetInView:self.view configuration:^(REActionSheet *actionSheet) {
        
        @strongify(self);
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil) andActionBlock:^{
            [QMImagePicker takePhotoInViewController:self resultHandler:self];
        }];
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_FROM_LIBRARY", nil) andActionBlock:^{
            [QMImagePicker choosePhotoInViewController:self resultHandler:self];
        }];
        
        [actionSheet addCancelButtonWihtTitle:NSLocalizedString(@"QM_STR_CANCEL", nil) andActionBlock:^{
            
        }];
    }];
}

- (IBAction)chooseUserPicture:(id)__unused sender {
    
    [self avatarPressAction];
}

- (void)imageViewDidTap:(QMImageView *)__unused imageView {
    
    [self avatarPressAction];
}

- (IBAction)pressentUserAgreement:(id)__unused sender {
    
    [QMLicenseAgreement presentUserAgreementInViewController:self completion:nil];
}

- (IBAction)done:(id)__unused sender {
    
    if (self.task != nil) {
        // task in progress
        return;
    }
    
    NSString *fullName = self.fullNameField.text;
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    if (fullName.length == 0 || password.length == 0 || email.length == 0 || [[fullName stringByTrimmingCharactersInSet:whiteSpaceSet] length] == 0) {
        
        [QMNotification showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_FILL_IN_ALL_THE_FIELDS", nil) timeUntilDismiss:kQMDefaultNotificationDismissTime];
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
                
                [QMNotification dismissNotification];
                [self performSegueWithIdentifier:kQMSceneSegueMain sender:nil];
            };
            
            [QMNotification showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_SIGNING_UP", nil) timeUntilDismiss:0];
            [QMCore instance].currentProfile.userAgreementAccepted = userAgreementSuccess;
            
            self.task = [[[[QMCore instance].authService signUpAndLoginWithUser:newUser] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
                
                if (!task.isFaulted) {
                    
                    [[QMCore instance].currentProfile setAccountType:QMAccountTypeEmail];
                    if (self.selectedImage != nil) {
                        
                        return [[QMCore instance].currentProfile updateUserImage:self.selectedImage progress:nil];
                    }
                    else {
                        
                        task.result.password = newUser.password;
                        [[QMCore instance].currentProfile synchronizeWithUserData:task.result];
                        presentTabBar();
                    }
                }
                return nil;
            }] continueWithBlock:^id _Nullable(BFTask<QBUUser *> * _Nonnull task) {
                // saving picture to the cache
                if (task.result != nil) {
                    
                    [self.userImage setImage:self.selectedImage withKey:task.result.avatarUrl];
                    presentTabBar();
                }
                
                return nil;
            }];
        }
    }];
}

#pragma mark - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    self.selectedImage = photo;
    [self.userImage applyImage:photo];
}

@end
