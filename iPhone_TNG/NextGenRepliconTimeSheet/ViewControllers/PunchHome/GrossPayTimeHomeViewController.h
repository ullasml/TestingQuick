
#import <UIKit/UIKit.h>
#import "GrossPayPagingController.h"
#import "GrossPayController.h"
#import "GrossHoursController.h"
#import "Enum.h"

@protocol GrossSummary ;
@class GrossPayPagingController;
@class UserPermissionsStorage;
@class CurrencyValue;
@class GrossHours;
@protocol Theme;
@protocol GrossPayTimeHomeControllerDelegate;

@interface GrossPayTimeHomeViewController : UIViewController <UIPageViewControllerDelegate,UIPageViewControllerDataSource, GrossPayControllerDelegate,GrossHoursControllerDelegate>
@property (nonatomic, readonly) BOOL disPlayPayAmountPermission;
@property (nonatomic, readonly) BOOL disPlayPayHoursPermission;
@property (nonatomic, readonly) GrossPayPagingController *grossPayPagingController;
@property (nonatomic, weak, readonly)  UIPageControl  *pageControl;
@property (nonatomic, readonly) BOOL viewMoreOrLessAction;
@property (nonatomic, readonly) NSString *scriptCalculationDate;
@property (weak, nonatomic, readonly) UIView *seperatorView;
@property (weak, nonatomic, readonly) IBOutlet UIView *pageControllerContainerView;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)setupWithGrossSummary:(id <GrossSummary> )periodSummary
                     delegate:(id <GrossPayTimeHomeControllerDelegate>)delegate;


@end

@protocol GrossPayTimeHomeControllerDelegate <NSObject>

-(void)grossPayTimeHomeControllerIntendsToUpdateHeight:(CGFloat)height viewItems:(ViewItemsAction)action;


@end
