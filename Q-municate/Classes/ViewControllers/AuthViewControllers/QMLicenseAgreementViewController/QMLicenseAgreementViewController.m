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

NSString *const kQMAgreementUrl = @"http://q-municate.com/agreement";

@interface QMLicenseAgreementViewController ()

<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation QMLicenseAgreementViewController

- (void)dealloc {
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [SVProgressHUD show];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kQMAgreementUrl]];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
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
