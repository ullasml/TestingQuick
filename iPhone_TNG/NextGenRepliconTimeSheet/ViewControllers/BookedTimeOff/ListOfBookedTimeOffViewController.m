#import "ListOfBookedTimeOffViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Util.h"
#import "UISegmentedControlExtension.h"
#import "TimeOffBalanceViewController.h"
#import "TimeOffHolidayViewController.h"
#import "TimeOffDetailsViewController.h"
#import "NSString+Double_Float.h"
#import "NSNumber+Double_Float.h"
#import "RepliconServiceManager.h"
#import <Blindside/BSInjector.h>


@interface ListOfBookedTimeOffViewController ()
@property(nonatomic,strong) TimeOffBookingsViewController *timeOffBookingViewCtrl;
@property(nonatomic,strong) TimeOffBalanceViewController *timeOffBalanceViewCtrl;
@property(nonatomic,strong) TimeOffHolidayViewController *timeOffHolidayViewCtrl;
@property(nonatomic,strong) TimeOffObject *bookedTimeOffObject;
@property(nonatomic,strong) MultiDayTimeOffViewController *multiDayTimeOffViewController;
@property (nonatomic,weak) id<BSInjector> injector;
@property (nonatomic) id<Theme> theme;
@property(nonatomic,assign) BOOL isFromDeepLink;

@end

@implementation ListOfBookedTimeOffViewController

@synthesize leftButton;
@synthesize segmentedCtrl;
@synthesize setViewTag;
@synthesize isCalledFromMenu;
@synthesize currentContentOffset;

#define segment_view_section_height 52
#define kTagFirst 1
#define kTagSecond 2
#define kTagThird 3
#define booking_Tag 0
#define balances_Tag 1
#define holiday_Tag 2

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.theme = theme;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    [self createCustomHeaderView];
    [self.timeOffBookingViewCtrl viewWillAppear:TRUE];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    switch (self.setViewTag)
    {
        case booking_Tag:
            [self.timeOffBookingViewCtrl viewWillDisappear:TRUE];
            break;
        case balances_Tag:
            [self.timeOffBalanceViewCtrl viewWillDisappear:TRUE];
            break;
        case holiday_Tag:
            [self.timeOffHolidayViewCtrl viewWillDisappear:TRUE];
            break;
        default:
            break;
    }
    self.isFromDeepLink = NO;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [Util setToolbarLabel: self withText: RPLocalizedString(BookedTimeOffList_Title, BookedTimeOffList_Title)];
    self.navigationController.navigationBar.translucent = NO;
    self.bookedTimeOffObject=[[TimeOffObject alloc]init];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addBookTimeOffEntryAction)];

    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)createCustomHeaderView
{
    float xOffset = 30.0f;
    float yOffset = 9.0f;
    float wSegment = CGRectGetWidth(self.view.bounds) - 2 * xOffset;
    float hSegment = 34.0f;

    [self.view setBackgroundColor:RepliconStandardBackgroundColor];

    NSArray *items = [[NSArray alloc] initWithObjects:
                      RPLocalizedString(Summary_Text,@""),
                      RPLocalizedString(BALANCES,@""),RPLocalizedString(HOLIDAY,@""),nil];

    self.segmentedCtrl = [[UISegmentedControl alloc] initWithItems:items];
    [self.segmentedCtrl setFrame:CGRectMake(xOffset, yOffset, wSegment, hSegment)];
    [self.segmentedCtrl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedCtrl setTag:kTagFirst forSegmentAtIndex:0];
    [self.segmentedCtrl setTag:kTagSecond forSegmentAtIndex:1];
    [self.segmentedCtrl setTag:kTagThird forSegmentAtIndex:2];
    self.segmentedCtrl.clipsToBounds = YES;
    self.segmentedCtrl.layer.cornerRadius = 4.0f;

    NSDictionary *textAttributes = @{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]};
    [self.segmentedCtrl setTitleTextAttributes:textAttributes
                                      forState:UIControlStateNormal];

    [self.segmentedCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                      forState:UIControlStateSelected];
    self.segmentedCtrl.tintColor = [Util colorWithHex:@"#007AC9" alpha:1.0f];
    self.segmentedCtrl.backgroundColor = [UIColor whiteColor];

    self.segmentedCtrl.selectedSegmentIndex = booking_Tag;

    UIView *segmentSectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 50)];
    segmentSectionView.backgroundColor = [Util colorWithHex:@"#EEEEEE" alpha:1];

    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(segmentSectionView.bounds) - 1, CGRectGetWidth(self.view.bounds), 1.0f)];
    separatorView.backgroundColor = [Util colorWithHex:@"#CCCCCC" alpha:1.0f];

    [segmentSectionView addSubview:separatorView];
    [segmentSectionView addSubview:self.segmentedCtrl];

    [self.view addSubview:segmentSectionView];

    [self addSummaryView];
}

/************************************************************************************************************
 @Function Name   : segmentChanged
 @Purpose         : To handle segment selected
 @param           : (id)sender
 @return          : nil
 *************************************************************************************************************/

-(void)segmentChanged:(id)sender {
    // when a segment is selected, it resets the text colors
    // so set them back
    UISegmentedControl *segmentCtrl=(UISegmentedControl *)sender;


    switch (segmentCtrl.selectedSegmentIndex) {
        case 0:
            if (self.setViewTag!=booking_Tag)
            {
                CLS_LOG(@"-----Summary View segement action on ListOfBookedTimeOffViewController -----");
                [self addSummaryView];

            }

            break;
        case 1:
            if (self.setViewTag!=balances_Tag)
            {
                CLS_LOG(@"-----Balance View segement action on ListOfBookedTimeOffViewController -----");
                [self addBalanceView];

            }


            break;
        case 2:
            if (self.setViewTag!=holiday_Tag)
            {
                CLS_LOG(@"-----Holiday View segement action on ListOfBookedTimeOffViewController -----");
                [self addHolidayView];
            }
        default:
            break;
    }

    [UIView commitAnimations];
}

-(void)addBookTimeOffEntryAction
{
    CLS_LOG(@"-----Book timeoff action on ListOfBookedTimeOffViewController -----");

    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [Util showOfflineAlert];
        return;
    }

    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    NSMutableArray *timeOffTypesArray=[timeoffModel getAllTimeOffTypesFromDB];
    if ([timeOffTypesArray count]==0)
    {
        [Util errorAlert:@"" errorMessage:RPLocalizedString(noTimeOffTypesAssigned, @"")];
        return;
    }
    

    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    NSString *userURI=[standardUserDefaults objectForKey:@"UserUri"];
    BOOL hasMultiDayTimeOffBooking = [timeoffModel hasMultiDayTimeOffBooking:userURI];
    if(hasMultiDayTimeOffBooking){
        self.multiDayTimeOffViewController = [self.injector getInstance:InjectorKeyMultiDayTimeOffViewController];
        [self.multiDayTimeOffViewController setupWithModelType:TimeOffModelTypeTimeOff screenMode:ADD_BOOKTIMEOFF navigationFlow:TIMEOFF_BOOKING_NAVIGATION delegate:self timeOffUri:nil timeSheetURI:nil date:nil];
        [self.navigationController pushViewController:self.multiDayTimeOffViewController animated:YES];
    }
    else{
    NSMutableArray *enabledCustomFieldUris=[standardUserDefaults objectForKey:@"timeoffEnableOnlyUdfUriArr"];
    [timeoffModel updateCustomFieldTableFor:TIMEOFF_UDF enableUdfuriArray:enabledCustomFieldUris];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    theCalendar.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dayComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSDate *startDate = [theCalendar dateFromComponents:dayComponent];
    
    [self.bookedTimeOffObject setBookedStartDate:startDate];
    [self.bookedTimeOffObject setBookedEndDate:startDate];
    self.bookedTimeOffObject.typeName=nil;
    self.bookedTimeOffObject.typeIdentity=nil;
    self.bookedTimeOffObject.comments=nil;
    self.bookedTimeOffObject.sheetId=nil;
    self.bookedTimeOffObject.numberOfHours=nil;
    self.bookedTimeOffObject.approvalStatus=nil;
    self.bookedTimeOffObject.startDurationEntryType=nil;
    self.bookedTimeOffObject.endDurationEntryType=nil;
    self.bookedTimeOffObject.entryDate=nil;
    self.bookedTimeOffObject.endTime=nil;
    self.bookedTimeOffObject.startTime=nil;
    self.bookedTimeOffObject.startNumberOfHours=nil;
    self.bookedTimeOffObject.endNumberOfHours=nil;


    TimeOffDetailsViewController *bookedTimeOffEntryController= [[TimeOffDetailsViewController alloc]initWithEntryDetails:self.bookedTimeOffObject sheetId:nil screenMode:ADD_BOOKTIMEOFF];
    bookedTimeOffEntryController.isStatusView=NO;
    bookedTimeOffEntryController.navigationFlow = TIMEOFF_BOOKING_NAVIGATION;
    [bookedTimeOffEntryController setTimeOffObj:self.bookedTimeOffObject];
    [bookedTimeOffEntryController TimeOffDetailsReceived];

    UINavigationController *tempnavcontroller = [[UINavigationController alloc] initWithRootViewController:bookedTimeOffEntryController];
    [self presentViewController:tempnavcontroller animated:YES completion:nil];
    }
}

-(void)goBack:(id)sender{
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)];
}


//callback method from BookedTimeOffSummaryViewController
- (void)didSelectRowAtSummaryViewWithIndexPath:(NSIndexPath *)indexPath
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    DLog(@"%ld",(long)indexPath.row);
    CLS_LOG(@"-----Row selected on ListOfBookedTimeOffViewController -----");
}

- (void)didSelectRowAtSummaryFromTimeOffBooking:(NSIndexPath *)indexPath :(TimeOffObject *)timeOffObj withContentOffset:(CGPoint)contentOffset
{
    
    
    self.bookedTimeOffObject = timeOffObj;
    self.currentContentOffset = contentOffset;
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    DLog(@"%ld",(long)indexPath.row);
    CLS_LOG(@"-----Row selected on ListOfBookedTimeOffViewController -----");
    
    
    NSString *bookedTimeoffURI=[timeOffObj sheetId];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeoffDetailsReponse) name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    
    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    NSArray *dataArray=[timeoffModel getTimeoffInfoSheetIdentity:bookedTimeoffURI];
    for (int i=0; i<[dataArray count]; i++)
    {
        NSDictionary *dict= [dataArray objectAtIndex:i];
        if (([dict objectForKey:@"endDateDurationDecimal"]==nil || [[dict objectForKey:@"endDateDurationDecimal"] isKindOfClass:[NSNull class]]) &&([dict objectForKey:@"startDateDurationDecimal"]==nil || [[dict objectForKey:@"startDateDurationDecimal"] isKindOfClass:[NSNull class]]) )
        {
            AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [[RepliconServiceManager timeoffService]fetchTimeoffEntryDataForBookedTimeoff:bookedTimeoffURI withTimeSheetUri:nil];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
        }
    }

    
    /*TimeOffDetailsViewController *timeOffDetailsViewCtrl= [[TimeOffDetailsViewController alloc] initWithEntryDetails:timeOffObj sheetId:[timeOffObj sheetId] screenMode:screenMode];
    timeOffDetailsViewCtrl.sheetIdString = [timeOffObj sheetId];
    timeOffDetailsViewCtrl.navigationFlow = TIMEOFF_BOOKING_NAVIGATION;
    NSString *bookedTimeoffURI=[timeOffObj sheetId];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForMultiDayTimeoff:) name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];

    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    NSArray *dataArray=[timeoffModel getTimeoffInfoSheetIdentity:bookedTimeoffURI];
    for (int i=0; i<[dataArray count]; i++)
    {
        NSDictionary *dict= [dataArray objectAtIndex:i];
        if (([dict objectForKey:@"endDateDurationDecimal"]==nil || [[dict objectForKey:@"endDateDurationDecimal"] isKindOfClass:[NSNull class]]) &&([dict objectForKey:@"startDateDurationDecimal"]==nil || [[dict objectForKey:@"startDateDurationDecimal"] isKindOfClass:[NSNull class]]) )
        {
            AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [[RepliconServiceManager timeoffService]fetchTimeoffEntryDataForBookedTimeoff:bookedTimeoffURI withTimeSheetUri:nil];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
        }
    }
    [self.navigationController pushViewController:timeOffDetailsViewCtrl animated:YES];
*/
}

-(void)timeoffDetailsReponse{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];

    NSLog(@"%@",self.bookedTimeOffObject.sheetId);
    NSInteger screenMode;
    BOOL status;
    if ([self.bookedTimeOffObject.approvalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS]||[self.bookedTimeOffObject.approvalStatus isEqualToString:APPROVED_STATUS]) {
        screenMode=VIEW_BOOKTIMEOFF;
        status=YES;
    }
    else{
        screenMode=EDIT_BOOKTIMEOFF;
        status=NO;
    }
    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    BOOL isMultiDayTimeOff=[timeoffModel isMultiDayTimeOff:self.bookedTimeOffObject.sheetId];
    if(isMultiDayTimeOff){
        self.multiDayTimeOffViewController = [self.injector getInstance:InjectorKeyMultiDayTimeOffViewController];
        [self.multiDayTimeOffViewController setupWithModelType:TimeOffModelTypeTimeOff screenMode:screenMode navigationFlow:TIMEOFF_BOOKING_NAVIGATION delegate:self timeOffUri:self.bookedTimeOffObject.sheetId timeSheetURI:nil date:nil];
        [self.navigationController pushViewController:self.multiDayTimeOffViewController animated:YES];
    }
    else{
        TimeOffDetailsViewController *timeOffDetailsViewCtrl= [[TimeOffDetailsViewController alloc] initWithEntryDetails:self.bookedTimeOffObject sheetId:[self.bookedTimeOffObject sheetId] screenMode:screenMode];
        timeOffDetailsViewCtrl.sheetIdString = [self.bookedTimeOffObject sheetId];
        timeOffDetailsViewCtrl.navigationFlow = TIMEOFF_BOOKING_NAVIGATION;
        [timeOffDetailsViewCtrl TimeOffDetailsReceived];
        [self.navigationController pushViewController:timeOffDetailsViewCtrl animated:YES];
    }
}

-(void)addSummaryView
{
    [self.timeOffBookingViewCtrl.view removeFromSuperview];
    self.timeOffBookingViewCtrl=nil;

    TimeOffBookingsViewController *timeOffBookViewController = [[TimeOffBookingsViewController alloc] init];
    timeOffBookViewController.contentOffSet = self.currentContentOffset;
    self.timeOffBookingViewCtrl=timeOffBookViewController;
    self.timeOffBookingViewCtrl.delegate=self;

    CGRect frame=self.timeOffBookingViewCtrl.view.frame;
    frame.origin.y=50.0;
    self.timeOffBookingViewCtrl.view.frame=frame;
    
    [self.timeOffBalanceViewCtrl.view removeFromSuperview];
    [self.timeOffHolidayViewCtrl.view removeFromSuperview];

    [self.view addSubview:self.timeOffBookingViewCtrl.view];

    self.setViewTag=booking_Tag;

}

-(void)addBalanceView;
{
    [self.timeOffBalanceViewCtrl.view removeFromSuperview];
    self.timeOffBalanceViewCtrl=nil;

    TimeOffBalanceViewController *bookedTimeOffBalanceViewCtrl = [[TimeOffBalanceViewController alloc] init];
    self.timeOffBalanceViewCtrl=bookedTimeOffBalanceViewCtrl;
    

    CGRect frame=self.timeOffBalanceViewCtrl.view.frame;
    frame.origin.y=50.0;
    self.timeOffBalanceViewCtrl.view.frame=frame;

    [self.timeOffBookingViewCtrl.view removeFromSuperview];
    [self.timeOffHolidayViewCtrl.view removeFromSuperview];
    [self.view addSubview:self.timeOffBalanceViewCtrl.view];

    self.setViewTag=balances_Tag;
}

-(void)addHolidayView
{

    [self.timeOffHolidayViewCtrl.view removeFromSuperview];
    self.timeOffHolidayViewCtrl=nil;

    TimeOffHolidayViewController *tempcompanyHolidayViewCtrl=[[TimeOffHolidayViewController alloc]init];
    self.timeOffHolidayViewCtrl=tempcompanyHolidayViewCtrl;


    CGRect frame=self.timeOffHolidayViewCtrl.view.frame;
    frame.origin.y=50.0;

    UIView *view = self.timeOffHolidayViewCtrl.view;
    self.timeOffHolidayViewCtrl.view.frame=frame;
    [self.timeOffBookingViewCtrl.view removeFromSuperview];
    [self.timeOffBalanceViewCtrl.view removeFromSuperview];
    
    [self.view addSubview:view];
    
    self.setViewTag=holiday_Tag;
    
    
}

- (CGFloat)heightForTableView
{
    static CGFloat paddingForLastCellBottomSeparatorFudgeFactor = 50;
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame)) +
    paddingForLastCellBottomSeparatorFudgeFactor;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
    self.leftButton=nil;
    self.timeOffBookingViewCtrl=nil;
    self.timeOffBalanceViewCtrl=nil;
    self.timeOffHolidayViewCtrl=nil;
    
}

#pragma Mark - AppShortcuts

- (void)launchBookTimeOff{
    self.isFromDeepLink = YES;
    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    NSMutableArray *timeOffTypesArray=[timeoffModel getAllTimeOffTypesFromDB];
    if ([timeOffTypesArray count] > 0){
        [self addBookTimeOffEntryAction];
        self.isFromDeepLink = NO;
    }
}

- (void)checkForDeeplinkAndNavigate{
    if(self.isFromDeepLink){
        self.isFromDeepLink = NO;
        [self addBookTimeOffEntryAction];
    }
}


@end
