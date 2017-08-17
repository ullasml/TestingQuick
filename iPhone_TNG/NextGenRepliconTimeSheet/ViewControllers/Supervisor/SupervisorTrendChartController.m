#import "SupervisorTrendChartController.h"
#import "Theme.h"
#import "EmployeeClockInTrendSummaryRepository.h"
#import "DateProvider.h"
#import "EmployeeClockInTrendSummary.h"
#import <KSDeferred/KSPromise.h>
#import "EmployeeClockInTrendSummaryDataPoint.h"
#import "SupervisorTrendChartPlotView.h"
#import "SupervisorTrendChartPresenter.h"


@interface SupervisorTrendChartController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chartViewHeightConstraint;
@property (weak, nonatomic) IBOutlet SupervisorTrendChartPlotView *chartView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *topYLabel;
@property (weak, nonatomic) IBOutlet UILabel *middleYLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomYLabel;
@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet UIView *middleLineView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;
@property (weak, nonatomic) IBOutlet UILabel *noClockinsLabel;

@property (nonatomic) EmployeeClockInTrendSummaryRepository *employeeClockInTrendSummaryRepository;
@property (nonatomic) SupervisorTrendChartPresenter *supervisorTrendChartPresenter;
@property (nonatomic) id<Theme> theme;

@property (nonatomic) EmployeeClockInTrendSummary *employeeClockInTrendSummary;

@end


@implementation SupervisorTrendChartController

- (instancetype)initWithEmployeeClockInTrendSummaryRepository:(EmployeeClockInTrendSummaryRepository *)employeeClockInTrendSummaryRepository
                                supervisorTrendChartPresenter:(SupervisorTrendChartPresenter *)supervisorTrendChartPresenter
                                                        theme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.employeeClockInTrendSummaryRepository = employeeClockInTrendSummaryRepository;
        self.supervisorTrendChartPresenter = supervisorTrendChartPresenter;
        self.theme = theme;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [self.theme cardContainerBackgroundColor];

    self.headerLabel.text = RPLocalizedString(@"Employee Clock In Trend", @"Employee Clock In Trend");
    self.headerLabel.font = [self.theme cardContainerHeaderFont];
    self.headerLabel.textColor = [self.theme cardContainerHeaderColor];

    self.view.layer.borderWidth = [self.theme cardContainerBorderWidth];
    self.view.layer.borderColor = [self.theme cardContainerBorderColor];

    self.chartView.barColor = [self.theme plotBarColor];

    self.topYLabel.font = [self.theme plotLabelFont];
    self.topYLabel.textColor = [self.theme plotLabelTextColor];
    self.topYLabel.text = @"";
    self.middleYLabel.font = [self.theme plotLabelFont];
    self.middleYLabel.textColor = [self.theme plotLabelTextColor];
    self.middleYLabel.text = @"";
    self.bottomYLabel.font = [self.theme plotLabelFont];
    self.bottomYLabel.textColor = [self.theme plotLabelTextColor];
    self.bottomYLabel.text = @"";

    self.topLineView.backgroundColor = [self.theme plotHorizontalLineColor];
    self.middleLineView.backgroundColor = [self.theme plotHorizontalLineColor];
    self.bottomLineView.backgroundColor = [self.theme plotHorizontalLineColor];

    self.noClockinsLabel.text = RPLocalizedString(@"No Recent Clock-Ins",@"");
    self.noClockinsLabel.font = self.theme.plotNoCheckinsLabelFont;
    self.noClockinsLabel.textColor = self.theme.plotLabelTextColor;
    self.noClockinsLabel.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self.employeeClockInTrendSummaryRepository fetchEmployeeClockInTrendSummary] then:^id(EmployeeClockInTrendSummary *employeeClockInTrendSummary) {
        self.employeeClockInTrendSummary = employeeClockInTrendSummary;
        [self updatePlot];
        return nil;
    } error:^id(NSError *error) {
        return nil;
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.chartViewHeightConstraint.constant = 185.0;
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds), 0);
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (void)removeXSubLabels
{
    NSArray * views = self.scrollView.subviews;
    for (UIView *view in views)
    {
        if([view isKindOfClass:[UILabel class]])
        {
            [view removeFromSuperview];
        }
    }
}

- (void)updatePlot
{
    [self removeXSubLabels];

    NSArray *dataPoints = self.employeeClockInTrendSummary.dataPoints;

    NSArray *values = [self.supervisorTrendChartPresenter valuesForEmployeeClockInTrendSummary:self.employeeClockInTrendSummary];
    NSArray *xLabels = [self.supervisorTrendChartPresenter xLabelsForDataPoints:dataPoints];
    NSInteger maximum = [self.supervisorTrendChartPresenter maximumValueForDataPoints:dataPoints];

    if (maximum % 2)
    {
        maximum++;
    }

    self.noClockinsLabel.hidden = maximum > 0;

    if (maximum == 0)
    {
        maximum = 2;
    }

    NSInteger yMidpoint = maximum / 2;

    self.topYLabel.text = [NSString stringWithFormat:@"%ld", (long)maximum];
    self.middleYLabel.text = [NSString stringWithFormat:@"%ld", (long)yMidpoint];
    self.bottomYLabel.text = @"0";

    [self.chartView updateWithValues:values yScale:maximum];

    CGFloat labelY = self.scrollView.contentSize.height - 35.0f;
    CGFloat barWidth = floorf(self.scrollView.contentSize.width / values.count);
    CGFloat samplingIntervalsPerHour = 3600 / self.employeeClockInTrendSummary.samplingIntervalSeconds;
    CGFloat totalHourWidth = samplingIntervalsPerHour * barWidth;

    NSDate *firstStartDate = [dataPoints.firstObject startDate];
    NSTimeInterval seconds = [firstStartDate timeIntervalSinceReferenceDate];
    NSInteger secondsSinceHour = (NSInteger)seconds % 3600;
    CGFloat offset = totalHourWidth * secondsSinceHour / 3600.0f;

    [xLabels enumerateObjectsUsingBlock:^(NSString *xLabel, NSUInteger idx, BOOL *stop) {
        CGFloat labelX = totalHourWidth * idx - offset;
        if(labelX >= 0) {
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentRight;
            label.text = xLabel;
            label.textColor = [self.theme plotLabelTextColor];
            label.font = [self.theme plotLabelFont];
            label.transform = CGAffineTransformMakeRotation(-M_PI_2);

            label.frame = CGRectMake(labelX, labelY, barWidth, 35.0f);

            [self.scrollView addSubview:label];
        }
    }];
}

@end
