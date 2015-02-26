//
//  QMLicenseAgreement.m
//  Q-municate
//
//  Created by Andrey Ivanov on 26.08.14.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLicenseAgreement.h"
#import "QMLicenseAgreementViewController.h"
#import "QMServicesManager.h"

@implementation QMLicenseAgreement

+ (void)checkAcceptedUserAgreementInViewController:(UIViewController *)vc completion:(void(^)(BOOL success))completion {
    
    if (QM.profile.userAgreementAccepted) {
        
        if (completion) completion(YES);
    }
    else {
        
        QMLicenseAgreementViewController *licenceController =
        [vc.storyboard instantiateViewControllerWithIdentifier:@"QMLicenceAgreementControllerID"];
        
        licenceController.licenceCompletionBlock = completion;
        
        UINavigationController *navViewController =
        [[UINavigationController alloc] initWithRootViewController:licenceController];
        
        [vc presentViewController:navViewController
                         animated:YES
                       completion:nil];
    }
}

@end
