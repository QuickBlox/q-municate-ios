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
#import "UINavigationController+QMNotification.h"
#import "QMChatVC.h"

@interface QMNewMessageViewController ()

<
QMMessageContactListViewControllerDelegate,
QMTagFieldViewDelegate
>

@property (weak, nonatomic) QMMessageContactListViewController *messageContactListViewController;

@property (weak, nonatomic) IBOutlet QMTagFieldView *tagFieldView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagFieldViewHeightConstraint;

@property (weak, nonatomic) BFTask *dialogCreationTask;

@end

@implementation QMNewMessageViewController

#pragma mark - Lifecycle

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // configuring tag field
    self.tagFieldView.placeholder = NSLocalizedString(@"QM_STR_TAG_FIELD_PLACEHOLDER", nil);
    self.tagFieldView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.tagFieldView.delegate = self;
}

#pragma mark - Actions

- (IBAction)rightBarButtonPressed:(UIBarButtonItem *)__unused sender {
    
    if (self.dialogCreationTask) {
        // task is in progress
        return;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:kQMSceneSegueChat]) {
        
        QMChatVC *chatViewController = segue.destinationViewController;
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

#pragma mark - QMMessageContactListViewControllerDelegate

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

#pragma mark - QMTagFieldViewDelegate

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

@end
