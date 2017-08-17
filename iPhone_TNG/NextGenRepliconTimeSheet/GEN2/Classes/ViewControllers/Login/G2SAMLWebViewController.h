

#import <UIKit/UIKit.h>


@interface G2SAMLWebViewController : UIViewController<UIWebViewDelegate> {
	
	UIWebView *webView;
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
@property (nonatomic, strong) UIImageView *overlayimageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong)  NSString *userNameStr,*passwordStr;
@property(nonatomic,assign) int count;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *urlAddress;
@property (nonatomic, strong) UITextField *userNameField,*passwordField;
-(void)addOverlay;
-(void)removeOverlay:(id)sender;

-(void)showAuthenticationRequiredDialog;

@end


