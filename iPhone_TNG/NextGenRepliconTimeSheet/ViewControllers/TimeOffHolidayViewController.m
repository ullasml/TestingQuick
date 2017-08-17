//
//  TimeOffHolidayViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/29/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffHolidayViewController.h"
#import "Constants.h"
#import "Util.h"
#import "TimeoffModel.h"
#import "FrameworkImport.h"
#import "RepliconServiceManager.h"
#import "TimeOffHolidayView.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "ErrorBannerViewController.h"
#import "InjectorKeys.h"
#import "AppDelegate.h"
#import "ErrorBannerViewParentPresenterHelper.h"


@interface TimeOffHolidayViewController () <TimeOffHolidayViewDelegate>
@property (nonatomic,strong) NSMutableDictionary *companyHolidayList;
@property (nonatomic,strong) NSMutableArray *keyNamesArray;
@property (nonatomic,strong) TimeOffHolidayView *timeoffholidayView;
@end

@implementation TimeOffHolidayViewController

-(void)loadView
{
    [super loadView];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper = [appDelegate.injector getInstance:[ErrorBannerViewParentPresenterHelper class]];

    self.companyHolidayList = [[NSMutableDictionary alloc] init];
    self.timeoffholidayView = [[TimeOffHolidayView alloc] initWithFrame:[[UIScreen mainScreen] bounds] errorBannerViewParentPresenterHelper:errorBannerViewParentPresenterHelper];
    [self.timeoffholidayView setTimeOffHolidayDelegate:self];
    self.view = self.timeoffholidayView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSString *holidayCalendarUri=[defaults objectForKey:@"holidayCalendarURI"];
    
    if (holidayCalendarUri==nil || [holidayCalendarUri isKindOfClass:[NSNull class]])
    {
        [Util errorAlert:@"" errorMessage:RPLocalizedString(HOLIDAY_CALENDAR_NOT_SET_ERROR_MSG, HOLIDAY_CALENDAR_NOT_SET_ERROR_MSG)];
        return;
    }
    
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    TimeoffModel *timeoffModel = [[TimeoffModel alloc]init];
    
    NSMutableDictionary *tempCompanyHolidayList=[timeoffModel getCompanyHolidayInfoDict];
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [NSDate date];
    NSDateComponents *todaydateComponents = [calendar components:unitFlags fromDate:date];
    NSInteger year = [todaydateComponents year];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createCompanyHolidayList)
                                                 name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION
                                               object:nil];
    if (![[tempCompanyHolidayList objectForKey:[NSString stringWithFormat:@"%d",(int)year]] isKindOfClass:[NSNull class]]&&[tempCompanyHolidayList objectForKey:[NSString stringWithFormat:@"%d",(int)year]]!=nil &&![[tempCompanyHolidayList objectForKey:[NSString stringWithFormat:@"%d",(int)year-1]] isKindOfClass:[NSNull class]]&&[tempCompanyHolidayList objectForKey:[NSString stringWithFormat:@"%d",(int)year-1]]!=nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
    }
    else{
        
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[RepliconServiceManager timeoffService]fetchTimeoffCompanyHolidaysData:nil];
    }

}

-(void)createCompanyHolidayList{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
    //Implemented PullToRefresh Functionality
    if ([self.companyHolidayList count] > 0) {
        [self.companyHolidayList removeAllObjects];
    }
    
    TimeoffModel *timeoffModel = [[TimeoffModel alloc]init];
    self.companyHolidayList=[timeoffModel getCompanyHolidayInfoDict];

    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [NSDate date];
    NSDateComponents *todaydateComponents = [calendar components:unitFlags fromDate:date];
    NSInteger year = [todaydateComponents year];

    int scrollSectionIndex=0;
    if ([self.keyNamesArray containsObject:[NSString stringWithFormat:@"%d",(int)year-1]])
    {
        scrollSectionIndex=1;
    }
    [self.timeoffholidayView setUpCompanyHolidays:self.companyHolidayList];
    [self.timeoffholidayView refreshTableViewWithContentOffsetReset];
}

- (void)listOfTimeOffHolidayView:(TimeOffHolidayView *)listOfTimeOffHolidayView refreshAction:(id)sender
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [listOfTimeOffHolidayView stopAnimatingIndicator];
        [Util showOfflineAlert];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreshCompanyHolidayView)
                                                 name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager timeoffService]fetchTimeoffCompanyHolidaysData:nil];
}
/************************************************************************************************************
 @Function Name   : refreshViewFromRefreshedData
 @Purpose         : To reload tableview everytime when pull to refresh action is made
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)pullToRefreshCompanyHolidayView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
    if ([self.companyHolidayList count] > 0) {
        [self.companyHolidayList removeAllObjects];
    }
    
    TimeoffModel *timeoffModel = [[TimeoffModel alloc]init];
    self.companyHolidayList=[timeoffModel getCompanyHolidayInfoDict];
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [NSDate date];
    NSDateComponents *todaydateComponents = [calendar components:unitFlags fromDate:date];
    NSInteger year = [todaydateComponents year];
    
    int scrollSectionIndex=0;
    if ([self.keyNamesArray containsObject:[NSString stringWithFormat:@"%d",(int)year-1]])
    {
        scrollSectionIndex=1;
    }
    [self.timeoffholidayView setUpCompanyHolidays:self.companyHolidayList];
    [self.timeoffholidayView refreshTableViewAfterPulltoRefresh];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
