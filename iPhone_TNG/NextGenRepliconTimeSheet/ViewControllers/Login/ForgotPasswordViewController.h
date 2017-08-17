#import <UIKit/UIKit.h>
#import "ForgotPasswordRepository.h"
#import <repliconkit/ReachabilityMonitor.h>

@protocol SpinnerDelegate;
@protocol Theme;
@class GATracker;
@interface ForgotPasswordViewController : UIViewController <UITextFieldDelegate>


@property (weak,nonatomic,readonly)  UILabel *forgotPasswordLabel;
@property (weak,nonatomic,readonly)  UIButton *resetButton;
@property (weak,nonatomic,readonly)  UIView *containerView;
@property (weak,nonatomic,readonly)  UITextField *companyNameTextField;
@property (weak,nonatomic,readonly)  UITextField *emailTextField;
@property (nonatomic,readonly)  ForgotPasswordRepository *forgotPasswordRepository;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak, readonly) id<Theme> theme;
@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, readonly) GATracker *tracker;

- (instancetype)initWithForgotPasswordRepository:(ForgotPasswordRepository *)forgotPasswordRepository
                                 spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                                           theme:(id <Theme>)theme
                             reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                emmConfigManager:(EMMConfigManager *)emmConfigManager
                                         tracker:(GATracker *)tracker NS_DESIGNATED_INITIALIZER;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

-(IBAction)resetButtonClick:(id)sender;

@end
