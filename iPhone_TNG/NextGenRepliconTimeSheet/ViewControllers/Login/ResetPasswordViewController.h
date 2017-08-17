#import <UIKit/UIKit.h>
#import "LoginDelegate.h"
#import "ResetPasswordView.h"


@protocol SpinnerDelegate;
@protocol Router;
@class GATracker;
@protocol Theme;


@interface ResetPasswordViewController : UIViewController <LoginDelegate, ResetPasswordViewDelegate>
{
    UITableView    *loginTableView;
    UIButton	   *loginButton;
    UIActivityIndicatorView *activityIndicator;
}

@property (nonatomic) UITableView  *loginTableView;
@property (nonatomic) UIButton	   *loginButton;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak, readonly) id<Router> router;
@property (nonatomic, readonly) GATracker *tracker;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSpinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate router:(id <Router>)router tracker:(GATracker *)tracker theme:(id<Theme>)theme;

@end
