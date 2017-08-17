//
//  BaseNavigationController.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 5/5/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "BaseNavigationController.h"
#import "ErrorBannerViewController.h"
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"
#import "AppDelegate.h"

@interface BaseNavigationController ()

@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];


}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self presentErrorBanner];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (appDelegate.isWaitingForDeepLinkToErrorDetails)
    {
        appDelegate.isWaitingForDeepLinkToErrorDetails = NO;
        [appDelegate launchErrorDetailsViewController];
    }

}

-(void)presentErrorBanner
{
    ErrorBannerViewController *errorBannerViewController = [self.injector getInstance:InjectorKeyErrorBannerViewController];

    [errorBannerViewController presentErrorDetailsControllerOnParentController:self withTabBarcontroller:self.tabBarController];
}

@end
