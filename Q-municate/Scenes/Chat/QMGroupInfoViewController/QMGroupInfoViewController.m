//
//  QMGroupInfoViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 4/5/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMGroupInfoViewController.h"
#import "QMGroupOccupantsViewController.h"
#import "QMGroupHeaderView.h"
#import "QMCore.h"
#import "UINavigationController+QMNotification.h"

#import "QMPlaceholder.h"
#import "QMImagePicker.h"
#import <QMImageView.h>

@interface QMGroupInfoViewController ()

<
QMGroupHeaderViewDelegate,
QMImagePickerResultHandler
>

@property (weak, nonatomic) QMGroupOccupantsViewController *groupOccupantsViewController;
@property (weak, nonatomic) IBOutlet QMGroupHeaderView *headerView;

@property (weak, nonatomic) QMImageView *avatarImageView;

@end

@implementation QMGroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView.delegate = self;
    [self.headerView setTitle:self.chatDialog.name avatarUrl:self.chatDialog.photo placeholderID:self.chatDialog.ID.hash];
}

#pragma mark - Actions

- (IBAction)didPressGroupHeader {
    
#warning TODO: open base viewcontroller with one field edit
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:KQMSceneSegueGroupOccupants]) {
        
        self.groupOccupantsViewController = segue.destinationViewController;
        self.groupOccupantsViewController.chatDialog = self.chatDialog;
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

@end
