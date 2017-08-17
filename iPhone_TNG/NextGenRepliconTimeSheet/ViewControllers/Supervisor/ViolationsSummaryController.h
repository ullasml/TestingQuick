#import <UIKit/UIKit.h>
#import "WaiverController.h"


@class SupervisorDashboardSummaryRepository;
@class SelectedWaiverOptionPresenter;
@class ViolationSectionHeaderPresenter;
@class ViolationSeverityPresenter;
@class TeamTableStylist;
@class KSPromise;
@protocol Theme;
@protocol SpinnerDelegate;
@protocol ViolationsSummaryControllerDelegate;


@interface ViolationsSummaryController : UIViewController <UITableViewDataSource, UITableViewDelegate, WaiverControllerDelegate>

@property (nonatomic, weak, readonly) UITableView *tableView;

@property (nonatomic, readonly) SupervisorDashboardSummaryRepository *supervisorDashboardSummaryRepository;
@property (nonatomic, readonly) ViolationSectionHeaderPresenter *violationSectionHeaderPresenter;
@property (nonatomic, readonly) SelectedWaiverOptionPresenter *selectedWaiverOptionPresenter;
@property (nonatomic, readonly) ViolationSeverityPresenter *violationSeverityPresenter;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) TeamTableStylist *stylist;
@property (nonatomic, readonly) id<Theme> theme;

@property (nonatomic, readonly) KSPromise *violationSectionsPromise;
@property (nonatomic, weak, readonly) id<ViolationsSummaryControllerDelegate> delegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSupervisorDashboardSummaryRepository:(SupervisorDashboardSummaryRepository *)supervisorDashboardSummaryRepository
                             violationSectionHeaderPresenter:(ViolationSectionHeaderPresenter *)violationSectionHeaderPresenter
                               selectedWaiverOptionPresenter:(SelectedWaiverOptionPresenter *)selectedWaiverOptionPresenter
                                  violationSeverityPresenter:(ViolationSeverityPresenter *)violationSeverityPresenter
                                            teamTableStylist:(TeamTableStylist *)teamTableStylist
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                                       theme:(id <Theme>)theme;

- (void)setupWithViolationSectionsPromise:(KSPromise *)violationSectionsPromise
                                 delegate:(id<ViolationsSummaryControllerDelegate>)delegate;

@end


@protocol ViolationsSummaryControllerDelegate <NSObject>

@required
- (KSPromise *)violationsSummaryControllerDidRequestViolationSectionsPromise:(ViolationsSummaryController *)violationsSummaryController;

@optional
- (void)violationsSummaryControllerDidRequestToUpdateUI:(ViolationsSummaryController *)violationsSummaryController;

@end
