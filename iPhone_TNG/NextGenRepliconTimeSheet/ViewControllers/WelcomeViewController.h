
#import <UIKit/UIKit.h>
#import "RepliconBaseController.h"
#import "AppDelegate.h"
#import "WelcomeContentViewController.h"
#import "FrameworkImport.h"


@interface WelcomeViewController : RepliconBaseController <UIPageViewControllerDataSource, UIPageViewControllerDelegate, WelcomeContentViewControllerDelegate>

@property (nonatomic, strong)          UINavigationController   *navigationController;
@property (nonatomic, weak, readonly)  UIButton                 *signInButton;
@property (nonatomic, weak, readonly)  UIView                   *topView;
@property (nonatomic, weak, readonly)  UIView                   *bottomView;
@property (nonatomic, weak, readonly)  UIPageControl            *pageControl;
@property (nonatomic, strong)          UIPageViewController     *pageViewController;
@property (nonatomic, readonly)        AppDelegate              *appDelegate;
@property (nonatomic, readonly)        GATracker                *tracker;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithAppDelegate:(AppDelegate *)appDelegate tracker:(GATracker *)tracker;

//button action
-(IBAction)cancelSignUp:(UIStoryboardSegue *)segue;
-(IBAction)signInButtonAction;
- (WelcomeContentViewController *)viewControllerAtIndex:(NSUInteger)index;

-(void)trackGAScreenEventsForIndex:(NSUInteger)screenIndex;

@end
