//
//  TimeOffBalanceViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/29/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffBalanceViewController.h"
#import "TimeOffBalanceView.h"
#import "TimeoffModel.h"
#import "FrameworkImport.h"
#import "RepliconServiceManager.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "ErrorBannerViewController.h"
#import "InjectorKeys.h"
#import "AppDelegate.h"
#import "ErrorBannerViewParentPresenterHelper.h"


@interface TimeOffBalanceViewController () <TimeOffBalancesViewDelegate>
{
    TimeoffModel *timeOffModel;
}
@property(nonatomic,strong) TimeOffBalanceView *timeOffBalanceView;
@end

@implementation TimeOffBalanceViewController

-(void)loadView
{
    [super loadView];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper = [appDelegate.injector getInstance:[ErrorBannerViewParentPresenterHelper class]];
    
    self.timeOffBalanceView = [[TimeOffBalanceView alloc] initWithFrame:[[UIScreen mainScreen] bounds] errorBannerViewParentPresenterHelper:errorBannerViewParentPresenterHelper];
    [self.timeOffBalanceView setTimeOffBalanceViewDelegate:self];
    self.view = self.timeOffBalanceView;
    
    timeOffModel =[[TimeoffModel alloc]init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSMutableArray *sectionsArr = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Perform long running process
        NSMutableArray *balanceAvailableArr=[self gettimeOffBalanceAvailableArray];
        NSMutableArray *balanceUsedArr=[self gettimeOffBalanceUsedArray];
        NSMutableArray *balanceTrackedArr=[self gettimeOffBalanceTrackedArray];
        
        if ([balanceAvailableArr count]>0)
        {
            [sectionsArr addObject:RPLocalizedString(BOOKED_TIMEOFF_AVAILABLE, BOOKED_TIMEOFF_AVAILABLE)];
        }
        if ([balanceUsedArr count]>0)
        {
            [sectionsArr addObject:RPLocalizedString(BOOKED_TIMEOFF_USED, BOOKED_TIMEOFF_USED)];
        }
        if ([balanceTrackedArr count]>0)
        {
            [sectionsArr addObject:RPLocalizedString(BOOKED_TIMEOFF_UNTRACKED, BOOKED_TIMEOFF_UNTRACKED)];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self.timeOffBalanceView setUpTimeOffBalceArray:balanceAvailableArr :balanceUsedArr :balanceTrackedArr :sectionsArr];
            [self.timeOffBalanceView refreshTableViewAfterPulltoRefresh];
        });
    });
    
}

#pragma TimeOff Balance Array

/************************************************************************************************************
 @Function Name   : createAll_TimeOff_ModelObjects_DataArray
 @Purpose         : To create TimeOff objects from the list of timeoff array from DB and store in an array and let the
 controller pass it on to the view thereby adhering to MVC
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(NSMutableArray *)gettimeOffBalanceAvailableArray
{
    NSMutableArray *balanceAvailableArr=[[timeOffModel getAllTypeBalanceSummaryFromDB] objectForKey:TIME_OFF_AVAILABLE_KEY];
    return balanceAvailableArr;
}
-(NSMutableArray *)gettimeOffBalanceUsedArray
{
    NSMutableArray *balanceUsedArr=[[timeOffModel getAllTypeBalanceSummaryFromDB] objectForKey:TIME_OFF_USED_KEY];
    return balanceUsedArr;
}
-(NSMutableArray *)gettimeOffBalanceTrackedArray
{
    NSMutableArray *balanceTrackedArr=[[timeOffModel getAllTypeBalanceSummaryFromDB] objectForKey:TIME_OFF_UNTRACKED_KEY];
    return balanceTrackedArr;
}


#pragma mark Pull To Refresh/ More action
/************************************************************************************************************
 @Function Name   : refreshAction_From_TimeOffBooking
 @Purpose         : To fetch modified records of timeoff
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)listOfTimeOffBalanceView:(TimeOffBalanceView *)listOfTimeOffBalanceView refreshAction:(id)sender
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [listOfTimeOffBalanceView stopAnimatingIndicator];
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Check for update action triggered on TimeOffBookingViewController-----");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreshTimeOffBalanceDataRecieved:)
                                                 name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager timeoffService]fetchTimeoffData:nil isPullToRefresh:YES];
}
/************************************************************************************************************
 @Function Name   : refreshAction_From_TimeOffBooking
 @Purpose         : To fetch more records of timeoff
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)listOfTimeOffBalanceView:(TimeOffBalanceView *)listOfTimeOffBalanceView moreAction:(id)sender
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [listOfTimeOffBalanceView stopAnimatingIndicator];
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----More action triggered on TimeOffBookingViewController-----");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
    [[RepliconServiceManager timeoffService]fetchNextRecentTimeoffData:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreActionDataRecieved:)
                                                 name:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION
                                               object:nil];
    
}

/************************************************************************************************************
 @Function Name   : pullToRefresh_DataRecieved_callback_from_service
 @Purpose         : To let controller handle removal of observers and let TimeOffView handle UI
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)pullToRefreshTimeOffBalanceDataRecieved:(NSNotification *)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
//    id isDeltaUpdateKey=[[notificationObject userInfo] valueForKey:@"isDeltaUpdate"];
//    if (isDeltaUpdateKey!=nil && ![isDeltaUpdateKey isKindOfClass:[NSNull class]])
//    {
//        BOOL isDeltaValue = [[[notificationObject userInfo] valueForKey:@"isDeltaUpdate"] boolValue];
//        [self.timeOffView setIsDataUpdate:isDeltaValue];
//    }
    
    NSMutableArray *sectionsArr = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Perform long running process
        NSMutableArray *balanceAvailableArr=[self gettimeOffBalanceAvailableArray];
        NSMutableArray *balanceUsedArr=[self gettimeOffBalanceUsedArray];
        NSMutableArray *balanceTrackedArr=[self gettimeOffBalanceTrackedArray];
        
        if ([balanceAvailableArr count]>0)
        {
            [sectionsArr addObject:RPLocalizedString(BOOKED_TIMEOFF_AVAILABLE, BOOKED_TIMEOFF_AVAILABLE)];
        }
        if ([balanceUsedArr count]>0)
        {
            [sectionsArr addObject:RPLocalizedString(BOOKED_TIMEOFF_USED, BOOKED_TIMEOFF_USED)];
        }
        if ([balanceTrackedArr count]>0)
        {
            [sectionsArr addObject:RPLocalizedString(BOOKED_TIMEOFF_UNTRACKED, BOOKED_TIMEOFF_UNTRACKED)];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self.timeOffBalanceView setUpTimeOffBalceArray:balanceAvailableArr :balanceUsedArr :balanceTrackedArr :sectionsArr];
            [self.timeOffBalanceView refreshTableViewAfterPulltoRefresh];
        });
    });
}

/************************************************************************************************************
 @Function Name   : moreActionDataRecieved_callback_from_service
 @Purpose         : To let controller handle removal of observers and let TimeOffView handle UI
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)moreActionDataRecieved:(NSNotification *)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
//    BOOL isErrorOccuredOnMoreAction = [[[notificationObject userInfo] objectForKey:@"isErrorOccured"] boolValue];
    NSMutableArray *sectionsArr = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Perform long running process
        NSMutableArray *balanceAvailableArr=[self gettimeOffBalanceAvailableArray];
        NSMutableArray *balanceUsedArr=[self gettimeOffBalanceUsedArray];
        NSMutableArray *balanceTrackedArr=[self gettimeOffBalanceTrackedArray];
        
        if ([balanceAvailableArr count]>0)
        {
            [sectionsArr addObject:RPLocalizedString(BOOKED_TIMEOFF_AVAILABLE, BOOKED_TIMEOFF_AVAILABLE)];
        }
        if ([balanceUsedArr count]>0)
        {
            [sectionsArr addObject:RPLocalizedString(BOOKED_TIMEOFF_USED, BOOKED_TIMEOFF_USED)];
        }
        if ([balanceTrackedArr count]>0)
        {
            [sectionsArr addObject:RPLocalizedString(BOOKED_TIMEOFF_UNTRACKED, BOOKED_TIMEOFF_UNTRACKED)];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self.timeOffBalanceView setUpTimeOffBalceArray:balanceAvailableArr :balanceUsedArr :balanceTrackedArr :sectionsArr];
            [self.timeOffBalanceView refreshTableViewAfterPulltoRefresh];
        });
    });
    
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
