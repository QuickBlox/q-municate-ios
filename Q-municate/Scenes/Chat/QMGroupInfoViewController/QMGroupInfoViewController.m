//
//  QMGroupInfoViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupInfoViewController.h"
#import "QMGroupOccupantsViewController.h"
#import "QMGroupNameViewController.h"
#import "QMGroupHeaderView.h"
#import "QMCore.h"
#import "UINavigationController+QMNotification.h"

#import "QMPlaceholder.h"
#import "QMImagePicker.h"
#import <QMImageView.h>

#import <NYTPhotoViewer/NYTPhotosViewController.h>
#import "QMImagePreview.h"

@interface QMGroupInfoViewController ()

<
QMGroupHeaderViewDelegate,
QMImagePickerResultHandler,

QMChatServiceDelegate,
QMChatConnectionDelegate,

NYTPhotosViewControllerDelegate
>

@property (weak, nonatomic) QMGroupOccupantsViewController *groupOccupantsViewController;
@property (weak, nonatomic) IBOutlet QMGroupHeaderView *headerView;

@end

@implementation QMGroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView.delegate = self;
    [self updateGroupHeaderView];
    
    // subscribing for delegates
    [[QMCore instance].chatService addDelegate:self];
}

- (void)updateGroupHeaderView {
    
    [self.headerView setTitle:self.chatDialog.name avatarUrl:self.chatDialog.photo placeholderID:self.chatDialog.ID.hash];
}

#pragma mark - Actions

- (IBAction)didPressGroupHeader {
    
    [self performSegueWithIdentifier:kQMSceneSegueGroupName sender:self.chatDialog];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:KQMSceneSegueGroupOccupants]) {
        
        self.groupOccupantsViewController = segue.destinationViewController;
        self.groupOccupantsViewController.chatDialog = self.chatDialog;
    }
    else if ([segue.identifier isEqualToString:kQMSceneSegueGroupName]) {
        
        QMGroupNameViewController *groupNameVC = segue.destinationViewController;
        groupNameVC.chatDialog = sender;
    }
}

#pragma mark - QMGroupHeaderViewDelegate

- (void)groupHeaderView:(QMGroupHeaderView *)__unused groupHeaderView didTapAvatar:(QMImageView *)avatarImageView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker takePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          [QMImagePicker choosePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    if (self.chatDialog.photo.length > 0) {
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_OPEN_IMAGE", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
                                                              
                                                              [QMImagePreview previewImageView:self.headerView.avatarImage inViewController:self];
                                                          }]];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CANCEL", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:nil]];
    
    if (alertController.popoverPresentationController) {
        // iPad support
        alertController.popoverPresentationController.sourceView = avatarImageView;
        alertController.popoverPresentationController.sourceRect = avatarImageView.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    [self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    [[[QMCore instance].chatManager changeAvatar:photo forGroupChatDialog:self.chatDialog] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        [navigationController dismissNotificationPanel];
        if (!task.isFaulted) {
            
            [self.headerView.avatarImage setImage:photo withKey:self.chatDialog.photo];
        }
        
        return nil;
    }];
}

#pragma mark - QMChatServiceDelegate

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    
    if ([chatDialog isEqual:self.chatDialog]) {
        
        [self updateGroupHeaderView];
    }
}

- (void)chatService:(QMChatService *)__unused chatService didUpdateChatDialogsInMemoryStorage:(NSArray<QBChatDialog *> *)dialogs {
    
    if ([dialogs containsObject:self.chatDialog]) {
        
        [self updateGroupHeaderView];
    }
}

#pragma mark - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.headerView.avatarImage;
}

@end
