#import <UIKit/UIKit.h>


@class EmployeeClockInTrendSummaryRepository;
@class SupervisorTrendChartPlotView;
@class DateProvider;
@protocol Theme;
@class SupervisorTrendChartPresenter;


@interface SupervisorTrendChartController : UIViewController

@property (weak, nonatomic, readonly) SupervisorTrendChartPlotView *chartView;
@property (weak, nonatomic, readonly) UIScrollView *scrollView;
@property (weak, nonatomic, readonly) UILabel *bottomYLabel;
@property (weak, nonatomic, readonly) UILabel *middleYLabel;
@property (weak, nonatomic, readonly) UILabel *headerLabel;
@property (weak, nonatomic, readonly) UILabel *topYLabel;
@property (weak, nonatomic, readonly) UIView *topLineView;
@property (weak, nonatomic, readonly) UIView *middleLineView;
@property (weak, nonatomic, readonly) UIView *bottomLineView;
@property (weak, nonatomic, readonly) UILabel *noClockinsLabel;

@property (nonatomic, readonly) EmployeeClockInTrendSummaryRepository *employeeClockInTrendSummaryRepository;
@property (nonatomic, readonly) SupervisorTrendChartPresenter *supervisorTrendChartPresenter;
@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithEmployeeClockInTrendSummaryRepository:(EmployeeClockInTrendSummaryRepository *)EmployeeClockInTrendSummaryRepository
                                supervisorTrendChartPresenter:(SupervisorTrendChartPresenter *)supervisorTrendChartPresenter
                                                        theme:(id<Theme>)theme;

@end
