//
//  SettingUpViewController.m
//  Replicon
//
//  Created by Abhishek Nimbalkar on 4/21/14.
//  Copyright (c) 2014 Replicon INC. All rights reserved.
//

#import "SettingUpViewController.h"
#import "SignUpCarouselItemView.h"
#import "Util.h"
#import "Constants.h"
#import "FrameworkImport.h"
#import "RepliconServiceManager.h"
#import "EventTracker.h"
#import "ACSimpleKeychain.h"

#define AUTOSCROLL_INTERVAL 6.0
#define TEMP_SETUP_INTERVAL 5.0


@interface SettingUpViewController () {
    NSTimer *_autoScollTimer;
    NSTimer *_tempSetupTimer;
}

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *paginatedScrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawerBottomConstraint;
@end



@implementation SettingUpViewController
@synthesize bottomView;
@synthesize startButton;
@synthesize previousPage;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SIGNUP_DATA_RECIEVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signUpData:) name:SIGNUP_DATA_RECIEVED_NOTIFICATION object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [Util setToolbarLabel:self withText: RPLocalizedString(SETTINGUP_YOUR_ACCOUNT_TEXT, @"") ];
   
    self.previousPage=-1;
    
    self.navigationItem.hidesBackButton = YES;
    
    [self setStartButtonHidden:YES];
    
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    spinner.hidesWhenStopped = NO;
    [spinner startAnimating];
    UIBarButtonItem *spinnerButton = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    self.navigationItem.rightBarButtonItem = spinnerButton;
    
    
    self.pageImages = [NSArray arrayWithObjects:
                       [UIImage imageNamed:@"Carousel-1"],
                       [UIImage imageNamed:@"Carousel-2"],
                       [UIImage imageNamed:@"Carousel-3"],
                       [UIImage imageNamed:@"Carousel-4"],
                       [UIImage imageNamed:@"Carousel-5"],
                       [UIImage imageNamed:@"Carousel-6"],
                       [UIImage imageNamed:@"Carousel-7"],
                       [UIImage imageNamed:@"Carousel-8"],
                       nil];
    
    self.pageTexts = [NSArray arrayWithObjects:
                       RPLocalizedString(CAROUSEL1_TEXT, CAROUSEL1_TEXT),
                       RPLocalizedString(CAROUSEL2_TEXT, CAROUSEL2_TEXT),
                       RPLocalizedString(CAROUSEL3_TEXT, CAROUSEL3_TEXT),
                       RPLocalizedString(CAROUSEL4_TEXT, CAROUSEL4_TEXT),
                       RPLocalizedString(CAROUSEL5_TEXT, CAROUSEL5_TEXT),
                       RPLocalizedString(CAROUSEL6_TEXT, CAROUSEL6_TEXT),
                       RPLocalizedString(CAROUSEL7_TEXT, CAROUSEL7_TEXT),
                       RPLocalizedString(CAROUSEL8_TEXT, CAROUSEL8_TEXT),
                       nil];
    
    NSInteger pageCount = self.pageImages.count;
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = pageCount;
    
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
    
    [self loadVisiblePages];
    
    
    
    /*
    UIImage *signUpOriginalImage = [UIImage imageNamed:@"bg_signupBtn"];
    UIEdgeInsets signUpInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    UIImage *signUpStretchableImage = [signUpOriginalImage resizableImageWithCapInsets:signUpInsets];
    [startButton setBackgroundImage:signUpStretchableImage forState:UIControlStateNormal];
    */
    
    if (isiPhone5)
    {
    }
    else
    {
        
        //Iphone  3.5 inch
        bottomView.frame = CGRectMake(0, 385, SCREEN_WIDTH, 95);
        
    }

    [self.startButton setTitle:RPLocalizedString(START_USING_REPLICON_TEXT, @"") forState:UIControlStateNormal];
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


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGSize pagesScrollViewSize = self.paginatedScrollView.frame.size;
    self.paginatedScrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * self.pageImages.count, pagesScrollViewSize.height);
    
    if(!_autoScollTimer) _autoScollTimer = [NSTimer scheduledTimerWithTimeInterval:AUTOSCROLL_INTERVAL target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    
    //if(!_tempSetupTimer) _tempSetupTimer = [NSTimer scheduledTimerWithTimeInterval:TEMP_SETUP_INTERVAL target:self selector:@selector(setupComplete:) userInfo:nil repeats:NO];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [_autoScollTimer invalidate];
    _autoScollTimer = nil;
    
    [_tempSetupTimer invalidate];
    _tempSetupTimer = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)timerFireMethod:(NSTimer *)timer {
    
    NSInteger newPage = self.pageControl.currentPage + 1;
    //if(newPage == self.pageControl.numberOfPages) newPage = 0;
    if(newPage == self.pageControl.numberOfPages) {
        [_autoScollTimer invalidate];
        _autoScollTimer = nil;
        return;
    }
    
    CGFloat newX = self.paginatedScrollView.frame.size.width*newPage;
    [self.paginatedScrollView setContentOffset:CGPointMake(newX, 0) animated:YES];
    
   
}

- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) return;
    
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView == [NSNull null]) {
        // 2
        CGRect frame = self.paginatedScrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 65.0;
        
        // 3
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[self.pageImages objectAtIndex:page]];
        newPageView.contentMode = UIViewContentModeTop;
        newPageView.frame = frame;
        [self.paginatedScrollView addSubview:newPageView];
        
       
        
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self.pageTexts objectAtIndex:page]];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_20]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake(230.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        
        UILabel *label=[[UILabel alloc]init];
        label.backgroundColor=[UIColor clearColor];
        
        
        
        if (mainSize.height<=50.0)
        {
            frame.origin.x=frame.origin.x +50.0;
            frame.size.width=230.0;
            label.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_20];
        }
        else if (mainSize.height<=80.0)
        {
             frame.origin.x=frame.origin.x +20.0;
            frame.size.width=300.0;
            label.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_17];
        }
        else if (mainSize.height>80.0)
        {
            frame.origin.x=frame.origin.x +20.0;
            frame.size.width=300.0;
            label.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15];
        }
        
        frame.origin.y=10.0;
        frame.size.height=50.0;
        
       
        [label setTextColor:[Util colorWithHex:@"#3f3f3f" alpha:1]];
        label.frame=frame;
        label.numberOfLines=3.0;
        label.text=[self.pageTexts objectAtIndex:page];
        label.textAlignment=NSTextAlignmentCenter;
        [self.paginatedScrollView addSubview:label];
        
        // 4
        [self.pageViews replaceObjectAtIndex:page withObject:newPageView];
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= self.pageImages.count) return;
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = [self.pageViews objectAtIndex:page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        [self.pageViews replaceObjectAtIndex:page withObject:[NSNull null]];
    }
}

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = self.paginatedScrollView.frame.size.width;
    NSInteger page = (NSInteger)floor((self.paginatedScrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    self.pageControl.currentPage = page;
    
    // Work out which pages you want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    
	// Load pages in our range
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    
	// Purge anything after the last page
    for (NSInteger i=lastPage+1; i<self.pageImages.count; i++) {
        [self purgePage:i];
    }
    
    if (self.pageControl.currentPage!=previousPage)
    {
        NSInteger currentPage = self.pageControl.currentPage+1;
        NSString *event= [NSString stringWithFormat:@"Carousel %d page",(int)currentPage];
        [EventTracker.sharedInstance log:event];
    }
    
    previousPage=self.pageControl.currentPage;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_autoScollTimer invalidate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Load the pages that are now on screen
    [self loadVisiblePages];
}



-(void)setStartButtonHidden:(BOOL)hidden {
    /*[self.view layoutSubviews];
    self.drawerBottomConstraint.constant = hidden ? -60 : 0;
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self.view layoutSubviews];
                     }
                     completion:nil];*/
}

-(void) setupComplete:(NSTimer*)timer {
    [self setStartButtonHidden:NO];
    self.title = @"Setup Complete";
    self.navigationItem.rightBarButtonItem = nil;
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         if (isiPhone5)
                         {
                             // this is iphone 4 inch
                             bottomView.frame = CGRectMake(0, 413, SCREEN_WIDTH, 95);
                         }
                         else
                         {
                             
                             //Iphone  3.5 inch
                             bottomView.frame = CGRectMake(0, 325, SCREEN_WIDTH, 95);
                             
                         }

                     }
                     completion:nil];
}

#pragma mark - Other Method
-(void)signUpData :(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SIGNUP_DATA_RECIEVED_NOTIFICATION object:nil];
    
    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"isError"]boolValue];
    
    if (!hasError)
    {
        if (![notification.object  isKindOfClass:[NSNull class]] && notification.object  != nil) {
            NSDictionary *tempDict = notification.object;
            // MOBI-471
            ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
            NSString *companyNameString=[[tempDict objectForKey:@"companyKey"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            companyNameString=[companyNameString stringByReplacingOccurrencesOfString:@" " withString:@""];

            if ([keychain storeUsername:[tempDict objectForKey:@"loginName"] password:[tempDict objectForKey:@"password"] companyName:companyNameString forService:@"repliconUserCredentials"]) {
                NSLog(@"**SAVED**");
            }
            
       //     [[NSUserDefaults standardUserDefaults] setObject:@"test" forKey:@"urlPrefixesStr"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"urlPrefixesStr"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"tempurlPrefixesStr"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isConnectStagingServer"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        self.navigationItem.rightBarButtonItem = nil;
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             if (isiPhone5)
                             {
                                 // this is iphone 4 inch
                                 bottomView.frame = CGRectMake(0, 413, SCREEN_WIDTH, 95);
                             }
                             else
                             {
                                 
                                 //Iphone  3.5 inch
                                 bottomView.frame = CGRectMake(0, 325, SCREEN_WIDTH, 95);
                                 
                             }
                             
                         }
                         completion:nil];
        [Util setToolbarLabel:self withText: RPLocalizedString(SETUP_COMPLETE_TEXT, @"") ];
        [self setStartButtonHidden:NO];
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    else
    {
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             if (isiPhone5)
                             {
                                 // this is iphone 4 inch
                                 bottomView.frame = CGRectMake(0, 413, SCREEN_WIDTH, 95);
                             }
                             else
                             {
                                 
                                 //Iphone  3.5 inch
                                 bottomView.frame = CGRectMake(0, 325, SCREEN_WIDTH, 95);
                                 
                             }
                             
                         }
                         completion:nil];
        
        [self.navigationController popToRootViewControllerAnimated:TRUE];
    }
}

-(IBAction)startUsingRepliconClicked:(id)sender
{
   
    
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        
        [Util showOfflineAlert];
        return;
    }
    
    [EventTracker.sharedInstance log:@"Start Using Replicon Clicked"];
    
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
   [defaults setBool:YES forKey:@"RememberMe"];
   [defaults synchronize];
        
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

    [[RepliconServiceManager loginService] sendrequestToFetchUserIntegrationDetailsForiOS7WithDelegate:self buttonType:@"Sign In"];
    
        
    
   

}

- (void)dealloc
{
    self.paginatedScrollView.delegate= nil;
}

@end
