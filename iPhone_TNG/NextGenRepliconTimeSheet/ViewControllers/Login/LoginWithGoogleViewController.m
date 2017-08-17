//
//  LoginWithGoogleViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 25/11/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "LoginWithGoogleViewController.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface LoginWithGoogleViewController ()

@end

@implementation LoginWithGoogleViewController
@synthesize urlString;
@synthesize webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Util setToolbarLabel:self withText: RPLocalizedString(SIGN_IN_WITH_GOOGLE, SIGN_IN_WITH_GOOGLE) ];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    // load view
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];

}



- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
