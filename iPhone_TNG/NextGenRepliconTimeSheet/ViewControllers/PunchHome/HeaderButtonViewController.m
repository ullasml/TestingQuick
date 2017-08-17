#import "HeaderButtonViewController.h"
#import "Timesheet.h"
#import "Constants.h"
#import "TimesheetInfo.h"
#import "Theme.h"
#import "TimeSheetApprovalStatus.h"
#import "TimePeriodSummary.h"

@interface HeaderButtonViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *approvalStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *approvalStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *issuesStatusImageView;
@property (weak, nonatomic) IBOutlet UILabel *issuesStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *issuesButton;
@property (weak, nonatomic) IBOutlet UIButton *approvalStatusButton;
@property (weak, nonatomic) IBOutlet UIView *issuesStatusView;
@property (weak, nonatomic) IBOutlet UILabel *issuesCountLabel;

@property (nonatomic) id<Theme> theme;
@property (nonatomic,weak) id <HeaderButtonControllerDelegate> delegate;
@property (nonatomic) id<Timesheet> timesheet;


@end

@implementation HeaderButtonViewController

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.theme = theme;
    }
    return self;
}

- (void)setupWithDelegate:(id <HeaderButtonControllerDelegate>)delegate
                timesheet:(id <Timesheet>)timesheet
{
    self.delegate = delegate;
    self.timesheet =  timesheet;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.containerView.backgroundColor = [UIColor clearColor];
    NSInteger issuesCount = self.timesheet.issuesCount ? self.timesheet.issuesCount : 0;
    if (issuesCount > 0){
        NSString *violationsTitle = issuesCount > 1 ? NSLocalizedString(Issues_text, Issues_text) : NSLocalizedString(Issue_text, Issue_text);
        UIImage *issuesImage = [UIImage imageNamed:@"violation-active"];
        self.issuesStatusLabel.font = [self.theme timesheetStatusLabelFont];
        self.issuesStatusLabel.textColor = [self.theme issuesButtonDefaultTitleOrBorderColor];
        self.issuesStatusLabel.backgroundColor = [UIColor clearColor];
        self.issuesStatusLabel.text = violationsTitle;
        [self styleButton:self.issuesButton borderColor:[self.theme issuesButtonDefaultTitleOrBorderColor]];
        self.issuesStatusImageView.image = issuesImage;
        self.issuesStatusImageView.backgroundColor = [UIColor clearColor];
        self.issuesCountLabel.text = [NSString stringWithFormat:@"%ld", (long)issuesCount];
        self.issuesCountLabel.textColor = [self.theme issuesCountColor];
        self.issuesCountLabel.font = [self.theme  timesheetIssuesCountLabelFont];
    }
    else{
        [self.issuesButton removeFromSuperview];
        [self.issuesStatusView removeFromSuperview];
    }
    
    NSString *status = self.timesheet.approvalStatus.approvalStatusUri;
    [self statusTitleAndColorForTimesheetStatus:status];
    self.approvalStatusLabel.font = [self.theme timesheetStatusLabelFont];
    self.approvalStatusLabel.backgroundColor = [UIColor clearColor];
    self.approvalStatusImageView.backgroundColor = [UIColor clearColor];
}


#pragma mark - Private

-(IBAction)buttonAction:(id)sender{
    [self.delegate userDidIntendToViewViolationsWidget];
}

-(void)styleButton:(UIButton*)button borderColor:(UIColor*)borderColor{
    button.backgroundColor = [UIColor clearColor];
    button.titleLabel.font = [self.theme timesheetViolationsLabelFont];
    [button setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    button.layer.cornerRadius = 14;
    button.layer.borderColor = [borderColor CGColor];
    button.layer.borderWidth = 2;
    button.clipsToBounds = true;
}


-(void)statusTitleAndColorForTimesheetStatus:(NSString*)status{
    UIImage *statusImage =  nil;
    UIColor *titleColor;
    NSString *statusTitle;
    if ([status isEqualToString:NOT_SUBMITTED_STATUS_URI])  {
        statusTitle =  NSLocalizedString(NOT_SUBMITTED_STATUS, NOT_SUBMITTED_STATUS);
        titleColor =  [self.theme notSubmittedColor];
        statusImage =  [UIImage imageNamed:@"not-submitted"];
    }
    else if ([status isEqualToString:APPROVED_STATUS_URI]) {
        statusTitle =  NSLocalizedString(APPROVED_STATUS, APPROVED_STATUS);
        titleColor =  [self.theme approvedColor];
        statusImage =  [UIImage imageNamed:@"approved"];
    }
    else if ([status isEqualToString:REJECTED_STATUS_URI]){
        statusTitle =  NSLocalizedString(REJECTED_STATUS, APPROVED_STATUS);
        titleColor =  [self.theme rejectedColor];
        statusImage =  [UIImage imageNamed:@"rejected"];
    }
    else {
        statusTitle =  NSLocalizedString(WAITING_FOR_APRROVAL_STATUS, APPROVED_STATUS);
        titleColor =  [self.theme waitingForApprovalButtonBorderColor];
        statusImage =  [UIImage imageNamed:@"waiting-for-approval"];
    }
    [self styleButton:self.approvalStatusButton borderColor:titleColor];
    self.approvalStatusImageView.image = statusImage;
    self.approvalStatusLabel.text = statusTitle;
    self.approvalStatusLabel.textColor = titleColor;
}


@end
