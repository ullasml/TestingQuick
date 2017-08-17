//
//  PunchClockViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 12/19/11.
//  Copyright (c) 2011 Replicon. All rights reserved.
//

#import "G2PunchClockViewController.h"
#import "G2Constants.h"
#import "G2TimesheetModel.h"
#import "G2Util.h"
#import "FrameworkImport.h"
#import "G2RepliconServiceManager.h"
#import "G2TimeSheetEntryObject.h"
#import "RepliconAppDelegate.h"
#import "G2PermissionsModel.h"

@implementation G2PunchClockViewController
@synthesize  bgImageView;
@synthesize  currentDateLbl;
@synthesize  hourLbl,hourLbl1;
@synthesize  minsLbl,minsLbl1;
@synthesize  colonLbl;
@synthesize  am_pm_Lbl;
@synthesize  punchInOutHeaderLbl;
@synthesize  punchInOutValueLbl,punchInOutValueLbl1;
@synthesize  clockOnOffHeaderLbl;
@synthesize  clockOnOffValueLbl,clockOnOffValueLbl1;
@synthesize  punchButton;
@synthesize  clockImageView;
@synthesize hiddentimer;
@synthesize visibleTimer;
@synthesize timer;
@synthesize  isAutoPunchOut;
@synthesize autotTimer;
@synthesize  isFromPunchButton,isErrorAlert;
@synthesize  isStop;
@synthesize isNotRunAutoRefresh;
@synthesize temporarySelectedDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isStop=FALSE;
    
}




-(void)viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
    
    
    hourLbl1.hidden=TRUE;
    minsLbl1.hidden=TRUE;
    hourLbl.hidden=TRUE;
    minsLbl.hidden=TRUE;
    am_pm_Lbl.hidden=TRUE;
    
    isFromPunchButton=FALSE;
    isErrorAlert=FALSE;
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.temporarySelectedDate=[NSDate date];
    appDelegate.punchClockIsZeroTimeEntries=TRUE;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_PUNCH_DETAILS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refreshPunchDetails)
                                                 name: REFRESH_PUNCH_DETAILS
                                               object: nil];
    [self timeEntryActionForPunchDetailsFromLoadOrTimer ];
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showClock) userInfo:nil repeats:YES];
    
    
    
    
    
    
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    //    [self refreshPunchDetails];
    
    self.autotTimer=[NSTimer scheduledTimerWithTimeInterval:AUTO_SYNC_PUNCH_STATUS target:self selector:@selector(timeEntryActionForPunchDetailsFromLoadOrTimer) userInfo:nil repeats:YES];
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.locationController) {
        G2MyCLController *templocationController = [[G2MyCLController alloc] init];
        appDelegate.locationController=templocationController;
        
        appDelegate.locationController.delegate = appDelegate;;
        
    }
    if ([appDelegate.locationController.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [appDelegate.locationController.locationManager requestWhenInUseAuthorization];
    }

    /*if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        [appDelegate.locationController.locationManager requestAlwaysAuthorization];
        [appDelegate.locationController.locationManager requestWhenInUseAuthorization];
    }*/

    [appDelegate.locationController.locationManager startUpdatingLocation];


    //appDelegate.isLocationServiceEnabled=TRUE;
    
    appDelegate.isFirstTimeAppLaunchedAtPunchClock=TRUE;
    
    if (!appDelegate.isShowPunchButton) {
        [self.punchButton setHidden:TRUE];
    }
    
    
    
    NSArray *navViewCtrlsArr=[appDelegate.navController viewControllers];
    for (int i=0;i<[navViewCtrlsArr count]; i++) {
        if ([[navViewCtrlsArr objectAtIndex:i] isKindOfClass:[G2HomeViewController class]]) {
            [[NSNotificationCenter defaultCenter] removeObserver: [navViewCtrlsArr objectAtIndex:i] name: @"allTimesheetRequestsServed" object: nil];
            
            break;
            
        }
    }
    
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REFRESH_PUNCH_DETAILS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allLockedTimesheetRequestsServed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FETCH_LOCKEDINOUT_TIMESHEET_FOR_ENTRY_DATE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCKED_TIME_ENTRY_SAVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCKED_TIME_ENTRY_EDITED_NOTIFICATION object:nil];
    
    [timer invalidate];
    [autotTimer invalidate];
}

- (void)timeEntryActionForPunchDetails {
    
    if ( [NetworkMonitor isNetworkAvailableForListener:self] == YES)
        
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allLockedTimesheetRequestsServed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleProcessCompleteActions)
                                                     name: @"allLockedTimesheetRequestsServed"
                                                   object: nil];
        isStop=TRUE;
        
        if (isFromPunchButton)
        {
            RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            appDelegate.punchClockIsZeroTimeEntries=FALSE;
        }
        
        [[G2RepliconServiceManager lockedInOutTimesheetService]fetchTimeSheetUSerDataForDate: self andDate:[NSDate date]];
        
	}
	else
    {
        isFromPunchButton=NO;
		[G2Util showOfflineAlert];
		return;
        
	}
}

- (void)timeEntryActionForPunchDetailsFromLoadOrTimer {
    
    if ( [NetworkMonitor isNetworkAvailableForListener:self] == YES)
        
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allLockedTimesheetRequestsServed" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleProcessCompleteActions)
                                                     name: @"allLockedTimesheetRequestsServed"
                                                   object: nil];
        isStop=TRUE;
        [[G2RepliconServiceManager lockedInOutTimesheetService]fetchTimeSheetUSerDataForDate: self andDate:[NSDate date]];
        
	}
	else
    {
		[G2Util showOfflineAlert];
		return;
        
	}
}


-(void)showClock
{
    
    NSDate *dateShow= [NSDate dateWithTimeIntervalSinceNow:0];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
    //[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
	[dateFormat setTimeStyle:NSDateFormatterShortStyle];
	NSString *dateString = [dateFormat stringFromDate:dateShow];
    NSArray *componentsArr0=[dateString componentsSeparatedByString:@":"];
    if ([componentsArr0 count]>1) {
        if ([[componentsArr0 objectAtIndex:0]intValue]>12 || [[componentsArr0 objectAtIndex:0]intValue]==0 || [[componentsArr0 objectAtIndex:0]intValue]==12)
        {
            hourLbl.text = [NSString stringWithFormat:@"%d",  [[componentsArr0 objectAtIndex:0]intValue]-12 ];
            am_pm_Lbl.text=@"PM";
            if ([hourLbl.text intValue]<0) {
                hourLbl.text = @"12";
                am_pm_Lbl.text=@"AM";
            }
            if ([hourLbl.text intValue]==0) {
                hourLbl.text = @"12";
                am_pm_Lbl.text=@"PM";
            }
            
            
        }
        else
        {
            hourLbl.text = [componentsArr0 objectAtIndex:0];
            am_pm_Lbl.text=@"AM";
        }
        
        if (![hourLbl.text isKindOfClass:[NSNull class] ])
        {
            
            if ([hourLbl.text length]==2) {
                CGRect frame=CGRectMake(39.0, 125.0, 99.0, 86.0);
                hourLbl.frame=frame;
                frame=CGRectMake(143.0, 125.0, 18.0, 86.0);
                colonLbl.frame=frame;
                frame=CGRectMake(171.0, 125.0, 99.0, 86.0);
                minsLbl.frame=frame;
                frame=CGRectMake(260.0, 177.0, 37.0, 29.0);
                am_pm_Lbl.frame=frame;
            }
            else
            {
                CGRect frame=CGRectMake(19.0, 125.0, 99.0, 86.0);
                hourLbl.frame=frame;
                frame=CGRectMake(123.0, 125.0, 18.0, 86.0);
                colonLbl.frame=frame;
                frame=CGRectMake(151.0, 125.0, 99.0, 86.0);
                minsLbl.frame=frame;
                frame=CGRectMake(240.0, 177.0, 37.0, 29.0);
                am_pm_Lbl.frame=frame;
                
                
            }
        }
        
        
        NSString *minsStr=[componentsArr0 objectAtIndex:1];
        NSArray *componentsArr1=[minsStr componentsSeparatedByString:@" "];
        if ([componentsArr1 count]>1) {
            minsLbl.text=[componentsArr1 objectAtIndex:0];
            am_pm_Lbl.text=[componentsArr1 objectAtIndex:1];
        }
        else if ([componentsArr1 count]==1)
        {
            minsLbl.text=[componentsArr1 objectAtIndex:0];
            
        }
    }
	
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"EEEE, MMMM dd, yyyy"];
    currentDateLbl.text=[dateFormat stringFromDate:dateShow];
   
    colonLbl.text=@":";
    
    
    NSDate *selectedDate=[NSDate date];
    if (isAutoPunchOut) {
        
        [self updateClockOnOffLabelForPunchIn:selectedDate andTime: punchInOutValueLbl1.text];
        NSArray *hrminsArr=[ clockOnOffValueLbl1.text componentsSeparatedByString:@" "];
        if ([hrminsArr count]>3) {
            clockOnOffValueLbl1.text=[NSString stringWithFormat:@"%d HRS %d MIN",[[hrminsArr objectAtIndex:0]intValue]+pasthrsValue,[[hrminsArr objectAtIndex:2]intValue]+pastminsValue];
        }
        
        [self updateClockOnOffLabelForTimeIn:punchInOutValueLbl.text];
        NSArray *hrminsArr0=[ clockOnOffValueLbl.text componentsSeparatedByString:@" "];
        if ([hrminsArr0 count]>3) {
            clockOnOffValueLbl.text=[NSString stringWithFormat:@"%d HRS %d MIN",[[hrminsArr0 objectAtIndex:0]intValue],[[hrminsArr0 objectAtIndex:2]intValue]];
        }
    }
    else
    {
        [self updateClockOnOffLabelForPunchIn:selectedDate andTime: punchInOutValueLbl.text];
    }
    
    //    }
    
    if ([hourLbl.text isEqualToString:@"12"] && [minsLbl.text isEqualToString:@"00"] && [am_pm_Lbl.text isEqualToString:@"AM"]) {
        if (!isNotRunAutoRefresh) {
            isNotRunAutoRefresh=TRUE;
            
            [self timeEntryActionForPunchDetailsFromLoadOrTimer];
        }
        
    }
    else
    {
        isNotRunAutoRefresh=FALSE;
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"])
    {
        minsLbl1.text=minsLbl.text;
        if ([am_pm_Lbl.text isEqualToString:@"AM"]) {
            if ([hourLbl.text isEqualToString:@"12"]) {
                hourLbl1.text=@"0";
            }
            else
            {
                hourLbl1.text=hourLbl.text;
            }
            
        }
        else
        {
            if ([hourLbl.text isEqualToString:@"12"]) {
                hourLbl1.text=@"12";
            }
            else
            {
                hourLbl1.text=[NSString stringWithFormat:@"%d",[hourLbl.text intValue]+12];
            }
            
        }
        
        
        if (![hourLbl1.text isKindOfClass:[NSNull class] ])
        {
            if ([hourLbl1.text length]==2) {
                CGRect frame=CGRectMake(49.0, 125.0, 99.0, 86.0);
                hourLbl1.frame=frame;
                frame=CGRectMake(153.0, 125.0, 18.0, 86.0);
                colonLbl.frame=frame;
                frame=CGRectMake(181.0, 125.0, 99.0, 86.0);
                minsLbl1.frame=frame;
            }
            else
            {
                CGRect frame=CGRectMake(29.0, 125.0, 99.0, 86.0);
                hourLbl1.frame=frame;
                frame=CGRectMake(133.0, 125.0, 18.0, 86.0);
                colonLbl.frame=frame;
                frame=CGRectMake(161.0, 125.0, 99.0, 86.0);
                minsLbl1.frame=frame;
                
            }
        }
        
        
        
        
        
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"]) {
        hourLbl.hidden=FALSE;
        minsLbl.hidden=FALSE;
        am_pm_Lbl.hidden=FALSE;
    }
    else
    {
        hourLbl1.hidden=FALSE;
        minsLbl1.hidden=FALSE;
        
    }
    
}

-(IBAction)punchBtnClicked:(id)sender
{
    
    [G2RepliconServiceManager lockedInOutTimesheetService].totalRequestsSent=0;
    [G2RepliconServiceManager lockedInOutTimesheetService].totalRequestsServed=0;
    self.temporarySelectedDate=[NSDate date];
    isPreviousTimeSheetPeriodFetched=NO;
    
    G2TimesheetModel *timesheetModel = [[G2TimesheetModel alloc] init];
    NSMutableArray *dbTimeentriesArray = [timesheetModel getTimeEntryForWithDate:[NSDate date]];
   
    BOOL canPunch=TRUE;
    if ([dbTimeentriesArray count]>0) {
        if ([[dbTimeentriesArray objectAtIndex:0] objectForKey:@"approvalStatus"]!=nil || ![[[dbTimeentriesArray objectAtIndex:0] objectForKey:@"approvalStatus"] isKindOfClass:[NSNull class]])
        {
            if ([[[dbTimeentriesArray objectAtIndex:0] objectForKey:@"approvalStatus"] isEqualToString:@"Waiting For Approval"]) {
                canPunch=FALSE;
            }
            else if ([[[dbTimeentriesArray objectAtIndex:0] objectForKey:@"approvalStatus"] isEqualToString:@"Approved"]) {
                canPunch=FALSE;
            }
        }
    }
    else
    {
        NSString *approvalStatus=[[NSUserDefaults standardUserDefaults] objectForKey:PUNCHCLOCK_NOENTRIES_APPROVAL_STATUS];
        if (approvalStatus!=nil || ![approvalStatus isKindOfClass:[NSNull class]])
        {
            if ([approvalStatus isEqualToString:@"Waiting For Approval"]) {
                canPunch=FALSE;
            }
            else if ([approvalStatus isEqualToString:@"Approved"]) {
                canPunch=FALSE;
            }
        }
    }
    
    if (canPunch) {
        isFromPunchButton=TRUE;
        
        [self timeEntryActionForPunchDetails ];
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        appDelegate.punchClockIsZeroTimeEntries=FALSE;
        
        if ([punchButton.titleLabel.text isEqualToString:RPLocalizedString(PUNCHIN, "")])
        {
            // [punchButton setTitle:PUNCHOUT forState:UIControlStateNormal];
            self.hiddentimer=[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(hideSecondsColon) userInfo:nil repeats:NO];
            clockImageView.hidden=FALSE;
        }
        else
        {
            // [punchButton setTitle:PUNCHIN forState:UIControlStateNormal];
            if ([hiddentimer isValid]) {
                [hiddentimer invalidate];
            }
            if ([visibleTimer isValid]) {
                [visibleTimer invalidate];
            }
            clockImageView.hidden=TRUE;
            colonLbl.hidden=FALSE;
        }
        
    }
    else
    {
        G2PermissionsModel *permission=[[G2PermissionsModel alloc]init];
        BOOL reopenPermission=[permission checkUserPermissionWithPermissionName:@"ReopenTimesheet"];//US4660//Juhi
        if ([punchButton.titleLabel.text isEqualToString:RPLocalizedString(PUNCHIN, "")])
        {
            if (reopenPermission)
            {
                [G2Util errorAlert:@"" errorMessage:RPLocalizedString( PunchInMessage,@"")];
            }
            else
                [G2Util errorAlert:@"" errorMessage:RPLocalizedString( @"Please unsubmit your timesheet in order to punch in",@"")];//US4660//Juhi
        }
        else
        {
            if (reopenPermission)
            {
                [G2Util errorAlert:@"" errorMessage:RPLocalizedString( PunchOutMessage,@"")];
            }
            else
                [G2Util errorAlert:@"" errorMessage:RPLocalizedString( @"Please unsubmit your timesheet in order to punch out",@"")];//US4660//Juhi
        }
    
    }
    
}


-(void)hideSecondsColon
{
    colonLbl.hidden=TRUE;
    if ([hiddentimer isValid]) {
        [hiddentimer invalidate];
    }
    self.visibleTimer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showSecondsColon) userInfo:nil repeats:NO];
}
-(void)showSecondsColon
{
    colonLbl.hidden=FALSE;
    if ([visibleTimer isValid]) {
        [visibleTimer invalidate];
    }
    self.hiddentimer=[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hideSecondsColon) userInfo:nil repeats:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}


-(void)refreshPunchDetails
{
    DLog(@"----REFRESHING PUNCH CLOCK-----");
    
    G2TimesheetModel *timesheetModel = [[G2TimesheetModel alloc] init];
    NSDate *selectedDate=[NSDate date];
    
    isAutoPunchOut=FALSE;
    hrsValue=0;
    minsValue=0;
    pasthrsValue=0;
    pastminsValue=0;
    
	NSMutableArray *dbTimeentriesArray = [timesheetModel getTimeEntryForWithDate:selectedDate];
    NSDictionary *entryDict=nil;
    NSDate *lastDate=nil;
    int index=0;
    for (int i=0; i<[dbTimeentriesArray count]; i++)
    {
        entryDict=[dbTimeentriesArray objectAtIndex:i];
        
        if ([entryDict objectForKey:@"time_out"]==nil || [[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]  )
        {
            index=i;
            break;
        }
        else
        {
            if (i>0) {
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [dateFormat setLocale:locale];
                [dateFormat setDateFormat:@"h:mm a"];
                NSDate *timeOutDate = [dateFormat dateFromString:[entryDict objectForKey:@"time_out"]];
               
                NSComparisonResult result = [timeOutDate compare:lastDate];
                if (result==NSOrderedDescending) {
                    //lastdate is future
                    index=i;
                    lastDate=timeOutDate;
                }
                else
                {
                    //do nothing here
                }
            }
            else
            {
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [dateFormat setLocale:locale];
                [dateFormat setDateFormat:@"h:mm a"];
                lastDate = [dateFormat dateFromString:[entryDict objectForKey:@"time_out"]];
                
                index=0;
            }
            
        }
    }
    entryDict=[dbTimeentriesArray objectAtIndex:index];
    NSString *tmp_time_out=[entryDict objectForKey:@"time_out"];
    NSString *tmp_time_in=[entryDict objectForKey:@"time_in"];
    NSMutableArray *previousDBTimeentriesArray = [timesheetModel getTimeEntryForWithDate:[[NSDate date] dateByAddingTimeInterval: -86400.0]];
    
    
    //De4216 //DE10917Ullas
    if (![tmp_time_in isKindOfClass:[NSNull class]] && tmp_time_in!=nil)
    {
        if ([dbTimeentriesArray count]==1 && ([tmp_time_in isEqualToString:@"12:00 AM"] || [tmp_time_in isEqualToString:@"0:00 AM"])&&(tmp_time_out==nil || [tmp_time_out isKindOfClass:[NSNull class]])&& !isFromPunchButton && [previousDBTimeentriesArray count]==0 && isPreviousTimeSheetPeriodFetched==NO)
        {
            if ( [NetworkMonitor isNetworkAvailableForListener:self] == YES)
                
            {
                isPreviousTimeSheetPeriodFetched=YES;
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allLockedTimesheetRequestsServed" object:nil];
                [[NSNotificationCenter defaultCenter] addObserver: self
                                                         selector: @selector(handleProcessCompleteActions)
                                                             name: @"allLockedTimesheetRequestsServed"
                                                           object: nil];
                isStop=TRUE;
                self.temporarySelectedDate=[self.temporarySelectedDate dateByAddingTimeInterval: -86400.0];
                [[G2RepliconServiceManager lockedInOutTimesheetService]fetchTimeSheetUSerDataForDate: self andDate:self.temporarySelectedDate];
                return;
                
            }
            else
            {
                [G2Util showOfflineAlert];
                return;
                
            }
            
        }
        
    }
    
    //isZeroTimeEntries=FALSE;
    if (entryDict)
    {
        
        NSString *time_out=[entryDict objectForKey:@"time_out"];
        
        //PUNCH IN STATUS
        if (time_out==nil || [time_out isKindOfClass:[NSNull class]]||[time_out isEqualToString:@"11:59 PM"]) {
            punchInOutHeaderLbl.text=RPLocalizedString(PUNCHINSTATUS, "");
            clockOnOffHeaderLbl.text=RPLocalizedString(ONCLOCK, "") ;
            
            if (isFromPunchButton) {
                if ([punchButton.titleLabel.text isEqualToString:RPLocalizedString(PUNCHIN, "")])
                {
                    isErrorAlert=TRUE;
                    isFromPunchButton=FALSE;
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                    isStop=FALSE;
                    [G2Util errorAlert:RPLocalizedString(PUNCHCLOCK_ERROR_ALERT, "") errorMessage:@""];
                }
                
            }
            
            [punchButton setTitle:RPLocalizedString(PUNCHOUT, "") forState:UIControlStateNormal];
            
            //CHECK FOR AUTO PUNCH OUT AND CALCULATE LAST MANUAL PUNCH IN
            
            if ([[entryDict objectForKey:@"time_in"] isKindOfClass:[NSString class]]) {
                if ([[entryDict objectForKey:@"time_in"] isEqualToString:@"12:00 AM"] || [[entryDict objectForKey:@"time_in"] isEqualToString:@"0:00 AM"]) {
                    
                    
                    NSMutableArray *previousDBTimeentriesArray = [timesheetModel getTimeEntryForWithDate:[selectedDate dateByAddingTimeInterval: -86400.0]];
                    for (NSInteger i=[previousDBTimeentriesArray count]-1; i>=0; i--)
                    {
                        NSDictionary *entryDict1=[previousDBTimeentriesArray objectAtIndex:i];
                        NSString *time_out1=[entryDict1 objectForKey:@"time_out"];
                        
                        
                        if ([time_out1 isKindOfClass:[NSString class]]) {
                            if ([time_out1 isEqualToString:@"11:59 PM"]) {
                                
                                if ([entryDict1 objectForKey:@"time_in"]!=nil && ![[entryDict1 objectForKey:@"time_in"] isKindOfClass:[NSNull class]] )
                                {
                                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"]) {
                                        punchInOutValueLbl.text=[G2Util convertMidnightTimeFormat: [entryDict1 objectForKey:@"time_in"]];
                                    }
                                    else
                                    {
                                        punchInOutValueLbl.text=[G2Util convert12HourTimeStringTo24HourTimeString:[entryDict1 objectForKey:@"time_in"]];
                                    }
                                    G2TimesheetModel *timesheetModel = [[G2TimesheetModel alloc] init];
                                    [timesheetModel updatePunchClockPunchData:[entryDict1 objectForKey:@"sheetIdentity"] andEntryIdentity:[entryDict1 objectForKey:@"identity"] status:TRUE ];
                                    
                                }
                                
                                
                                //                                [self updateClockOnOffLabelForPunchIn:selectedDate andTime: [entryDict objectForKey:@"time_in"]];
                                //
                                //                                NSArray *hrminsArr=[[entryDict1 objectForKey:@"durationHourFormat"] componentsSeparatedByString:@":"];
                                //                                if ([hrminsArr count]>1) {
                                //                                    pasthrsValue=[[hrminsArr objectAtIndex:0]intValue];
                                //                                    pastminsValue=[[hrminsArr objectAtIndex:1]intValue];
                                //                                    clockOnOffValueLbl.text=[NSString stringWithFormat:@"%d HRS %d MIN",[[hrminsArr objectAtIndex:0]intValue]+hrsValue,[[hrminsArr objectAtIndex:1]intValue]+minsValue];
                                //                                }
                                
                                isAutoPunchOut=TRUE;
                            }
                        }
                        
                        break;
                    }
                    
                }
            }
            
            
            
            if (isAutoPunchOut) {
                if ([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]] )
                {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"]) {
                        punchInOutValueLbl1.text=[G2Util convertMidnightTimeFormat: [entryDict objectForKey:@"time_in"]];
                    }
                    else
                    {
                        punchInOutValueLbl1.text=[G2Util convert12HourTimeStringTo24HourTimeString:[entryDict objectForKey:@"time_in"]];
                    }
                    
                    G2TimesheetModel *timesheetModel = [[G2TimesheetModel alloc] init];
                    [timesheetModel updatePunchClockPunchData:[entryDict objectForKey:@"sheetIdentity"] andEntryIdentity:[entryDict objectForKey:@"identity"] status:TRUE ];
                   
                }
                
            }
            else
            {
                if ([entryDict objectForKey:@"time_in"]!=nil && ![[entryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]] )
                {
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"]) {
                        punchInOutValueLbl.text=[G2Util convertMidnightTimeFormat: [entryDict objectForKey:@"time_in"]];
                    }
                    else
                    {
                        punchInOutValueLbl.text=[G2Util convert12HourTimeStringTo24HourTimeString:[entryDict objectForKey:@"time_in"]];
                    }
                    
                    G2TimesheetModel *timesheetModel = [[G2TimesheetModel alloc] init];
                    [timesheetModel updatePunchClockPunchData:[entryDict objectForKey:@"sheetIdentity"] andEntryIdentity:[entryDict objectForKey:@"identity"] status:TRUE ];
                   
                    
                }
                
                
                
                [self updateClockOnOffLabelForPunchIn:selectedDate andTime: punchInOutValueLbl.text];
            }
            
            
            
            self.hiddentimer=[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(hideSecondsColon) userInfo:nil repeats:NO];
            clockImageView.hidden=FALSE;
            
            
            
            
        }
        //PUNCH OUT STATUS
        else
        {
            punchInOutHeaderLbl.text=RPLocalizedString(PUNCHOUTSTATUS, "");
            clockOnOffHeaderLbl.text=RPLocalizedString(OFFCLOCK, "");
            
            if (isFromPunchButton) {
                if ([punchButton.titleLabel.text isEqualToString:PUNCHOUT])
                {
                    isErrorAlert=TRUE;
                    isFromPunchButton=FALSE;
                    
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                    isStop=FALSE;
                    [G2Util errorAlert:RPLocalizedString(PUNCHCLOCK_ERROR_ALERT, "") errorMessage:@""];
                    
                }
                
            }
            
            
            [punchButton setTitle:RPLocalizedString(PUNCHIN, "") forState:UIControlStateNormal];
            
            
            if ([entryDict objectForKey:@"time_out"]!=nil && ![[entryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]] )
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"]) {
                    punchInOutValueLbl.text=[G2Util convertMidnightTimeFormat: [entryDict objectForKey:@"time_out"]];
                }
                else
                {
                    punchInOutValueLbl.text=[G2Util convert12HourTimeStringTo24HourTimeString:[entryDict objectForKey:@"time_out"]];
                }
                punchInOutValueLbl1.text=@"";
                clockOnOffValueLbl1.text=@"";
                
            }
            
            
            //            NSArray *hrminsArr=[[entryDict objectForKey:@"durationHourFormat"] componentsSeparatedByString:@":"];
            //            if ([hrminsArr count]>1) {
            //                clockOnOffValueLbl.text=[NSString stringWithFormat:@"%@ HRS %@ MIN",[hrminsArr objectAtIndex:0],[hrminsArr objectAtIndex:1]];
            //            }
            
            
            if ([hiddentimer isValid]) {
                [hiddentimer invalidate];
            }
            if ([visibleTimer isValid]) {
                [visibleTimer invalidate];
            }
            clockImageView.hidden=TRUE;
            colonLbl.hidden=FALSE;
            
            
        }
    }
    
   
    
    if ([punchButton.titleLabel.text isEqualToString:RPLocalizedString(PUNCHIN, "")])
    {
        punchInOutHeaderLbl.text=RPLocalizedString(PUNCHOUTSTATUS, "");
        clockOnOffHeaderLbl.text=RPLocalizedString(OFFCLOCK, "");
    }
    else
    {
        punchInOutHeaderLbl.text=RPLocalizedString(PUNCHINSTATUS, "");
        clockOnOffHeaderLbl.text=RPLocalizedString(ONCLOCK, "");
    }
    
    BOOL isCLearValues=FALSE;
    if ([dbTimeentriesArray count]==0 )
    {
        isCLearValues=TRUE;
    }
    else if ([dbTimeentriesArray count]==1 )
    {
        if ([[dbTimeentriesArray objectAtIndex:0] objectForKey:@"time_in"]==nil || [[[dbTimeentriesArray objectAtIndex:0] objectForKey:@"time_in"] isKindOfClass:[NSNull class]])
        {
            isCLearValues=TRUE;
        }
    }
    
    if (isCLearValues)
    {
        clockOnOffValueLbl.text=@"";
        clockOnOffValueLbl1.text=@"";
        punchInOutValueLbl.text=@"";
        punchInOutValueLbl1.text=@"";
        if ([hiddentimer isValid]) {
            [hiddentimer invalidate];
        }
        if ([visibleTimer isValid]) {
            [visibleTimer invalidate];
        }
        clockImageView.hidden=TRUE;
        colonLbl.hidden=FALSE;
        [punchButton setTitle:RPLocalizedString(PUNCHIN, "")  forState:UIControlStateNormal];
    }
}

-(void)updateClockOnOffLabelForPunchIn:(NSDate *)selectedDate andTime:(NSString *)timeIn
{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    
    [dateFormat setDateFormat:@"hh:mm a"];;
    
    NSDate* timeInDate = [dateFormat dateFromString:timeIn];
    if (timeInDate==nil) {
        [dateFormat setDateFormat:@"HH:mm"];;
        timeInDate = [dateFormat dateFromString:timeIn];
    }
    
    NSDate* currentDate = [dateFormat dateFromString:[dateFormat stringFromDate:selectedDate]];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    NSDateComponents *conversionInfo=nil;
    if (timeInDate!=nil) {
        conversionInfo = [sysCalendar components:unitFlags fromDate:timeInDate  toDate:currentDate  options:0];
    }
    
    //De4216 Ullas
    NSDateComponents *conversionInfoTemp = [sysCalendar components:unitFlags fromDate:self.temporarySelectedDate  toDate:[NSDate date]  options:0];
    //        DLog(@"Conversion: %dmin %dhours %ddays %dmoths",[conversionInfo minute], [conversionInfo hour], [conversionInfo day], [conversionInfo month]);
    
    if (conversionInfo!=nil) {
        if ([conversionInfo hour]>=0 && [conversionInfo minute]>=0 ) {
            G2SupportDataModel *supportDataModel=[[G2SupportDataModel alloc]init];
            
            if ([ [supportDataModel getUserHourFormat] isEqualToString:@"Decimal"]) {
                double hours = [conversionInfo hour];
                //                if ([conversionInfoTemp day]==1)
                //                {
                //                    if (![timeIn isEqualToString:@"12:00 AM"] && ![timeIn isEqualToString:@"0:00 AM"])
                //                        hours=([conversionInfoTemp day]*24)+hours;
                //                }
                double minutes = [conversionInfo minute];
                double decimalHours = hours + (minutes/60.0) ;
                NSString *decp = [G2Util getRoundedValueFromDecimalPlaces:decimalHours];
                NSNumber *decimalTime = [NSNumber numberWithFloat:[decp floatValue]];
                NSString *lblValue=[NSString stringWithFormat:@"%@",decimalTime];
                NSArray *parts = [lblValue componentsSeparatedByString:@"."];
                if ([parts count] > 1)
                {
                    if (![[parts objectAtIndex:1] isKindOfClass:[NSNull class] ])
                    {
                        if ([[parts objectAtIndex:1] length]==1) {
                            if (isAutoPunchOut) {
                                clockOnOffValueLbl1.text=[NSString stringWithFormat:@"%@.%@0 HRS",[parts objectAtIndex:0],[parts objectAtIndex:1]];
                            }
                            else
                            {
                                clockOnOffValueLbl.text=[NSString stringWithFormat:@"%@.%@0 HRS",[parts objectAtIndex:0],[parts objectAtIndex:1]];
                            }
                            
                        }
                        else
                        {
                            if (isAutoPunchOut) {
                                clockOnOffValueLbl1.text=[NSString stringWithFormat:@"%@ HRS",decimalTime];
                            }
                            else
                            {
                                clockOnOffValueLbl.text=[NSString stringWithFormat:@"%@ HRS",decimalTime];
                            }
                            
                        }
                    }
                    
                }
                else
                {
                    if ([decimalTime intValue]==0) {
                        if (isAutoPunchOut) {
                            clockOnOffValueLbl1.text=@"0.00 HRS";
                        }
                        else
                        {
                            clockOnOffValueLbl.text=@"0.00 HRS";
                        }
                        
                    }
                }
                
                
            }
            else
            {
                NSInteger hrs=[conversionInfo hour];
                NSInteger min=[conversionInfo minute];
                
                //                if ([conversionInfoTemp day]==1)
                //                {
                //                    if (![timeIn isEqualToString:@"12:00 AM"] && ![timeIn isEqualToString:@"0:00 AM"])
                //                        hrs=([conversionInfoTemp day]*24)+hrs;
                //                }
                
                if (isAutoPunchOut) {
                    clockOnOffValueLbl1.text=[NSString stringWithFormat:@"%ld HRS %ld MIN",(long)hrs,(long)min];
                }
                else
                {
                    clockOnOffValueLbl.text=[NSString stringWithFormat:@"%ld HRS %ld MIN",(long)hrs,(long)min];
                }
                
                
            }
        
        }
        else {
            
            if ([conversionInfoTemp day]==1) {
                G2SupportDataModel *supportDataModel=[[G2SupportDataModel alloc]init];
                
                if ([ [supportDataModel getUserHourFormat] isEqualToString:@"Decimal"]) {
                    double hours = [conversionInfo hour];
                    hours=([conversionInfoTemp day]*24)+hours;
                    double minutes = [conversionInfo minute];
                    double decimalHours = hours + (minutes/60.0) ;
                    NSString *decp = [G2Util getRoundedValueFromDecimalPlaces:decimalHours];
                    NSNumber *decimalTime = [NSNumber numberWithFloat:[decp floatValue]];
                    NSString *lblValue=[NSString stringWithFormat:@"%@",decimalTime];
                    NSArray *parts = [lblValue componentsSeparatedByString:@"."];
                    if ([parts count] > 1)
                    {
                        if (![[parts objectAtIndex:1] isKindOfClass:[NSNull class] ])
                        {
                            if ([[parts objectAtIndex:1] length]==1) {
                                if (isAutoPunchOut) {
                                    clockOnOffValueLbl1.text=[NSString stringWithFormat:@"%@.%@0 HRS",[parts objectAtIndex:0],[parts objectAtIndex:1]];
                                }
                                else
                                {
                                    clockOnOffValueLbl.text=[NSString stringWithFormat:@"%@.%@0 HRS",[parts objectAtIndex:0],[parts objectAtIndex:1]];
                                }
                                
                            }
                            else
                            {
                                if (isAutoPunchOut) {
                                    clockOnOffValueLbl1.text=[NSString stringWithFormat:@"%@ HRS",decimalTime];
                                }
                                else
                                {
                                    clockOnOffValueLbl.text=[NSString stringWithFormat:@"%@ HRS",decimalTime];
                                }
                                
                            }
                        }
                        
                    }
                    else
                    {
                        if ([decimalTime intValue]==0) {
                            if (isAutoPunchOut) {
                                clockOnOffValueLbl1.text=@"0.00 HRS";
                            }
                            else
                            {
                                clockOnOffValueLbl.text=@"0.00 HRS";
                            }
                            
                        }
                    }
                    
                    
                }
                else
                {
                    NSInteger hrs=[conversionInfo hour];
                    NSInteger min=[conversionInfo minute];
                    if ([conversionInfoTemp day]==1)
                    {
                        if (![timeIn isEqualToString:@"12:00 AM"] && ![timeIn isEqualToString:@"0:00 AM"])
                            hrs=([conversionInfoTemp day]*24)+hrs;
                        min=([conversionInfoTemp day]*60)+min;
                    }
                    
                    if (isAutoPunchOut) {
                        clockOnOffValueLbl1.text=[NSString stringWithFormat:@"%ld HRS %ld MIN",(long)hrs,(long)min];
                    }
                    else
                    {
                        clockOnOffValueLbl.text=[NSString stringWithFormat:@"%ld HRS %ld MIN",(long)hrs,(long)min];
                    }
                    
                    
                }
            
            }
        }
        
        
    }
    
    
    
    
    hrsValue=[conversionInfo hour];
    minsValue=[conversionInfo minute];
    

}


-(void) handleProcessCompleteActions

{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allLockedTimesheetRequestsServed" object:nil];
    if (!isErrorAlert && isFromPunchButton)
    {
        isFromPunchButton=FALSE;
        G2TimeSheetEntryObject *timeSheetEntryObject=[[G2TimeSheetEntryObject alloc]init];
        [timeSheetEntryObject setEntryDate:[NSDate date]];
        //HANDLE PUNCH IN
        if ([punchButton.titleLabel.text isEqualToString:RPLocalizedString(PUNCHIN, "")])
        {
            NSDate *selectedEntryDate = [timeSheetEntryObject entryDate];
            if (selectedEntryDate != nil && [selectedEntryDate isKindOfClass:[NSDate class]]) {
                
                // [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:SavingMessage];
                if ([[NetworkMonitor sharedInstance] networkAvailable]) {
                    
                    isStop=FALSE;
                    [[G2RepliconServiceManager lockedInOutTimesheetService]
                     getTimesheetFromApiAndAddTimeEntry:timeSheetEntryObject];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:FETCH_LOCKEDINOUT_TIMESHEET_FOR_ENTRY_DATE object:nil];
                    [[NSNotificationCenter defaultCenter]
                     addObserver:self selector:@selector(saveEntryForFetchedSheet:) name:FETCH_LOCKEDINOUT_TIMESHEET_FOR_ENTRY_DATE object:nil];
                }
                
                //             [[RepliconServiceManager timesheetService] sendRequestToAddNewTimeEntryWithObjectForLockedInOutTimesheets:timeSheetEntryObject];
            }
            
        }
        
        //HANDLE PUNCH OUT
        else
        {
            
            [self editEntryForFetchedSheet];
        }
    }
    else
    {
        
        if (isStop) {
            
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            
            
            isStop=FALSE;
        }
        
    }
    
    isErrorAlert=FALSE;
    
}



-(void)saveEntryForFetchedSheet:(id)notificationObject {
    //DLog(@"saveEntryForFetchedSheet: notificationObject");
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:FETCH_LOCKEDINOUT_TIMESHEET_FOR_ENTRY_DATE object:nil];
    
    NSString *fetchedSheetId = ((NSNotification *)notificationObject).object;
    //update the entry object with fetched sheetId
    //DLog(@"fetchedSheetId %@",fetchedSheetId);
    if (fetchedSheetId != nil && ![fetchedSheetId isKindOfClass:[NSNull class]]) {
        
        G2TimeSheetEntryObject *timeSheetEntryObject=[[G2TimeSheetEntryObject alloc]init];
        [timeSheetEntryObject setEntryDate:[NSDate date]];
        [timeSheetEntryObject setSheetId:fetchedSheetId];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:locale];
        [dateFormat setDateFormat:@"h:mm a"];
        [timeSheetEntryObject setInTime:[dateFormat stringFromDate:[NSDate date]]];
       
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCKED_TIME_ENTRY_SAVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(fetchTimeSheetAfterPunchStatus)
                                                     name: LOCKED_TIME_ENTRY_SAVED_NOTIFICATION
                                                   object: nil];
        
        isStop=FALSE;
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if(!appDelegate.punchClockIsZeroTimeEntries)
        {
            [[G2RepliconServiceManager lockedInOutTimesheetService] sendRequestToAddNewTimeEntryWithObjectForLockedInOutTimesheets:timeSheetEntryObject];
            isFromPunchButton=FALSE;
            appDelegate.punchClockIsZeroTimeEntries=TRUE;
        }
        else
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            G2TimesheetModel *timesheetModel=[[G2TimesheetModel alloc]init];
            NSMutableArray *dbTimeentriesArray = [timesheetModel getTimeEntryForWithDate:[NSDate date]];
           
            if ([dbTimeentriesArray count]>0 )
            {
                appDelegate.punchClockIsZeroTimeEntries=FALSE;
            }
            else
            {
                appDelegate.punchClockIsZeroTimeEntries=TRUE;
            }
            
        }
        
    }
}

-(void)editEntryForFetchedSheet {
    G2TimesheetModel *timeSheetModel=[[G2TimesheetModel alloc]init];
    NSArray *fetchedTimeSheetsArr=[timeSheetModel getPunchClockTimeentries];
   
    
    for (int i=0; i<[fetchedTimeSheetsArr count]; i++) {
        NSDictionary *timeEntryDict=[fetchedTimeSheetsArr objectAtIndex:i];
        
        if ([timeEntryDict objectForKey:@"time_out"]==nil || [[timeEntryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class] ] )
        {
            NSString *fetchedSheetId=[timeEntryDict objectForKey:@"sheetIdentity"];
            if (fetchedSheetId != nil && ![fetchedSheetId isKindOfClass:[NSNull class]]) {
                
                G2TimeSheetEntryObject *timeSheetEntryObject=[[G2TimeSheetEntryObject alloc]init];
                [timeSheetEntryObject setEntryDate:[NSDate date]];
                [timeSheetEntryObject setSheetId:fetchedSheetId];
                [timeSheetEntryObject setIdentity:[timeEntryDict objectForKey:@"identity"]];
                [timeSheetEntryObject setInTime:[timeEntryDict objectForKey:@"time_in"]];
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [dateFormat setLocale:locale];
                [dateFormat setDateFormat:@"h:mm a"];
                [timeSheetEntryObject setOutTime:[dateFormat stringFromDate:[NSDate date]]];
                
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCKED_TIME_ENTRY_EDITED_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver: self
                                                         selector: @selector(fetchTimeSheetAfterPunchStatus)
                                                             name: LOCKED_TIME_ENTRY_EDITED_NOTIFICATION
                                                           object: nil];
                isStop=FALSE;
                [[G2RepliconServiceManager lockedInOutTimesheetService] sendRequestToEditTheTimeEntryDetailsWithUserDataForLockedInOutTimesheets:timeSheetEntryObject];
                
            }
            
        }
        
        
    }
    
    
}


-(void)fetchTimeSheetAfterPunchStatus
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCKED_TIME_ENTRY_SAVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LOCKED_TIME_ENTRY_EDITED_NOTIFICATION object:nil];
    //    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    [self timeEntryActionForPunchDetails];
}


-(void)updateClockOnOffLabelForTimeIn:(NSString *)timeIn
{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    
    [dateFormat setDateFormat:@"hh:mm a"];
    
    
    NSDate* timeInDate = [dateFormat dateFromString:timeIn];
    NSDate* timeOutDate = [dateFormat dateFromString:@"11:59 PM"];
    
    if (timeInDate==nil) {
        [dateFormat setDateFormat:@"HH:mm"];;
        timeInDate = [dateFormat dateFromString:timeIn];
        timeOutDate = [dateFormat dateFromString:@"23:59"];
    }
    
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:timeInDate  toDate:timeOutDate  options:0];
    //
    //            DLog(@"Conversion: %dmin %dhours %ddays %dmoths",[conversionInfo minute], [conversionInfo hour], [conversionInfo day], [conversionInfo month]);
    
    if ([conversionInfo hour]>=0 && [conversionInfo minute]>=0 ) {
        G2SupportDataModel *supportDataModel=[[G2SupportDataModel alloc]init];
        
        if ([ [supportDataModel getUserHourFormat] isEqualToString:@"Decimal"]) {
            double hours = [conversionInfo hour];
            double minutes = [conversionInfo minute];
            double decimalHours = hours + (minutes/60.0) ;
            NSString *decp = [G2Util getRoundedValueFromDecimalPlaces:decimalHours];
            NSNumber *decimalTime = [NSNumber numberWithFloat:[decp floatValue]];
            NSString *lblValue=[NSString stringWithFormat:@"%@",decimalTime];
            NSArray *parts = [lblValue componentsSeparatedByString:@"."];
			if ([parts count] > 1)
            {
                if (![[parts objectAtIndex:1] isKindOfClass:[NSNull class] ])
                {
                    if ([[parts objectAtIndex:1] length]==1) {
                        
                        clockOnOffValueLbl.text=[NSString stringWithFormat:@"%@.%@0 HRS",[parts objectAtIndex:0],[parts objectAtIndex:1]];
                        
                        
                    }
                    else
                    {
                        
                        clockOnOffValueLbl.text=[NSString stringWithFormat:@"%@ HRS",decimalTime];
                        
                        
                    }
                }
                
            }
            else
            {
                if ([decimalTime intValue]==0) {
                    
                    clockOnOffValueLbl.text=@"0.00 HRS";
                    
                    
                }
            }
            
            
        }
        else
        {
            
            clockOnOffValueLbl.text=[NSString stringWithFormat:@"%ld HRS %ld MIN",(long)[conversionInfo hour],(long)[conversionInfo minute]];
            
            
            
        }
        
    }
    
    
    
    

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.bgImageView=nil;
    self.currentDateLbl=nil;
    self.hourLbl=nil;
    self.minsLbl=nil;
    self.colonLbl=nil;
    self.hourLbl1=nil;
    self.minsLbl1=nil;
    self.am_pm_Lbl=nil;
    self.punchInOutHeaderLbl=nil;
    self.punchInOutValueLbl=nil;
    self.punchInOutValueLbl1=nil;
    self.clockOnOffHeaderLbl=nil;
    self.clockOnOffValueLbl=nil;
    self.clockOnOffValueLbl1=nil;
    self.punchButton=nil;
    self.clockImageView=nil;
}



@end
