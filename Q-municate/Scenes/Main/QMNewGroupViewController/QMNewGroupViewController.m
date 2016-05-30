//
//  QMNewGroupViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/18/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNewGroupViewController.h"
#import "QMGroupContactListViewController.h"
#import "QMImagePicker.h"
#import <QMImageView.h>
#import "QMTagFieldView.h"
#import "QMCore.h"
#import "UINavigationController+QMNotification.h"
#import "QMChatVC.h"
#import "QMContent.h"

static const CGFloat kQMNameFieldRightPadding = 12.0f;

@interface QMNewGroupViewController ()

<
QMImagePickerResultHandler,
QMImageViewDelegate,
QMGroupContactListViewControllerDelegate,
QMTagFieldViewDelegate,
UITextFieldDelegate
>

@property (weak, nonatomic) QMGroupContactListViewController *groupContactListViewController;

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet QMTagFieldView *tagFieldView;

@property (strong, nonatomic) UIImage *selectedImage;
@property (weak, nonatomic) BFTask *dialogCreationTask;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagFieldViewHeightConstraint;

@end

@implementation QMNewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // setting up avatar image view
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    self.avatarImageView.delegate = self;
    
    // setting up name text field
    self.nameTextField.placeholder = NSLocalizedString(@"QM_STR_NAME_FIELD_PLACEHOLDER", nil);
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   kQMNameFieldRightPadding,
                                                                   CGRectGetHeight(self.nameTextField.frame))];
    self.nameTextField.rightView = paddingView;
    self.nameTextField.rightViewMode = UITextFieldViewModeAlways;
    // subscribing to delegate in order to hide keyboard on return
    self.nameTextField.delegate = self;
    
    // tag field
    self.tagFieldView.placeholder = NSLocalizedString(@"QM_STR_TAG_FIELD_PLACEHOLDER", nil);
    self.tagFieldView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tagFieldView.delegate = self;
}

#pragma mark - Actions

- (IBAction)nextButtonPressed:(id)__unused sender {
    
    if (self.dialogCreationTask) {
        // task is in progress
        return;
    }
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    if (self.selectedImage != nil) {
        
        __weak UINavigationController *navigationController = self.navigationController;
        
        self.dialogCreationTask = [[QMContent uploadJPEGImage:self.selectedImage progress:nil] continueWithBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull task) {
            
            if (!task.isFaulted) {
                
                [self.avatarImageView setImage:self.avatarImageView.image withKey:task.result.publicUrl];
                return [self createGroupChatWithPhotoURL:task.result.publicUrl];
            }
            else {
                
                [navigationController dismissNotificationPanel];
                return nil;
            }
        }];
    }
    else {
        
        self.dialogCreationTask = [self createGroupChatWithPhotoURL:nil];
    }
}

- (BFTask *)createGroupChatWithPhotoURL:(NSString *)photoURL {
    
    NSArray *occupantsIDs = [[QMCore instance].contactManager idsOfUsers:self.tagFieldView.tagIDs];
    __block QBChatDialog *chatDialog = nil;
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    @weakify(self);
    return [[[[QMCore instance].chatService createGroupChatDialogWithName:self.nameTextField.text photo:photoURL occupants:self.tagFieldView.tagIDs] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        @strongify(self);
        [navigationController dismissNotificationPanel];
        
        if (!task.isFaulted) {
            
            chatDialog = task.result;
            [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
            
            return [[QMCore instance].chatService sendSystemMessageAboutAddingToDialog:chatDialog toUsersIDs:occupantsIDs withText:kQMDialogsUpdateNotificationMessage];
            
        }
        
        return [BFTask cancelledTask];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        return task.isCancelled ? nil : [[QMCore instance].chatService sendNotificationMessageAboutAddingOccupants:occupantsIDs toDialog:chatDialog withNotificationText:kQMDialogsUpdateNotificationMessage];
    }];
}

- (IBAction)nameFieldDidChange:(UITextField *)__unused sender {
    
    [self updateNextButtonState];
}

- (void)imageViewDidTap:(QMImageView *)imageView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker takePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_FROM_LIBRARY", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker choosePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = imageView;
        alertController.popoverPresentationController.sourceRect = imageView.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMChatVC *chatViewController = segue.destinationViewController;
        chatViewController.chatDialog = sender;
    }
    else if ([segue.identifier isEqualToString:kQMSceneSegueGroupContactList]) {
        
        self.groupContactListViewController = segue.destinationViewController;
        self.groupContactListViewController.delegate = self;
    }
}

- (void)updateNextButtonState {
    
    BOOL nextAllowed = self.tagFieldView.tagIDs.count > 0 && self.nameTextField.text.length > 0;
    
    self.navigationItem.rightBarButtonItem.enabled = nextAllowed;
}

#pragma mark - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    self.selectedImage = photo;
    [self.avatarImageView applyImage:photo];
}

#pragma mark - QMGroupContactListViewControllerDelegate

- (void)groupContactListViewController:(QMGroupContactListViewController *)__unused groupContactListViewController didDeselectUser:(QBUUser *)deselectedUser {
    
    [self.tagFieldView removeTagWithID:deselectedUser];
    
    [self updateNextButtonState];
}

- (void)groupContactListViewController:(QMGroupContactListViewController *)__unused groupContactListViewController didSelectUser:(QBUUser *)selectedUser {
    
    [self.tagFieldView addTag:selectedUser.fullName tagID:selectedUser animated:YES];
    [self.tagFieldView scrollToTextField:YES];
    [self.tagFieldView clearText];
    
    [self updateNextButtonState];
}

- (void)groupContactListViewController:(QMGroupContactListViewController *)__unused groupContactListViewController didScrollContactList:(UIScrollView *)__unused scrollView {
    
    [self.view endEditing:YES];
}

#pragma mark - QMTagFieldViewDelegate

- (void)tagFieldView:(QMTagFieldView *)__unused tagFieldView didDeleteTagWithID:(id)tagID {
    
    [self.groupContactListViewController deselectUser:tagID];
    
    [self updateNextButtonState];
}

- (void)tagFieldView:(QMTagFieldView *)__unused tagFieldView didChangeHeight:(CGFloat)height {
    
    self.tagFieldViewHeightConstraint.constant = height;
}

- (void)tagFieldView:(QMTagFieldView *)__unused tagFieldView didChangeText:(NSString *)text {
    
    [self.groupContactListViewController performSearch:text];
}

- (void)tagFieldView:(QMTagFieldView *)__unused tagFieldView didChangeSearchStatus:(BOOL)__unused searchIsActive byClearingTextField:(BOOL)byClearingTextField {
    
    if (!byClearingTextField) {
        
        [self.groupContactListViewController performSearch:@""];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // hiding keyboard for chat name text field
    [textField resignFirstResponder];
    return YES;
}

@end
