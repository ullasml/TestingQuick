
#import <UIKit/UIKit.h>
#import "PunchOverviewController.h"
#import "Enum.h"
#import "AddPunchTimeLineCell.h"

@protocol TimesheetDayTimeLineControllerDelegate;
@class PunchPresenter;
@class TimeLineCellStylist;
@class PunchOverviewControllerProvider;
@class UserPermissionsStorage;
@class KSPromise;
@class TimeLinePunchesStorage;
@class DurationStringPresenter;
@class AuditHistoryRepository;
@class ImageFetcher;

#import <repliconkit/ReachabilityMonitor.h>


@interface TimesheetDayTimeLineController : UIViewController<UITableViewDelegate, UITableViewDataSource,AddPunchTimeLineCellDelegate>

@property (weak, nonatomic, readonly) UITableView *timelineTableView;

@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (weak, nonatomic, readonly) id<TimesheetDayTimeLineControllerDelegate> delegate;
@property (nonatomic, readonly) TimeLineCellStylist *cellStylist;
@property (nonatomic, readonly) PunchPresenter *punchPresenter;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) NSMutableArray *punches;
@property (nonatomic, readonly) AuditHistoryRepository *auditHistoryRepository;
@property (nonatomic, readonly) TimeLinePunchesStorage *timeLinePunchesStorage;
@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, readonly) ImageFetcher *imageFetcher;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly)  ButtonStylist *buttonStylist;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                       durationStringPresenter:(DurationStringPresenter *)durationStringPresenter
                        auditHistoryRepository:(AuditHistoryRepository *)auditHistoryRepository
                        timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
                           reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                           timeLineCellStylist:(TimeLineCellStylist *)timeLineCellStylist
                                punchPresenter:(PunchPresenter *)punchPresenter
                                  imageFetcher:(ImageFetcher *)imageFetcher
                                         theme:(id <Theme>)theme
                         childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                 buttonStylist:(ButtonStylist *)buttonStylist;

- (void)setupWithPunchChangeObserverDelegate:(id <PunchChangeObserverDelegate>)punchChangeObserverDelegate
                 serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                                    delegate:(id <TimesheetDayTimeLineControllerDelegate>)delegate
                                     userURI:(NSString *)userURI
                                    flowType:(FlowType)flowType
                                     punches:(NSArray *)punches
                        timeLinePunchFlow:(TimeLinePunchFlow)timeLinePunchFlow;
@end


@protocol TimesheetDayTimeLineControllerDelegate <NSObject>

- (void)timesheetDayTimeLineController:(TimesheetDayTimeLineController *)timesheetDayTimeLineController didUpdateHeight:(CGFloat) height;
- (NSDate *)timesheetDayTimeLineControllerDidRequestDate:(TimesheetDayTimeLineController *)timesheetDayTimeLineController;

@optional

- (NSString *)timesheetDayTimeLineControllerDidRequestUserUri:(NSString *)userUri;

@end
