#import "TimesheetSummaryController.h"
#import "Theme.h"
#import "Cursor.h"
#import "TimesheetDetailsPresenter.h"
#import "TeamTimesheetSummary.h"
#import "Timesheet.h"
#import "TimesheetInfo.h"
#import "TimePeriodSummary.h"
#import "TimeSheetApprovalStatus.h"
#import "TimesheetPeriod.h"
#import "DateProvider.h"
#import "IndexCursor.h"
#import "ChildControllerHelper.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "HeaderButtonViewController.h"


@interface TimesheetSummaryController ()

@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPeriodLabel;
@property (weak, nonatomic) IBOutlet UIButton *previousTimesheetButton;
@property (weak, nonatomic) IBOutlet UIButton *nextTimesheetButton;
@property (weak, nonatomic) IBOutlet UIView *violationsAndStatusButtonContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;

@property (nonatomic) TimesheetDetailsPresenter *timesheetDetailsPresenter;
@property (nonatomic) TimesheetInfo *timesheet;
@property (nonatomic) IndexCursor *cursor;
@property (nonatomic, weak) id<Theme> theme;
@property (nonatomic, weak) id<TimesheetSummaryControllerDelegate> delegate;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic, weak) id<BSInjector> injector;

@end


@implementation TimesheetSummaryController

- (instancetype)initWithTimesheetDetailsPresenter:(TimesheetDetailsPresenter *)timesheetDetailsPresenter
                            childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                            theme:(id <Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.timesheetDetailsPresenter = timesheetDetailsPresenter;
        self.childControllerHelper = childControllerHelper;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithDelegate:(id <TimesheetSummaryControllerDelegate>)delegate
                   cursor:(IndexCursor *)cursor
                timesheet:(id <Timesheet>)timesheet {
    self.delegate = delegate;
    self.timesheet = timesheet;
    self.cursor = cursor;
}

#pragma mark - UIButton actions

- (IBAction)previousTimesheetButtonTapped:(id)sender
{
    [self.delegate timesheetSummaryControllerDidTapPreviousButton:self];
}

- (IBAction)nextTimesheetButtonTapped:(id)sender
{
    [self.delegate timesheetSummaryControllerDidTapNextButton:self];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentPeriodLabel.font = [self.theme timesheetDetailCurrentPeriodFont];
    self.dateRangeLabel.font = [self.theme timesheetDetailDateRangeFont];
    self.currentPeriodLabel.textColor = [self.theme timesheetDetailCurrentPeriodTextColor];
    self.dateRangeLabel.textColor = [self.theme timesheetDetailDateRangeTextColor];
    [self.dateRangeLabel setBackgroundColor:[UIColor clearColor]];
    [self.currentPeriodLabel setBackgroundColor:[UIColor clearColor]];
    [self.nextTimesheetButton setBackgroundColor:[UIColor clearColor]];
    [self.previousTimesheetButton setBackgroundColor:[UIColor clearColor]];
    self.violationsAndStatusButtonContainerView.backgroundColor = [self.theme cardContainerBackgroundColor];


    [self.dateRangeLabel setAccessibilityIdentifier:@"uia_timesheet_period_date_range_label_identifier"];
    [self.previousTimesheetButton setAccessibilityIdentifier:@"uia_previous_timesheet_navigation_button_identifier"];
    [self.nextTimesheetButton setAccessibilityIdentifier:@"uia_next_timesheet_navigation_button_identifier"];
    
    self.dateRangeLabel.text = [self.timesheetDetailsPresenter dateRangeTextWithTimesheetPeriod:self.timesheet.period];
    TimeSheetApprovalStatus *timeSheetApprovalStatus = self.timesheet.approvalStatus;
    NSString *currentPeriod = [self.timesheetDetailsPresenter approvalStatusForTimeSheet:timeSheetApprovalStatus
                                                                                  cursor:nil
                                                                         timeSheetPeriod:self.timesheet.period];
    self.currentPeriodLabel.text = currentPeriod;
    if (currentPeriod.length == 0) {
        [self.currentPeriodLabel removeFromSuperview];
    }
    
    self.nextTimesheetButton.hidden = [self.cursor canMoveForwards] ? false : true;
    self.previousTimesheetButton.hidden = [self.cursor canMoveBackwards] ? false : true;
    
    HeaderButtonViewController *headerButtonViewController = [self.injector getInstance:[HeaderButtonViewController class]];
    [headerButtonViewController setupWithDelegate:self timesheet:self.timesheet];
    [self.childControllerHelper addChildController:headerButtonViewController
                                toParentController:self
                                   inContainerView:self.violationsAndStatusButtonContainerView];

}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.widthConstraint.constant = CGRectGetWidth(self.view.bounds);
    [self.delegate timesheetSummaryControllerUpdateViewHeight:self height:self.scrollView.contentSize.height];
}

#pragma mark - <HeaderButtonControllerDelegate>

-(void)userDidIntendToViewViolationsWidget
{
    [self.delegate timesheetSummaryControllerDidTapissuesButton:self];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
