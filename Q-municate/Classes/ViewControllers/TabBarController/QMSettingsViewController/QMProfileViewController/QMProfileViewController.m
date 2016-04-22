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
#import "UIImage+Cropper.h"
#import "REActionSheet.h"
#import "QMImagePicker.h"
#import "QMUsersUtils.h"
#import <QBUUser+CustomData.h>

@interface QMProfileViewController ()

<UITextFieldDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet QMImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet QMPlaceHolderTextView *statusField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateProfileButton;
@property (weak, nonatomic) IBOutlet UISwitch *isProfileSearchableSwitch;

@property (strong, nonatomic) NSString *fullNameFieldCache;
@property (copy, nonatomic) NSString *phoneFieldCache;
@property (copy, nonatomic) NSString *statusTextCache;
@property (assign, nonatomic) BOOL isSearchableCache;

@property (nonatomic, strong) UIImage *avatarImage;

@end


@implementation QMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.avatarView.imageViewType = QMImageViewTypeCircle;
    self.statusField.placeHolder = @"Add status...";
    
    [self updateProfileView];
    [self setUpdateButtonActivity];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)updateProfileView {
  
    
    self.fullNameFieldCache = self.currentUser.fullName;
    self.phoneFieldCache = self.currentUser.phone ?: @"";
    self.statusTextCache = self.currentUser.status ?: @"";
    self.isSearchableCache = self.currentUser.isSearchable;
  
    UIImage *placeholder = [UIImage imageNamed:@"upic-placeholder"];
    NSURL *url = [QMUsersUtils userAvatarURL:self.currentUser];
    
    [self.avatarView setImageWithURL:url
                         placeholder:placeholder
                             options:SDWebImageHighPriority
                            progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                ILog(@"r - %zd; e - %zd", receivedSize, expectedSize);
                            } completedBlock:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                
                            }];
    
    self.fullNameField.text = self.currentUser.fullName;
    self.emailField.text = self.currentUser.email;
    self.phoneNumberField.text = self.currentUser.phone;
    self.statusField.text = self.currentUser.status;
    [self.isProfileSearchableSwitch setOn:self.currentUser.isSearchable animated:NO];
}

- (IBAction)changeAvatar:(id)sender {
    [self.view endEditing:YES];

    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    __weak __typeof(self)weakSelf = self;
    [QMImagePicker chooseSourceTypeInVC:self allowsEditing:YES result:^(UIImage *image) {
        
        weakSelf.avatarImage = image;
        weakSelf.avatarView.image = [image imageByCircularScaleAndCrop:weakSelf.avatarView.frame.size];
        [weakSelf setUpdateButtonActivity];
    }];
}

- (void)setUpdateButtonActivity {
    
    BOOL activity = [self fieldsWereChanged];
    self.updateProfileButton.enabled = activity;
}

- (IBAction)hideKeyboard:(id)sender {
    [sender resignFirstResponder];
}

- (BOOL)checkFullNameField {
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    if (self.fullNameFieldCache.length < 3 || self.fullNameFieldCache.length > 50 || [[self.fullNameFieldCache stringByTrimmingCharactersInSet:whiteSpaceSet] length] == 0) return NO;
    
    if ([self.fullNameFieldCache containsString:@"<"]) return NO;
    if ([self.fullNameFieldCache containsString:@">"]) return NO;
    if ([self.fullNameFieldCache containsString:@";"]) return NO;
    
    return YES;
}

- (IBAction)saveChanges:(id)sender {
    
    if (!QMApi.instance.isInternetConnected) {
        [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
        return;
    }
    
    [self.view endEditing:YES];
    
    if (![self checkFullNameField]) {
        [REAlertView showAlertWithMessage:@"Full name field must be 3-50 characters and can't contain '<', '>' and ';'" actionSuccess:NO];
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
  
    self.currentUser.isSearchable = self.isSearchableCache;
    QBUpdateUserParameters *params = [QBUpdateUserParameters new];
    params.customData = self.currentUser.customData;
    params.fullName = self.fullNameFieldCache;
    params.phone = self.phoneFieldCache;
    params.status = self.statusTextCache;
    
    [SVProgressHUD showProgress:0.f status:nil maskType:SVProgressHUDMaskTypeClear];
    [[QMApi instance] updateCurrentUser:params image:self.avatarImage progress:^(float progress) {
        //
        [SVProgressHUD showProgress:progress status:nil maskType:SVProgressHUDMaskTypeClear];
    } completion:^(BOOL success) {
        //
        if (success) {
            weakSelf.avatarImage = nil;
            [weakSelf updateProfileView];
            [weakSelf setUpdateButtonActivity];
        }
        [SVProgressHUD dismiss];
    }];
}

- (BOOL)fieldsWereChanged {
    
    if (self.avatarImage) return YES;
    if (![self.fullNameFieldCache isEqualToString:self.currentUser.fullName]) return YES;
    if (![self.phoneFieldCache isEqualToString:self.currentUser.phone ?: @""]) return YES;
    if (![self.statusTextCache isEqualToString:self.currentUser.status ?: @""]) return YES;
    if (self.isSearchableCache != self.currentUser.isSearchable) return YES;
  
    return NO;
}

- (IBAction)changeProfileSearchableValue:(UISwitch *)sender
{
  if (!QMApi.instance.isInternetConnected)
  {
    [REAlertView showAlertWithMessage:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) actionSuccess:NO];
    return;
  }
  self.isSearchableCache = sender.isOn;
  [self setUpdateButtonActivity];
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.fullNameField) {
        self.fullNameFieldCache = str;
    } else if (textField == self.phoneNumberField) {
        self.phoneFieldCache = str;
    }
    
    [self setUpdateButtonActivity];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    self.statusTextCache = textView.text;
    [self setUpdateButtonActivity];
}

@end
