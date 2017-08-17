#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "LoginView.h"
#import "LoginDelegate.h"

@class GATracker;
@class LoginCredentialsHelper;
@class EMMConfigManager;
@protocol Router;
@protocol SpinnerDelegate;
@protocol CookiesDelegate;
@protocol Theme;


@interface LoginViewController : UIViewController <MFMailComposeViewControllerDelegate, LoginViewDelegate, LoginDelegate,UIActionSheetDelegate>

@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak, readonly) id<CookiesDelegate> cookiesDelegate;
@property (nonatomic, weak, readonly) id<Router> router;
@property (nonatomic, readonly) LoginView *loginView;
@property (nonatomic, readonly) GATracker *tracker;
@property (nonatomic, readonly) LoginCredentialsHelper *loginCredentialsHelper;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSpinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                        cookiesDelegate:(id <CookiesDelegate>)cookiesDelegate
                                 router:(id <Router>)router
                                tracker:(GATracker *)tracker
                 loginCredentialsHelper:(LoginCredentialsHelper *)loginCredentialsHelper
                                  theme:(id<Theme>)theme
                       emmConfigManager:(EMMConfigManager *)emmConfigManager
                           userDefaults:(NSUserDefaults *)userDefaults;

@property (nonatomic,assign) BOOL showPasswordField;

- (void)launchGoogleSignInViewController:(NSString *)url;

@end
