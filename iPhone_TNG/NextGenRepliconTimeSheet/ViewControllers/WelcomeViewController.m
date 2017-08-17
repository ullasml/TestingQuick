
#import "WelcomeViewController.h"
#import "Constants.h"
#import "Util.h"
#import "InjectorProvider.h"
#import "EventTracker.h"
#import "ACSimpleKeychain.h"
#import "WelcomeContentViewController.h"
#import "AppDelegate.h"
#import <Blindside/BSInjector.h>
#import "Theme.h"
#import "WelcomeFlowControllerProvider.h"


@interface WelcomeViewController ()
{
    NSUInteger transitionPageIndex;
}

// private properties
@property (nonatomic) NSArray                                   *pageTitles;
@property (nonatomic) NSArray                                   *pageDetailsText;
@property (nonatomic, weak) IBOutlet UIButton                   *signInButton;
@property (nonatomic, weak) IBOutlet UIView                     *topView;
@property (nonatomic, weak) IBOutlet UIView                     *bottomView;
@property (nonatomic, weak) IBOutlet UIPageControl              *pageControl;
@property (nonatomic) WelcomeFlowControllerProvider             *welcomeFlowControllerProvider;
@property (nonatomic) AppDelegate                               *appDelegate;
@property (nonatomic) GATracker                                 *tracker;
@end




@implementation WelcomeViewController
@synthesize navigationController;
@synthesize signInButton;


- (instancetype)initWithAppDelegate:(AppDelegate *)appDelegate tracker:(GATracker *)tracker
{
    self = [super init];
    if (self) {
        self.appDelegate =appDelegate;
        self.tracker = tracker;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
		
    [self.view setBackgroundColor:[self.theme welcomeViewBGColor]];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.welcomeFlowControllerProvider = [[WelcomeFlowControllerProvider alloc] init];

    _pageDetailsText = @[RPLocalizedString(attendanceDetailsText,@""),
                    RPLocalizedString(approvalAttendanceDetailsText,@""),
                    RPLocalizedString(clientBillingDetailsText,@""),
                    RPLocalizedString(approvalClientBillingDetailsText,@"")];
    _pageTitles = @[RPLocalizedString(attendanceTitle,@""), RPLocalizedString(approvalAttendanceTitle,@""), RPLocalizedString(clientBillingTitle,@""), RPLocalizedString(approvalClientBillingTitle,@"")];
    
    // Create page view controller
    self.pageViewController = [self.welcomeFlowControllerProvider providePageViewControllerInstance];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    self.pageViewController.view.frame = self.topView.bounds;
    transitionPageIndex=0;

    [self trackGAScreenEventsForIndex:0];

    WelcomeContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageViewController];
    [self.topView addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    [startingViewController playVideo];
    
    [self.pageControl setUserInteractionEnabled:NO];
    [self.pageControl setPageIndicatorTintColor:[self.theme welcomepageCurrentPageTintColor]];
    [self.pageControl setCurrentPageIndicatorTintColor:[self.theme welcomepageCurrentPageControlColor]];
    [self.pageViewController.view setBackgroundColor:[self.theme welcomeViewBGColor]];

    [self.signInButton setTitleColor:[self.theme signInButtonTitleColor] forState:UIControlStateNormal];
    [self.signInButton.titleLabel setFont:[self.theme SignInButtonTitleLabelFont]];
    [self.signInButton setTitle:RPLocalizedString(LOGIN_TEXT, @"") forState:UIControlStateNormal];
    [self.signInButton setAccessibilityLabel:@"uia_welcome_sign_in_button_identifier"];
    self.signInButton.layer.cornerRadius = [self.theme signInButtonCornerRadius];
    self.signInButton.clipsToBounds = YES;


    EventTracker *eventTracker = [self.appDelegate.injector getInstance:[EventTracker class]];
    [eventTracker log:@"Free trial landing page"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

}

- (WelcomeContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }

    WelcomeContentViewController *pageContentViewController = [self.appDelegate.injector getInstance:[WelcomeContentViewController class]];
    [pageContentViewController setUpWithPageTitle:self.pageTitles[index] pageDetailsText:self.pageDetailsText[index] pageIndex:index delegate:(id)self];
    
    return pageContentViewController;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


-(BOOL)prefersStatusBarHidden {
	return YES; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelSignUp:(UIStoryboardSegue *)segue {
		//do stuff
	NSLog(@"Sign up cancelled");
}

-(IBAction)signInButtonAction
{
    [self.appDelegate launchLoginViewController:NO];
    WelcomeContentViewController *previousViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    [previousViewController stopVideo];
}

- (void)appplicationIsActive:(NSNotification *)notification {
}

- (void)applicationBackgroundNotification:(NSNotification *)notification {
    WelcomeContentViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    [currentViewController stopVideo];
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    WelcomeContentViewController *currentViewController = [self.pageViewController.viewControllers objectAtIndex:0];
    if (currentViewController.player && currentViewController.player.playbackState != MPMoviePlaybackStatePlaying) {
        [currentViewController playVideo];
    }
}

#pragma mark - Page View Controller Data Source and Delegate


- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
        if([pendingViewControllers count]>0)
        {
            transitionPageIndex = [(WelcomeContentViewController*)[pendingViewControllers objectAtIndex:0] pageIndex];
        }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if([previousViewControllers count]>0)
    {
        if(completed)
        {
            WelcomeContentViewController *previousViewController = [previousViewControllers objectAtIndex:0];
            [previousViewController stopVideo];
            
            WelcomeContentViewController *nextViewController = [self.pageViewController.viewControllers objectAtIndex:0];
            [nextViewController playVideo];
            
            self.pageControl.currentPage = transitionPageIndex;

            [self trackGAScreenEventsForIndex:transitionPageIndex];

        }
    }
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WelcomeContentViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((WelcomeContentViewController*) viewController).pageIndex;
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 0; // [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}


#pragma mark - WelcomeContentViewControllerDelegate

- (void)welcomeContentVideoDidFinished:(WelcomeContentViewController *)welcomeContentViewController
{
    NSUInteger currentIndex = self.pageControl.currentPage;
        
    ++currentIndex;
    currentIndex = currentIndex % (4);
    
    self.pageControl.currentPage = currentIndex;
    
    WelcomeContentViewController *viewController = [self viewControllerAtIndex:currentIndex];
    NSArray *viewControllers = @[viewController];
    
    [self.pageViewController setViewControllers:viewControllers
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:NO completion:nil];
    [viewController playVideo];

     [self trackGAScreenEventsForIndex:currentIndex];
}


#pragma -mark <Private>

-(void)trackGAScreenEventsForIndex:(NSUInteger)screenIndex
{
    switch (screenIndex) {
        case 0:
            [self.tracker trackScreenView:@"demoslide1_time_capture_for_attendance" forTracker:TrackerProduct];
            break;
        case 1:
            [self.tracker trackScreenView:@"demoslide2_approvals_for_time_and_attendance" forTracker:TrackerProduct];
            break;
        case 2:
            [self.tracker trackScreenView:@"demoslide3_time_capture_for_client_billing" forTracker:TrackerProduct];
            break;
        case 3:
            [self.tracker trackScreenView:@"demoslide4_approvals_for_client_billing" forTracker:TrackerProduct];
            break;
        default:
            break;
    }
}

@end
