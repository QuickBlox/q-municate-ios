//
//  QMNewMessageViewController.m
//  Q-municate
//
//  Created by Vitaliy Gorbachov on 3/15/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import "QMNewMessageViewController.h"
#import "QMMessageContactListViewController.h"

#import "QMTagFieldView.h"
#import "QMCore.h"
#import "QMChatVC.h"
#import "QMHelpers.h"
#import "SVProgressHUD.h"

@interface QMNewMessageViewController ()

<
QMMessageContactListViewControllerDelegate,
QMTagFieldViewDelegate
>

@property (weak, nonatomic) QMMessageContactListViewController *messageContactListViewController;

@property (weak, nonatomic) IBOutlet QMTagFieldView *tagFieldView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagFieldViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagFieldViewTopConstraint;

@property (weak, nonatomic) BFTask *dialogCreationTask;

@end

@implementation QMNewMessageViewController

//MARK: - Lifecycle

- (void)dealloc {
    
    QMLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    
    // removing left bar button item that is responsible for split view
    // display mode managing. Not removing it will cause item update
    // for deallocated navigation item
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    // configuring tag field
    self.tagFieldView.placeholder = NSLocalizedString(@"QM_STR_TAG_FIELD_PLACEHOLDER", nil);
    self.tagFieldView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tagFieldView.delegate = self;
}

//MARK: - Actions

- (IBAction)rightBarButtonPressed:(UIBarButtonItem *)__unused sender {
    
    if (self.dialogCreationTask) {
        // task is in progress
        return;
    }
    
    NSArray *tagIDs = [self.tagFieldView tagIDs];
    
    if (![QMCore.instance isInternetConnected]) {
         [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"QM_STR_CHECK_INTERNET_CONNECTION", nil)];
        return;
    }
    
    if (tagIDs.count > 1) {
        // creating group chat
        
        NSArray *fullNames = [tagIDs valueForKeyPath:qm_keypath(QBUUser, fullName)];
        NSString *name = [fullNames componentsJoinedByString:@", "];
        NSArray *occupantsIDs = [QMCore.instance.contactManager idsOfUsers:tagIDs];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
        
        __block QBChatDialog *chatDialog = nil;
        
        @weakify(self);
        self.dialogCreationTask = [[[QMCore.instance.chatService createGroupChatDialogWithName:name photo:nil occupants:tagIDs] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
            
            [SVProgressHUD dismiss];
            @strongify(self);            
            if (!task.isFaulted) {
                
                chatDialog = task.result;
                [self performSegueWithIdentifier:kQMSceneSegueChat sender:chatDialog];
                [self removeControllerFromStack];
                
                return [QMCore.instance.chatService sendSystemMessageAboutAddingToDialog:chatDialog toUsersIDs:occupantsIDs withText:kQMDialogsUpdateNotificationMessage];
                
            }

            return [BFTask cancelledTask];
            
        }] continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            return task.isCancelled ? nil : [QMCore.instance.chatService sendNotificationMessageAboutAddingOccupants:occupantsIDs toDialog:chatDialog withNotificationText:kQMDialogsUpdateNotificationMessage];
        }];
    }
    else {
        // creating or opening private chat
        QBUUser *user = tagIDs.firstObject;
        QBChatDialog *privateDialog = [QMCore.instance.chatService.dialogsMemoryStorage privateChatDialogWithOpponentID:user.ID];
        
        if (privateDialog != nil) {
            
            [self performSegueWithIdentifier:kQMSceneSegueChat sender:privateDialog];
            [self removeControllerFromStack];
        }
        else {
            [SVProgressHUD showWithStatus:NSLocalizedString(@"QM_STR_LOADING", nil)];
            
            @weakify(self);
            self.dialogCreationTask = [[QMCore.instance.chatService createPrivateChatDialogWithOpponent:user] continueWithBlock:^id _Nullable(BFTask<QBChatDialog *> * _Nonnull task) {
                
                @strongify(self);
                [SVProgressHUD dismiss];
                
                if (!task.isFaulted) {
                    
                    [self performSegueWithIdentifier:kQMSceneSegueChat sender:task.result];
                    [self removeControllerFromStack];
                }
                
                return nil;
            }];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        UINavigationController *chatNavigationController = segue.destinationViewController;
        QMChatVC *chatViewController = (QMChatVC *)chatNavigationController.topViewController;
        chatViewController.chatDialog = sender;
    }
    else if ([segue.identifier isEqualToString:kQMSceneSegueNewMessageContactList]) {
        
        self.messageContactListViewController = segue.destinationViewController;
        self.messageContactListViewController.delegate = self;
    }
}

- (void)updateNextButtonState {
    
    BOOL nextAllowed = [self.tagFieldView tagIDs].count > 0;
    self.navigationItem.rightBarButtonItem.enabled = nextAllowed;
}

// MARK: - Overrides

- (void)setAdditionalNavigationBarHeight:(CGFloat)additionalNavigationBarHeight {
    CGFloat previousAdditionalNavigationBarHeight = self.additionalNavigationBarHeight;
    [super setAdditionalNavigationBarHeight:additionalNavigationBarHeight];
    
    self.tagFieldViewTopConstraint.constant += additionalNavigationBarHeight - previousAdditionalNavigationBarHeight;
}

//MARK: - QMMessageContactListViewControllerDelegate

- (void)messageContactListViewController:(QMMessageContactListViewController *)__unused messageContactListViewController didDeselectUser:(QBUUser *)deselectedUser {
    
    [self.tagFieldView removeTagWithID:deselectedUser];
    [self updateNextButtonState];
}

- (void)messageContactListViewController:(QMMessageContactListViewController *)__unused messageContactListViewController didSelectUser:(QBUUser *)selectedUser {
    
    [self.tagFieldView addTag:selectedUser.fullName tagID:selectedUser animated:YES];
    [self.tagFieldView scrollToTextField:YES];
    [self.tagFieldView clearText];
    
    [self updateNextButtonState];
}

- (void)messageContactListViewController:(QMMessageContactListViewController *)__unused messageContactListViewController didScrollContactList:(UIScrollView *)__unused scrollView {
    
    [self.view endEditing:YES];
}

//MARK: - QMTagFieldViewDelegate

- (void)tagFieldView:(QMTagFieldView *)__unused tagFieldView didDeleteTagWithID:(id)tagID {
    
    [self.messageContactListViewController deselectUser:tagID];
    
    [self updateNextButtonState];
}

- (void)tagFieldView:(QMTagFieldView *)__unused tagFieldView didChangeHeight:(CGFloat)height {
    
    self.tagFieldViewHeightConstraint.constant = height;
}

- (void)tagFieldView:(QMTagFieldView *)__unused tagFieldView didChangeText:(NSString *)text {
    
    [self.messageContactListViewController performSearch:text];
}

- (void)tagFieldView:(QMTagFieldView *)__unused tagFieldView didChangeSearchStatus:(BOOL)__unused searchIsActive byClearingTextField:(BOOL)byClearingTextField {
    
    if (!byClearingTextField) {
        
        [self.messageContactListViewController performSearch:@""];
    }
}

//MARK: - Helpers

- (void)removeControllerFromStack {
    
    if (self.splitViewController.isCollapsed) {
        
        removeControllerFromNavigationStack(self.navigationController, self);
    }
    else {
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
