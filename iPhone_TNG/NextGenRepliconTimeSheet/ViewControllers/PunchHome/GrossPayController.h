#import <UIKit/UIKit.h>
#import "GrossPayCollectionViewViewController.h"
#import "Enum.h"
#import "GrossPayHours.h"

@class CurrencyValue;
@class ChildControllerHelper;
@protocol GrossPayControllerDelegate ;
@protocol Theme;


@interface GrossPayController : UIViewController<GrossPayCollectionViewControllerDelegate, GrossPayHours>

@property (weak, nonatomic, readonly) UILabel *grossPayHeaderLabel;
@property (weak, nonatomic, readonly) UILabel *totalPayLabel;
@property (weak, nonatomic, readonly) UILabel *asterixPayLabel;
@property (weak, nonatomic, readonly) UIView *separatorView;
@property (weak, nonatomic, readonly) UIView *grossPayLegendsContainerView;
@property (weak, nonatomic, readonly) UIView *donutWidgetView;
@property (nonatomic, readonly) BOOL viewMoreOrLessAction;
@property (nonatomic, readonly) CurrencyValue *grossPay;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) NSString *scriptCalculationDate;
@property (nonatomic, readonly) id <GrossPayHours> grossPayHours;
@property (weak, nonatomic, readonly) NSLayoutConstraint *asterixHeightConstraint;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        theme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)setupWithGrossPay:(CurrencyValue *)grossPay grossPayHeaderText:(NSString *)grossPayHeaderText actualsPayCode:(NSArray *)actualsByPayCodeArray delegate:(id <GrossPayControllerDelegate>)delegate scriptCalculationDate:(NSString *)scriptCalculationDate;

@end

@protocol GrossPayControllerDelegate <NSObject>

-(void)grossPayControllerIntendsToUpdateHeight:(CGFloat)height viewItems:(ViewItemsAction)action;

- (BOOL)didGrossPayHomeViewControllerShowingViewMore;
@end
