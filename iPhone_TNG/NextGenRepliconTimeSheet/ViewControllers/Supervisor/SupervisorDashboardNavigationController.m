#import "SupervisorDashboardNavigationController.h"
#import "OfflineBanner.h"
#import "Theme.h"


@interface SupervisorDashboardNavigationController ()

@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) OfflineBanner *offlineBanner;
@property (nonatomic) id <Theme> theme;

@end


@implementation SupervisorDashboardNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                       reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                     theme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.reachabilityMonitor = reachabilityMonitor;
        [self.reachabilityMonitor addObserver:self];
        self.theme = theme;

        self.viewControllers = @[rootViewController];
    }
    return self;
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

#pragma mark - UINavigationController

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [super setNavigationBarHidden:hidden animated:animated];
    [self resetOfflineBannerAnimated:animated];
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
    self.offlineBanner.hidden = [self.reachabilityMonitor isNetworkReachable];

    if (self.offlineBanner.hidden)
    {
        return;
    }

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

@end
