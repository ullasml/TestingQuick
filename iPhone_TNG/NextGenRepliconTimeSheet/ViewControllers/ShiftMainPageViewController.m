//
//  ShiftMainPageViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 27/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ShiftMainPageViewController.h"
#import "TimesheetObject.h"
#import "ShiftDetailViewController.h"
#import "ShiftsModel.h"
#import "AppDelegate.h"
#import "ShiftsSummaryViewController.h"
#import "ShiftPickerViewController.h"
#import "RepliconServiceManager.h"
#import <Blindside/BSInjector.h>

@interface ShiftMainPageViewController ()

@property (nonatomic, weak) id<BSInjector> injector;

@end

@implementation ShiftMainPageViewController
@synthesize shiftWeekDatesArray;
@synthesize viewControllers;
@synthesize scrollView;
@synthesize pageControl;
@synthesize currentlySelectedPage;
@synthesize daySelectionScrollView;
@synthesize daySelectionScrollViewDelegate;
@synthesize dateDict;
@synthesize delegate;

#define Page_Control_View_Height 50
- (void)viewDidLoad
{
    [super viewDidLoad];
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    
    [Util setToolbarLabel:self withText:RPLocalizedString(SHIFT_DETAILS, @"")];

    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [shiftWeekDatesArray count]; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    
    UIScrollView *tmpScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,[self.view bounds].size.width,[self.view bounds].size.height+49)];
    self.scrollView=tmpScrollView;
    
	
    [scrollView setPagingEnabled:YES];
    [scrollView setContentSize:CGSizeMake([self.shiftWeekDatesArray count]*self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setScrollEnabled:NO];
    [scrollView setDelegate:self];
    [scrollView setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
    [self.view addSubview:scrollView];
    
    
    UIPageControl *tmpPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width, Page_Control_View_Height)];
    self.pageControl=tmpPageControl;
    
    self.pageControl.currentPage = currentlySelectedPage;
	self.pageControl.numberOfPages = self.shiftWeekDatesArray.count;
    self.pageControl.hidesForSinglePage=YES;
    [pageControl setBackgroundColor:[Util colorWithHex:@"#333333" alpha:1.0]];
    [self.view addSubview:pageControl];
    [self.pageControl setHidden:YES];
    
    [self updateWeekDayData];
}


-(void)goToFirstPage
{
    if ([delegate isKindOfClass:[ShiftsSummaryViewController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([delegate isKindOfClass:[ShiftPickerViewController class]])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)timesheetDayBtnClickedWithTag:(NSInteger)page
{
    
    self.currentlySelectedPage=page;
    [self loadScrollViewWithPage:page fromDayButtonClick:YES];
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = Page_Control_View_Height;
    [self.scrollView scrollRectToVisible:bounds animated:NO];
    
}

-(void)timesheetDayBtnHighLightOnCrossOver:(NSInteger)page
{
    
}

- (void)loadScrollViewWithPage:(NSUInteger)page fromDayButtonClick:(BOOL)fromDayButtonClick
{
    if (page >= self.shiftWeekDatesArray.count)
        return;
    
    // replace the placeholder if necessary
    ShiftDetailViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [self.injector getInstance:[ShiftDetailViewController class]];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];

    }
    NSDate *formattedDate=[self.shiftWeekDatesArray objectAtIndex:page];
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    myDateFormatter.dateFormat = @"EEEE, dd MMM, yyyy";
    
    NSLocale *locale=[NSLocale currentLocale];
    [myDateFormatter setLocale:locale];
    controller.headerDateString=[myDateFormatter stringFromDate:formattedDate];
    
    
     NSTimeInterval  dateStamp = [[myDateFormatter dateFromString:[myDateFormatter stringFromDate:formattedDate]] timeIntervalSince1970];
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [controller getDataFromDB:(double)dateStamp];
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
    else
    {
        [controller getDataFromDB:(double)dateStamp];
        [controller.shiftDetailTableView reloadData];
    }
}

/*-(void)createShiftSummary:(NSNotification *)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    NSDictionary *dataDict=notification.userInfo;
    BOOL isError= FALSE;
    
    if (![dataDict isKindOfClass:[NSNull class]] && dataDict !=nil)
    {
        isError=[[notification.userInfo objectForKey:@"isError"] boolValue];
    }
    
    if (isError)
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        return;
    }
    
    
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTimeOffAndRequestForTimeOffs:) name:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil];
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    NSDate *startDate=[dateFormatter dateFromString:[self.dateDict objectForKey:@"startDate"]];
    NSDate *endDate=[dateFormatter dateFromString:[self.dateDict objectForKey:@"endDate"]];
    [[RepliconServiceManager shiftsService]fetchTimeoffDataForStartDate:startDate andEndDate:endDate andShiftId:[self.dateDict objectForKey:@"id"]];

}


-(void)checkTimeOffAndRequestForTimeOffs:(NSNotification *)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil];
    
    
    
    NSDictionary *dataDict=notification.userInfo;
    BOOL isError= FALSE;
    
    if (![dataDict isKindOfClass:[NSNull class]] && dataDict !=nil)
    {
        isError=[[notification.userInfo objectForKey:@"isError"] boolValue];
    }
    
    if (isError)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        
        return;
    }
    
    [self loadScrollViewWithPage:self.currentlySelectedPage fromDayButtonClick:YES];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    

}*/


-(void)createShiftSummary:(NSNotification *)notification
{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    
    NSDictionary *dataDict=notification.userInfo;
    BOOL isError= FALSE;
    
    if (![dataDict isKindOfClass:[NSNull class]] && dataDict !=nil)
    {
        isError=[[notification.userInfo objectForKey:@"isError"] boolValue];
    }
    
    if (!isError)
    {
        [self updateWeekDayData];
        [self loadScrollViewWithPage:self.currentlySelectedPage fromDayButtonClick:0];
    }
    
}


-(void)checkTimeOffAndRequestForTimeOffs:(NSNotification *)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SHIFT_CHECK_TIMEOFF_NOTIFICATION object:nil];
    
    
    
    NSDictionary *dataDict=notification.userInfo;
    BOOL isError= FALSE;
    
    if (![dataDict isKindOfClass:[NSNull class]] && dataDict !=nil)
    {
        isError=[[notification.userInfo objectForKey:@"isError"] boolValue];
    }
    
    if (isError)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        
        return;
    }
    
    ShiftsModel *shiftModel=[[ShiftsModel alloc]init];
    
    NSMutableArray *shiftByIdArr=[shiftModel getShiftDetailsFromDBForID:[self.dateDict objectForKey:@"id"]];
    
    SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
    NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
    BOOL hasTimeoffBookingAccess=FALSE;
    
    if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
    {
        NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
        
        hasTimeoffBookingAccess        = [[userDetailsDict objectForKey:@"hasTimeoffBookingAccess"]boolValue];//Implemented as per
    }
    
    if (![shiftByIdArr isKindOfClass:[NSNull class]] && shiftByIdArr !=nil && hasTimeoffBookingAccess)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *startDate=[dateFormatter dateFromString:[self.dateDict objectForKey:@"startDate"]];
        NSDate *endDate=[dateFormatter dateFromString:[self.dateDict objectForKey:@"endDate"]];
        [[RepliconServiceManager shiftsService]fetchTimeoffDataForStartDate:startDate andEndDate:endDate andShiftId:[self.dateDict objectForKey:@"id"]];
//        return;
    }

    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *startDate=[dateFormatter dateFromString:[self.dateDict objectForKey:@"startDate"]];
        NSDate *endDate=[dateFormatter dateFromString:[self.dateDict objectForKey:@"endDate"]];
        [[RepliconServiceManager shiftsService]fetchOnlyBulkGetUserHolidaySeriesForStartDate:startDate andEndDate:endDate andShiftId:[self.dateDict objectForKey:@"id"]];
    }
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
}


-(void)updateWeekDayData
{
    NSMutableArray *shiftObjects=[NSMutableArray array];
    ShiftsModel *shiftModel=[[ShiftsModel alloc]init];
    for (int k=0; k<[shiftWeekDatesArray count]; k++)
    {
        
        TimesheetObject *tsObj=[[TimesheetObject alloc]init];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        
        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";
        NSTimeInterval  dateStamp = [[myDateFormatter dateFromString:[myDateFormatter stringFromDate:[shiftWeekDatesArray objectAtIndex:k]]] timeIntervalSince1970];
        NSMutableArray *entryArray= [NSMutableArray arrayWithArray:[shiftModel getShiftinfoForEntryDate:(double)dateStamp]];
        
        for (int k=0; k<[entryArray count]; k++)
        {
            NSString *status= @"";
            NSDictionary *tempDict=[entryArray objectAtIndex:k];
            status = [tempDict objectForKey:@"timeOffApprovalStatus"];
            if([tempDict objectForKey:@"timeOffApprovalStatus"] != nil && ![[tempDict objectForKey:@"timeOffApprovalStatus"] isKindOfClass:[NSNull class]] && [[tempDict objectForKey:@"type"] isEqualToString:TIME_OFF_ENTRY])
            {
                if ([[tempDict objectForKey:@"timeOffApprovalStatus"] isEqualToString:REJECTED_STATUS] || [[tempDict objectForKey:@"timeOffApprovalStatus"] isEqualToString:NOT_SUBMITTED_STATUS]) {
                    [entryArray removeObjectAtIndex:k];
                }
            }
        }
        
        
        
        if ([entryArray count]>0)
        {
            [tsObj setHasEntry:YES];
        }
        else
            [tsObj setHasEntry:NO];
        
        [tsObj setEntryDate:[myDateFormatter stringFromDate:[shiftWeekDatesArray objectAtIndex:k]]];
        [shiftObjects addObject:tsObj];
        
    }
    
    if (self.daySelectionScrollView) {
        [self. daySelectionScrollView removeFromSuperview];
    }
    
    self.daySelectionScrollView = [[DaySelectionScrollView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, Page_Control_View_Height)
                                                                                   andWithTsDataArray:shiftObjects
                                                                             withCurrentlySelectedDay:currentlySelectedPage
                                                                   withDelegate:self withTimesheetUri:@"" approvalsModuleName:nil];
    [daySelectionScrollView setBackgroundColor:[UIColor lightGrayColor]];
    self.daySelectionScrollViewDelegate=(id)daySelectionScrollView;
    [self.view addSubview:daySelectionScrollView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.scrollView.delegate = nil;
}
@end
