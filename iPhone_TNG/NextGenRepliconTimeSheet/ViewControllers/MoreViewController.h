#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "LaunchLoginDelegate.h"


@class DoorKeeper;
@class ReachabilityMonitor;
@class PunchOutboxStorage;
@class AppConfigRepository;
@class AppDelegate;
@class AppConfig;
@class MobileAppConfigRequestProvider;
@class LoginModel;

@interface MoreViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    UIBarButtonItem *leftButton;
}

@property (nonatomic) UIBarButtonItem *leftButton;
@property (nonatomic) UIButton        *mailBtn;
@property (nonatomic) UILabel         *debugDescLabel;
@property (nonatomic) UILabel         *debugModeLabel;
@property (nonatomic) UILabel         *versionLabel;
@property (nonatomic) UILabel         *versionLabelValue;
@property (nonatomic) UIScrollView    *scrollView;
@property (nonatomic) UIImageView     *DebugLineImageView;

@property (nonatomic, readonly) UISwitch *nodeSwitch;
@property (nonatomic, readonly) UIButton *logOutButton;
@property (nonatomic, readonly) UILabel  *nodeLabel;

@property (nonatomic, readonly) id<LaunchLoginDelegate> launchLoginDelegate;
@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, readonly) AppConfigRepository *appConfigRepository;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, readonly) PunchOutboxStorage *outbox;
@property (nonatomic, readonly) AppDelegate *appDelegate;
@property (nonatomic, readonly) DoorKeeper *doorKeeper;
@property (nonatomic, readonly) AppConfig *appConfig;
@property (nonatomic, readonly) MobileAppConfigRequestProvider *mobileAppConfigRequestProvider;
@property (nonatomic, readonly) LoginModel *loginModel;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithAppConfigRequestProvider:(MobileAppConfigRequestProvider *)mobileAppConfigRequestProvider
                             launchLoginDelegate:(id <LaunchLoginDelegate>)launchLoginDelegate
                             appConfigRepository:(AppConfigRepository *)appConfigRepository
                                       appConfig:(AppConfig *)appConfig
                             reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                    userDefaults:(NSUserDefaults *)userDefaults
                                     appDelegate:(AppDelegate *)appDelegate
                                      doorKeeper:(DoorKeeper *)doorKeeper
                                          outbox:(PunchOutboxStorage *)outbox
                                      loginModel:(LoginModel *)loginModel NS_DESIGNATED_INITIALIZER;

-(void)doSevenTaps;

@end
