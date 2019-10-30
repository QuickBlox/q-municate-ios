//
//  QMLicenseAgreementViewController.m
//  Qmunicate
//
//  Created by Injoit on 10/07/2014.
//  Copyright © 2014 QuickBlox. All rights reserved.
//

#import "QMLicenseAgreementViewController.h"
#import "SVProgressHUD.h"
#import "QMCore.h"

NSString *const kQMAgreementUrl = @"https://q-municate.com/terms-of-use";

@interface QMLicenseAgreementViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptButton;

@end

@implementation QMLicenseAgreementViewController

- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL licenceAccepted = QMCore.instance.currentProfile.userAgreementAccepted;
    if (licenceAccepted) {
        
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kQMAgreementUrl]];
    [self.webView loadRequest:request];
}

- (IBAction)done:(id) sender {
    
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

- (IBAction)acceptLicense:(id) sender {
    
    QMCore.instance.currentProfile.userAgreementAccepted = YES;
    [self dismissViewControllerSuccess:YES];
}

//MARK: - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

@end
