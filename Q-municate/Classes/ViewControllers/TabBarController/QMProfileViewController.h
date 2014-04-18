//
//  QMProfileViewController.h
//  Q-municate
//
//  Created by lysenko.mykhayl on 3/24/14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AsyncImageView.h>

@interface QMProfileViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBActionStatusDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet AsyncImageView *userPhotoImageView;
@property (nonatomic, weak) IBOutlet UITextField *userNameTextField;
@property (nonatomic, weak) IBOutlet UITextField *userMailTextField;
@property (nonatomic, weak) IBOutlet UIButton *chooseUserPhotoButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextView *userStatusTextView;

@end
