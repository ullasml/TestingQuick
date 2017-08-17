//
//  ShiftsViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 20/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ShiftsViewController.h"
#import "Constants.h"
#import "SupportDataModel.h"
#import "ShiftsModel.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "RepliconServiceManager.h"
#import "ShiftsService.h"
#import "ShiftsSummaryViewController.h"
#import "ShiftsModel.h"
#import "FrameworkImport.h"
#import "Util.h"
#import "ShiftPickerViewController.h"
#import "ShiftDetailViewController.h"
#import <Blindside/BSInjector.h>


#define ROW_HEIGHT          44
#define SECTION_HEIGHT      26
#define SUNDAY_URI          @"urn:replicon:day-of-week:sunday"
#define MONDAY_URI          @"urn:replicon:day-of-week:monday"
#define TUESDAY_URI         @"urn:replicon:day-of-week:tuesday"
#define WEDNESDAY_URI       @"urn:replicon:day-of-week:wednesday"
#define THURSDAY_URI        @"urn:replicon:day-of-week:thursday"
#define FRIDAY_URI          @"urn:replicon:day-of-week:friday"
#define SATURDAY_URI        @"urn:replicon:day-of-week:saturday"


#define OFFLINE_MODE_TITLE @"Offline Mode"

@interface ShiftsViewController ()
@property (nonatomic) id<Theme> theme;
@property(nonatomic,assign)BOOL isFromDeepLink;
@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation ShiftsViewController
@synthesize isCalledFromMenu;
@synthesize shiftsListTableView;
@synthesize shiftsListArray;
@synthesize supportDataModel;
@synthesize obj_ShiftsModel;

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
    // Do any additional setup after loading the view.
    UIBarButtonItem *punchHistoryBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"calendarSchedule"]
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(pickerButtonClicked:)];
    [self.navigationItem setRightBarButtonItem:punchHistoryBtn animated:NO];

}

-(void)loadView
{

    [Util setToolbarLabel:self withText: RPLocalizedString(SHIFT_ENTRY, @"") ];
    [super loadView];
    [self.view setBackgroundColor:RepliconStandardWhiteColor];



    float height = 64.0f;
    self.shiftsListTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0 ,SCREEN_WIDTH,SCREEN_HEIGHT- height) style:UITableViewStylePlain];
    self.shiftsListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.shiftsListTableView.delegate = self;
    self.shiftsListTableView.dataSource = self;
    if ([self.shiftsListTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.shiftsListTableView.separatorInset = UIEdgeInsetsZero;
    }
    if ([self.shiftsListTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.shiftsListTableView.layoutMargins = UIEdgeInsetsZero;
    }



    self.shiftsListArray = [[NSMutableArray alloc] init];

    self.supportDataModel = [[SupportDataModel alloc] init];
    self.obj_ShiftsModel = [[ShiftsModel alloc] init];


    refreshCount = 0;
    UIView *bckView = [UIView new];
    [bckView setBackgroundColor:RepliconStandardBackgroundColor];
    [ self.shiftsListTableView setBackgroundView:bckView];


    [self createShiftsListTable];
    [self configureTableForPullToRefresh];
}


#pragma mark -
#pragma mark - Other Method


-(void)createShiftsListTable
{

    NSMutableArray *userDetailsArr=[self.supportDataModel getUserDetailsFromDatabase];

    NSString *dayUri= nil;

    if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
    {
        NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
        dayUri = [userDetailsDict objectForKey:@"workWeekStartDayUri"];
    }
    [[NSUserDefaults standardUserDefaults] setValue:dayUri forKey:@"workWeekStartDayUri"];
    self.shiftsListArray = [self createWeekList];


    for (UIView *view in self.view.subviews)
    {
        [view removeFromSuperview];
    }
    [self.view addSubview:shiftsListTableView];
    [self.shiftsListTableView reloadData];
}


-(NSString*)generateUDIDForDatabade
{
    NSString *IDString = [Util getRandomGUID];


    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"] invertedSet];
    IDString = [[IDString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    return IDString;
}

-(void)configureTableForPullToRefresh
{
    ShiftsViewController *weakSelf = self;

    // setup infinite scrolling
    [self.shiftsListTableView addInfiniteScrollingWithActionHandler:^{

        [weakSelf.view setUserInteractionEnabled:YES];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {

                           [weakSelf.shiftsListTableView.infiniteScrollingView startAnimating];
                           [weakSelf moreAction];


                       });
    }];

}


-(void)moreAction
{
    if ([self.shiftsListArray count] > 0) {
        [self.shiftsListArray removeAllObjects];
    }
    self.shiftsListArray = [self createWeekList];
    [self.view setUserInteractionEnabled:YES];
    ShiftsViewController *weakSelf = self;
    [weakSelf.shiftsListTableView.infiniteScrollingView stopAnimating];
    [self.shiftsListTableView reloadData];
}





-(NSMutableArray*)createWeekList
{
    refreshCount = refreshCount+1;
    NSMutableArray  *tempArray = [NSMutableArray array];

    NSArray *uriArray = [NSArray arrayWithObjects:
                         @"urn:replicon:day-of-week:sunday",
                         @"urn:replicon:day-of-week:monday",
                         @"urn:replicon:day-of-week:tuesday",
                         @"urn:replicon:day-of-week:wednesday",
                         @"urn:replicon:day-of-week:thursday",
                         @"urn:replicon:day-of-week:friday",
                         @"urn:replicon:day-of-week:saturday",
                         nil];

    NSCalendar *gregorian1 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian1 components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];


    NSMutableArray *userDetailsArr=[self.supportDataModel getUserDetailsFromDatabase];

    NSString *dayUri= nil;

    if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
    {
        NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
        dayUri = [userDetailsDict objectForKey:@"workWeekStartDayUri"];
    }


    // start by retrieving day, weekday, month and year components for yourDate
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *todayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
    NSInteger theDay = [todayComponents day];
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    NSDateFormatter *startDateFormat = [[NSDateFormatter alloc] init];
    [startDateFormat setDateFormat:@"MMM dd"];
    NSDateFormatter *endDateFormat = [[NSDateFormatter alloc] init];
    [endDateFormat setDateFormat:@"MMM dd, yyyy"];

    // now build a NSDate object for yourDate using these components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];

    // now build a NSDate object for the next day
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];



    NSUInteger dayIndex = 0;
    NSUInteger dayDifference = 0;

    dayIndex = [uriArray indexOfObject:dayUri] +1;
    dayDifference = dayIndex - weekday;


    if ([[self.obj_ShiftsModel getShiftByDateFromDB] count] > 0) {
        [self.obj_ShiftsModel deleteAllShiftsFromDB];
        [self.obj_ShiftsModel deleteAllShiftEntryDetailsFromDB];
        [self.obj_ShiftsModel deleteAllShiftsDetailsFromDB];
    }

    for (int i=0; i<10*refreshCount; i++) {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
        [offsetComponents setDay:dayDifference+(7*i)];
        NSDate *startDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
        [offsetComponents setDay:dayDifference+6+(7*i)];
        NSDate *lastDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        NSString *startDateString = [dateFormat stringFromDate:startDate];
        NSString *lastDateString = [dateFormat stringFromDate:lastDate];
        [tempDict setValue:startDateString forKey:@"startDate"];
        [tempDict setValue:lastDateString forKey:@"endDate"];
        [tempDict setValue:[self generateUDIDForDatabade] forKey:@"id"];
        [tempDict setValue:[NSString stringWithFormat:@"%@ - %@",[startDateFormat stringFromDate:startDate], [endDateFormat stringFromDate:lastDate]] forKey:@"dateString"];
        [obj_ShiftsModel saveShiftDataToDB:tempDict];
        [tempArray addObject:tempDict];
    }
    return tempArray;
}


- (IBAction)pickerButtonClicked:(id)sender {
    NSMutableArray *userDetailsArr=[self.supportDataModel getUserDetailsFromDatabase];
    
    
    ShiftPickerViewController *obj_ShiftPickerViewController = [self.injector getInstance:[ShiftPickerViewController class]];
    if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
    {
        NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
        obj_ShiftPickerViewController.dayUriString = [userDetailsDict objectForKey:@"workWeekStartDayUri"];
    }
    
    
    [self.navigationController pushViewController:obj_ShiftPickerViewController animated:YES];
    
}


#pragma mark -
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    else{
        return [self.shiftsListArray count] -1 ;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, SECTION_HEIGHT)];
    sectionView.backgroundColor=TimesheetTotalHoursBackgroundColor;

    UILabel *titleLbl=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.bounds.size.width, 22)];
    [titleLbl setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_14]];
    [titleLbl setTextColor:[Util colorWithHex:@"#333333" alpha:1]];

    [sectionView addSubview:titleLbl];

    if(section == 0)
    {
        titleLbl.text =RPLocalizedString(@"Current", @"Current") ;
    }
    else{
        titleLbl.text =RPLocalizedString(@"Future", @"Future") ;
    }

    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0,SECTION_HEIGHT-1, CGRectGetWidth(tableView.bounds), 1)];
    separatorView.backgroundColor = [Util colorWithHex:@"#CCCCCC" alpha:1.0f];
    [sectionView addSubview:separatorView];

    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier;
    CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSInteger rowIndex = indexPath.row;
    if (indexPath.section == 1) {
        rowIndex = rowIndex +1;
    }



    NSDictionary *tempDict = [self.shiftsListArray objectAtIndex:rowIndex];
    cell.textLabel.text = [tempDict objectForKey:@"dateString"];
    cell.textLabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }

    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0,ROW_HEIGHT-1, CGRectGetWidth(tableView.bounds), 1)];
    separatorView.backgroundColor = [Util colorWithHex:@"#CCCCCC" alpha:1.0f];
    [cell.contentView addSubview:separatorView];

    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //US8906//JUHI
    ShiftsSummaryViewController *shiftSummaryViewCtrl= [self.injector getInstance:[ShiftsSummaryViewController class]];
    NSInteger rowIndex = indexPath.row;
    if (indexPath.section == 1) {
        rowIndex = rowIndex +1;
    }
    NSMutableDictionary *tempDict = [self.shiftsListArray objectAtIndex:rowIndex];

    NSMutableArray *array=[Util getArrayOfDatesForWeekWithStartDate:[tempDict objectForKey:@"startDate"] andEndDate:[tempDict objectForKey:@"endDate"]];


    [[NSUserDefaults standardUserDefaults] setValue:[tempDict objectForKey:@"id"] forKey:@"id"];
    shiftSummaryViewCtrl.shiftDuration=[tempDict objectForKey:@"dateString"];
    shiftSummaryViewCtrl.shiftSummaryIdentity=[tempDict objectForKey:@"id"];
    if (!array)
    {
        array=[NSMutableArray array];
    }
    shiftSummaryViewCtrl.allEntriesArray=array;
    [[NSNotificationCenter defaultCenter] removeObserver:shiftSummaryViewCtrl name:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:shiftSummaryViewCtrl selector:@selector(createShiftSummary:) name:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];


    [[NSNotificationCenter defaultCenter] removeObserver:shiftSummaryViewCtrl name:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:shiftSummaryViewCtrl selector:@selector(checkTimeOffAndRequestForTimeOffs:) name:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil];



    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }

    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    [[RepliconServiceManager shiftsService] sendRequestShiftToServiceForDataDict:tempDict];


    [self.navigationController pushViewController:shiftSummaryViewCtrl animated:YES];
    [shiftsListTableView deselectRowAtIndexPath:indexPath animated:NO];


}

- (void)selectShiftAtIndex:(NSIndexPath *)indexPath{
    if(self.isFromDeepLink){
        self.isFromDeepLink = NO;
        [self.shiftsListTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self tableView:self.shiftsListTableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)launchCurrentShift{
    self.isFromDeepLink = YES;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if([self.shiftsListTableView cellForRowAtIndexPath:indexPath]){
        [self selectShiftAtIndex:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isFromDeepLink && indexPath.section == 0 && indexPath.row == 0){
        [self selectShiftAtIndex:indexPath];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isFromDeepLink = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.shiftsListTableView.delegate = nil;
    self.shiftsListTableView.dataSource = nil;
}

@end
