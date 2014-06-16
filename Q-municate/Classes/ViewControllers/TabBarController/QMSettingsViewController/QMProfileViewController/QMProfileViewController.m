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

#define kDefaultContainerYOffset	0.0f
#define kUserNameContainerYOffset	-40.0f
#define kUserMailContainerYOffset	-90.0f
#define kUserPhoneContainerYOffset	-150.0f
#define kUserStatusContainerYOffset	-170.0f

#define kUserStatusLengthConstraint	43

@interface QMProfileViewController ()

@property (nonatomic) BOOL isUserDataChanged;
@property (nonatomic) BOOL isUserPhotoChanged;
@property (assign) BOOL shouldShowWarning;
@property (assign) BOOL isBackButtonClicked;
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
    self.shouldShowWarning = YES;
	self.isBackButtonClicked = NO;

	self.oldUserDataDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDataInfoDictionary];
    self.oldUserStatusString = [[NSUserDefaults standardUserDefaults] objectForKey:kUserStatusText];
    self.localUser = [QMContactList shared].me;
    if (!self.localUser.phone) {
		self.localUser.phone = kEmptyString;
    }
    self.userNameTextField.text = self.localUser.fullName;
	NSString *mailString;
	if (self.localUser.email) {
	    mailString = self.localUser.email;
	} else {
		mailString = [QMContactList shared].facebookMe[kEmail];
	}
	mailString = [mailString stringByReplacingOccurrencesOfString:@"%2b" withString:@"+"];
	self.userMailTextField.text = mailString;
	self.userPhoneTextField.text = self.localUser.phone;

	if (!self.oldUserStatusString || [self.oldUserStatusString isEqualToString:kEmptyString]) {
		self.oldUserStatusString = kSettingsProfileDefaultStatusString;
	}
	[self checkStatusColorWithString:self.oldUserStatusString];
	self.userStatusTextView.text = self.oldUserStatusString;
	self.isUserPhotoChanged = NO;
    
    [self loadUserAvatarToImageView];

    CALayer *imageLayer = self.userPhotoImageView.layer;
    imageLayer.cornerRadius = self.userPhotoImageView.frame.size.width / 2;
    imageLayer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
	self.isBackButtonClicked = YES;
	[self.userStatusTextView resignFirstResponder];
	[self setOldValues];
	[super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.isBackButtonClicked = NO;
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
	if ([self checkForFullnessOfLoginAndMailFields]) {
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[self presentViewController:imagePicker animated:YES completion:nil];
	}
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    CGSize imgViewSize = CGSizeMake(200, 200);
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
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self checkForChanges];
	if (textField == self.userPhoneTextField) {
		[self showNavDoneButton];
		[self setFrameOffset:kUserPhoneContainerYOffset];
	} else {
		if (self.navigationItem.rightBarButtonItems) {
			[self.navigationItem setRightBarButtonItems:nil];
		}
	}
	if (textField == self.userNameTextField) {
		[self setFrameOffset:kUserNameContainerYOffset];
	} else if (textField == self.userMailTextField) {
		[self setFrameOffset:kUserMailContainerYOffset];
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	return [self checkForFullnessOfLoginAndMailFields];
}

- (BOOL)checkForFullnessOfLoginAndMailFields
{
	if ((!self.userNameTextField.text.length || !self.userMailTextField.text.length) && self.shouldShowWarning) {
		self.shouldShowWarning = NO;
		[self showAlertWithMessage:kSettingsProfileMessageWarningString];
		return NO;
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *textString = textField.text;
	if (!textString.length && (textField == self.userNameTextField || textField == self.userMailTextField)) {
		[self showAlertWithMessage:kSettingsProfileMessageWarningString];
		return NO;
	}
	[self checkForChanges];
    [textField resignFirstResponder];
	[self setFrameOffset:kDefaultContainerYOffset];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *textString = textField.text;
	NSString *resultString;
	if (!range.length) {
	    resultString = [NSString stringWithFormat:@"%@%@%@", [textString substringToIndex:range.location], string, [textString substringFromIndex:range.location]];
	} else {
		resultString = [NSString stringWithFormat:@"%@%@", [textString substringToIndex:range.location], [textString substringFromIndex:range.location + 1]];
	}
	NSLog(@"resultString: %@", resultString);
	if (textField == self.userNameTextField) {
	    if (![resultString isEqualToString:self.localUser.fullName]) {
			self.isUserDataChanged = YES;
		} else {
			self.isUserDataChanged = NO;
		}
	} else if (textField == self.userMailTextField) {
		if (self.localUser.email) {
			if (![resultString isEqualToString:self.localUser.email]) {
				self.isUserDataChanged = YES;
			} else {
				self.isUserDataChanged = NO;
			}
		} else {
			NSString *fbMailString = [QMContactList shared].facebookMe[kEmail];
			BOOL isMailEqual = [resultString isEqualToString:fbMailString];
			if (!isMailEqual) {
				self.isUserDataChanged = YES;
			} else {
				self.isUserDataChanged = NO;
			}
		}
	} else if (textField == self.userPhoneTextField) {
		if (![resultString isEqualToString:self.localUser.phone]) {
			self.isUserDataChanged = YES;
		} else {
			self.isUserDataChanged = NO;
		}
	}
	[self checkForDoneButton];

	return YES;
}


#pragma mark - TextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	if (![self checkForFullnessOfLoginAndMailFields]) {
		return NO;
	}
	NSString *statusString = textView.text;
	if ([statusString isEqualToString:kSettingsProfileDefaultStatusString]) {
	    self.userStatusTextView.text = kEmptyString;
		[self.userStatusTextView setTextColor:[UIColor blackColor]];
	}
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	NSString *statusString = textView.text;
	self.userStatusTextView.text = [self verifyResultStatusWithString:statusString];
}

- (NSString *)verifyResultStatusWithString:(NSString *)resultTextViewString
{
	if ([resultTextViewString isEqualToString:kEmptyString]) {
		resultTextViewString = kSettingsProfileDefaultStatusString;
	}
	if ([resultTextViewString isEqualToString:kSettingsProfileDefaultStatusString]) {
		[self.userStatusTextView setTextColor:kHintColor];
	}
	return resultTextViewString;
}

#pragma mark -
- (void)showNavDoneButton
{
	UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 36)];
	[doneButton setTitle:kButtonTitleSaveString forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(hideNumKeyboard) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
	[self.navigationItem setRightBarButtonItems:@[doneBarButton]];
}

- (IBAction)hideNumKeyboard
{
	[self.userPhoneTextField resignFirstResponder];
	[self.navigationItem setRightBarButtonItems:nil];
	[self setFrameOffset:kDefaultContainerYOffset];
	[self checkForChanges];
}

- (void)checkForChanges
{
	[self verifyInputFields];
	[self checkForDoneButton];
}

- (void)verifyInputFields
{
	NSString *fbMailString = [QMContactList shared].facebookMe[kEmail];
	BOOL isPhoneEqual = [self.userPhoneTextField.text isEqualToString:self.localUser.phone];
	BOOL isFullNameEqual = [self.userNameTextField.text isEqualToString:self.localUser.fullName];
	BOOL isMailEqual = ![self.userMailTextField.text isEqualToString:self.localUser.email] || ![self.userMailTextField.text isEqualToString:fbMailString];
	BOOL isStatusEqual = [self.userStatusTextView.text isEqualToString:self.oldUserStatusString];
	BOOL isStatusEmpty = [self.userStatusTextView.text isEqualToString:kEmptyString];
	if (!isPhoneEqual ||!isFullNameEqual || !isMailEqual || !(isStatusEqual || isStatusEmpty)) {
		self.isUserDataChanged = YES;
	} else {
		self.isUserDataChanged = NO;
	}
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
    ILog(@"saving data");
	if (self.userStatusTextView.text.length > kUserStatusLengthConstraint && self.shouldShowWarning) {
		self.shouldShowWarning = NO;
		[self showAlertWithMessage:kSettingsProfileTextViewMessageWarningString];
		return;
	}
	if ([self checkForFullnessOfLoginAndMailFields]) {
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
}

- (void)updateOtherDataForBlob:(QBCBlob *)blob
{
	[self prepareUserData];
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

- (void)prepareUserData
{
	NSString *userNameString = self.userNameTextField.text;
	if (![userNameString isEqualToString:self.localUser.fullName]) {
		self.localUser.fullName = userNameString;
	}
	NSString *userMailString = self.userMailTextField.text;
	userMailString = [userMailString stringByReplacingOccurrencesOfString:@"+" withString:@"%2b"];
	if (![userMailString isEqualToString:self.localUser.email]) {
		self.localUser.email = userMailString;
	}
	NSString *userPhoneString = self.userPhoneTextField.text;
	if (![userPhoneString isEqualToString:self.localUser.phone]) {
		self.localUser.phone = userPhoneString;
	}
}

- (void)checkStatusColorWithString:(NSString *)userStatusString
{
	if ([userStatusString isEqualToString:kSettingsProfileDefaultStatusString]) {
		[self.userStatusTextView setTextColor:kHintColor];
	} else {
		[self.userStatusTextView setTextColor:[UIColor blackColor]];
	}
}

- (void)setOldValues
{
	self.userNameTextField.text = self.localUser.fullName;
	self.userMailTextField.text = self.localUser.email;
	self.userPhoneTextField.text = self.localUser.phone;
	self.userStatusTextView.text = self.oldUserStatusString;
	[self checkStatusColorWithString:self.oldUserStatusString];
	[self resetChanges];
}

- (void)resetChanges
{
    self.isUserDataChanged = NO;
    self.isUserPhotoChanged = NO;
	self.shouldShowWarning = YES;
	self.isBackButtonClicked = NO;
    [self checkForDoneButton];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[self checkForChanges];
	[self setFrameOffset:kUserStatusContainerYOffset];
	if (self.navigationItem.rightBarButtonItems) {
		[self.navigationItem setRightBarButtonItems:nil];
	}
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	if (textView.text.length > kUserStatusLengthConstraint && self.shouldShowWarning && !self.isBackButtonClicked) {
		self.shouldShowWarning = NO;
		[self showAlertWithMessage:kSettingsProfileTextViewMessageWarningString];
		return NO;
	}
	return YES;
}


- (void)setFrameOffset:(CGFloat)yOffset
{
	CGRect r = self.containerView.frame;
	r.origin.y = yOffset;
	[UIView animateWithDuration:0.3f animations:^{
		[self.containerView setFrame:r];
	}];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
		if (textView.text.length > kUserStatusLengthConstraint) {
			[self showAlertWithMessage:kSettingsProfileTextViewMessageWarningString];
			return NO;
		}
//        NSString *userStatusString = textView.text;
//		userStatusString = [self verifyResultStatusWithString:userStatusString];
//		if (![userStatusString isEqualToString:self.oldUserStatusString]) {
//            self.isUserDataChanged = YES;
//        } else {
//            self.isUserDataChanged = NO;
//        }
		[self checkForChanges];
        [textView resignFirstResponder];
        CGRect r = self.containerView.frame;
        r.origin.y = 0;
        [UIView animateWithDuration:0.3f animations:^{
            [self.containerView setFrame:r];
        }];
    } else if (textView.text.length == kUserStatusLengthConstraint && !range.length) {
		return NO;
    } else {
		NSString *userStatusString = textView.text;
		NSString *resultString;
		if (!range.length) {
			resultString = [NSString stringWithFormat:@"%@%@", userStatusString, text];
		} else {
			resultString = [userStatusString substringToIndex:range.location];
		}
		NSLog(@"resultString: %@", resultString);
		userStatusString = [self verifyResultStatusWithString:resultString];
		if (![userStatusString isEqualToString:self.oldUserStatusString]) {
			self.isUserDataChanged = YES;
		} else {
			self.isUserDataChanged = NO;
		}
		[self checkStatusColorWithString:userStatusString];
		[self checkForDoneButton];
	}
    return YES;
}

#pragma mark - Alert
- (void)showAlertWithMessage:(NSString *)messageString
{
	[[[UIAlertView alloc] initWithTitle:kEmptyString message:messageString delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
	self.shouldShowWarning = YES;
}


@end
