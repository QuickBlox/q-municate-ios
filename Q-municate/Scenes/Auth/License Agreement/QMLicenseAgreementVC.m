//
//  QMLicenseAgreementViewController.m
//  Q-municate
//
//  Created by Igor Alefirenko on 10/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLicenseAgreementVC.h"
#import <SVProgressHUD.h>
#import "REAlertView.h"
#import "QMServicesManager.h"

NSString *const kQMAgreementUrl = @"http://q-municate.com/agreement";

@interface QMLicenseAgreementViewController ()

<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptButton;

@end

@implementation QMLicenseAgreementViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL licenceAccepted = QM.profile.userAgreementAccepted;
    
    if (licenceAccepted) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [SVProgressHUD show];
    
    NSURL *licenseUrl = [NSURL URLWithString:kQMAgreementUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:licenseUrl];
    [self.webView loadRequest:request];
}

- (IBAction)done:(id)sender {
    
    [self dismissViewControllerSuccess:NO];
}

- (void)dismissViewControllerSuccess:(BOOL)success {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if(self.licenceCompletionBlock) {
            
            self.licenceCompletionBlock(success);
            self.licenceCompletionBlock = nil;
        }
    }];
}

- (IBAction)acceptLicense:(id)sender {
    
    QM.profile.userAgreementAccepted = YES;
    [self dismissViewControllerSuccess:YES];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

@end
