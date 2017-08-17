
#import <UIKit/UIKit.h>
@protocol Theme;
@protocol WorkHours;

@class WorkHoursPromise;
@class DayTimeSummaryController;
@class TimeSummaryPresenter;
@class KSPromise;
@class TodaysDateControllerProvider;
@class ChildControllerHelper;
@class TodaysDateController;

@protocol DayTimeSummaryUpdateDelegate <NSObject>

-(void)dayTimeSummaryController:(DayTimeSummaryController *)dayTimeSummaryController
        didUpdateWorkHours:(id <WorkHours>)workhours;

@end

@interface DayTimeSummaryController : UIViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, readonly) KSPromise *workHoursPromise;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) TimeSummaryPresenter *timeSummaryPresenter;
@property (weak, nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, readonly) id <WorkHours> workHours;
@property (nonatomic, readonly) id <DayTimeSummaryUpdateDelegate> delegate;
@property (nonatomic, readonly) BOOL isScheduledDay;
@property (nonatomic, readonly) TodaysDateController *todaysDateController;
@property (nonatomic, readonly) TodaysDateControllerProvider *todaysDateControllerProvider;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (weak, nonatomic, readonly) UIView *todaysDateContainer;
@property (weak, nonatomic, readonly) NSLayoutConstraint *todaysDateHeightConstraint;
@property (nonatomic, readonly) CGFloat todaysDateContainerHeight;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithWorkHoursPresenterProvider:(TimeSummaryPresenter *)timeSummaryPresenter
                                             theme:(id<Theme>)theme
                      todaysDateControllerProvider:(TodaysDateControllerProvider *)todaysDateControllerProvider
                             childControllerHelper:(ChildControllerHelper *)childControllerHelper NS_DESIGNATED_INITIALIZER;

- (void)setupWithDelegate:(id <DayTimeSummaryUpdateDelegate>)delegate
     placeHolderWorkHours:(id <WorkHours>)placeHolderWorkHours
         workHoursPromise:(KSPromise *)workHoursPromise
           hasBreakAccess:(BOOL)hasBreakAccess
           isScheduledDay:(BOOL)isScheduledDay
todaysDateContainerHeight:(CGFloat)todaysDateContainerHeight;


- (void)updateRegularHoursLabelWithOffset:(NSDateComponents *)offsetDateComponents;
- (void)updateBreakHoursLabelWithOffset:(NSDateComponents *)offsetDateComponents;

@end
