//
//  AppRatingViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 04/08/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "AppRatingViewController.h"
#import "AppDelegate.h"

@interface AppRatingViewController ()

@end

@implementation AppRatingViewController
@synthesize delegate;
@synthesize rateView;
@synthesize appRatingValue;
@synthesize appRateView;
@synthesize customPopUpView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    [self showAppRatingView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showAppRatingView
{
    self.rateView = [[RateView alloc] init];
    
    self.rateView.notSelectedImage = [UIImage imageNamed:@"icon_ratingStar.png"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"icon_ratingStarSelected.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"icon_ratingStarSelected.png"];
    self.rateView.rating = 0;
    self.rateView.editable = YES;
    self.rateView.maxRating = 5;
    self.rateView.delegate = delegate;
    
    
    
    
    appRateView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    appRateView.backgroundColor = [UIColor blackColor];
    appRateView.alpha = 0.4;
    
    float y_offset = 125;
    float button_common_width = 290;
    float button_common_height = 44;
    
    UIImage *signUpOriginalImage = [UIImage imageNamed:@"bg_customAlertDialog.png"];
    UIEdgeInsets signUpInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    UIImage *signUpStretchableImage = [signUpOriginalImage resizableImageWithCapInsets:signUpInsets];
    
    customPopUpView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-button_common_width)/2, (SCREEN_HEIGHT/2)- 130, button_common_width, 260)];
    [customPopUpView setImage:signUpStretchableImage];
    customPopUpView.userInteractionEnabled = YES;
    
    float stringHeight = [self getHeightForString:RATE_APP_TEXT fontSize:14 forWidth:290];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 290, stringHeight)];
    msgLabel.text = RPLocalizedString(RATE_APP_TEXT, @"");
    msgLabel.backgroundColor = [UIColor clearColor];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
    msgLabel.numberOfLines = 0;
    msgLabel.font = [UIFont systemFontOfSize:14.0];
    
    self.rateView.frame = CGRectMake(70, 40+stringHeight, 230, 50);
    
    
    UIView *lineViewInner1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, y_offset, 290, 0.5)];
    lineViewInner1.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    [customPopUpView addSubview:lineViewInner1];
    
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(0, y_offset, button_common_width, button_common_height)];
    submitButton.backgroundColor = [UIColor clearColor];
    submitButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_17];
    submitButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [submitButton setTitle:RPLocalizedString(SUBMIT_RATING_TEXT, @"") forState:UIControlStateNormal];
    [submitButton addTarget:delegate action:@selector(commonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.tag = 0;
    [submitButton setTitleColor:[UIColor colorWithRed:1/255.0 green:128/255.0 blue:233/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    y_offset = y_offset+button_common_height;
    
    UIView *lineViewInner2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, y_offset, 290, 0.5)];
    lineViewInner2.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    [customPopUpView addSubview:lineViewInner2];
    
    UIButton *noThanksButton = [[UIButton alloc] initWithFrame:CGRectMake(0, y_offset, button_common_width, button_common_height)];
    noThanksButton.backgroundColor = [UIColor clearColor];
    noThanksButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_17];
    noThanksButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [noThanksButton setTitle:RPLocalizedString(NO_THANKS_TEXT, @"") forState:UIControlStateNormal];
    [noThanksButton addTarget:delegate action:@selector(commonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    noThanksButton.tag = 1;
    [noThanksButton setTitleColor:[UIColor colorWithRed:1/255.0 green:128/255.0 blue:233/255.0 alpha:1.0] forState:UIControlStateNormal];
    
    
    y_offset = y_offset+button_common_height;
    
    UIView *lineViewInner3 = [[UIView alloc] initWithFrame:CGRectMake(0.0, y_offset, 290, 0.5)];
    lineViewInner3.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    [customPopUpView addSubview:lineViewInner3];
    
    
    UIButton *remindButton = [[UIButton alloc] initWithFrame:CGRectMake(0, y_offset, button_common_width, button_common_height)];
    remindButton.backgroundColor = [UIColor clearColor];
    remindButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_17];
    remindButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [remindButton setTitle:RPLocalizedString(REMIND_ME_LATER_TEXT, @"") forState:UIControlStateNormal];
    [remindButton setTitleColor:[UIColor colorWithRed:1/255.0 green:128/255.0 blue:233/255.0 alpha:1.0] forState:UIControlStateNormal];
    [remindButton addTarget:delegate action:@selector(commonButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    remindButton.tag = 2;
    
    
    [self.view addSubview:appRateView];
    [customPopUpView addSubview:msgLabel];
    [customPopUpView addSubview:rateView];
    [customPopUpView addSubview:submitButton];
    [customPopUpView addSubview:noThanksButton];
    [customPopUpView addSubview:remindButton];
    
    
    customPopUpView.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{customPopUpView.alpha = 1.0;}];
    
    customPopUpView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:1.1],
                              [NSNumber numberWithFloat:0.8],
                              [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.duration = 0.3;
    bounceAnimation.removedOnCompletion = NO;
    [customPopUpView.layer addAnimation:bounceAnimation forKey:@"bounce"];
    
    customPopUpView.layer.transform = CATransform3DIdentity;
    [self.view addSubview:customPopUpView];
}

-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{
   
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    return mainSize.height;
}


- (void)rateView:(RateView *)rateView ratingDidChange:(float)rating
{
    
}

@end
