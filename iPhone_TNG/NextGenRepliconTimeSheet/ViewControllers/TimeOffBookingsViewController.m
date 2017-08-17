//
//  TimeOffBookingsViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/28/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffBookingsViewController.h"
#import "TimeOffView.h"
#import "TimeoffModel.h"
#import "TimeOffObject.h"
#import "RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "AppProperties.h"
#import "TimeOffDetailsViewController.h"
#import "AppDelegate.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "ErrorBannerViewController.h"
#import "InjectorKeys.h"
#import "ErrorBannerViewParentPresenterHelper.h"



@interface TimeOffBookingsViewController () <TimeOffBookingsViewDelegate>
@property(nonatomic,strong) TimeOffView *timeOffView;
@end

@implementation TimeOffBookingsViewController

-(void)loadView
{
    [super loadView];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper = [appDelegate.injector getInstance:[ErrorBannerViewParentPresenterHelper class]];

    self.timeOffView = [[TimeOffView alloc] initWithFrame:[[UIScreen mainScreen] bounds] errorBannerViewParentPresenterHelper:errorBannerViewParentPresenterHelper];
    [self.timeOffView setTimeOffBookingViewDelegate:self];
    self.timeOffView.currentContentOffset = self.contentOffSet;
    self.view = self.timeOffView;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
        //self.navigationController.navigationBar.translucent = NO;
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
        
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Perform long running process
        NSMutableArray *timeOffModelObjectsArray=[self createAllTimeOffModelObjectsDataArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self.timeOffView setUpTimeOffObjectsArray:timeOffModelObjectsArray];
            [self.timeOffView refreshTableViewWithContentOffsetReset:!self.isCalledFromMenu];
        });
    });
    
    TimeoffModel *timeOffModel=[[TimeoffModel alloc]init];
     NSMutableArray *dbtimeOffArray=[timeOffModel getAllTimeoffsFromDB];
    if ([dbtimeOffArray count]<=0)
    {
        if([NetworkMonitor isNetworkAvailableForListener: self])
        {
            [self fetchTimeoff];
        }


    }
    
    
    self.isCalledFromMenu = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma TimeOff Array

/************************************************************************************************************
 @Function Name   : createAll_TimeOff_ModelObjects_DataArray
 @Purpose         : To create TimeOff objects from the list of timeoff array from DB and store in an array and let the
 controller pass it on to the view thereby adhering to MVC
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(NSMutableArray *)createAllTimeOffModelObjectsDataArray
{
    NSMutableArray *timeOffArray=[[NSMutableArray alloc]init];
    TimeoffModel *timeOffModel=[[TimeoffModel alloc]init];
    NSMutableArray *dbtimeOffArray=[timeOffModel getAllTimeoffsFromDB];
    
    for (NSDictionary *timeOffDict in dbtimeOffArray)
    {
        TimeOffObject *timeOffObj   = [[TimeOffObject alloc] initWithDataDictionary:timeOffDict];
        [timeOffArray addObject:timeOffObj];
    }
    return timeOffArray;
    
   
}


-(void)fetchTimeoff {
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    [[RepliconServiceManager timeoffService] fetchTimeoffData:nil isPullToRefresh:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                selector: @selector(handleAllTimeoffRequestsServed)
                                    name: AllTimeoffRequestsServed
                                  object: nil];
}

-(void)handleAllTimeoffRequestsServed {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AllTimeoffRequestsServed object:nil];
   [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Perform long running process
        NSMutableArray *timeOffModelObjectsArray=[self createAllTimeOffModelObjectsDataArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self.timeOffView setUpTimeOffObjectsArray:timeOffModelObjectsArray];
            [self.timeOffView refreshTableViewWithContentOffsetReset:!self.isCalledFromMenu];
            if ([self.delegate respondsToSelector:@selector(checkForDeeplinkAndNavigate)])
            {
                [self.delegate checkForDeeplinkAndNavigate];
            }
        });
    });
}


#pragma mark Pull To Refresh/ More action
/************************************************************************************************************
 @Function Name   : refreshAction_From_TimeOffBooking
 @Purpose         : To fetch modified records of timeoff
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)listOfTimeOffBookView:(TimeOffView *)listOfTimeOffBookingsView refreshAction:(id)sender
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [listOfTimeOffBookingsView stopAnimatingIndicator];
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Check for update action triggered on TimeOffBookingViewController-----");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullToRefreshTimeOffBookingDataRecieved:)
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
- (void)listOfTimeOffBookView:(TimeOffView *)listOfTimeOffBookingsView moreAction:(id)sender
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [listOfTimeOffBookingsView stopAnimatingIndicator];
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----More action triggered on TimeOffBookingViewController-----");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
    [[RepliconServiceManager timeoffService]fetchNextRecentTimeoffData:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreTimeOffActionDataRecieved:)
                                                 name:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION
                                               object:nil];

}

/************************************************************************************************************
 @Function Name   : pullToRefresh_DataRecieved_callback_from_service
 @Purpose         : To let controller handle removal of observers and let TimeOffView handle UI
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)pullToRefreshTimeOffBookingDataRecieved:(NSNotification *)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
    id isDeltaUpdateKey=[[notificationObject userInfo] valueForKey:@"isDeltaUpdate"];
    if (isDeltaUpdateKey!=nil && ![isDeltaUpdateKey isKindOfClass:[NSNull class]])
    {
        BOOL isDeltaValue = [[[notificationObject userInfo] valueForKey:@"isDeltaUpdate"] boolValue];
        [self.timeOffView setIsDataUpdate:isDeltaValue];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Perform long running process
        NSMutableArray *timeOffModelObjectsArray=[self createAllTimeOffModelObjectsDataArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self.timeOffView setUpTimeOffObjectsArray:timeOffModelObjectsArray];
            [self.timeOffView refreshTableViewAfterPulltoRefresh];

        });
    });
}

/************************************************************************************************************
 @Function Name   :TimeOff moreActionDataRecieved_callback_from_service
 @Purpose         : To let controller handle removal of observers and let TimeOffView handle UI
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)moreTimeOffActionDataRecieved:(NSNotification *)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
    BOOL isErrorOccuredOnMoreAction = [[[notificationObject userInfo] objectForKey:@"isErrorOccured"] boolValue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Perform long running process
        NSMutableArray *timeOffModelObjectsArray=[self createAllTimeOffModelObjectsDataArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self.timeOffView setUpTimeOffObjectsArray:timeOffModelObjectsArray];
            [self.timeOffView refreshTableViewAfterMoreAction:isErrorOccuredOnMoreAction];

        });
    });

}
/************************************************************************************************************
 @Function Name   : DidSelect call from TimeOff View
 @Purpose         : To let controller handle didselect in TimeOffController
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)listofTimeOFfBookView:(TimeOffView *)listOfTimeOffBookingsView selectedIndexPath:(NSIndexPath *)indexPath withTimeOffObject:(TimeOffDetailsObject *)timeOffObj withContentOffset:(CGPoint)tableOffset
{
    if ([self.delegate respondsToSelector:@selector(didSelectRowAtSummaryFromTimeOffBooking::withContentOffset:)])
    {
        [self.delegate didSelectRowAtSummaryFromTimeOffBooking:indexPath :timeOffObj withContentOffset:tableOffset];
    }
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
