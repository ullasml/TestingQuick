#import "BookedTimeOffDateSelectionViewController.h"
#import "Constants.h"
#import "Util.h"


@interface BookedTimeOffDateSelectionViewController ()

@end

@implementation BookedTimeOffDateSelectionViewController
@synthesize calendarView;
@synthesize selectedStartDate;
@synthesize selectedEndDate;
@synthesize tempSelectedStartDate;
@synthesize tempSelectedEndDate;
@synthesize delegate;
@synthesize requestedTimeOffValueLb,balanceValueLbl;
@synthesize screenMode;
@synthesize progressView;
@synthesize entryDelegate;

#define ROW_HEIGHT 48.0

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    TKCalendarMonthView *_calendarView=nil;

    if (self.screenMode==SELECT_START_DATE_SCREEN)
    {
        if (self.selectedStartDate!=nil) {
            _calendarView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES forMonthDate:self.selectedStartDate  showCompleteCalendar:YES];
        }
        else {

            if (self.selectedEndDate!=nil)
            {
                _calendarView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES forMonthDate:self.selectedEndDate  showCompleteCalendar:YES];
            }
            else {
                _calendarView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES forMonthDate:[NSDate date]  showCompleteCalendar:YES];
            }

        }

    }
    else
    {
        if (self.selectedEndDate!=nil) {
            _calendarView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES forMonthDate:self.selectedEndDate  showCompleteCalendar:YES];
        }
        else {
            if (self.selectedStartDate!=nil)
            {
                _calendarView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES forMonthDate:self.selectedStartDate  showCompleteCalendar:YES];
            }
            else {
                _calendarView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES forMonthDate:[NSDate date]  showCompleteCalendar:YES];
            }

        }

    }

    CGRect frame = _calendarView.frame;
    frame.origin.y = 0;
    _calendarView.frame = frame;
    self.calendarView=_calendarView;

    self.calendarView.delegate = self;
    self.calendarView.dataSource = self;

    [self.calendarView setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:self.calendarView];


    NSDate *tmpStartDate=nil;
    NSDate *tmpEndDate=nil;
    if (self.selectedStartDate!=nil) {
        tmpStartDate=[Util constructDesiredFormattedDateForDate:self.selectedStartDate];
    }
    else {
        tmpStartDate=self.selectedStartDate;
    }
    if (self.selectedEndDate!=nil) {
        tmpEndDate=[Util constructDesiredFormattedDateForDate:self.selectedEndDate];
    }
    else {
        tmpEndDate=self.selectedEndDate;
    }

    [defaults setObject:tmpStartDate forKey:@"selectedStartDate"];
    [defaults setObject:tmpEndDate forKey:@"selectedEndDate"];
    [defaults synchronize];
    [_calendarView reload];

    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [Util setToolbarLabel: self withText: RPLocalizedString(BOOKED_TIMEOFF_CHOOSE_DATES_TITLE, BOOKED_TIMEOFF_CHOOSE_DATES_TITLE)];


    //[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    self.navigationController.navigationBar.topItem.title=RPLocalizedString(BACK, BACK);


    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(@"Cancel", @"Cancel")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(cancelAction)];

    [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];



    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(@"Done", @"Done")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(doneAction)];
    [rightButton setAccessibilityLabel:@"uia_timeoff_done_button_identifier"];

    [self.navigationItem setRightBarButtonItem:rightButton animated:NO];



    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicatorView setFrame:CGRectMake((self.view.bounds.size.width - 50)/2, 125, 50, 50)];
    [indicatorView setHidesWhenStopped:YES];
    [indicatorView startAnimating];
    [tempView addSubview:indicatorView];
    if ([[[UIDevice currentDevice] systemVersion] newFloatValue] >= 5.0f) {
        indicatorView.color=[UIColor blackColor];
    }

    tempView.backgroundColor=RepliconStandardBackgroundColor;
    tempView.alpha=0.5;
    self.progressView=tempView;



    [self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];

    [self performSelector:@selector(paintCalendarFromAPICall) withObject:nil afterDelay:2];
}

-(void)paintCalendarFromAPICall
{
    NSMutableDictionary *dict=[Util generateCalendarSupportData];
    [self.calendarView paint_ApproveRejectedWaiting_Dates_To_Calendar:dict withWeekends:[dict objectForKey:BOOKED_TIMEOFF_WEEKEND_DATE_KEY]];
    [self.progressView removeFromSuperview];
}


-(void)cancelAction
{
    CLS_LOG(@"-----Date selection cancel action on BookedTimeOffDateSelectionViewController -----");

    if(self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        /*if ([entryDelegate isKindOfClass:[BookedTimeOffEntryViewController class]]) {
         [entryDelegate setIsComment:YES];
         UITextView *textstr=[entryDelegate commentsTextView];
         [delegate performSelector:@selector(updateComments:) withObject:textstr.text];

         }*/
        [self.navigationController popViewControllerAnimated:YES];
        if([delegate respondsToSelector:@selector(animateCellWhichIsSelected)]){
            [delegate performSelector:@selector(animateCellWhichIsSelected)];
        }
    }
}

-(void)doneAction
{
    CLS_LOG(@"-----Date selection done action on BookedTimeOffDateSelectionViewController -----");
    if(self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION)
    {
        if([delegate respondsToSelector:@selector(didSelectStartAndEndDate:forEndDate:)])
            [delegate didSelectStartAndEndDate:self.selectedStartDate forEndDate:self.selectedEndDate];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(didSelectDateForStartDate:forEndDate:)])
            [delegate didSelectDateForStartDate:self.selectedStartDate forEndDate:self.selectedEndDate];

        /* if ([delegate isKindOfClass:[BookedTimeOffEntryViewController class]]) {

         [delegate performSelector:@selector(updateEntry) withObject:nil];

         }*/
        [self.navigationController popViewControllerAnimated:YES];
        if([delegate respondsToSelector:@selector(animateCellWhichIsSelected)]){
            [delegate performSelector:@selector(animateCellWhichIsSelected)];
        }
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{

    NSArray *data =nil;
    if (self.selectedStartDate!=nil) {
        self.selectedStartDate=[Util constructDesiredFormattedDateForDate:selectedStartDate];
    }
    if (self.selectedEndDate!=nil) {
        self.selectedEndDate=[Util constructDesiredFormattedDateForDate:selectedEndDate];
    }
    if (self.selectedEndDate==nil && self.selectedStartDate==nil) {
        self.selectedStartDate=nil;
        self.selectedEndDate=nil;
    }

    if (selectedStartDate!=nil && selectedEndDate!=nil && [selectedStartDate compare:selectedEndDate]!=NSOrderedSame)
    {
        NSMutableArray *datesArray=[NSMutableArray array];

        //enddate greater than startdate
        if ([self.selectedStartDate compare:self.selectedEndDate]==NSOrderedAscending)
        {
            for (NSDate *nextDate = selectedEndDate ; [nextDate compare:selectedStartDate] >= 0 ; nextDate = [nextDate dateByAddingTimeInterval:-(24*60*60)] )
            {

                NSDate *temp=[Util constructDesiredFormattedDateForDate:nextDate];
                [datesArray addObject:temp];
            }

        }
        //startdate greater than enddate
        else
        {
            for (NSDate *nextDate = selectedStartDate ; [nextDate compare:selectedEndDate]>= 0 ; nextDate = [nextDate dateByAddingTimeInterval:-(24*60*60)] )
            {
                NSDate *temp=[Util constructDesiredFormattedDateForDate:nextDate];
                [datesArray addObject:temp];

            }
        }

        data = datesArray;

    }
    else
    {
        data = [NSArray arrayWithObjects:
                selectedStartDate,nil];
    }


    // Initialise empty marks array, this will be populated with TRUE/FALSE in order for each day a marker should be placed on.
    NSMutableArray *marks = [NSMutableArray array];

    // Initialise calendar to current type and set the timezone to never have daylight saving
    NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    // Construct DateComponents based on startDate so the iterating date can be created.
    // Its massively important to do this assigning via the NSCalendar and NSDateComponents because of daylight saving has been removed
    // with the timezone that was set above. If you just used "startDate" directly (ie, NSDate *date = startDate;) as the first
    // iterating date then times would go up and down based on daylight savings.
    NSDateComponents *comp = [cal components:(NSCalendarUnitMonth | NSCalendarUnitMinute | NSCalendarUnitYear |
                                              NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitSecond)
                                    fromDate:startDate];
    NSDate *d = [cal dateFromComponents:comp];

    // Init offset components to increment days in the loop by one each time
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];


    // for each date between start date and end date check if they exist in the data array
    while (YES) {
        // Is the date beyond the last date? If so, exit the loop.
        // NSOrderedDescending = the left value is greater than the right
        if ([d compare:lastDate] == NSOrderedDescending) {
            break;
        }

        // If the date is in the data array, add it to the marks array, else don't
        if (  ([d compare:selectedStartDate] == NSOrderedSame  && selectedStartDate!=nil ) ||  ([d compare:selectedEndDate] == NSOrderedSame && selectedEndDate!=nil))
        {
            [marks addObject:[NSNumber numberWithInt:1]];
        }
        else if ([data containsObject:d]) {
            [marks addObject:[NSNumber numberWithInt:-1]];
        } else {
            [marks addObject:[NSNumber numberWithInt:0]];
        }

        // Increment day using offset components (ie, 1 day in this instance)
        d = [cal dateByAddingComponents:offsetComponents toDate:d options:0];
    }





    return [NSArray arrayWithArray:marks];
}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDateForDoubleTap:(NSDate*)date
{

    self.selectedStartDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStartDate"];
    self.selectedEndDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedEndDate"];

    [self.calendarView reload];
}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView monthDidChange:(NSDate*)month isNextPreviousBtn:(BOOL)isNextPreviousBtn animated:(BOOL)animated
{
    //Do not alter the selectedstartdate and selectedenddate

    /*self.selectedStartDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStartDate"];
     self.selectedEndDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedEndDate"];*/

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if(!isNextPreviousBtn)
    {
        NSDate *tmpStartDate=[defaults objectForKey:@"selectedStartDate"];
        NSDate *tmpEndDate=[defaults objectForKey:@"selectedEndDate"];


        if (tmpStartDate!=nil && tmpEndDate!=nil)
        {
            if ([tmpStartDate compare:tmpEndDate]==NSOrderedSame)
            {
                self.selectedEndDate=month;
                [defaults setObject:month forKey:@"selectedEndDate"];
            }
            else {
                self.selectedStartDate=nil;
                self.selectedEndDate=nil;
                [defaults removeObjectForKey:@"selectedEndDate"];
                [defaults removeObjectForKey:@"selectedStartDate"];

            }
            [defaults synchronize];


        }

        if (self.selectedStartDate==nil && self.selectedEndDate==nil)
        {
            self.selectedStartDate=month;
            self.selectedEndDate=month;
            [defaults setObject:month forKey:@"selectedStartDate"];
        }

        else if (self.selectedStartDate!=nil && self.selectedEndDate!=nil)
        {
            if ([self.selectedStartDate compare:month]!=NSOrderedSame)
            {
                self.selectedEndDate=month;
                [defaults setObject:month forKey:@"selectedEndDate"];

            }
            else if ([self.selectedStartDate compare:month]==NSOrderedSame) {
                self.selectedStartDate=nil;
                self.selectedEndDate=nil;
            }

        }
        else
        {
            if ([month compare:self.selectedStartDate]==NSOrderedSame) {
                month=self.selectedEndDate;
            }
            else if ([month compare:self.selectedEndDate]==NSOrderedSame) {
                month=self.selectedStartDate;
            }

            self.selectedStartDate=month;
            self.selectedEndDate=month;
            [defaults setObject:month forKey:@"selectedStartDate"];

        }

        [defaults synchronize];
    }


}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date
{
    /*self.selectedStartDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStartDate"];
     self.selectedEndDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedEndDate"];
     [_calendarView reload];*/


    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDate *tmpStartDate=[defaults objectForKey:@"selectedStartDate"];
    NSDate *tmpEndDate=[defaults objectForKey:@"selectedEndDate"];


    if (tmpStartDate!=nil && tmpEndDate!=nil)
    {
        if ([tmpStartDate compare:tmpEndDate]==NSOrderedSame)
        {
            self.selectedEndDate=date;
            [defaults setObject:date forKey:@"selectedEndDate"];
        }
        else {
            self.selectedStartDate=nil;
            self.selectedEndDate=nil;
            [defaults removeObjectForKey:@"selectedEndDate"];
            [defaults removeObjectForKey:@"selectedStartDate"];

        }
        [defaults synchronize];
    }


    if (self.selectedStartDate==nil && self.selectedEndDate==nil)
    {
        self.selectedStartDate=date;
        self.selectedEndDate=date;
        [defaults setObject:date forKey:@"selectedStartDate"];
    }
    else if (self.selectedStartDate!=nil && self.selectedEndDate!=nil)
    {
        if ([self.selectedStartDate compare:date]!=NSOrderedSame)
        {
            self.selectedEndDate=date;
            [defaults setObject:date forKey:@"selectedEndDate"];
        }
        else if ([self.selectedStartDate compare:date]==NSOrderedSame) {
            self.selectedStartDate=nil;
            self.selectedEndDate=nil;
        }
    }
    else
    {
        if ([date compare:self.selectedStartDate]==NSOrderedSame) {
            date=self.selectedEndDate;
        }
        else if ([date compare:self.selectedEndDate]==NSOrderedSame) {
            date=self.selectedStartDate;
        }

        self.selectedStartDate=date;
        self.selectedEndDate=date;
        [defaults setObject:date forKey:@"selectedStartDate"];

    }

    [defaults synchronize];
    [calendarView reload];
    
}









- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.requestedTimeOffValueLb=nil;
    //    self.calendarView=nil;
    self.progressView=nil;
}




@end
