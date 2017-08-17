//
//  TermsOfServiceViewController.m
//  Replicon
//
//  Created by Abhishek Nimbalkar on 5/6/14.
//  Copyright (c) 2014 Replicon INC. All rights reserved.
//

#import "TermsOfServiceViewController.h"
#import "Constants.h"
#import "Util.h"

#define TERMS_LINK @"http://www.replicon.com/mobile-app-terms-service"

@interface TermsOfServiceViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation TermsOfServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Util setToolbarLabel:self withText: RPLocalizedString(TermsOfServiceTabbarTitle, @"") ];

    
    // load terms
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:TERMS_LINK]]];
//    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    /*if (version<7.0)
    {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];}*/
    self.navigationItem.backBarButtonItem = nil;
    }
     


/*-(void) viewDidLayoutSubviews
{
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    if (version<7.0)
    {
        CGRect tmpFram = self.navigationController.navigationBar.frame;
        tmpFram.origin.y += 20;
        self.navigationController.navigationBar.frame = tmpFram;
    }
}*/


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activityIndicator stopAnimating];
}


@end
