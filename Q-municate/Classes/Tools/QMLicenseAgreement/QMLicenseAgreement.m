//
//  QMLicenseAgreement.m
//  Q-municate
//
//  Created by Injoit on 26.08.14.
//  Copyright © 2014 QuickBlox. All rights reserved.
//

#import "QMLicenseAgreement.h"
#import "QMCore.h"
#import "QMLicenseAgreementViewController.h"

@implementation QMLicenseAgreement

+ (void)checkAcceptedUserAgreementInViewController:(UIViewController *)vc completion:(void(^)(BOOL success))completion {
    
    BOOL licenceAccepted = QMCore.instance.currentProfile.userAgreementAccepted;
    
    if (licenceAccepted) {
        
        if (completion) completion(YES);
    }
    else {
        
        [self presentUserAgreementInViewController:vc completion:completion];
    }
}

+ (void)presentUserAgreementInViewController:(UIViewController *)vc completion:(void(^)(BOOL success))completion {
    
    QMLicenseAgreementViewController *licenceController =
    [vc.storyboard instantiateViewControllerWithIdentifier:@"QMLicenceAgreementControllerID"];
    
    licenceController.licenceCompletionBlock = completion;
    
    UINavigationController *navViewController =
    [[UINavigationController alloc] initWithRootViewController:licenceController];
    
    [vc presentViewController:navViewController
                     animated:YES
                   completion:nil];
}

@end
