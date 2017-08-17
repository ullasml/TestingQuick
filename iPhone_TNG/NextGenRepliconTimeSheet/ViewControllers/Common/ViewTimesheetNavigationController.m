//
//  ViewTimesheetNavigationController.m
//  NextGenRepliconTimeSheet
//

#import "ViewTimesheetNavigationController.h"
#import "Constants.h"
#import "OfflineBanner.h"
#import "Theme.h"
#import "TimerProvider.h"
#import "LoginModel.h"
#import "UserPermissionsStorage.h"

@interface UINavigationController (ViewTimesheetNavigationController)

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
@interface ViewTimesheetNavigationController ()

@property (nonatomic, assign) BOOL shouldIgnorePushingViewControllers;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) OfflineBanner *offlineBanner;
@property (nonatomic) id <Theme> theme;
@property (nonatomic) TimerProvider *timerProvider;
@property (nonatomic) NSTimer *currentTimer;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;

@end

@implementation ViewTimesheetNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                    userPermissionsStorage:(UserPermissionsStorage*)userPermissionsStorage
                       reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                             timerProvider:(TimerProvider *)timerProvider
                                     theme:(id <Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.reachabilityMonitor = reachabilityMonitor;
        [self.reachabilityMonitor addObserver:self];
        self.timerProvider = timerProvider;
        self.theme = theme;
        self.userPermissionsStorage = userPermissionsStorage;
        self.viewControllers = @[rootViewController];
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.offlineBanner = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([OfflineBanner class]) owner:nil options:nil] firstObject];
    self.offlineBanner.backgroundColor = [self.theme offlineBannerBackgroundColor];
    self.offlineBanner.label.textColor = [self.theme offlineBannerTextColor];
    self.offlineBanner.label.font = [self.theme offlineBannerFont];
    self.offlineBanner.label.text = RPLocalizedString(@"No Internet Connection.", @"No Internet Connection.");
    [self.offlineBanner.closeButton addTarget:self action:@selector(hideOfflineBanner) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.offlineBanner];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetOfflineBannerAnimated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UINavigationController

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [super setNavigationBarHidden:hidden animated:animated];
    [self resetOfflineBannerAnimated:animated];
}

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    [self.navigationBar setTranslucent:NO];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if (!self.shouldIgnorePushingViewControllers)
    {
        [super pushViewController: viewController animated: animated];
    }
    
    self.shouldIgnorePushingViewControllers = YES;
}


- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super didShowViewController:viewController animated:animated];
    self.shouldIgnorePushingViewControllers = NO;
}


#pragma mark - <ReachabilityMonitorDelegate>

- (void)networkReachabilityChanged
{
    [self resetOfflineBannerAnimated:NO];
}

#pragma mark - Actions

- (void)hideOfflineBanner
{
    self.offlineBanner.hidden = YES;
}

#pragma mark - Private

- (void)resetOfflineBannerAnimated:(BOOL)animated
{
    BOOL isReachable = [self.reachabilityMonitor isNetworkReachable];
    self.offlineBanner.hidden = isReachable;
    self.offlineBanner.label.text = RPLocalizedString(@"No Internet Connection.", @"No Internet Connection.");
    [self.currentTimer invalidate];
    
    if (self.offlineBanner.hidden)
    {
        return;
    }
    
    self.currentTimer = [self.timerProvider scheduledTimerWithTimeInterval:10
                                                                    target:self
                                                                  selector:@selector(showOfflineInstructions)
                                                                  userInfo:nil
                                                                   repeats:NO];
    
    CGFloat offlineBannerTop;
    CGFloat offlineBannerHeight = 26.0f;
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    if (self.navigationBarHidden)
    {
        offlineBannerTop = 0.0f;
        
        offlineBannerHeight += CGRectGetHeight(statusBarFrame);
    }
    else
    {
        CGRect navBarFrame = self.navigationBar.frame;
        offlineBannerTop = CGRectGetHeight(statusBarFrame) + CGRectGetHeight(navBarFrame) ;
    }
    
    void (^animations)() = ^{
        self.offlineBanner.frame = CGRectMake(0.0f, offlineBannerTop, CGRectGetWidth(self.view.bounds), offlineBannerHeight);
    };
    
    if (animated)
    {
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:animations];
    }
    else
    {
        animations();
    }
}

- (void) showOfflineInstructions
{
    [self.currentTimer invalidate];
    self.offlineBanner.label.text = RPLocalizedString(@"No Internet Connection.", @"No Internet Connection.");
}

@end
