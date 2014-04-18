//
//  QMProfileViewController.m
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMProfileViewController.h"
#import "UIImageView+ImageWithBlobID.h"
#import "UIImage+Cropper.h"
#import "QMContactList.h"
#import "QMContent.h"
#import "QMAuthService.h"
#import "QMUtilities.h"

@interface QMProfileViewController ()

@property (nonatomic) BOOL isUserDataChanged;
@property (nonatomic) BOOL isUserPhotoChanged;
@property (strong, nonatomic) NSDictionary *oldUserDataDictionary;
@property (strong, nonatomic) NSString *oldUserStatusString;
@property (strong, nonatomic) UIBarButtonItem *backItem;
@property (strong, nonatomic) QBUUser *localUser;

@end

@implementation QMProfileViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.oldUserDataDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDataInfoDictionary];
    self.oldUserStatusString = [[NSUserDefaults standardUserDefaults] objectForKey:kUserStatusText];
    self.localUser = [QMContactList shared].me;
    
    self.userNameTextField.text = self.localUser.fullName;
    self.userMailTextField.text = self.localUser.email;

    self.userStatusTextView.text = self.oldUserStatusString;
    self.isUserPhotoChanged = NO;
    
    [self loadUserAvatarToImageView];

    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    CALayer *imageLayer = self.userPhotoImageView.layer;
    imageLayer.cornerRadius = self.userPhotoImageView.frame.size.width / 2;
    imageLayer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadUserAvatarToImageView
{
    if (self.localUser.website != nil) {
        [self.userPhotoImageView setImageURL:[NSURL URLWithString:self.localUser.website]];
        return;
    }
    [self.userPhotoImageView loadImageWithBlobID:self.localUser.blobID];
}

- (IBAction)chooseUserPicture:(UIButton *)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    CGSize imgViewSize = self.userPhotoImageView.frame.size;
    UIImage *image =  info[UIImagePickerControllerOriginalImage];
    UIImage *scaledImage = [image imageByScalingProportionallyToMinimumSize:imgViewSize];
    [self.userPhotoImageView setImage:scaledImage];
    self.isUserPhotoChanged = YES;
    [self checkForDoneButton];

    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *textString = textField.text;
    if (textField == self.userNameTextField) {
        if (![textString isEqualToString:self.localUser.fullName]) {
            self.isUserDataChanged = YES;
        } else {
            self.isUserDataChanged = NO;
        }
    } else if (textField == self.userMailTextField) {
        if (![textString isEqualToString:self.localUser.email]) {
            self.isUserDataChanged = YES;
        } else {
            self.isUserDataChanged = NO;
        }
    }
    [self checkForDoneButton];
    [textField resignFirstResponder];
    return YES;
}

- (void)checkForDoneButton
{
    if (self.isUserDataChanged || self.isUserPhotoChanged) {
        if (!self.backItem) {
            self.backItem = self.navigationController.navigationBar.backItem.backBarButtonItem;
        }
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kButtonTitleDoneString style:UIBarButtonItemStyleDone target:self action:@selector(saveChanges)];
    } else {
        self.navigationItem.leftBarButtonItem = self.backItem;
    }
}

- (void)saveChanges
{
    NSLog(@"saving data");
    [QMUtilities createIndicatorView];
    if (self.isUserPhotoChanged) {
        QMContent *content = [[QMContent alloc] init];
        [content loadImageForBlob:self.userPhotoImageView.image named:self.oldUserDataDictionary[@"id"] completion:^(QBCBlob *blob) {
            self.localUser.website = [blob publicUrl];
            [self updateOtherDataForBlob:blob];
        }];
    } else {
        [self updateOtherDataForBlob:nil];
    }
}

- (void)updateOtherDataForBlob:(QBCBlob *)blob
{
    NSString *userNameString = self.userNameTextField.text;
    if (![userNameString isEqualToString:self.localUser.fullName]) {
        self.localUser.fullName = userNameString;
    }
    NSString *userMailString = self.userMailTextField.text;
    if (![userMailString isEqualToString:self.localUser.email]) {
        self.localUser.email = userMailString;
    }
    
    [[QMAuthService shared] updateUser:self.localUser withBlob:blob completion:^(QBUUser *user, BOOL success, NSError *error) {
        if (success) {
            [QMContactList shared].me = user;
			[self resetChanges];
		} else {
			[[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:[NSString stringWithFormat:@"%@", error] delegate:self cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
		}
        [QMUtilities removeIndicatorView];
    }];

    // hard code till there will be a field in QBUUser where to save to
    [[NSUserDefaults standardUserDefaults] setObject:self.userStatusTextView.text forKey:kUserStatusText];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetChanges
{
    self.isUserDataChanged = NO;
    self.isUserPhotoChanged = NO;
    [self checkForDoneButton];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect r = self.containerView.frame;
    r.origin.y = r.origin.y - 80;
    [UIView animateWithDuration:0.3f animations:^{
        [self.containerView setFrame:r];
    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        NSString *userStatusString = textView.text;
        if (![userStatusString isEqualToString:self.oldUserStatusString]) {
            self.isUserDataChanged = YES;
        } else {
            self.isUserDataChanged = NO;
        }
        [self checkForDoneButton];
        [textView resignFirstResponder];
        CGRect r = self.containerView.frame;
        r.origin.y = 0;
        [UIView animateWithDuration:0.3f animations:^{
            [self.containerView setFrame:r];
        }];
    }
    return YES;
}


@end
