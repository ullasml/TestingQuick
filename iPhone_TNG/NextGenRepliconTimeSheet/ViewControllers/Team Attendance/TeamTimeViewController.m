//
//  TeamTimeViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "TeamTimeViewController.h"
#import "ImageNameConstants.h"
#import "Constants.h"
#import "TimesheetObject.h"
#import "FrameworkImport.h"
#import "RepliconServiceManager.h"
#import "UISegmentedControlExtension.h"
#import "TeamTimeUserObject.h"
#import "TeamTimeActivityObject.h"
#import "TeamTimePunchObject.h"
#import "TeamTimeBreakObject.h"
#import "LoginModel.h"
#import "PunchEntryViewController.h"
#import "TeamTimeNavigationController.h"
#import "PunchHistoryNavigationController.h"
#import "SupervisorDashboardNavigationController.h"

@interface TeamTimeViewController ()
@property (nonatomic, assign) id navigationType;
@property (nonatomic) id<Theme> theme;
@end

#define Page_Control_View_Height 50
#define segment_view_section_height 52
#define kTagFirst 1
#define kTagSecond 2
#define kTagThird 3
#define Punches_Tag 0
#define Images_Tag 1
#define Loaction_Tag 2

@implementation TeamTimeViewController
@synthesize isCalledFromMenu;
@synthesize daySelectionScrollView;
@synthesize daySelectionScrollViewDelegate;
@synthesize datesArray;
@synthesize segmentedCtrl;
@synthesize timeViewController;
@synthesize locationViewController;
@synthesize imageViewController;
@synthesize setViewTag;
@synthesize currentSelectedPage;
@synthesize currentDateString;
@synthesize btnClicked;
@synthesize dataArray;
@synthesize timesheetStartDate;
@synthesize timesheetEndDate;
@synthesize sheetIdentity;
@synthesize approvalsModuleName;
@synthesize approvalsModuleUserUri;
@synthesize isEditable;
@synthesize trackTimeEntryChangeDelegate;
@synthesize sheetApprovalStatus;
@synthesize hasUserChangedAnyValue;


- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.theme = theme;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationType = (UINavigationController*)self.navigationController;
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]]||[self.navigationType isKindOfClass:[PunchHistoryNavigationController class]]||[self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        [self paintView];
    }
    else
    {
        
    }
    if([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
      [Util setToolbarLabel: self withText: RPLocalizedString(TeamTimeTabbarTitle, TeamTimeTabbarTitle)];
        
    }
    else if([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(PunchHistoryTabbarTitle, PunchHistoryTabbarTitle)];
        
    }
    else
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(PUNCH_TIMESHEET_WIDGET_TITLE, @"")];
        
    }
    

    
    if ([self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]] &&
        [self canSupervisorEditPunch]) {

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPunchForPunchHistory)];
    }



}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
            if (self.hasUserChangedAnyValue)
            {
                if ([self.trackTimeEntryChangeDelegate isKindOfClass:[WidgetTSViewController class]])
                {
                    [self.trackTimeEntryChangeDelegate sendValidationCheckRequestOnlyOnChange];
                }
            }
}


-(void)paintView
{
    CLS_LOG(@"-----Team View Selected -----");
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    NSMutableArray  *tempArray= [self createWeekList:NO];
    self.datesArray=tempArray;
    NSMutableArray *teamTimeDateObjArray=[NSMutableArray array];
    
    for (int k=0; k<[tempArray count]; k++)
    {
        
        TimesheetObject *tsObj=[[TimesheetObject alloc]init];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        
        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *entryDate=[myDateFormatter dateFromString:[tempArray objectAtIndex:k]];
        myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";
        NSString *entryDateStr=[myDateFormatter stringFromDate:entryDate];
        [tsObj setEntryDate:entryDateStr];
        [teamTimeDateObjArray addObject:tsObj];
        
    }
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    
    //[myDateFormatter setLocale:locale];
    //[myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSUInteger selectedButton=0;
    if([self.navigationType isKindOfClass:[TeamTimeNavigationController class]]||[self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
        [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSString *entryDateStr=[myDateFormatter stringFromDate:[NSDate date]];
        selectedButton=[self.datesArray indexOfObject:entryDateStr];
    }
    else
    {
        //Do nothing for widget Timesheet
    }
    
    DaySelectionScrollView *tmpDaySelectionScrollView = [[DaySelectionScrollView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, Page_Control_View_Height)andWithTsDataArray:teamTimeDateObjArray withCurrentlySelectedDay:selectedButton withDelegate:self withTimesheetUri:@""  approvalsModuleName:nil];
    self.daySelectionScrollView =tmpDaySelectionScrollView;
    [daySelectionScrollView setBackgroundColor:[UIColor lightGrayColor]];
    self.daySelectionScrollViewDelegate=(id)daySelectionScrollView;
    [self.view addSubview:daySelectionScrollView];
    
    [self createCustomHeaderView];

}
-(void)auditTrialbuttonAction
{
    if([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
        TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
        NSMutableArray *userInfoArray=[teamTimeModel getDistinctUsersFromDB];
        AuditTrialUsersViewController *auditTrialUsersVC=[[AuditTrialUsersViewController alloc]init];
        auditTrialUsersVC.listDataArray=userInfoArray;
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *date=[myDateFormatter dateFromString:[self.datesArray objectAtIndex:self.currentSelectedPage]];
        [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
        NSDictionary *dateDict=[Util convertDateToApiDateDictionary:date];
        NSString *dateString=[NSString stringWithFormat:@"    %@ %@",RPLocalizedString(@"On", @""),[myDateFormatter stringFromDate:date]];
        auditTrialUsersVC.dateDict=dateDict;
        auditTrialUsersVC.dateString=dateString;
        [self.navigationController pushViewController:auditTrialUsersVC animated:YES];
    }
    else if([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
        if (![NetworkMonitor isNetworkAvailableForListener:self])
        {
            [Util showOfflineAlert];
            return;
        }
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
        NSDate *date=[myDateFormatter dateFromString:[self.datesArray objectAtIndex:self.currentSelectedPage]];
        [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
        NSDictionary *dateDict=[Util convertDateToApiDateDictionary:date];
        NSString *dateString=[NSString stringWithFormat:@"    %@ %@",RPLocalizedString(@"On", @""),[myDateFormatter stringFromDate:date]];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSString *strUserURI=[defaults objectForKey:@"UserUri"];
        AuditTrialViewController *auditTrialVC=[[AuditTrialViewController alloc]init];
        auditTrialVC.headerDateString=dateString;
        auditTrialVC.userName=RPLocalizedString(AuditTrialTitle, @"");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AUDIT_TRIAL_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:auditTrialVC selector:@selector(auditTrialDataReceivedAction:)
                                                     name:AUDIT_TRIAL_NOTIFICATION
                                                   object:nil];
        [[RepliconServiceManager teamTimeService]sendRequestToGetAuditTrialDataForUserUri:strUserURI andDate:dateDict];
        [self.navigationController pushViewController:auditTrialVC animated:YES];
    }
    else
    {
        if (![NetworkMonitor isNetworkAvailableForListener:self])
        {
            [Util showOfflineAlert];
            return;
        }

        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
        if (self.datesArray.count>0)
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            NSDate *date=[myDateFormatter dateFromString:[self.datesArray objectAtIndex:self.currentSelectedPage]];
            [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
            NSDictionary *dateDict=[Util convertDateToApiDateDictionary:date];
            NSString *dateString=[NSString stringWithFormat:@"    %@ %@",RPLocalizedString(@"On", @""),[myDateFormatter stringFromDate:date]];

            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            NSString *strUserURI=nil;
            if (self.approvalsModuleName==nil || [self.approvalsModuleName isKindOfClass:[NSNull class]]||[self.approvalsModuleName isEqualToString:@""])
            {
                strUserURI=[defaults objectForKey:@"UserUri"];
            }
            else
            {
                strUserURI= approvalsModuleUserUri;
            }
            AuditTrialViewController *auditTrialVC=[[AuditTrialViewController alloc]init];
            auditTrialVC.headerDateString=dateString;
            auditTrialVC.userName=RPLocalizedString(AuditTrialTitle, @"");
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AUDIT_TRIAL_NOTIFICATION object:nil];

            [[NSNotificationCenter defaultCenter] addObserver:auditTrialVC selector:@selector(auditTrialDataReceivedAction:)
                                                         name:AUDIT_TRIAL_NOTIFICATION
                                                       object:nil];
            [[RepliconServiceManager teamTimeService]sendRequestToGetAuditTrialDataForUserUri:strUserURI andDate:dateDict];
            [self.navigationController pushViewController:auditTrialVC animated:YES];
        }


    }
    
}
-(void)createCustomHeaderView
{
    float xOffset=5.0f;
    float yOffset=9.0f;
    float wSegment=self.view.frame.size.width-2*xOffset-30;
    float hSegment=34.0f;
    
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    
    NSArray *items = [[NSArray alloc] initWithObjects:
                      RPLocalizedString(SEGMENT_TIME,@""),
                      RPLocalizedString(SEGMENT_IMAGES,@""),RPLocalizedString(SEGMENT_LOCATION,@""),nil];
    
    
    UISegmentedControl *tempSegmentCtrl = [[UISegmentedControl alloc] initWithItems:items];
    
    self.segmentedCtrl=tempSegmentCtrl;
    
    
    
//    [self.segmentedCtrl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.segmentedCtrl setFrame:CGRectMake(xOffset, yOffset, wSegment, hSegment)];
    [self.segmentedCtrl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedCtrl setTag:kTagFirst forSegmentAtIndex:0];
    [self.segmentedCtrl setTag:kTagSecond forSegmentAtIndex:1];
    [self.segmentedCtrl setTag:kTagThird forSegmentAtIndex:2];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
        [self.segmentedCtrl setTintColor:[Util colorWithHex:@"#107ebe" alpha:1]];
        
       
        
        [self.segmentedCtrl setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]}
                                          forState:UIControlStateNormal];
        
        [self.segmentedCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                          forState:UIControlStateSelected];
        
        
        [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
        [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
        [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
        [self changeUISegmentFont:self.segmentedCtrl];
        [self setTextColorsForSegmentedControl:self.segmentedCtrl];
        self.segmentedCtrl.selectedSegmentIndex=Punches_Tag;
    }
    else{
        [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
        [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagSecond];
        [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagThird];
        [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#b6c1c8" alpha:1]];
    }
    
    UIView *segmentSectionView=[[UIView alloc]initWithFrame:CGRectMake(0, Page_Control_View_Height, self.view.frame.size.width, 50)];
    //Fix for ios7//JUHI
    if (version>=7.0)
    {
        [segmentSectionView setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1]];
    }
    else{
        [segmentSectionView setBackgroundColor:[Util colorWithHex:@"#b6c1c8" alpha:1]];
    }
    
    UIImage *separtorImage=[Util thumbnailImage:TOP_SEPARATOR];
    
    UIImageView *separatorView=[[UIImageView alloc]initWithFrame:CGRectMake(0, segment_view_section_height+1-separtorImage.size.height, self.view.frame.size.width, separtorImage.size.height)];
    [separatorView setImage:separtorImage];
    [self.view addSubview:separatorView];
    
    
    [self setTextColorsForSegmentedControl:self.segmentedCtrl];
    [self.segmentedCtrl setSelectedSegmentIndex:Punches_Tag];
    [segmentSectionView addSubview:self.segmentedCtrl];
    float x=self.segmentedCtrl.frame.size.width+self.segmentedCtrl.frame.origin.x+3;
    float y=self.segmentedCtrl.frame.origin.y+3;
    UIImage *auditTrialImage=[Util thumbnailImage:AuditTrialImage];
    UIButton *auditTrialButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [auditTrialButton setFrame:CGRectMake(x,y,30,30.0)];
    [auditTrialButton setImage:auditTrialImage forState:UIControlStateNormal];
    [auditTrialButton addTarget:self action:@selector(auditTrialbuttonAction) forControlEvents:UIControlEventTouchUpInside];
    [auditTrialButton setBackgroundColor:[UIColor clearColor]];
    [auditTrialButton setTag:010];
    [segmentSectionView addSubview:auditTrialButton];
    [self.view addSubview:segmentSectionView];
    [self addTimeView];
    [self changeUISegmentFont:self.segmentedCtrl];
    
    
}


-(void)updateView :(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_VIEW_NOTIFICATION object:nil];
    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"isError"]boolValue];
    
    if (!hasError)
    {
        [self responseRecieved];
    }
}

#pragma mark -
#pragma mark Segment Delegates
-(void) changeUISegmentFont:(UIView*) myView
{
    // Getting the label subview of the passed view
    if ([myView isKindOfClass:[UILabel class]])
    {
        UILabel* label = (UILabel*)myView;
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];       // Set the font size you want to change to
        [label sizeToFit];
        CGRect frame=label.frame;
        frame.size.width=label.frame.size.width+100;
        label.frame=frame;
        
        NSString *string=label.text;
        if ([string hasPrefix:RPLocalizedString(SEGMENT_TIME,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(SEGMENT_TIME,@"")]];
        }
        else if([string hasPrefix:RPLocalizedString(SEGMENT_IMAGES,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(SEGMENT_IMAGES,@"")]];
        }
        else if([string hasPrefix:RPLocalizedString(SEGMENT_LOCATION,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(SEGMENT_LOCATION,@"")]];
        }
    }
    
    NSArray* subViewArray = [myView subviews];                  // Getting the subview array
    NSEnumerator* iterator = [subViewArray objectEnumerator];   // For enumeration
    UIView* subView;
    // Iterating through the subviews of the view passed
    while (subView = [iterator nextObject])
    {
        [self changeUISegmentFont:subView]; // Recursion
        
    }
    
}
/************************************************************************************************************
 @Function Name   : segmentChanged
 @Purpose         : To handle segment selected
 @param           : (id)sender
 @return          : nil
 *************************************************************************************************************/

-(void)segmentChanged:(id)sender
{
    UISegmentedControl *segmentCtrl=(UISegmentedControl *)sender;
    [self setTextColorsForSegmentedControl:(UISegmentedControl*)sender];
    
    
    switch (segmentCtrl.selectedSegmentIndex) {
        case 0:
            if (self.setViewTag!=Punches_Tag)
            {
                CLS_LOG(@"-----Summary View segement action on ListOfBookedTimeOffViewController -----");
                [self addTimeView];
                
            }
            
            break;
        case 1:
            if (self.setViewTag!=Images_Tag)
            {
                CLS_LOG(@"-----Balance View segement action on ListOfBookedTimeOffViewController -----");
                [self addImageView];
                
            }
            
            
            break;
        case 2:
            if (self.setViewTag!=Loaction_Tag)
            {
                CLS_LOG(@"-----Holiday View segement action on ListOfBookedTimeOffViewController -----");
                [self addLoactionView];
            }
        default:
            break;
    }
    [UIView commitAnimations];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    if (version<7.0)
    {
        //self.segmentedCtrl.selectedSegmentIndex=-1;//Punch-224 Ullas M L
    }
    
    [self changeUISegmentFont:self.segmentedCtrl];
    [self responseRecieved];
}
/************************************************************************************************************
 @Function Name   : setTextColorsForSegmentedControl
 @Purpose         : To set text color changes in the segment control
 @param           : (UISegmentedControl*)segmented
 @return          : nil
 *************************************************************************************************************/

-(void)setTextColorsForSegmentedControl:(UISegmentedControl*)segmented
{
    
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    switch (segmented.selectedSegmentIndex) {
        case 0:
            
            //Fix for ios7//JUHI
            if (version<7.0)
            {
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];
                
                [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagFirst];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
            }
            else{
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagFirst];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
                
            }
            break;
        case 1:
            
            //Fix for ios7//JUHI
            if (version<7.0)
            {
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagSecond];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                [segmented setShadowColor:[UIColor blackColor] forTag:kTagSecond];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagSecond];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
            }
            else{
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagSecond];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
            }
            break;
            
        case 2:
            //Fix for ios7//JUHI
            if (version<7.0)
            {
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagThird];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                [segmented setShadowColor:[UIColor blackColor] forTag:kTagThird];
                
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagThird];
            }
            else{
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagThird];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
            }
            
            break;
            
            
        default:
            
            //Fix for ios7//JUHI
            if (version<7.0)
            {
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                
                [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];
                
                [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagFirst];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
            }
            else{
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagFirst];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
            }
            
            break;
    }
    
    
    
    
}

-(void)addTimeView
{
    CLS_LOG(@"-----View punches -----");
    [self.timeViewController.view removeFromSuperview];
    timeViewController=nil;
    
    TimeViewController *bookedTimeOffSummaryCtrl = [[TimeViewController alloc] init];
    self.timeViewController=bookedTimeOffSummaryCtrl;
    self.timeViewController.delegate=self;
    
    CGRect frame=self.timeViewController.view.frame;
    frame.origin.y=segment_view_section_height+Page_Control_View_Height-2;
    self.timeViewController.view.frame=frame;
    
    self.timeViewController.dataArray=[self createDataListFor:Punches_Tag];
    
    [self.imageViewController.view removeFromSuperview];
    [self.locationViewController.view removeFromSuperview];
    self.timeViewController.currentDateString=self.currentDateString;
    BOOL isFromWidgetTimesheet=NO;
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
    }
    else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
        self.timeViewController.isFromPunchHistory=YES;
    }
    else
    {
        isFromWidgetTimesheet=YES;
        self.timeViewController.isFromPunchHistory=YES;
    }
    if (!isFromWidgetTimesheet)
    {
        [self.timeViewController getHeader];
    }
    
    [self.view addSubview:self.timeViewController.view];
    
    self.setViewTag=Punches_Tag;
    
    
}

-(void)addImageView;
{
    CLS_LOG(@"-----View Images -----");
    [self.imageViewController.view removeFromSuperview];
    imageViewController=nil;
    
    ImageViewController *bookedTimeOffBalanceViewCtrl = [[ImageViewController alloc] init];
    self.imageViewController=bookedTimeOffBalanceViewCtrl;
    
    
    CGRect frame=self.imageViewController.view.frame;
    frame.origin.y=segment_view_section_height+Page_Control_View_Height-2;
    self.imageViewController.view.frame=frame;
    
    self.imageViewController.dataArray=[self createDataListFor:Images_Tag];
    
    [self.timeViewController.view removeFromSuperview];
    [self.locationViewController.view removeFromSuperview];
    self.imageViewController.currentDateString=self.currentDateString;
    BOOL isFromWidgetTimesheet=NO;
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
    }
    else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
    }
    else
    {
        isFromWidgetTimesheet=YES;
    }
    if (!isFromWidgetTimesheet)
    {
        [self.imageViewController getHeader];
    }
    
    [self.view addSubview:self.imageViewController.view];
    
    self.setViewTag=Images_Tag;
    
    
    
}

-(void)addLoactionView
{
    CLS_LOG(@"-----View Location -----");
    [self.locationViewController.view removeFromSuperview];
    locationViewController=nil;
    
    LocationViewController *templocationViewController=[[LocationViewController alloc]init];
    self.locationViewController=templocationViewController;
    
    
    CGRect frame=self.locationViewController.view.frame;
    frame.origin.y=segment_view_section_height+Page_Control_View_Height-2;
    self.locationViewController.view.frame=frame;
    self.locationViewController.dataArray=[self createDataListFor:Loaction_Tag];
    [self.timeViewController.view removeFromSuperview];
    [self.imageViewController.view removeFromSuperview];
    self.locationViewController.currentDateString=self.currentDateString;
    BOOL isFromWidgetTimesheet=NO;
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
    }
    else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
    }
    else
    {
        isFromWidgetTimesheet=YES;
    }
    if (!isFromWidgetTimesheet)
    {
        [self.locationViewController getHeader];
    }
    
    [self.view addSubview:self.locationViewController.view];
    
    self.setViewTag=Loaction_Tag;
    
    
}
-(void)timesheetDayBtnClickedWithTag:(NSInteger)page
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == YES)
    {
        self.currentSelectedPage=page;
        if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]]||[self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AllTeamTimeRequestsServed object:nil];
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(responseRecieved)
                                                         name: AllTeamTimeRequestsServed
                                                       object: nil];
            
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            
            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
            NSDate *date=[myDateFormatter dateFromString:[self.datesArray objectAtIndex:page]];
            [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
            self.currentDateString=[myDateFormatter stringFromDate:date];
            
            if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
            {
                [[RepliconServiceManager teamTimeService] fetchTeamTimeSheetDataForDate:date];
            }
            else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
            {
                [[RepliconServiceManager punchHistoryService] fetchPunchHistoryDataForDate:date];
            }

            
        }
        else
        {
            //Do Nothing for widget Timesheet
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            
            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
            NSDate *date=[myDateFormatter dateFromString:[self.datesArray objectAtIndex:page]];
            [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
            self.currentDateString=[myDateFormatter stringFromDate:date];
            if (self.segmentedCtrl.selectedSegmentIndex==Punches_Tag)
            {
                [self.segmentedCtrl setSelectedSegmentIndex:Punches_Tag];
                
                [self addTimeView];
            }
            else if (self.segmentedCtrl.selectedSegmentIndex==Images_Tag)
            {
                [self.segmentedCtrl setSelectedSegmentIndex:Images_Tag];
                
                [self addImageView];
            }
            else if (self.segmentedCtrl.selectedSegmentIndex==Loaction_Tag)
            {
                [self.segmentedCtrl setSelectedSegmentIndex:Loaction_Tag];
                
                [self addLoactionView];
            }
            
            [self responseRecieved];
        }
        
        
        
    }
    else
    {
        [Util showOfflineAlert];
    }
    
}

-(void)timesheetDayBtnHighLightOnCrossOver:(NSInteger)page
{
    
}

-(void)responseRecieved
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AllTeamTimeRequestsServed object:nil];
    
    id ctrl=nil;
    if (self.segmentedCtrl.selectedSegmentIndex==Punches_Tag)
    {
        ctrl=self.timeViewController;
    }
    else if (self.segmentedCtrl.selectedSegmentIndex==Images_Tag)
    {
        ctrl=self.imageViewController;
    }
    else if (self.segmentedCtrl.selectedSegmentIndex==Loaction_Tag)
    {
        ctrl=self.locationViewController;
    }
    NSMutableArray *userInfoArray=nil;
    BOOL isPostPermission=FALSE;
    BOOL isEditPermission=FALSE;
    BOOL isFromPunchHistory=FALSE;
    BOOL isFromWidgetTimesheet=NO;
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
        TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
        userInfoArray=[teamTimeModel getAllTeamPunchesFromDB];
        if ([userInfoArray count]>0)
        {
            NSString *useruri=[[userInfoArray objectAtIndex:0] objectForKey:@"punchUserUri"];
            NSMutableDictionary *dict=[teamTimeModel getUserCapabilitiesForUserUri:useruri];
            isPostPermission=[[dict objectForKey:@"canTransferTimePunchToTimesheet"] boolValue];
            isEditPermission=[[dict objectForKey:@"canEditTimePunch"] boolValue];
        }
    }
    else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
        PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
        userInfoArray=[punchHistoryModel getAllPunchesFromDBIsFromWidgetTimesheet:NO forDate:nil approvalsModule:self.approvalsModuleName];
        if ([userInfoArray count]>0)
        {
            isPostPermission=[[[userInfoArray objectAtIndex:0] objectForKey:@"canTransferTimePunchToTimesheet"] boolValue];
            isEditPermission=[[[userInfoArray objectAtIndex:0] objectForKey:@"canEditTimePunch"] boolValue];
        }
        else
        {
            SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
            NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
            if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
            {
                
                isEditPermission = [[[userDetailsArr objectAtIndex:0] objectForKey:@"canEditTimePunch"]boolValue];
                isPostPermission = [[[userDetailsArr objectAtIndex:0] objectForKey:@"canTransferTimePunchToTimesheet"]boolValue];
            }
        }
        isFromPunchHistory=YES;
    }
    else
    {
        isFromWidgetTimesheet=YES;
        isFromPunchHistory=YES;
        PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
        if (self.datesArray.count>0)
        {
            NSString *dateStr=[self.datesArray objectAtIndex:self.currentSelectedPage];
            NSDate *date=[myDateFormatter dateFromString:dateStr];
            [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *todayDateStr=[myDateFormatter stringFromDate:date];
            userInfoArray=[punchHistoryModel getAllPunchesFromDBIsFromWidgetTimesheet:YES forDate:todayDateStr approvalsModule:self.approvalsModuleName];
        }

        if ([userInfoArray count]>0)
        {
            isPostPermission=[[[userInfoArray objectAtIndex:0] objectForKey:@"canTransferTimePunchToTimesheet"] boolValue];
            isEditPermission=[[[userInfoArray objectAtIndex:0] objectForKey:@"canEditTimePunch"] boolValue];
        }
        else
        {
            SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
            NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
            if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
            {
                
                isEditPermission = [[[userDetailsArr objectAtIndex:0] objectForKey:@"canEditTimePunch"]boolValue];
                isPostPermission = [[[userDetailsArr objectAtIndex:0] objectForKey:@"canTransferTimePunchToTimesheet"]boolValue];
            }
        }
        isFromPunchHistory=YES;
    }
    
    
    if (isPostPermission)
    {
        if ([userInfoArray count]>0)
        {
            /*UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(POST_BTN_TITLE, @"")
                                                                           style: UIBarButtonItemStylePlain
                                                                          target: self
                                                                          action: @selector(postAction)];
            
            [self.navigationItem setRightBarButtonItem:postButton animated:NO];*/
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
        }
        else
        {
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
        }
        
    }
    BOOL isShowPlusButton=NO;
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
        isShowPlusButton=NO;
    }
    else if ([self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        isShowPlusButton=[self canSupervisorEditPunch];
    }
    else
    {
        if (self.approvalsModuleName==nil||[self.approvalsModuleName isKindOfClass:[NSNull class]]||[self.approvalsModuleName isEqualToString:@""])
        {
            if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
            {
            }
            else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
            {
                SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
                NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
                if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
                {
                    
                    isShowPlusButton = [[[userDetailsArr objectAtIndex:0] objectForKey:@"canEditTimePunch"]boolValue];
                    
                }
                
            }
            else
            {
                if (isEditable)
                {
                    isShowPlusButton=YES;
                }
                
            }
            
        }
        
    }
    if (isShowPlusButton)
    {
        UIBarButtonItem *postButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPunchForPunchHistory)];
        
        [self.navigationItem setRightBarButtonItem:postButton animated:NO];
    }

    if ([ctrl isKindOfClass:[TimeViewController class]])
    {
        TimeViewController *ctrll=(TimeViewController *)ctrl;
        ctrll.isEditPunchAllowed=isEditPermission;
        ctrll.isFromPunchHistory=isFromPunchHistory;
        ctrll.dataArray=[self createDataListFor:Punches_Tag];
        ctrll.currentDateString=self.currentDateString;
        if (!isFromWidgetTimesheet)
        {
            [ctrll getHeader];
        }
        [ctrll.infoTableView reloadData];
    }
    else if ([ctrl isKindOfClass:[ImageViewController class]])
    {
        ImageViewController *ctrll=(ImageViewController *)ctrl;
        ctrll.dataArray=[self createDataListFor:Images_Tag];
        ctrll.isFromPunchHistory=isFromPunchHistory;
        ctrll.currentDateString=self.currentDateString;
        if (!isFromWidgetTimesheet)
        {
            [ctrll getHeader];
        }
        [ctrll.infoTableView reloadData];
    }

    else if ([ctrl isKindOfClass:[LocationViewController class]])
    {
        LocationViewController *ctrll=(LocationViewController *)ctrl;
        ctrll.isFromPunchHistory=isFromPunchHistory;
        ctrll.dataArray=[self createDataListFor:Loaction_Tag];
        ctrll.currentDateString=self.currentDateString;
        if (!isFromWidgetTimesheet)
        {
            [ctrll getHeader];
        }
        [ctrll.infoTableView reloadData];
    }

    
    
    
}
-(void)addPunchForPunchHistory
{
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    id ctrl=nil;
    if (self.segmentedCtrl.selectedSegmentIndex==Punches_Tag)
    {
        ctrl=self.timeViewController;
    }
    else if (self.segmentedCtrl.selectedSegmentIndex==Images_Tag)
    {
        ctrl=self.imageViewController;
    }
    else if (self.segmentedCtrl.selectedSegmentIndex==Loaction_Tag)
    {
        ctrl=self.locationViewController;
    }
    if ([ctrl isKindOfClass:[TimeViewController class]])
    {
        TimeViewController *ctrll=(TimeViewController *)ctrl;
        self.dataArray=ctrll.dataArray;
    }
    else if ([ctrl isKindOfClass:[ImageViewController class]])
    {
        ImageViewController *ctrll=(ImageViewController *)ctrl;
        self.dataArray=ctrll.dataArray;
    }
    
    else if ([ctrl isKindOfClass:[LocationViewController class]])
    {
        LocationViewController *ctrll=(LocationViewController *)ctrl;
        self.dataArray=ctrll.dataArray;
    }
    
    [self addPunch:indexPath isFRomAddPunch:YES];
}
-(NSMutableArray *)createDataListFor:(int)module
{
    
    NSMutableArray *localdataArray=[NSMutableArray array];
    NSMutableArray *userInfoArray=nil;
    
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
        TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
        userInfoArray=[teamTimeModel getDistinctUsersFromDB];
    }
    else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
        PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
        userInfoArray=[punchHistoryModel getDistinctUsersFromDBISFromWidgetTimesheet:NO forDate:nil approvalsModule:self.approvalsModuleName];
    }
    else
    {
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
        if (self.datesArray.count>0)
        {
            NSString *dateStr=[self.datesArray objectAtIndex:self.currentSelectedPage];
            NSDate *date=[myDateFormatter dateFromString:dateStr];
            [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *todayDateStr=[myDateFormatter stringFromDate:date];
            PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
            userInfoArray=[punchHistoryModel getDistinctUsersFromDBISFromWidgetTimesheet:YES forDate:todayDateStr approvalsModule:self.approvalsModuleName];
        }

    }

    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *locale=[NSLocale currentLocale];
    [myDateFormatter setLocale:locale];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
    

    BOOL isEntriesAvailable=NO;

    if (self.datesArray.count>0)
    {
        NSString *dateStr=[self.datesArray objectAtIndex:self.currentSelectedPage];
        NSDate *date=[myDateFormatter dateFromString:dateStr];
        [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *todayDateStr=[myDateFormatter stringFromDate:date];

        for (int i=0; i<[userInfoArray count]; i++)
        {
            TeamTimeUserObject *userObj=[[TeamTimeUserObject alloc]init];
            NSString *punchUserName=[[userInfoArray objectAtIndex:i] objectForKey:@"punchUserName"];
            NSString *punchUserUri=[[userInfoArray objectAtIndex:i] objectForKey:@"punchUserUri"];
            userObj.userName=punchUserName;
            userObj.userUri=punchUserUri;
            userObj.CellIdentifier=USER_CELL;
            userObj.isUserHasNoData = false;

            NSString *totalHours=nil;
            NSString *regularHours=nil;
            NSString *breakHours=nil;
            NSMutableDictionary *breakAndWorkHrsDict=nil;
            if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
            {
                TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
                totalHours=[teamTimeModel getSumOfTotalHoursForUser:punchUserUri];
            }
            else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
            {
                PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                totalHours=[punchHistoryModel getSumOfTotalHoursForUser:punchUserUri isFromWidgetTimesheet:NO forDate:nil approvalsModule:self.approvalsModuleName];
                breakAndWorkHrsDict=[punchHistoryModel getSumOfBreakHoursAndWorkHoursForUser:punchUserUri isFromWidgetTimesheet:NO forDate:nil approvalsModule:self.approvalsModuleName];
                breakHours=[breakAndWorkHrsDict objectForKey:@"breakHours"];
                regularHours=[breakAndWorkHrsDict objectForKey:@"regularHours"];
            }
            else
            {
                PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                totalHours=[punchHistoryModel getSumOfTotalHoursForUser:punchUserUri isFromWidgetTimesheet:YES forDate:todayDateStr approvalsModule:self.approvalsModuleName];
                breakAndWorkHrsDict=[punchHistoryModel getSumOfBreakHoursAndWorkHoursForUser:punchUserUri isFromWidgetTimesheet:YES forDate:todayDateStr approvalsModule:self.approvalsModuleName];
                breakHours=[breakAndWorkHrsDict objectForKey:@"breakHours"];
                regularHours=[breakAndWorkHrsDict objectForKey:@"regularHours"];


            }
            if ([totalHours floatValue]>=60)
            {
                int hrs=(int)[totalHours floatValue]/60;
                int mins=(int)[totalHours floatValue]%60;
                NSString *minsStr=nil;
                if (mins<10)
                {
                    minsStr=[NSString stringWithFormat:@"0%d",mins];
                }
                else
                {
                    minsStr=[NSString stringWithFormat:@"%d",mins];
                }
                userObj.durationInHrsMins=[NSString stringWithFormat:@"%d:%@",hrs,minsStr];
                userObj.totalHours=[NSString stringWithFormat:@"%d:%@",hrs,minsStr];
            }
            else
            {

                if ([totalHours floatValue]==0)
                {
                    userObj.totalHours=@"0:00";
                    userObj.durationInHrsMins=@"0:00";
                }
                else
                {
                    NSString *minsStr=nil;
                    if ([totalHours floatValue]<10)
                    {
                        minsStr=[NSString stringWithFormat:@"0%d",[totalHours intValue]];
                    }
                    else
                    {
                        minsStr=[NSString stringWithFormat:@"%d",[totalHours intValue]];
                    }

                    userObj.totalHours=[NSString stringWithFormat:@"0:%@",minsStr];
                    userObj.durationInHrsMins=[NSString stringWithFormat:@"0:%@",minsStr];
                }

            }
            if ([regularHours floatValue]>=60)
            {
                int hrs=(int)[regularHours floatValue]/60;
                int mins=(int)[regularHours floatValue]%60;
                NSString *minsStr=nil;
                if (mins<10)
                {
                    minsStr=[NSString stringWithFormat:@"0%d",mins];
                }
                else
                {
                    minsStr=[NSString stringWithFormat:@"%d",mins];
                }
                userObj.regularHours=[NSString stringWithFormat:@"%d:%@",hrs,minsStr];
            }
            else
            {

                if ([regularHours floatValue]==0)
                {
                    userObj.regularHours=@"0:00";
                }
                else
                {
                    NSString *minsStr=nil;
                    if ([regularHours floatValue]<10)
                    {
                        minsStr=[NSString stringWithFormat:@"0%d",[regularHours intValue]];
                    }
                    else
                    {
                        minsStr=[NSString stringWithFormat:@"%d",[regularHours intValue]];
                    }

                    userObj.regularHours=[NSString stringWithFormat:@"0:%@",minsStr];
                }

            }

            if ([breakHours floatValue]>=60)
            {
                int hrs=(int)[breakHours floatValue]/60;
                int mins=(int)[breakHours floatValue]%60;
                NSString *minsStr=nil;
                if (mins<10)
                {
                    minsStr=[NSString stringWithFormat:@"0%d",mins];
                }
                else
                {
                    minsStr=[NSString stringWithFormat:@"%d",mins];
                }
                userObj.breakHours=[NSString stringWithFormat:@"%d:%@",hrs,minsStr];
            }
            else
            {

                if ([breakHours floatValue]==0)
                {
                    userObj.breakHours=@"0:00";
                }
                else
                {
                    NSString *minsStr=nil;
                    if ([breakHours floatValue]<10)
                    {
                        minsStr=[NSString stringWithFormat:@"0%d",[breakHours intValue]];
                    }
                    else
                    {
                        minsStr=[NSString stringWithFormat:@"%d",[breakHours intValue]];
                    }

                    userObj.breakHours=[NSString stringWithFormat:@"0:%@",minsStr];
                }

            }





            //Uncomment this lines if you dont want to show the username section only for Punch History
            //        if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
            //        {
            [localdataArray addObject:userObj];
            //}



            if (module==Punches_Tag)
            {
                NSMutableArray *array=nil;
                if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
                {
                    TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
                    array=[teamTimeModel getPunchesForPunchUserUriGroupedByActivity:punchUserUri forDateStr:todayDateStr];
                }
                else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
                {
                    PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                    array=[punchHistoryModel getPunchesForPunchUserUriGroupedByActivity:punchUserUri forDateStr:todayDateStr isFromWidgetTimesheet:NO approvalsModule:self.approvalsModuleName];
                }
                else
                {
                    PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                    array=[punchHistoryModel getPunchesForPunchUserUriGroupedByActivity:punchUserUri forDateStr:todayDateStr isFromWidgetTimesheet:YES approvalsModule:self.approvalsModuleName];
                }


                if ([array count]==0) {
                    [localdataArray removeLastObject];
                }
                BOOL isEntireEntriesBlankEntry=NO;
                for (int i=0; i<[array count]; i++)
                {
                    NSString *userEntryUri=[[array objectAtIndex:i] objectForKey:@"entryUri"];
                    if (userEntryUri!=nil&&![userEntryUri isKindOfClass:[NSNull class]]&&![userEntryUri isEqualToString:@""])
                    {
                        isEntireEntriesBlankEntry=NO;
                    }
                }
                for (int i=0; i<[array count]; i++)
                {
                    isEntriesAvailable=YES;
                    BOOL hasActivityAccess=NO;
                    BOOL isBreak=[[[array objectAtIndex:i] objectForKey:@"isBreak"] boolValue];
                    NSString *userEntryUri=[[array objectAtIndex:i] objectForKey:@"entryUri"];
                    BOOL isBlankEntry=NO;
                    if (userEntryUri==nil||[userEntryUri isKindOfClass:[NSNull class]]||[userEntryUri isEqualToString:@""])
                    {
                        isBlankEntry=YES;
                    }
                    id tmpObj=nil;
                    if (isBreak)
                    {
                        TeamTimeBreakObject *activityObj=[[TeamTimeBreakObject alloc]init];
                        NSString *activityName=[[array objectAtIndex:i] objectForKey:@"entryName"];
                        NSString *activityUri=[[array objectAtIndex:i] objectForKey:@"entryUri"];
                        activityObj.breakName=activityName;
                        activityObj.breakUri=activityUri;
                        activityObj.CellIdentifier=BREAK_CELL;
                        tmpObj=activityObj;
                    }
                    else
                    {
                        TeamTimeActivityObject *activityObj=[[TeamTimeActivityObject alloc]init];
                        NSString *activityName=[[array objectAtIndex:i] objectForKey:@"entryName"];
                        NSString *activityUri=[[array objectAtIndex:i] objectForKey:@"entryUri"];
                        activityObj.activityName=activityName;
                        activityObj.activityUri=activityUri;
                        activityObj.CellIdentifier=ACTIVITY_CELL;

                        if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
                        {
                            TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
                            NSMutableDictionary *userCapabilitiesDict=[teamTimeModel getUserCapabilitiesForUserUri:punchUserUri];
                            hasActivityAccess=[[userCapabilitiesDict objectForKey:@"hasActivityAccess"]boolValue];
                        }
                        else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
                        {
                            LoginModel *loginModel=[[LoginModel alloc]init];
                            hasActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
                        }
                        else
                        {
                            LoginModel *loginModel=[[LoginModel alloc]init];
                            hasActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
                        }

                        if (isBlankEntry && !isEntireEntriesBlankEntry && hasActivityAccess)
                        {
                            activityObj.activityName=RPLocalizedString(ACTIVITY_NONE_STRING, @"");
                        }
                        tmpObj=activityObj;
                    }


                    float totalHourForActivity=0;
                    int hoursActivity=0;
                    int minsActivity=0;
                    NSMutableArray *tmpPunchArrayObj=[NSMutableArray array];
                    NSMutableArray *punchArr=[[array objectAtIndex:i] objectForKey:@"DataArray"];
                    for (int m=0; m<[punchArr count]; m++)
                    {
                        TeamTimePunchObject *punchObj=[[TeamTimePunchObject alloc]init];
                        NSMutableDictionary *datadict=[punchArr objectAtIndex:m];
                        punchObj.PunchInAddress =[datadict objectForKey:@"PunchInAddress"];
                        punchObj.PunchInDate =[datadict objectForKey:@"PunchInDate"];
                        punchObj.PunchInDateTimestamp =[datadict objectForKey:@"PunchInDateTimestamp"];
                        punchObj.PunchInLatitude =[datadict objectForKey:@"PunchInLatitude"];
                        punchObj.PunchInLongitude =[datadict objectForKey:@"PunchInLongitude"];
                        punchObj.PunchInTime =[datadict objectForKey:@"PunchInTime"];
                        punchObj.PunchOutAddress =[datadict objectForKey:@"PunchOutAddress"];
                        punchObj.PunchOutDate =[datadict objectForKey:@"PunchOutDate"];
                        punchObj.PunchOutDateTimestamp =[datadict objectForKey:@"PunchOutDateTimestamp"];
                        punchObj.PunchOutLatitude =[datadict objectForKey:@"PunchOutLatitude"];
                        punchObj.PunchOutLongitude =[datadict objectForKey:@"PunchOutLongitude"];
                        punchObj.PunchOutTime =[datadict objectForKey:@"PunchOutTime"];
                        punchObj.activityName =[datadict objectForKey:@"activityName"];
                        punchObj.activityUri =[datadict objectForKey:@"activityUri"];
                        punchObj.punchInAgent =[datadict objectForKey:@"punchInAgent"];
                        punchObj.punchInFullSizeImageLink =[datadict objectForKey:@"punchInFullSizeImageLink"];
                        punchObj.punchInFullSizeImageUri =[datadict objectForKey:@"punchInFullSizeImageUri"];
                        punchObj.punchInThumbnailSizeImageLink =[datadict objectForKey:@"punchInThumbnailSizeImageLink"];
                        punchObj.punchInThumbnailSizeImageUri =[datadict objectForKey:@"punchInThumbnailSizeImageUri"];
                        punchObj.punchInUri =[datadict objectForKey:@"punchInUri"];
                        punchObj.punchOutAgent =[datadict objectForKey:@"punchOutAgent"];
                        punchObj.punchOutFullSizeImageLink =[datadict objectForKey:@"punchOutFullSizeImageLink"];
                        punchObj.punchOutFullSizeImageUri =[datadict objectForKey:@"punchOutFullSizeImageUri"];
                        punchObj.punchOutThumbnailSizeImageLink =[datadict objectForKey:@"punchOutThumbnailSizeImageLink"];
                        punchObj.punchOutThumbnailSizeImageUri =[datadict objectForKey:@"punchOutThumbnailSizeImageUri"];
                        punchObj.punchOutUri =[datadict objectForKey:@"punchOutUri"];
                        punchObj.punchUserName =[datadict objectForKey:@"punchUserName"];
                        punchObj.punchUserUri =[datadict objectForKey:@"punchUserUri"];
                        punchObj.totalHours =[datadict objectForKey:@"totalHours"];
                        punchObj.CellIdentifier=PUNCH_CELL;
                        punchObj.breakName=[datadict objectForKey:@"breakName"];
                        punchObj.breakUri=[datadict objectForKey:@"breakUri"];


                        punchObj.punchInAgentUri=[datadict objectForKey:@"punchInAgentUri"];
                        punchObj.punchOutAgentUri=[datadict objectForKey:@"punchOutAgentUri"];
                        punchObj.punchInCloudClockUri=[datadict objectForKey:@"cloudClockInUri"];
                        punchObj.punchOutCloudClockUri=[datadict objectForKey:@"cloudClockOutUri"];
                        punchObj.punchInAccuracyInMeters=[datadict objectForKey:@"punchInaccuracyInMeters"];
                        punchObj.punchOutAccuracyInMeters=[datadict objectForKey:@"punchOutaccuracyInMeters"];
                        punchObj.punchInActionUri=[datadict objectForKey:@"punchInActionUri"];
                        punchObj.punchOutActionUri=[datadict objectForKey:@"punchOutActionUri"];


                        punchObj.isBreakPunch=isBreak;

                        NSString *inMaualStr=[datadict objectForKey:@"startPunchLastModificationTypeUri"];
                        NSString *outMaualStr=[datadict objectForKey:@"endPunchLastModificationTypeUri"];

                        if (inMaualStr!=nil && ![inMaualStr isKindOfClass:[NSNull class]]&&![inMaualStr isEqualToString:MANUAL_PUNCH_URI])
                        {
                            punchObj.isInManualEditPunch=YES;
                        }
                        else
                        {
                            punchObj.isInManualEditPunch=NO;
                        }
                        if (outMaualStr!=nil && ![outMaualStr isKindOfClass:[NSNull class]]&&![outMaualStr isEqualToString:MANUAL_PUNCH_URI])
                        {
                            punchObj.isOutManualEditPunch=YES;
                        }
                        else
                        {
                            punchObj.isOutManualEditPunch=NO;
                        }


                        //                        if (![self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
                        //                        {
                        punchObj.punchTransferredStatus=[datadict objectForKey:@"timesheetTransferStatus"];
                        //                        }

                        //MOBI-595
                        id punchInTS=[datadict objectForKey:@"PunchInDateTimestamp"];
                        id punchOutTS=[datadict objectForKey:@"PunchOutDateTimestamp"];
                        NSString *PunchInDateTimestamp=nil;
                        if (punchInTS!=nil && ![punchInTS isKindOfClass:[NSNull class]])
                        {
                            PunchInDateTimestamp=[[datadict objectForKey:@"PunchInDateTimestamp"] stringValue];
                        }
                        NSString *PunchOutDateTimestamp=nil;
                        if (punchOutTS!=nil && ![punchOutTS isKindOfClass:[NSNull class]])
                        {
                            PunchOutDateTimestamp=[[datadict objectForKey:@"PunchOutDateTimestamp"] stringValue];
                        }
                        if (PunchInDateTimestamp!=nil && ![PunchInDateTimestamp isKindOfClass:[NSNull class]]&& ![PunchInDateTimestamp isEqualToString:@""]&& PunchOutDateTimestamp!=nil && ![PunchOutDateTimestamp isKindOfClass:[NSNull class]]&& ![PunchOutDateTimestamp isEqualToString:@""] )
                        {
                            NSDate *inPunchDate=[Util convertTimestampFromDBToDate:PunchInDateTimestamp];
                            NSDate *outPunchDate=[Util convertTimestampFromDBToDate:PunchOutDateTimestamp];
                            NSMutableDictionary *diffDict=[Util getDifferenceDictionaryForInTimeDate:inPunchDate outTimeDate:outPunchDate];
                            hoursActivity=hoursActivity+[[diffDict objectForKey:@"hour"] newFloatValue];
                            minsActivity=minsActivity+[[diffDict objectForKey:@"minute"] newFloatValue];
                            if (![[datadict objectForKey:@"totalHours"] isKindOfClass:[NSNull class]]) {
                                totalHourForActivity=totalHourForActivity+[[datadict objectForKey:@"totalHours"] newFloatValue];
                            }
                            else{
                                totalHourForActivity = 0;
                            }

                        }
                        if (![[datadict objectForKey:@"punchInUri"] isKindOfClass:[NSNull class]] || ![[datadict objectForKey:@"punchOutUri"] isKindOfClass:[NSNull class]] ) {
                            [tmpPunchArrayObj addObject:punchObj];
                        }
                        else{
                        }



                    }
                    if (!isEntireEntriesBlankEntry)
                    {
                        if (isBreak)
                        {
                            TeamTimeBreakObject *breakObj=(TeamTimeBreakObject *)tmpObj;
                            breakObj.totalHours=[NSString stringWithFormat:@"%.2f",totalHourForActivity];
                            if (minsActivity<10)
                            {
                                breakObj.durationInHrsMins=[NSString stringWithFormat:@"%d:0%d",hoursActivity,minsActivity];
                            }
                            else
                            {
                                breakObj.durationInHrsMins=[NSString stringWithFormat:@"%d:%d",hoursActivity,minsActivity];
                            }
                            [localdataArray addObject:breakObj];
                        }
                        else
                        {
                            TeamTimeActivityObject *activityObj=(TeamTimeActivityObject *)tmpObj;
                            activityObj.totalHours=[NSString stringWithFormat:@"%.2f",totalHourForActivity];
                            if (minsActivity<10)
                            {
                                activityObj.durationInHrsMins=[NSString stringWithFormat:@"%d:0%d",hoursActivity,minsActivity];
                            }
                            else
                            {
                                activityObj.durationInHrsMins=[NSString stringWithFormat:@"%d:%d",hoursActivity,minsActivity];
                            }

                            if ([tmpPunchArrayObj count] != 0) {

                                [localdataArray addObject:activityObj];


                            }
                            else{
                                [localdataArray addObject:RPLocalizedString(NO_ENTRIES_TEXT, @"")];
                            }
                        }
                    }

                    if ([tmpPunchArrayObj count] == 0) {
                        userObj.isUserHasNoData = true;
                    }
                    [localdataArray addObjectsFromArray:tmpPunchArrayObj];

                }

            }
            else
            {
                NSMutableArray *punchesArray=nil;
                if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
                {
                    TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
                    punchesArray=[teamTimeModel getAllPunchesFromDBForUser:punchUserUri andDate:todayDateStr];
                }
                else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
                {
                    PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                    punchesArray=[punchHistoryModel getAllPunchesFromDBForUser:punchUserUri andDate:todayDateStr isFromWidgetTimesheet:NO approvalsModule:self.approvalsModuleName];
                }
                else
                {
                    PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                    punchesArray=[punchHistoryModel getAllPunchesFromDBForUser:punchUserUri andDate:todayDateStr isFromWidgetTimesheet:YES approvalsModule:self.approvalsModuleName];
                }

                if ([punchesArray count]==0) {
                    [localdataArray removeLastObject];
                }

                NSMutableArray *tmpPunchArrayObj=[NSMutableArray array];

                for (int m=0; m<[punchesArray count]; m++)
                {
                    isEntriesAvailable=YES;
                    TeamTimePunchObject *punchObj=[[TeamTimePunchObject alloc]init];
                    NSMutableDictionary *datadict=[punchesArray objectAtIndex:m];
                    punchObj.PunchInAddress =[datadict objectForKey:@"PunchInAddress"];
                    punchObj.PunchInDate =[datadict objectForKey:@"PunchInDate"];
                    punchObj.PunchInDateTimestamp =[datadict objectForKey:@"PunchInDateTimestamp"];
                    punchObj.PunchInLatitude =[datadict objectForKey:@"PunchInLatitude"];
                    punchObj.PunchInLongitude =[datadict objectForKey:@"PunchInLongitude"];
                    punchObj.PunchInTime =[datadict objectForKey:@"PunchInTime"];
                    punchObj.PunchOutAddress =[datadict objectForKey:@"PunchOutAddress"];
                    punchObj.PunchOutDate =[datadict objectForKey:@"PunchOutDate"];
                    punchObj.PunchOutDateTimestamp =[datadict objectForKey:@"PunchOutDateTimestamp"];
                    punchObj.PunchOutLatitude =[datadict objectForKey:@"PunchOutLatitude"];
                    punchObj.PunchOutLongitude =[datadict objectForKey:@"PunchOutLongitude"];
                    punchObj.PunchOutTime =[datadict objectForKey:@"PunchOutTime"];
                    punchObj.activityName =[datadict objectForKey:@"activityName"];
                    punchObj.activityUri =[datadict objectForKey:@"activityUri"];
                    punchObj.punchInAgent =[datadict objectForKey:@"punchInAgent"];
                    punchObj.punchInFullSizeImageLink =[datadict objectForKey:@"punchInFullSizeImageLink"];
                    punchObj.punchInFullSizeImageUri =[datadict objectForKey:@"punchInFullSizeImageUri"];
                    punchObj.punchInThumbnailSizeImageLink =[datadict objectForKey:@"punchInThumbnailSizeImageLink"];
                    punchObj.punchInThumbnailSizeImageUri =[datadict objectForKey:@"punchInThumbnailSizeImageUri"];
                    punchObj.punchInUri =[datadict objectForKey:@"punchInUri"];
                    punchObj.punchOutAgent =[datadict objectForKey:@"punchOutAgent"];
                    punchObj.punchOutFullSizeImageLink =[datadict objectForKey:@"punchOutFullSizeImageLink"];
                    punchObj.punchOutFullSizeImageUri =[datadict objectForKey:@"punchOutFullSizeImageUri"];
                    punchObj.punchOutThumbnailSizeImageLink =[datadict objectForKey:@"punchOutThumbnailSizeImageLink"];
                    punchObj.punchOutThumbnailSizeImageUri =[datadict objectForKey:@"punchOutThumbnailSizeImageUri"];
                    punchObj.punchOutUri =[datadict objectForKey:@"punchOutUri"];
                    punchObj.punchUserName =[datadict objectForKey:@"punchUserName"];
                    punchObj.punchUserUri =[datadict objectForKey:@"punchUserUri"];
                    punchObj.totalHours =[datadict objectForKey:@"totalHours"];
                    punchObj.breakName=[datadict objectForKey:@"breakName"];
                    punchObj.breakUri=[datadict objectForKey:@"breakUri"];

                    punchObj.punchInAgentUri=[datadict objectForKey:@"punchInAgentUri"];
                    punchObj.punchOutAgentUri=[datadict objectForKey:@"punchOutAgentUri"];
                    punchObj.punchInCloudClockUri=[datadict objectForKey:@"cloudClockInUri"];
                    punchObj.punchOutCloudClockUri=[datadict objectForKey:@"cloudClockOutUri"];
                    punchObj.punchInAccuracyInMeters=[datadict objectForKey:@"punchInaccuracyInMeters"];
                    punchObj.punchOutAccuracyInMeters=[datadict objectForKey:@"punchOutaccuracyInMeters"];
                    punchObj.punchInActionUri=[datadict objectForKey:@"punchInActionUri"];
                    punchObj.punchOutActionUri=[datadict objectForKey:@"punchOutActionUri"];

                    NSString *inMaualStr=[datadict objectForKey:@"startPunchLastModificationTypeUri"];
                    NSString *outMaualStr=[datadict objectForKey:@"endPunchLastModificationTypeUri"];


                    if (inMaualStr!=nil && ![inMaualStr isKindOfClass:[NSNull class]]&&![inMaualStr isEqualToString:MANUAL_PUNCH_URI])
                    {
                        punchObj.isInManualEditPunch=YES;
                    }
                    else
                    {
                        punchObj.isInManualEditPunch=NO;
                    }
                    if (outMaualStr!=nil && ![outMaualStr isKindOfClass:[NSNull class]]&&![outMaualStr isEqualToString:MANUAL_PUNCH_URI])
                    {
                        punchObj.isOutManualEditPunch=YES;
                    }
                    else
                    {
                        punchObj.isOutManualEditPunch=NO;
                    }


                    //                if (![self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
                    //                {
                    punchObj.punchTransferredStatus=[datadict objectForKey:@"timesheetTransferStatus"];
                    //                }
                    if (punchObj.breakUri!=nil&&![punchObj.breakUri isKindOfClass:[NSNull class]]&&![punchObj.breakUri isEqualToString:@""])
                    {
                        punchObj.isBreakPunch=YES;
                    }
                    else
                    {
                        punchObj.isBreakPunch=NO;
                    }
                    
                    if (module==Images_Tag)
                    {
                        punchObj.CellIdentifier=IMAGES_PAIR_CELL;
                    }
                    else
                    {
                        punchObj.CellIdentifier=LOCATION_PAIR_CELL;
                    }
                    
                    
                    if (![[datadict objectForKey:@"punchInUri"] isKindOfClass:[NSNull class]] || ![[datadict objectForKey:@"punchOutUri"] isKindOfClass:[NSNull class]] ) {
                        [tmpPunchArrayObj addObject:punchObj];
                    }
                    else{
                    }
                    
                    if ([tmpPunchArrayObj count] != 0) {
                        [localdataArray addObject:punchObj];
                    }
                    else{
                        [localdataArray addObject:RPLocalizedString(NO_ENTRIES_TEXT, @"")];
                        userObj.isUserHasNoData = true;
                    }
                    
                    
                }
            }
            
            
        }
    }


    BOOL tmpissFromPunchHistory=NO;
    if (![self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
        tmpissFromPunchHistory=YES;
    }
    if ([userInfoArray count]==0 && tmpissFromPunchHistory)
    {

        TeamTimeUserObject *userObj=[[TeamTimeUserObject alloc]init];
        userObj.CellIdentifier=USER_CELL;
        userObj.isUserHasNoData = TRUE;
        userObj.durationInHrsMins=@"0:00";
        userObj.totalHours=@"0:00";
        userObj.breakHours=@"0:00";
        userObj.regularHours=@"0:00";
        [localdataArray addObject:userObj];
        [localdataArray addObject:NO_ENTRIES_TEXT];
        isEntriesAvailable=YES;
        if ([self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]]) {
            userObj.userUri=self.approvalsModuleUserUri;
        }
        else{

            SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
            NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
            NSString *userUri=@"";
            if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
            {
                userUri= [[userDetailsArr objectAtIndex:0] objectForKey:@"uri"];
                
            }
            userObj.userUri=userUri;
            userObj.userName=@"";

        }

    
    }
    if (isEntriesAvailable) {
        return localdataArray;
    }
    return nil;
    
}

-(NSMutableArray*)createWeekList :(BOOL)isWeekStartedFromMonday
{
    NSMutableArray  *tempArray = [NSMutableArray array];
    if([self.navigationType isKindOfClass:[TeamTimeNavigationController class]]||[self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
        
        
        NSCalendar *gregorian1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [gregorian1 components:NSCalendarUnitWeekday fromDate:[NSDate date]];
        NSInteger weekday = [comps weekday];
        
        if (isWeekStartedFromMonday == TRUE) {
            if (weekday == 1 || weekday == 2) {
                weekday=2;
            }
            else
            {
                weekday = 2- weekday;
            }
        }
        else
        {
            if (weekday == 1) {
                weekday=1;
            }
            else
            {
                weekday = 1- weekday;
            }
        }
        
        
        // start by retrieving day, weekday, month and year components for yourDate
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *todayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
        NSInteger theDay = [todayComponents day];
        NSInteger theMonth = [todayComponents month];
        NSInteger theYear = [todayComponents year];
        
        
        // now build a NSDate object for yourDate using these components
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:theDay];
        [components setMonth:theMonth];
        [components setYear:theYear];
        NSDate *thisDate = [gregorian dateFromComponents:components];
        
        // now build a NSDate object for the next day
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        
        
        NSDate *finalEndDate=nil;
        NSDate *finalStartDate=nil;
        for (int i=0; i<4; i++)
        {
            [offsetComponents setDay:weekday-(7*i)];
            NSDate *startDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
            [offsetComponents setDay:weekday+6-(7*i)];
            NSDate *lastDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
            if (i==0)
            {
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:1];
                finalEndDate=[gregorian dateByAddingComponents:offsetComponents toDate:lastDate options:0];
            }
            if (i==3) {
                finalStartDate=startDate;
            }
        }
        
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *componentsNew = [gregorianCalendar components:NSCalendarUnitDay
                                                               fromDate:finalStartDate
                                                                 toDate:finalEndDate
                                                                options:0];
        
        for (int i=1; i<=[componentsNew day]; i++)
        {
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:i];
            NSDate *date = [gregorian dateByAddingComponents:offsetComponents toDate:finalStartDate options:0];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd-MM-yyyy"];
            NSString *startDateString = [dateFormat stringFromDate:date];
            [tempArray addObject:startDateString];
        }
    }
    else
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSString *startDateString = [dateFormat stringFromDate:timesheetStartDate];
         NSString *endDateString = [dateFormat stringFromDate:timesheetEndDate];
        
        NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSMutableArray *datesArrayTemp=[Util getArrayOfDatesForWeekWithStartDate:startDateString andEndDate:endDateString];
        if (!datesArrayTemp)
        {
            datesArrayTemp=[NSMutableArray array];
        }
        NSUInteger count=[datesArrayTemp count];
        for (int i=0; i<count; i++)//MOBI-967
        {
            NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
            [offsetComponents setDay:i];
            NSDate *date = [gregorianCalendar dateByAddingComponents:offsetComponents toDate:timesheetStartDate options:0];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd-MM-yyyy"];
            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            NSString *startDateString = [dateFormat stringFromDate:date];
            [tempArray addObject:startDateString];
        }
    }
   
    
    return tempArray;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [myDateFormatter setLocale:locale];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [myDateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *dateStr=[self.datesArray objectAtIndex:self.currentSelectedPage];
    NSDate *date=[myDateFormatter dateFromString:dateStr];
    [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *todayDateStr=[myDateFormatter stringFromDate:date];
    
    //DON't ALLOW for Punch History
    BOOL isEditPermission=FALSE;
    NSMutableArray *userInfoArray=nil;
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
        TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
        userInfoArray=[teamTimeModel getAllTeamPunchesFromDB];
        if ([userInfoArray count]>0)
        {
            NSString *useruri=[[userInfoArray objectAtIndex:0] objectForKey:@"punchUserUri"];
            NSMutableDictionary *dict=[teamTimeModel getUserCapabilitiesForUserUri:useruri];
            
            isEditPermission=[[dict objectForKey:@"canEditTimePunch"] boolValue];
        }
    }
    else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
        PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
        userInfoArray=[punchHistoryModel getAllPunchesFromDBIsFromWidgetTimesheet:NO forDate:nil approvalsModule:self.approvalsModuleName];
        if ([userInfoArray count]>0)
        {
            
            isEditPermission=[[[userInfoArray objectAtIndex:0] objectForKey:@"canEditTimePunch"] boolValue];
        }
        
    }
    else if ([self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
       isEditPermission=[self canSupervisorEditPunch];
        
    }
    else
    {
        if (!isEditable)
        {
            isEditPermission=NO;
        }
        else
        {
            SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
            NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
            if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
            {

                isEditPermission = [[[userDetailsArr objectAtIndex:0] objectForKey:@"canEditTimePunch"]boolValue];
                
            }
        }


    }
    NSString *startTimeString=nil;
    NSString *endTimeString=nil;
    NSString *punchInUri=nil;
    NSString *punchOutUri=nil;
    id tmpObj=[self.dataArray objectAtIndex:indexPath.row];
    
    
    if ([tmpObj isKindOfClass:[TeamTimePunchObject class]])
    {
        TeamTimePunchObject *punchObj=(TeamTimePunchObject *)tmpObj;
        startTimeString=punchObj.PunchInTime;
        endTimeString=punchObj.PunchOutTime;
        punchInUri=punchObj.punchInUri;
        punchOutUri=punchObj.punchOutUri;
    }
    
    BOOL isNavigate=YES;
    if (!isEditPermission) {
        if ([btnClicked isEqualToString:@"In"])
        {
            if (startTimeString==nil ||[startTimeString isKindOfClass:[NSNull class]]||[startTimeString isEqualToString:@""])
            {
                isNavigate=NO;
            }
            
            
        }
        if ([btnClicked isEqualToString:@"Out"])
        {
            if (endTimeString==nil ||[endTimeString isKindOfClass:[NSNull class]]||[endTimeString isEqualToString:@""])
            {
                isNavigate=NO;
            }
        }

    }


    if (isNavigate) {
        //    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
        //    {
        id tmpObj=[self.dataArray objectAtIndex:indexPath.row];
        PunchEntryViewController *punchViewController=[[PunchEntryViewController alloc]init];
        punchViewController.approvalsModuleName = self.approvalsModuleName;
        punchViewController.delegate=self;
        
        if ([btnClicked isEqualToString:@"In"])
        {
            if (startTimeString!=nil && ![startTimeString isKindOfClass:[NSNull class]])
            {
                punchViewController.screenMode=EDIT_PUNCH_ENTRY;
            }
            else {
                punchViewController.screenMode=ADD_PUNCH_ENTRY;
                
                if ([btnClicked isEqualToString:@"In"])
                {
                    punchViewController.setViewTag=0;
                }
                
                
            }
            
            punchViewController.BtnClicked=@"In";
            punchViewController.punchUri=punchInUri;
        }
        if ([btnClicked isEqualToString:@"Out"])
        {
            if (endTimeString!=nil && ![endTimeString isKindOfClass:[NSNull class]])
            {
                punchViewController.screenMode=EDIT_PUNCH_ENTRY;
            }
            else {
                punchViewController.screenMode=ADD_PUNCH_ENTRY;
                
                if ([btnClicked isEqualToString:@"Out"])
                {
                    punchViewController.setViewTag=1;
                }
                
                
            }
            
            punchViewController.BtnClicked=@"Out";
            punchViewController.punchUri=punchOutUri;
        }
        if (!isEditPermission) {
            punchViewController.screenMode=VIEW_PUNCH_ENTRY;
        }
        if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]]||
            [self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
        {
            //Do nothing
        }
        else if ([self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            if ([self canSupervisorEditPunch]) {

                if ([btnClicked isEqualToString:@"In"]&& (startTimeString==nil || [startTimeString isKindOfClass:[NSNull class]])){
                    punchViewController.screenMode=ADD_PUNCH_ENTRY;

                }
                else if ([btnClicked isEqualToString:@"Out"]&& (endTimeString==nil || [endTimeString isKindOfClass:[NSNull class]])){
                    punchViewController.screenMode=ADD_PUNCH_ENTRY;

                }
                else{
                    punchViewController.screenMode=EDIT_PUNCH_ENTRY;

                }
            }
            else{
                punchViewController.screenMode=VIEW_PUNCH_ENTRY;
            }
        }
        else
        {
            if (!isEditable)
            {
                punchViewController.screenMode=VIEW_PUNCH_ENTRY;
            }
            
        }
        if ([tmpObj isKindOfClass:[TeamTimePunchObject class]])
        {
            if (punchViewController.screenMode==ADD_PUNCH_ENTRY)
            {
                [self addPunch:indexPath isFRomAddPunch:NO];
            }
            else
            {
                TeamTimePunchObject *punchObj=(TeamTimePunchObject *)tmpObj;
               
                

                
                punchViewController.currentPageDate=self.currentDateString;
                punchViewController.currentUser=punchObj.punchUserName;
                TeamTimePunchObject *tempPunchObj=[[TeamTimePunchObject alloc]init];
                
                tempPunchObj.PunchInAddress =punchObj.PunchInAddress;
                tempPunchObj.PunchInDate =punchObj.PunchInDate;
                tempPunchObj.PunchInDateTimestamp =punchObj.PunchInDateTimestamp;
                tempPunchObj.PunchInLatitude =punchObj.PunchInLatitude;
                tempPunchObj.PunchInLongitude =punchObj.PunchInLongitude;
                tempPunchObj.PunchInTime =punchObj.PunchInTime;
                tempPunchObj.PunchOutAddress =punchObj.PunchOutAddress;
                tempPunchObj.PunchOutDate =punchObj.PunchOutDate;
                tempPunchObj.PunchOutDateTimestamp =punchObj.PunchOutDateTimestamp;
                tempPunchObj.PunchOutLatitude =punchObj.PunchOutLatitude;
                tempPunchObj.PunchOutLongitude =punchObj.PunchOutLongitude;
                tempPunchObj.PunchOutTime =punchObj.PunchOutTime;
                tempPunchObj.activityName =punchObj.activityName;
                tempPunchObj.activityUri =punchObj.activityUri;
                tempPunchObj.punchInAgent =punchObj.punchInAgent;
                tempPunchObj.punchInFullSizeImageLink =punchObj.punchInFullSizeImageLink;
                tempPunchObj.punchInFullSizeImageUri =punchObj.punchInFullSizeImageUri;
                tempPunchObj.punchInThumbnailSizeImageLink =punchObj.punchInThumbnailSizeImageLink;
                tempPunchObj.punchInThumbnailSizeImageUri =punchObj.punchInThumbnailSizeImageUri;
                tempPunchObj.punchInUri =punchObj.punchInUri;
                tempPunchObj.punchOutAgent =punchObj.punchOutAgent;
                tempPunchObj.punchOutFullSizeImageLink =punchObj.punchOutFullSizeImageLink;
                tempPunchObj.punchOutFullSizeImageUri =punchObj.punchOutFullSizeImageUri;
                tempPunchObj.punchOutThumbnailSizeImageLink =punchObj.punchOutThumbnailSizeImageLink;
                tempPunchObj.punchOutThumbnailSizeImageUri =punchObj.punchOutThumbnailSizeImageUri;
                tempPunchObj.punchOutUri =punchObj.punchOutUri;
                tempPunchObj.punchUserName =punchObj.punchUserName;
                tempPunchObj.punchUserUri =punchObj.punchUserUri;
                tempPunchObj.totalHours =punchObj.totalHours;
                tempPunchObj.CellIdentifier=PUNCH_CELL;
                tempPunchObj.breakName=punchObj.breakName;
                tempPunchObj.breakUri=punchObj.breakUri;
                tempPunchObj.isBreakPunch=punchObj.isBreakPunch;
                
                tempPunchObj.punchInAgentUri=punchObj.punchInAgentUri;
                tempPunchObj.punchOutAgentUri=punchObj.punchOutAgentUri;
                tempPunchObj.punchInCloudClockUri=punchObj.punchInCloudClockUri;
                tempPunchObj.punchOutCloudClockUri=punchObj.punchOutCloudClockUri;
                tempPunchObj.punchInAccuracyInMeters=punchObj.punchInAccuracyInMeters;
                tempPunchObj.punchOutAccuracyInMeters=punchObj.punchOutAccuracyInMeters;
                tempPunchObj.punchInActionUri=punchObj.punchInActionUri;
                tempPunchObj.punchOutActionUri=punchObj.punchOutActionUri;
                
                
                if(tempPunchObj.punchOutActionUri!=nil && ![tempPunchObj.punchOutActionUri isKindOfClass:[NSNull class]] && [btnClicked isEqualToString:@"Out"])
                {
                    if ([tempPunchObj.punchOutActionUri isEqualToString:PUNCH_START_BREAK_URI])
                    {
                        if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
                        {
                            TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
                            NSDictionary *getPunchDict=[teamTimeModel getPunchFromDBWithUri:tempPunchObj.punchOutUri forActionURI:tempPunchObj.punchOutActionUri];
                            
                            if ([getPunchDict allKeys])
                            {
                                tempPunchObj.breakName=[getPunchDict objectForKey:@"breakName"];
                                tempPunchObj.breakUri=[getPunchDict objectForKey:@"breakUri"];
                                //tempPunchObj.punchInUri=tempPunchObj.punchOutActionUri;
                                // punchViewController.BtnClicked=@"In";
                            }
                            
                            
                            
                        }
                        else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
                        {
                            PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                            NSDictionary *getPunchDict=[punchHistoryModel getPunchFromDBWithUri:tempPunchObj.punchOutUri forActionURI:tempPunchObj.punchOutActionUri isFromWidgetTimesheet:NO forDate:nil approvalsModule:self.approvalsModuleName];
                            
                            if ([getPunchDict allKeys])
                            {
                                tempPunchObj.breakName=[getPunchDict objectForKey:@"breakName"];
                                tempPunchObj.breakUri=[getPunchDict objectForKey:@"breakUri"];
                                //tempPunchObj.punchInUri=tempPunchObj.punchOutActionUri;
                                //punchViewController.BtnClicked=@"In";
                            }
                        }
                        else
                        {
                            PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                            NSDictionary *getPunchDict=[punchHistoryModel getPunchFromDBWithUri:tempPunchObj.punchOutUri forActionURI:tempPunchObj.punchOutActionUri isFromWidgetTimesheet:YES forDate:todayDateStr approvalsModule:self.approvalsModuleName];
                            
                            if ([getPunchDict allKeys])
                            {
                                tempPunchObj.breakName=[getPunchDict objectForKey:@"breakName"];
                                tempPunchObj.breakUri=[getPunchDict objectForKey:@"breakUri"];
                                //tempPunchObj.punchInUri=tempPunchObj.punchOutActionUri;
                                //punchViewController.BtnClicked=@"In";
                            }
                        }
                    }
                    
                    else if ([tempPunchObj.punchOutActionUri isEqualToString:PUNCH_TRANSFER_URI])
                    {
                        if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
                        {
                            TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
                            NSDictionary *getPunchDict=[teamTimeModel getPunchFromDBWithUri:tempPunchObj.punchOutUri forActionURI:tempPunchObj.punchOutActionUri];
                            
                            if ([getPunchDict allKeys])
                            {
                                tempPunchObj.activityName=[getPunchDict objectForKey:@"activityName"];
                                tempPunchObj.activityUri=[getPunchDict objectForKey:@"activityUri"];
                                //tempPunchObj.punchInUri=tempPunchObj.punchOutActionUri;
                                // punchViewController.BtnClicked=@"In";
                            }
                            
                            
                            
                        }
                        else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
                        {
                            PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                            NSDictionary *getPunchDict=[punchHistoryModel getPunchFromDBWithUri:tempPunchObj.punchOutUri forActionURI:tempPunchObj.punchOutActionUri isFromWidgetTimesheet:NO forDate:nil approvalsModule:self.approvalsModuleName];
                            
                            if ([getPunchDict allKeys])
                            {
                                tempPunchObj.activityName=[getPunchDict objectForKey:@"activityName"];
                                tempPunchObj.activityUri=[getPunchDict objectForKey:@"activityUri"];
                                //tempPunchObj.punchInUri=tempPunchObj.punchOutActionUri;
                                //punchViewController.BtnClicked=@"In";
                            }
                        }
                        else
                        {
                            PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
                            NSDictionary *getPunchDict=[punchHistoryModel getPunchFromDBWithUri:tempPunchObj.punchOutUri forActionURI:tempPunchObj.punchOutActionUri isFromWidgetTimesheet:YES forDate:todayDateStr approvalsModule:self.approvalsModuleName];
                            
                            if ([getPunchDict allKeys])
                            {
                                tempPunchObj.activityName=[getPunchDict objectForKey:@"activityName"];
                                tempPunchObj.activityUri=[getPunchDict objectForKey:@"activityUri"];
                                //tempPunchObj.punchInUri=tempPunchObj.punchOutActionUri;
                                //punchViewController.BtnClicked=@"In";
                            }
                        }
                    }
                }
                
                
                
                
                tempPunchObj.isInManualEditPunch=punchObj.isInManualEditPunch;
                tempPunchObj.isOutManualEditPunch=punchObj.isOutManualEditPunch;
                punchViewController.timesheetURI=self.sheetIdentity;
                punchViewController.punchObj=tempPunchObj;
                
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_VIEW_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:UPDATE_VIEW_NOTIFICATION object:nil];
                [self.navigationController pushViewController:punchViewController animated:YES];
            }
            
            
            
        }
       
        //    }

    }
    
    

}
- (void)addPunch:(NSIndexPath *)indexPath isFRomAddPunch:(BOOL)isFromAddPunch{
    id tmpObj=[self.dataArray objectAtIndex:indexPath.row];
    PunchEntryViewController *punchViewController=[[PunchEntryViewController alloc]init];
    punchViewController.approvalsModuleName = self.approvalsModuleName;
    punchViewController.delegate=self;
    TeamTimePunchObject *tempPunchObj=nil;
    
    punchViewController.setViewTag=0;
//    
//    
    if ([btnClicked isEqualToString:@"In"])
    {
        punchViewController.setViewTag=0;
    }
    else if ([btnClicked isEqualToString:@"Out"])
    {
        punchViewController.setViewTag=1;
    }
    if (isFromAddPunch)
    {
        punchViewController.setViewTag=0;
    }
    
    punchViewController.screenMode=ADD_PUNCH_ENTRY;
    
    
    if ([tmpObj isKindOfClass:[TeamTimePunchObject class]])
    {
       tempPunchObj=[(TeamTimePunchObject *)tmpObj copy];
        punchViewController.currentPageDate=self.currentDateString;
        punchViewController.currentUser=tempPunchObj.punchUserName;
        
    }
    
    
    if ([tmpObj isKindOfClass:[TeamTimeUserObject class]])
    {
        TeamTimeUserObject *userObj=(TeamTimeUserObject *)tmpObj;
        punchViewController.currentUser=userObj.userName;
            
        punchViewController.screenMode=ADD_PUNCH_ENTRY;
        punchViewController.currentPageDate=self.currentDateString;
       tempPunchObj=[[TeamTimePunchObject alloc]init];
        
        tempPunchObj.punchUserName =userObj.userName;;
        tempPunchObj.punchUserUri =userObj.userUri;
    }
    
    
    
    tempPunchObj.PunchInAddress =nil;
    tempPunchObj.PunchInDate =nil;
    tempPunchObj.PunchInDateTimestamp =nil;
    tempPunchObj.PunchInLatitude =nil;
    tempPunchObj.PunchInLongitude =nil;
    tempPunchObj.PunchInTime =nil;
    tempPunchObj.PunchOutAddress =nil;
    tempPunchObj.PunchOutDate =nil;
    tempPunchObj.PunchOutDateTimestamp =nil;
    tempPunchObj.PunchOutLatitude =nil;
    tempPunchObj.PunchOutLongitude =nil;
    tempPunchObj.PunchOutTime =nil;
    tempPunchObj.activityName =nil;
    tempPunchObj.activityUri =nil;
    tempPunchObj.punchInAgent =nil;
    tempPunchObj.punchInFullSizeImageLink =nil;
    tempPunchObj.punchInFullSizeImageUri =nil;
    tempPunchObj.punchInThumbnailSizeImageLink =nil;
    tempPunchObj.punchInThumbnailSizeImageUri =nil;
    tempPunchObj.punchInUri =nil;
    tempPunchObj.punchOutAgent =nil;
    tempPunchObj.punchOutFullSizeImageLink =nil;
    tempPunchObj.punchOutFullSizeImageUri =nil;
    tempPunchObj.punchOutThumbnailSizeImageLink =nil;
    tempPunchObj.punchOutThumbnailSizeImageUri =nil;
    tempPunchObj.punchOutUri =nil;
    
    tempPunchObj.totalHours =nil;
    tempPunchObj.CellIdentifier=PUNCH_CELL;
    tempPunchObj.breakName=nil;
    tempPunchObj.breakUri=nil;
    tempPunchObj.isBreakPunch=NO;
    
    tempPunchObj.punchInAgentUri =nil;
    tempPunchObj.punchOutAgentUri =nil;
    tempPunchObj.punchInCloudClockUri =nil;
    tempPunchObj.punchOutCloudClockUri =nil;
    tempPunchObj.punchInAccuracyInMeters=nil;
    tempPunchObj.punchOutAccuracyInMeters=nil;
    tempPunchObj.punchInActionUri=nil;
    tempPunchObj.punchOutActionUri=nil;
    
    
    
    punchViewController.timesheetURI=sheetIdentity;
    punchViewController.punchObj=tempPunchObj;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATE_VIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView:) name:UPDATE_VIEW_NOTIFICATION object:nil];
    
    [self.navigationController pushViewController:punchViewController animated:YES];
}


-(void)postActionReceived:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:POST_TEAM_NOTIFICATION object:nil];
    
    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"isError"]boolValue];
    
    if (!hasError)
    {
        [self timesheetDayBtnClickedWithTag:self.currentSelectedPage];
        
        
    }
    else
    {
         [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    }
    
   
}
-(void)receivedPunchesForTimesheet
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
    [self paintView];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//Mobi-854 testCase//JUHI
-(BOOL)showAddButton:(BOOL)canEditTimePunch{
    
    
    if (canEditTimePunch)
    {
        return TRUE;
    }

    return FALSE;
}

-(BOOL )canSupervisorEditPunch
{
    SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
    NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
    if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
    {
        ApprovalsModel *approvalsModel = [[ApprovalsModel alloc]init];

        BOOL canEditTimesheet = NO;
        if (self.approvalsModuleName !=nil&& ![self.approvalsModuleName isKindOfClass:[NSNull class]]&& ![self.approvalsModuleName isEqualToString:@""])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                canEditTimesheet = [approvalsModel getTimeSheetEditStatusForSheetFromDB: self.sheetIdentity forTableName:@"PendingApprovalTimesheets"];
            }
            else
            {
                canEditTimesheet = [approvalsModel getTimeSheetEditStatusForSheetFromDB: self.sheetIdentity forTableName:@"PreviousApprovalTimesheets"];

            }
        }

        BOOL canEditTeamTimePunch = [[[userDetailsArr objectAtIndex:0] objectForKey:@"canEditTeamTimePunch"]boolValue];
        BOOL isTimesheetOpenForEdit = ([self.sheetApprovalStatus isEqualToString:NOT_SUBMITTED_STATUS]||
                                       [self.sheetApprovalStatus isEqualToString:REJECTED_STATUS]);
        return (canEditTimesheet && canEditTeamTimePunch && isTimesheetOpenForEdit);

    }

    return NO;

}
@end
