//
//  AppRatingViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 04/08/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RateView.h"
#import <MessageUI/MessageUI.h>
#import "Constants.h"



@interface AppRatingViewController : UIViewController<RateViewDelegate, MFMailComposeViewControllerDelegate>
{
    
}
@property (strong, nonatomic) RateView *rateView;
@property(nonatomic,assign) float appRatingValue;
@property(nonatomic,weak) id delegate;
@property (strong, nonatomic) UIView *appRateView;
@property (strong, nonatomic) UIImageView *customPopUpView;
-(void)showAppRatingView;
@end
