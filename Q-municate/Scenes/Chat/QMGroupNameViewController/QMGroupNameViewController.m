//
//  QMGroupNameViewController.m
//  Q-municate
//
//  Created by Injoit on 5/23/16.
//  Copyright © 2016 QuickBlox. All rights reserved.
//

#import "QMGroupNameViewController.h"
#import "QMCore.h"
#import "QMNavigationController.h"

@interface QMGroupNameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;

@end

@implementation QMGroupNameViewController

- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.groupNameField.text = self.chatDialog.name;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.groupNameField becomeFirstResponder];
}

//MARK: - Actions

- (IBAction)saveButtonPressed:(UIBarButtonItem *)sender {
    
    QMNavigationController *navigationController = (id)self.navigationController;
    
    [navigationController showNotificationWithType:QMNotificationPanelTypeLoading
                                           message:NSLocalizedString(@"QM_STR_LOADING", nil)
                                          duration:0];
    
    [[QMCore.instance.chatManager changeName:self.groupNameField.text forGroupChatDialog:self.chatDialog]
     continueWithBlock:^id(BFTask *task) {
         
         [navigationController dismissNotificationPanel];
         
         if (!task.isFaulted) {
             [navigationController popViewControllerAnimated:YES];
         }
         
         return nil;
     }];
}

- (IBAction)groupNameFieldEditingChanged:(UITextField *)sender {
    
    NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceCharacterSet];
    if ([sender.text stringByTrimmingCharactersInSet:whiteSpaceSet].length == 0
        || [sender.text isEqualToString:self.chatDialog.name]) {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        return;
    }
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

@end
