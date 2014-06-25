//
//  QMChangePasswordVC.m
//  Qmunicate
//
//  Created by Andrey on 24.06.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMChangePasswordVC.h"

@interface QMChangePasswordVC ()

@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic, getter = theNewPasswordTextField) IBOutlet UITextField *newPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;

@end

@implementation QMChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - actions

- (IBAction)pressChangeButton:(id)sender {
    
}

//- (void)changePassword
//{
//    // first stage:
//    [self showAlertWithTitle:kAlertTitleEnterPasswordString message:nil];
//}
//
//UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:kAlertTitleAreYouSureString
//                              //                                                             delegate:self
//                              //                                                    cancelButtonTitle:kAlertButtonTitleCancelString
//                              //                                               destructiveButtonTitle:kAlertButtonTitleLogOutString
//                              //


//typedef NS_ENUM(NSUInteger, QMPasswordCheckState) {
//    QMPasswordCheckStateNone,
//    QMPasswordCheckStateInputed,
//    QMPasswordCheckStateConfirmed
//};


@end
