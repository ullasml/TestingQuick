//
//  BookedTimeOffCalendarViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 6/28/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "BookedTimeOffCalendarViewController.h"
#import "Constants.h"
#import "Util.h"

@interface BookedTimeOffCalendarViewController ()

@end

@implementation BookedTimeOffCalendarViewController
@synthesize calendarView;
@synthesize selectedStartDate;
@synthesize selectedEndDate;
@synthesize tempSelectedStartDate;
@synthesize tempSelectedEndDate;
@synthesize timeoffTypeLbl;
@synthesize timeoffTypeValueLbl;
@synthesize mainScrollView;
@synthesize isCollapse;
@synthesize collapseBtn;
@synthesize delegate;
@synthesize isFirstTime;
@synthesize progressView;

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
    TKCalendarMonthView *_calendarView = [[TKCalendarMonthView alloc] initWithSundayAsFirst:YES forMonthDate:[NSDate date] showCompleteCalendar:NO];
	_calendarView.delegate = self;
	_calendarView.dataSource = self;
    self.calendarView=_calendarView;
  
	
    self.collapseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.collapseBtn setBackgroundColor:[UIColor clearColor]];
    UIImage *moreButtonImage=[Util thumbnailImage:BALANCE_TAB_ARROW_IMAGE];
	[self.collapseBtn setImage:moreButtonImage forState:UIControlStateNormal];
    [ self.collapseBtn addTarget:self action:@selector(collapseAction) forControlEvents:UIControlEventTouchUpInside];
    //self.collapseBtn.frame=CGRectMake(150.5, 311, 19.0, 7.0);
    self.collapseBtn.frame=CGRectMake(0, 311, 320.0, 60.0);
    self.collapseBtn.imageEdgeInsets = UIEdgeInsetsMake(-52.0, 0, 0, 0);
    
//    if (isFirstTime) 
//    {
//        [self viewDidAppear:FALSE];
//        self.isFirstTime=FALSE;
//    }
    
    for (UIView *view in self.view.subviews)
    {
        [view removeFromSuperview];
    }
    
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width , self.view.frame.size.height +50);
    scrollView.backgroundColor=[UIColor clearColor];
    [scrollView setScrollEnabled:NO];
    [self.view addSubview:scrollView];
    [scrollView addSubview:self.calendarView];
    
    self.mainScrollView=scrollView;
    
    [self.mainScrollView addSubview:collapseBtn];
    
    [collapseBtn setHidden:TRUE];
    
    UILabel *temptimeoffTypeLbl=[[UILabel alloc]initWithFrame:CGRectMake(10, 280.0, 200.0, 20.0)];
    self.timeoffTypeLbl=temptimeoffTypeLbl;
    
    [self.timeoffTypeLbl setBackgroundColor:[UIColor clearColor]];
    [self.timeoffTypeLbl setText:@"VACATION BALANCE:"];                           
    self.timeoffTypeLbl.textAlignment=NSTextAlignmentLeft;
    [self.timeoffTypeLbl setTextColor:RepliconStandardNavBarTintColor];
	[self.timeoffTypeLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:18.0]];
    [scrollView addSubview:self.timeoffTypeLbl];
    
    
    UILabel *temptimeoffTypeValueLbl=[[UILabel alloc]initWithFrame:CGRectMake(230, 280.0, 80.0, 20.0)];
    self.timeoffTypeValueLbl=temptimeoffTypeValueLbl;
   
    [self.timeoffTypeValueLbl setBackgroundColor:[UIColor clearColor]];
    [self.timeoffTypeValueLbl setText:@"0.4 Days"];                           
    self.timeoffTypeValueLbl.textAlignment=NSTextAlignmentRight;
    [self.timeoffTypeValueLbl setTextColor:RepliconStandardNavBarTintColor];
	[self.timeoffTypeValueLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:18.0]];
    [scrollView addSubview:self.timeoffTypeValueLbl];
    
    
    
    
    
    
    
    
    if(self.calendarView.frame.size.height>300.0)//6 row calendar
    {
        CGRect frame=self.timeoffTypeLbl.frame;
        frame.origin.y=335.0;
        self.timeoffTypeLbl.frame=frame;
        frame=self.timeoffTypeValueLbl.frame;
        frame.origin.y=335.0;
        self.timeoffTypeValueLbl.frame=frame;
        self.isCollapse=TRUE;
        
        
        
    }
    else 
    {
        CGRect frame=self.timeoffTypeLbl.frame;
        frame.origin.y=285.0;
        self.timeoffTypeLbl.frame=frame;
        frame=self.timeoffTypeValueLbl.frame;
        frame.origin.y=285.0;
        self.timeoffTypeValueLbl.frame=frame;
        self.isCollapse=FALSE;
        
        
    }
    
    
   
		UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView setFrame:CGRectMake(135, 125, 50, 50)];
        [indicatorView setHidesWhenStopped:YES];
        [indicatorView startAnimating];
        [tempView addSubview:indicatorView];
        if ([[[UIDevice currentDevice] systemVersion] newFloatValue] >= 5.0f) {
            indicatorView.color=[UIColor blackColor];
        }
    
        tempView.backgroundColor=[UIColor whiteColor];
        tempView.alpha=0.5;
        self.progressView=tempView;
    
	  
    
    [self.mainScrollView addSubview:self.progressView];
    
    [self performSelector:@selector(paintCalendarFromAPICall) withObject:nil afterDelay:2];
}





- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"ScreenMode"];
        [defaults synchronize];
}


-(void)paintCalendarFromAPICall
{
    NSMutableDictionary *dict=[Util generateCalendarSupportData];
    [self.calendarView paint_ApproveRejectedWaiting_Dates_To_Calendar:dict withWeekends:[dict objectForKey:BOOKED_TIMEOFF_WEEKEND_DATE_KEY]];
    [self.progressView removeFromSuperview];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSArray*) calendarMonthView:(TKCalendarMonthView*)monthView marksFromDate:(NSDate*)startDate toDate:(NSDate*)lastDate{
    
    NSArray *data =nil;
    if (selectedStartDate!=nil && selectedEndDate!=nil && [selectedStartDate compare:selectedEndDate]!=NSOrderedSame)
    {
        NSMutableArray *datesArray=[NSMutableArray array];
        
        //enddate greater than startdate
        if ([self.selectedStartDate compare:self.selectedEndDate]==NSOrderedAscending)
        {
            for (NSDate *nextDate = selectedEndDate ; [nextDate compare:selectedStartDate] >= 0 ; nextDate = [nextDate dateByAddingTimeInterval:-(24*60*60)] ) 
            {
                [datesArray addObject:nextDate];
            } 
            
        }
        //startdate greater than enddate
        else
        {
            for (NSDate *nextDate = selectedStartDate ; [nextDate compare:selectedEndDate]>= 0 ; nextDate = [nextDate dateByAddingTimeInterval:-(24*60*60)] ) 
            {
                [datesArray addObject:nextDate];
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
   
    /*self.selectedStartDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStartDate"];
    self.selectedEndDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedEndDate"];
    
    [_calendarView reload];*/
}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView monthDidChange:(NSDate*)month isNextPreviousBtn:(BOOL)isNextPreviousBtn animated:(BOOL)animated
{
    
    
    
    //Do not alter the selectedstartdate and selectedenddate
     if(self.calendarView.frame.size.height>300.0)//6 row calendar
     {
         [UIView beginAnimations:nil context:NULL];
         [UIView setAnimationDuration:0.5];
         CGRect frame=self.timeoffTypeLbl.frame;
         frame.origin.y=335.0;
         self.timeoffTypeLbl.frame=frame;
         frame=self.timeoffTypeValueLbl.frame;
         frame.origin.y=335.0;
         self.timeoffTypeValueLbl.frame=frame;
         self.isCollapse=TRUE;
          [UIView commitAnimations];
         
         
     }
     else 
     {
         [UIView beginAnimations:nil context:NULL];
         [UIView setAnimationDuration:0.4];
         CGRect frame=self.timeoffTypeLbl.frame;
         frame.origin.y=285.0;
         self.timeoffTypeLbl.frame=frame;
         frame=self.timeoffTypeValueLbl.frame;
         frame.origin.y=285.0;
         self.timeoffTypeValueLbl.frame=frame;
          self.isCollapse=FALSE;
         [UIView commitAnimations];
        
     }
    
    
    //HIPMUNK CALENDAR CHANGE------
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if(!isNextPreviousBtn)
    {
        NSDate *tmpStartDate=[defaults objectForKey:@"selectedStartDate"];
        NSDate *tmpEndDate=[defaults objectForKey:@"selectedEndDate"];
        
        
        if (tmpStartDate!=nil && tmpEndDate!=nil) 
        {
            if ([month compare:self.selectedStartDate]==NSOrderedSame) 
            {
                
                self.selectedStartDate=nil;
            }
            else if ([month compare:self.selectedEndDate]==NSOrderedSame) 
            {
                
                self.selectedEndDate=nil;
            }
            else {
                self.selectedStartDate=nil;
                self.selectedEndDate=nil;
            }
            [defaults removeObjectForKey:@"selectedEndDate"];
            [defaults removeObjectForKey:@"selectedStartDate"];
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
    
    //------------------

    //self.selectedStartDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStartDate"];
    //self.selectedEndDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedEndDate"];
    
    [UIView beginAnimations:nil context:NULL]; 
    [UIView setAnimationDuration:1.0];
    
    if(!isNextPreviousBtn && self.isCollapse)//6 row calendar
    {
        CGPoint point=CGPointMake(0, 50.0 );
        self.mainScrollView.contentOffset=point;
        
        
    }
    
    else {
        CGPoint point=CGPointMake(0, 0.0 );
        self.mainScrollView.contentOffset=point;
        
         self.collapseBtn.hidden=TRUE;
    }
    
     [UIView commitAnimations];
    if ([delegate respondsToSelector:@selector(didSelectDateForCalendarViewStartDate:forEndDate:)])
        [delegate didSelectDateForCalendarViewStartDate:self.selectedStartDate forEndDate:self.selectedEndDate];
    
    if(!isNextPreviousBtn && self.isCollapse)//6 row calendar
    {
        [self performSelector:@selector(showCollapseButton) withObject:nil afterDelay:1.0];
    }
    else {
        self.collapseBtn.hidden=TRUE;
    }
}

-(void)showCollapseButton
{
    self.collapseBtn.hidden=FALSE;
}

-(void)collapseAction
{
    [UIView beginAnimations:nil context:NULL]; 
    [UIView setAnimationDuration:1.0];
    
    CGPoint point=CGPointMake(0, 0.0 );
    self.mainScrollView.contentOffset=point;
    
    self.collapseBtn.hidden=TRUE;
    
    [UIView commitAnimations];
}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView didSelectDate:(NSDate*)date
{
    //self.selectedStartDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStartDate"];
    //self.selectedEndDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedEndDate"];
    
    //HIPMUNK CALENDAR CHANGE------
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDate *tmpStartDate=[defaults objectForKey:@"selectedStartDate"];
    NSDate *tmpEndDate=[defaults objectForKey:@"selectedEndDate"];
    
    
    if (tmpStartDate!=nil && tmpEndDate!=nil) 
    {
        
        if ([date compare:self.selectedStartDate]==NSOrderedSame) 
        {
            
            self.selectedStartDate=nil;
        }
        else if ([date compare:self.selectedEndDate]==NSOrderedSame) 
        {
            
            self.selectedEndDate=nil;
        }
        else {
            self.selectedStartDate=nil;
            self.selectedEndDate=nil;
        }
        [defaults removeObjectForKey:@"selectedEndDate"];
        [defaults removeObjectForKey:@"selectedStartDate"];
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
    [self.calendarView reload];
    
    [UIView beginAnimations:nil context:NULL]; 
    [UIView setAnimationDuration:1.0];
        
    //------------------
    if(isCollapse)//6 row calendar
    {
        CGPoint point=CGPointMake(0, 50.0 );
        self.mainScrollView.contentOffset=point;
        
        
        self.collapseBtn.hidden=FALSE;
    }
    
    else {
        CGPoint point=CGPointMake(0, 0.0 );
        self.mainScrollView.contentOffset=point;
        
        self.collapseBtn.hidden=TRUE;

    }
        
   [UIView commitAnimations];
    

    
    if ([delegate respondsToSelector:@selector(didSelectDateForCalendarViewStartDate:forEndDate:)])
        [delegate didSelectDateForCalendarViewStartDate:self.selectedStartDate forEndDate:self.selectedEndDate];
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.timeoffTypeLbl=nil;
    self.timeoffTypeValueLbl=nil;
    self.mainScrollView=nil;
    self.collapseBtn=nil;
//    self.calendarView=nil;
    self.progressView=nil;
}




@end
