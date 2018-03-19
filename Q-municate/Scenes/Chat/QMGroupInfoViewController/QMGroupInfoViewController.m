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
#import "QMNavigationController.h"
#import "QMGroupHeaderView.h"
#import "QMImagePreview.h"
#import "QMImagePicker.h"
#import "QMCore.h"

#import <NYTPhotoViewer/NYTPhotoViewer.h>
#import <QMChatViewController/QMImageView.h>

@interface QMGroupInfoViewController ()

< QMGroupHeaderViewDelegate, QMImagePickerResultHandler, QMChatServiceDelegate,
QMChatConnectionDelegate,NYTPhotosViewControllerDelegate >

@property (weak, nonatomic) QMGroupOccupantsViewController *groupOccupantsViewController;
@property (weak, nonatomic) IBOutlet QMGroupHeaderView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerViewTopConstraint;

@end

@implementation QMGroupInfoViewController

//MARK: - Life cycle

- (void)dealloc {
    
    QMLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView.delegate = self;
    [self updateGroupHeaderView];
    
    // subscribing for delegates
    [QMCore.instance.chatService addDelegate:self];
}

- (void)updateGroupHeaderView {
    
    [self.headerView setTitle:self.chatDialog.name avatarUrl:self.chatDialog.photo];
}

//MARK: - Actions

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

//MARK: - QMGroupHeaderViewDelegate

- (void)groupHeaderView:(QMGroupHeaderView *)__unused groupHeaderView didTapAvatar:(QMImageView *)avatarImageView {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_TAKE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          if (![QMCore.instance isInternetConnected]) {
                                                              
                                                              [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
                                                              return;
                                                          }
                                                          
                                                          [QMImagePicker takePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_CHOOSE_IMAGE", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull __unused action) {
                                                          
                                                          if (![QMCore.instance isInternetConnected]) {
                                                              
                                                              [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeWarning message:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil) duration:kQMDefaultNotificationDismissTime];
                                                              return;
                                                          }
                                                          
                                                          [QMImagePicker choosePhotoInViewController:self resultHandler:self];
                                                      }]];
    
    if (self.chatDialog.photo.length > 0) {
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"QM_STR_OPEN_IMAGE", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull __unused action) {
                                                              
                                                              [QMImagePreview previewImageWithURL:[NSURL URLWithString:self.chatDialog.photo] inViewController:self];
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

// MARK: - Overrides

- (void)setAdditionalNavigationBarHeight:(CGFloat)additionalNavigationBarHeight {
    CGFloat previousAdditionalNavigationBarHeight = self.additionalNavigationBarHeight;
    [super setAdditionalNavigationBarHeight:additionalNavigationBarHeight];
    
    self.headerViewTopConstraint.constant += additionalNavigationBarHeight - previousAdditionalNavigationBarHeight;
}

//MARK: - QMImagePickerResultHandler

- (void)imagePicker:(QMImagePicker *)__unused imagePicker didFinishPickingPhoto:(UIImage *)photo {
    
    [(QMNavigationController *)self.navigationController showNotificationWithType:QMNotificationPanelTypeLoading message:NSLocalizedString(@"QM_STR_LOADING", nil) duration:0];
    
    __weak UINavigationController *navigationController = self.navigationController;
    
    [[QMCore.instance.chatManager changeAvatar:photo forGroupChatDialog:self.chatDialog] continueWithBlock:^id(BFTask *task __unused) {
        
        [(QMNavigationController *)navigationController dismissNotificationPanel];
        
        return nil;
    }];
}

//MARK: - QMChatServiceDelegate

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

//MARK: - NYTPhotosViewControllerDelegate

- (UIView *)photosViewController:(NYTPhotosViewController *)__unused photosViewController referenceViewForPhoto:(id<NYTPhoto>)__unused photo {
    
    return self.headerView.avatarImage;
}

@end
