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
#import "QMAuthService.h"
#import "QMUtilities.h"


static NSUInteger const QM_MAX_STATUS_TEXT_LENGTH = 43;

// text field tags:
static NSUInteger const kFullNameFieldTag = 11;
static NSUInteger const kPhoneNumberFieldTag = 12;


@interface QMProfileViewController () <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet AsyncImageView *avatarView;
@property (weak, nonatomic) IBOutlet UITextField *fullNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextView *statusField;

@property (nonatomic, strong) QBUUser *me;

/** Field cache. */
@property (nonatomic, copy) NSString *fieldCacheString;

@end


@implementation QMProfileViewController
@synthesize me;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureAvatarView];
    
    me = [QMContactList shared].me;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // update profile screen:
    [self updateProfileView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)configureAvatarView
{
    self.avatarView.layer.cornerRadius = self.avatarView.frame.size.width / 2;
    self.avatarView.layer.borderWidth = 2.0f;
    self.avatarView.layer.borderColor = [UIColor colorWithRed:1/215 green:1/216 blue:1/215 alpha:0.04].CGColor;   //215,216,215
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.crossfadeDuration = 0.0f;
}

- (void)updateProfileView
{
    // avatar:
    [self.avatarView setImageURL:[NSURL URLWithString:me.website]];
    
    // full name:
    [self.fullNameField setText:me.fullName];
    
    // email:
    [self.emailField setText:me.email];
    
    // phone number:
    [self.phoneNumberField setText:me.phone];
    
    // status:
}

- (IBAction)updateRecord:(id)sender
{
    [sender resignFirstResponder];
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // caching string:
    _fieldCacheString = textField.text;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // check for field update:
    if ([_fieldCacheString isEqualToString:textField.text]) {
        return;
    }
    
    [QMUtilities createIndicatorView];
    // update user's modified field:
    if (textField.tag == kFullNameFieldTag) {
        me.fullName = textField.text;
    } else if (textField.tag == kPhoneNumberFieldTag) {
        me.phone = textField.text;
    }
    [[QMAuthService shared] updateUser:me withCompletion:^(QBUUser *user, BOOL success, NSError *error) {
        [QMUtilities removeIndicatorView];
        
        if (!success) {
            [[[UIAlertView alloc] initWithTitle:kAlertTitleErrorString message:error.description delegate:nil cancelButtonTitle:kAlertButtonTitleOkString otherButtonTitles:nil] show];
            return;
        }
        self.me = user;
        [self updateProfileView];
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
}

@end
