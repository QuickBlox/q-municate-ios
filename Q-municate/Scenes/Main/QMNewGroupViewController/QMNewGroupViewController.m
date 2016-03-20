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
#import "REActionSheet.h"
#import <QMImageView.h>
#import "QMTagFieldView.h"
#import "QMCore.h"
#import "QMChatVC.h"
#import "QMContent.h"

@interface QMNewGroupViewController ()

<
QMImagePickerResultHandler,
QMImageViewDelegate,
QMGroupContactListViewControllerDelegate,
QMTagFieldViewDelegate
>

@property (weak, nonatomic) QMGroupContactListViewController *groupContactListViewController;

@property (weak, nonatomic) IBOutlet QMImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet QMTagFieldView *tagFieldView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@property (strong, nonatomic) UIImage *selectedImage;
@property (weak, nonatomic) BFTask *dialogCreationTask;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagFieldViewHeightConstraint;

@end

@implementation QMNewGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nextButton.enabled = NO;
    
    // setting up avatar image view
    self.avatarImageView.imageViewType = QMImageViewTypeCircle;
    self.avatarImageView.delegate = self;
    
    // setting up name text field
    self.nameTextField.placeholder = NSLocalizedString(@"QM_STR_NAME_FIELD_PLACEHOLDER", nil);
    
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
    
    if (self.selectedImage != nil) {
        
        self.dialogCreationTask = [[QMContent uploadJPEGImage:self.selectedImage progress:nil] continueWithSuccessBlock:^id _Nullable(BFTask<QBCBlob *> * _Nonnull task) {
            
            [self.avatarImageView setImage:self.avatarImageView.image withKey:task.result.publicUrl];
            return [self createGroupChatWithPhotoURL:task.result.publicUrl];
        }];
    }
    else {
        
        self.dialogCreationTask = [self createGroupChatWithPhotoURL:nil];
    }
}

- (BFTask *)createGroupChatWithPhotoURL:(NSString *)photoURL {
    
    NSArray *occupantsIDs = [[QMCore instance] idsOfUsers:self.tagFieldView.tagIDs];
    __block QBChatDialog *chatDialog = nil;
    
    return [[[[QMCore instance].chatService createGroupChatDialogWithName:self.nameTextField.text photo:photoURL occupants:self.tagFieldView.tagIDs] continueWithSuccessBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
        
        chatDialog = task.result;
        [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
        
        return [[QMCore instance].chatService sendSystemMessageAboutAddingToDialog:chatDialog toUsersIDs:occupantsIDs];
        
    }] continueWithBlock:^id _Nullable(BFTask * _Nonnull __unused task) {
        
        return [[QMCore instance].chatService sendNotificationMessageAboutAddingOccupants:occupantsIDs toDialog:chatDialog withNotificationText:kQMDialogsUpdateNotificationMessage];
    }];
}

- (IBAction)nameFieldDidChange:(UITextField *)__unused sender {
    
    [self updateNextButtonState];
}

- (void)imageViewDidTap:(QMImageView *)__unused imageView {
    
    [REActionSheet presentActionSheetInView:self.view configuration:^(REActionSheet *actionSheet) {
        
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
    
    self.nextButton.enabled = nextAllowed;
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

@end
