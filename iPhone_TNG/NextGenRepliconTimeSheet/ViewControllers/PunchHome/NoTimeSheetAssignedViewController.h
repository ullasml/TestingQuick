
#import <UIKit/UIKit.h>

@class HomeSummaryRepository;
@class AppDelegate;
@protocol Theme;
@protocol SpinnerDelegate;
@class ButtonStylist;
@class ReachabilityMonitor;
@protocol HomeSummaryDelegate;
@class SupportDataModel;


@interface NoTimeSheetAssignedViewController : UIViewController

@property (nonatomic, weak, readonly) UIButton              *refreshButton;
@property (nonatomic, weak, readonly) UILabel               *msgLabel;
@property (nonatomic, weak, readonly) id<SpinnerDelegate>   spinnerDelegate;
@property (nonatomic, readonly)  HomeSummaryRepository      *homeSummaryRepository;
@property (nonatomic, readonly)  AppDelegate                *appDelegate;
@property (nonatomic, readonly)  id<Theme>                  theme;
@property (nonatomic, readonly)  ButtonStylist              *buttonStylist;
@property (nonatomic, readonly)  ReachabilityMonitor        *reachabilityMonitor;
@property (nonatomic, readonly)  id<HomeSummaryDelegate>    homeSummaryDelegate;
@property (nonatomic, readonly)  SupportDataModel           *supportDataModel;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithHomeSummaryRepository:(HomeSummaryRepository *)homeSummaryRepository
                          homeSummaryDelegate:(id <HomeSummaryDelegate>)homeSummaryDelegate
                          reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                             supportDataModel:(SupportDataModel *)supportDataModel
                              spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                buttonStylist:(ButtonStylist *)buttonStylist
                                  appDelegate:(AppDelegate *)appDelegate
                                        theme:(id<Theme>)theme;
-(IBAction)refreshButtonAction:(id)sender;
@end
