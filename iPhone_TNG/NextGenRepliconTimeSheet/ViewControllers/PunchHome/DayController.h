#import <UIKit/UIKit.h>
#import "PunchRepository.h"
#import "TimesheetDayTimeLineController.h"


@class DayTimeSummary;
@class ChildControllerHelper;
@class PunchOverviewEditController;
@protocol Theme;
@protocol UserSession;
@class TimesheetDaySummary;
@class DayTimeSummaryTitlePresenter;
@protocol DayControllerDelegate;

@interface DayController : UIViewController <TimesheetDayTimeLineControllerDelegate,PunchChangeObserverDelegate>

@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) NSArray *dayTimeSummaries;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) id <Theme> theme;
@property (nonatomic, readonly) id <UserSession> userSession;
@property (nonatomic, readonly) DayTimeSummaryCellPresenter *dayTimeSummaryCellPresenter;
@property (nonatomic, readonly) DayTimeSummaryTitlePresenter *dayTimeSummaryTitlePresenter;

@property (weak, nonatomic, readonly) NSLayoutConstraint *timeLineHeightConstraint;
@property (weak, nonatomic, readonly) UIView *workHoursContainerView;
@property (weak, nonatomic, readonly) UIView *timeLineContainerView;
@property (weak, nonatomic, readonly) UIView *topBorderLineView;
@property (weak, nonatomic, readonly) UIView *bottomBorderLineView;
@property (weak, nonatomic, readonly) NSLayoutConstraint *widthConstraint;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDayTimeSummaryTitlePresenter:(DayTimeSummaryTitlePresenter *)dayTimeSummaryTitlePresenter
                         dayTimeSummaryCellPresenter:(DayTimeSummaryCellPresenter *)dayTimeSummaryCellPresenter
                               childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                         userSession:(id <UserSession>)userSession
                                               theme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)setupWithPunchChangeObserverDelegate:(id <PunchChangeObserverDelegate>)punchChangeObserverDelegate
                         timesheetDaySummary:(TimesheetDaySummary *)timesheetDaySummary
                              hasBreakAccess:(BOOL)hasBreakAccess
                                    delegate:(id <DayControllerDelegate>) delegate
                                     userURI:(NSString *)userURI
                                        date:(NSDate *)date;

- (void) updateWithDayTimeSummaries:(TimesheetDaySummary *)dayTimeSummaries;


@end

@protocol DayControllerDelegate <NSObject>

- (KSPromise *)needsTimePunchesPromiseWhenUserEditOrAddOrDeletePunchForDayController:(DayController *)dayController;

@end
