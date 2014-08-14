//
//  QMLicenseAgreementViewController.m
//  Qmunicate
//
//  Created by Igor Alefirenko on 10/07/2014.
//  Copyright (c) 2014 Quickblox. All rights reserved.
//

#import "QMLicenseAgreementViewController.h"
#import <SVProgressHUD.h>
#import "REAlertView.h"
#import "QMApi.h"
#import "QMSettingsManager.h"

NSString *const kQMAgreementUrl = @"http://q-municate.com/agreement";

@interface QMLicenseAgreementViewController ()

<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *acceptButton;
@property (assign, nonatomic) BOOL licenceAccepted;

@end

@implementation QMLicenseAgreementViewController


- (void)dealloc
{
    if (self.licenceCompletionBlock) {
        self.licenceCompletionBlock(self.licenceAccepted);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:NO];
    
    // fast fix:
    _licenceAccepted = [[QMApi instance].settingsManager userAgreementAccepted];
    if (_licenceAccepted) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [SVProgressHUD show];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kQMAgreementUrl]];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (IBAction)acceptLicense:(id)sender
{
    [[QMApi instance].settingsManager setUserAgreementAccepted:YES];
    self.licenceAccepted = YES;
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [SVProgressHUD dismiss];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
