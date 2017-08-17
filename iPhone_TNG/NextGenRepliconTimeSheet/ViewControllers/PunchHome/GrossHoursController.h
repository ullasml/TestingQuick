
#import <UIKit/UIKit.h>
#import "GrossPayCollectionViewViewController.h"
#import "GrossPayHours.h"

@class GrossHours;
@class ChildControllerHelper;
@protocol Theme;
@protocol GrossHoursControllerDelegate;

@interface GrossHoursController : UIViewController<GrossPayCollectionViewControllerDelegate, GrossPayHours>

@property (weak, nonatomic, readonly) UILabel *grossHoursHeaderLabel;
@property (weak, nonatomic, readonly) UILabel *totalHoursLabel;
@property (weak, nonatomic, readonly) UILabel *asterixHoursLabel;
@property (weak, nonatomic, readonly) UIView *separatorView;
@property (nonatomic, readonly) GrossHours *grossHours;
@property (nonatomic, readonly) NSArray *actualsByPayHoursArray;
@property (weak, nonatomic, readonly) UIView *grossPayLegendsContainerView;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (weak, nonatomic, readonly) UIView *donutWidgetView;
@property (weak, nonatomic, readonly) NSLayoutConstraint *asterixHeightConstraint;

@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) NSString *scriptCalculationDate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        theme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)setupWithGrossHours:(GrossHours *)grossHours grossHoursHeaderText:(NSString *)grossHoursHeaderText actualsPayCode:(NSArray *)actualsByPayCodeArray delegate:(id <GrossHoursControllerDelegate>)delegate scriptCalculationDate:(NSString *)scriptCalculationDate;

@end

@protocol GrossHoursControllerDelegate <NSObject>

- (void)grossPayControllerIntendsToUpdateHeight:(CGFloat)height viewItems:(ViewItemsAction)action;

- (BOOL)didGrossPayHomeViewControllerShowingViewMore;
@end

