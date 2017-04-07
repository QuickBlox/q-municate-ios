//
//  QMLicenseAgreementViewController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 10/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLicenseAgreementViewController.h"
#import <SVProgressHUD.h>
#import "QMCore.h"

NSString *const kQMAgreementUrl = @"http://q-municate.com/agreement";

@interface QMLicenseAgreementViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptButton;

@end

@implementation QMLicenseAgreementViewController

- (void)dealloc {
    
    ILog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL licenceAccepted = [QMCore instance].currentProfile.userAgreementAccepted;
    if (licenceAccepted) {
        
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kQMAgreementUrl]];
    [self.webView loadRequest:request];
}

- (IBAction)done:(id)__unused sender {
    
    [self dismissViewControllerSuccess:NO];
}

- (void)dismissViewControllerSuccess:(BOOL)success {
    
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        
        @strongify(self);
        if (self.licenceCompletionBlock) {
            
            self.licenceCompletionBlock(success);
            self.licenceCompletionBlock = nil;
        }
    }];
}

- (IBAction)acceptLicense:(id)__unused sender {
    
    [QMCore instance].currentProfile.userAgreementAccepted = YES;
    [self dismissViewControllerSuccess:YES];
}

//MARK: - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)__unused webView {
    
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)__unused webView didFailLoadWithError:(NSError *)error {
    
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

@end
