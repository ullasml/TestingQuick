

#import <UIKit/UIKit.h>
#import "PNChartDelegate.h"
#import "PNChart.h"

@protocol Theme;

@interface DonutChartViewController : UIViewController<PNChartDelegate>

@property (nonatomic,readonly) PNPieChart *pieChart;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) NSArray *items;
@property (nonatomic,assign, readonly) CGRect donutChartViewBounds;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;
- (void)setupWithActualsPayCode:(NSArray *)actualsByPayCodeArray currencyDisplayText:(NSString *)currencyDisplayText donutChartViewBounds:(CGRect )donutChartViewBounds;
@end
