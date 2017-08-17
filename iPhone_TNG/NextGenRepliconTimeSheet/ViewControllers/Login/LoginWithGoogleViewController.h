//
//  LoginWithGoogleViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 25/11/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginWithGoogleViewController : UIViewController <UIWebViewDelegate>


@property (nonatomic,strong)   NSString                *urlString;
@property (strong, nonatomic)  UIWebView               *webView;
@end
