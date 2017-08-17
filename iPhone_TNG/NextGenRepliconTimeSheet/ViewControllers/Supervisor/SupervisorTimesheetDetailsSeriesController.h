#import <UIKit/UIKit.h>
#import "SupervisorTimesheetDetailsController.h"

@class ChildControllerHelper;
@class TeamTimesheetSummaryRepository;


@interface SupervisorTimesheetDetailsSeriesController : UIViewController<SupervisorTimesheetDetailsControllerDelegate>

@property (nonatomic, readonly) TeamTimesheetSummaryRepository *teamTimesheetSummaryRepository;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithTeamTimesheetSummaryRepository:(TeamTimesheetSummaryRepository *)teamTimesheetSummaryRepository
                                 childControllerHelper:(ChildControllerHelper *)childControllerHelper NS_DESIGNATED_INITIALIZER;

@end
