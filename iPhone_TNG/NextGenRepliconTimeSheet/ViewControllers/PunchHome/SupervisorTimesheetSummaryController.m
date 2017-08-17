#import "SupervisorTimesheetSummaryController.h"
#import "Theme.h"
#import "Cursor.h"
#import "TimesheetDetailsPresenter.h"
#import "Timesheet.h"
#import <KSDeferred/KSDeferred.h>
#import "TeamTimesheetSummary.h"
#import "TimesheetPeriodCursor.h"


@interface SupervisorTimesheetSummaryController ()

@property (weak, nonatomic) IBOutlet UILabel *dateRangeLabel;
@property (weak, nonatomic) IBOutlet UIButton *previousTimesheetButton;
@property (weak, nonatomic) IBOutlet UIButton *nextTimesheetButton;

@property (nonatomic) TimesheetDetailsPresenter *timesheetDetailsPresenter;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) KSPromise *timeSummaryPromise;
@property (nonatomic, weak) id<SupervisorTimesheetSummaryControllerDelegate> delegate;

@end


@implementation SupervisorTimesheetSummaryController

- (instancetype)initWithTimesheetDetailsPresenter:(TimesheetDetailsPresenter *)timesheetDetailsPresenter
                                            theme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.timesheetDetailsPresenter = timesheetDetailsPresenter;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithDelegate:(id<SupervisorTimesheetSummaryControllerDelegate>)delegate timeSummaryPromise:(KSPromise *)timeSummaryPromise
{
    self.delegate = delegate;
    self.timeSummaryPromise = timeSummaryPromise;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dateRangeLabel.text = nil;
    self.previousTimesheetButton.hidden = YES;
    self.nextTimesheetButton.hidden = YES;
    self.dateRangeLabel.font = [self.theme timesheetDetailDateRangeFont];
    [self.dateRangeLabel setAccessibilityIdentifier:@"uia_timesheet_period_date_range_label_identifier"];
    [self.previousTimesheetButton setAccessibilityIdentifier:@"uia_previous_timesheet_navigation_button_identifier"];
    [self.nextTimesheetButton setAccessibilityIdentifier:@"uia_next_timesheet_navigation_button_identifier"];
    
    [self.timeSummaryPromise then:^id(TeamTimesheetSummary *teamTimesheetSummary) {
        TimesheetPeriodCursor *cursor = [[TimesheetPeriodCursor alloc] initWithCurrentPeriod:teamTimesheetSummary.currentPeriod
                                                                              previousPeriod:teamTimesheetSummary.previousPeriod
                                                                                   nextPeriod:teamTimesheetSummary.nextPeriod];
        self.dateRangeLabel.text = [self.timesheetDetailsPresenter dateRangeTextWithTimesheetPeriod:teamTimesheetSummary.currentPeriod];
        self.nextTimesheetButton.enabled = [cursor canMoveForwards];
        self.previousTimesheetButton.enabled = [cursor canMoveBackwards];
        self.previousTimesheetButton.hidden = NO;
        self.nextTimesheetButton.hidden = NO;
        return nil;
    } error:^id(NSError *error) {
        return nil;
    }];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
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

@end
