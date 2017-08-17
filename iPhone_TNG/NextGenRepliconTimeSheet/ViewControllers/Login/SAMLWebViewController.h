#import <UIKit/UIKit.h>
#import "LoginDelegate.h"


@class LoginService;
@class AppDelegate;
@protocol SpinnerDelegate;


@interface SAMLWebViewController : UIViewController <UIWebViewDelegate, LoginDelegate> {

	UIWebView *mainWebView;
    NSString *urlAddress;
    BOOL _authed;
    UITextField *userNameField,*passwordField;
    int count;
    NSString *userNameStr,*passwordStr;
    NSURLAuthenticationChallenge *hackChallenge;
    UIActivityIndicatorView *indicatorView;
    UIImageView *overlayimageView;
    UIButton *overlayButton;
}

@property (nonatomic) UIImageView *overlayimageView;
@property (nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic)  NSString *userNameStr,*passwordStr;
@property (nonatomic) int count;
@property (nonatomic) UIWebView *mainWebView;
@property (nonatomic) NSString *urlAddress;
@property (nonatomic) UITextField *userNameField,*passwordField;
@property (nonatomic, readonly) LoginService *loginService;
@property (nonatomic, readonly) AppDelegate *appDelegate;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithLoginService:(LoginService *)loginService
                     spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                         appDelegate:(AppDelegate *)appDelegate NS_DESIGNATED_INITIALIZER;

- (void)addOverlay;
- (void)removeOverlay:(id)sender;
- (void)showAuthenticationRequiredDialog;
- (void)createWebviewAndAddtoWindow;
- (void)handleCookiesResponse;

@end


