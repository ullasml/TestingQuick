#import "SupervisorTimesheetDetailsSeriesController.h"
#import "SupervisorTimesheetDetailsController.h"
#import <Blindside/Blindside.h>
#import "ChildControllerHelper.h"
#import "TeamTimesheetSummaryRepository.h"
#import "TimesheetPeriodCursor.h"
#import <KSDeferred/KSPromise.h>
#import "UIViewController+NavigationBar.h"


@interface SupervisorTimesheetDetailsSeriesController ()

@property (nonatomic) TeamTimesheetSummaryRepository *teamTimesheetSummaryRepository;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) UIActivityIndicatorView *spinnerView;
@property (nonatomic, weak) id<BSInjector> injector;

@end


@implementation SupervisorTimesheetDetailsSeriesController

- (instancetype)initWithTeamTimesheetSummaryRepository:(TeamTimesheetSummaryRepository *)teamTimesheetSummaryRepository
                                 childControllerHelper:(ChildControllerHelper *)childControllerHelper
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.teamTimesheetSummaryRepository = teamTimesheetSummaryRepository;
        self.childControllerHelper = childControllerHelper;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinnerView startAnimating];
    self.spinnerView.hidden = YES;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinnerView];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self setupNavigationBarWithTitle:RPLocalizedString(@"Team Timesheets", nil) backButtonTitle:RPLocalizedString(@"Back", nil)];
    
    KSPromise *teamTimesheetSummaryPromise = [self.teamTimesheetSummaryRepository fetchTeamTimesheetSummaryWithTimesheetPeriod:nil];
    [teamTimesheetSummaryPromise then:^id(id value) {
        [self.spinnerView stopAnimating];
        return nil;
    } error:nil];
    
    SupervisorTimesheetDetailsController *supervisorTimesheetDetailsController = [self.injector getInstance:[SupervisorTimesheetDetailsController class]];
    [supervisorTimesheetDetailsController setupWithTeamTimesheetSummaryPromise:teamTimesheetSummaryPromise delegate:self];
    [self.childControllerHelper addChildController:supervisorTimesheetDetailsController
                                toParentController:self
                                   inContainerView:self.view];
}

- (void)viewDidLayoutSubviews
{
    SupervisorTimesheetDetailsController *supervisorTimesheetDetailsController = (id)self.childViewControllers.firstObject;
    supervisorTimesheetDetailsController.scrollView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length], 0, 0, 0);
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - <SupervisorTimesheetDetailsControllerDelegate>

- (void)supervisorTimesheetDetailsController:(SupervisorTimesheetDetailsController *)supervisorTimesheetDetailsController requestsPreviousTimesheetWithCursor:(TimesheetPeriodCursor *)timesheetPeriodCursor

{
    [self replaceTimesheetDetailsController:supervisorTimesheetDetailsController withNewTimesheetDetailsControllerForPeriod:timesheetPeriodCursor.previousPeriod];
}



- (void)supervisorTimesheetDetailsController:(SupervisorTimesheetDetailsController *)supervisorTimesheetDetailsController requestsNextTimesheetWithCursor:(TimesheetPeriodCursor *)timesheetPeriodCursor

{
    
    [self replaceTimesheetDetailsController:supervisorTimesheetDetailsController withNewTimesheetDetailsControllerForPeriod:timesheetPeriodCursor.nextPeriod];
    
}
#pragma mark - Private

- (void)replaceTimesheetDetailsController:(SupervisorTimesheetDetailsController *)supervisorTimesheetDetailsController withNewTimesheetDetailsControllerForPeriod:(TimesheetPeriod *)timesheetPeriod

{
    [self.spinnerView startAnimating];
    KSPromise *teamTimesheetSummaryPromise = [self.teamTimesheetSummaryRepository fetchTeamTimesheetSummaryWithTimesheetPeriod:timesheetPeriod];
    
    [teamTimesheetSummaryPromise then:^id(id value) {
        [self.spinnerView stopAnimating];
        return nil;
    } error:nil];
    SupervisorTimesheetDetailsController *newSupervisorTimesheetDetailsController = [self.injector getInstance:[SupervisorTimesheetDetailsController class]];
    [newSupervisorTimesheetDetailsController setupWithTeamTimesheetSummaryPromise:teamTimesheetSummaryPromise delegate:self];
    
    [self.childControllerHelper replaceOldChildController:supervisorTimesheetDetailsController
                                   withNewChildController:newSupervisorTimesheetDetailsController
                                       onParentController:self];
    
    newSupervisorTimesheetDetailsController.scrollView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length], 0, 0, 0);
    
    
}

@end
