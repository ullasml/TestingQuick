//
//  ShiftsSummaryViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 24/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//


#import "ShiftsSummaryViewController.h"
#import "Constants.h"
#import "ShiftsModel.h"
#import "AppDelegate.h"
#import "SupportDataModel.h"
#import "RepliconServiceManager.h"
#import <Blindside/BSInjector.h>


@interface ShiftsSummaryViewController()

@property (nonatomic, strong) NSArray<ShiftItemsSectionPresenter *> *shiftPresenters;
@property (nonatomic, weak) id<BSInjector> injector;


@end
@implementation ShiftsSummaryViewController
@synthesize shiftSummaryArray;
@synthesize shiftSummaryIdentity;
@synthesize shiftSummaryTableView;
@synthesize shiftDuration;
@synthesize allEntriesArray;
@synthesize shiftMainPageController;
@synthesize entriesArray;


-(instancetype)initWithSummaryPresenter:(ShiftSummaryPresenter *) shiftSummaryPresenter {
    self = [super init];
    if(self) {
        _shiftSummaryPresenter = shiftSummaryPresenter;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Util setToolbarLabel:self withText:shiftDuration];
    self.shiftSummaryTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0 ,self.view.frame.size.width,[self heightForTableView])  style:UITableViewStyleGrouped];
    
    self.shiftSummaryTableView.delegate=self;
    self.shiftSummaryTableView.dataSource=self;
    self.shiftSummaryTableView.backgroundColor = RepliconStandardBackgroundColor;
    [self.view addSubview: self.shiftSummaryTableView];

    self.shiftPresenters = [NSMutableArray array];
    self.shiftSummaryTableView.rowHeight = UITableViewAutomaticDimension;
    self.shiftSummaryTableView.estimatedRowHeight = 80;
    self.shiftSummaryTableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.shiftSummaryTableView.estimatedSectionHeaderHeight = 40;
    self.shiftSummaryTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.shiftSummaryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self registerCellsForTableView];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (selectedIndexPath!=nil)
    {
        [shiftSummaryTableView deselectRowAtIndexPath:selectedIndexPath animated:NO];
        
    }
    
}

- (void) registerCellsForTableView {
    [ShiftScheduleCell registerWithTableView:self.shiftSummaryTableView];
    [ShiftScheduleTimeOffCell registerWithTableView:self.shiftSummaryTableView];
    [ShiftScheduleHolidayCell registerWithTableView:self.shiftSummaryTableView];
}

#pragma mark - Frame math

- (CGFloat)heightForTableView
{
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame));
}


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
        NSMutableArray *tmpcurrentTimesheetArray=[[NSMutableArray alloc]init];
        self.shiftSummaryArray=tmpcurrentTimesheetArray;
        ShiftsModel *shiftModel=[[ShiftsModel alloc]init];
        NSMutableArray * shiftArray=[shiftModel getAllShiftEntryGroupedByDateForId:shiftSummaryIdentity];
        
        NSMutableArray *entryDateArray=[NSMutableArray array];
        for (int i=0; i<[allEntriesArray count]; i++)
        {
            NSDate *entryDate=[allEntriesArray objectAtIndex:i];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZZ"];
            NSString *entryDateStr=[dateFormatter stringFromDate:entryDate];
            entryDate=[dateFormatter dateFromString:entryDateStr];
            [dateFormatter setDateFormat:@"EEEE, MMM dd, yyyy"];
            entryDateStr=[dateFormatter stringFromDate:entryDate];
            if (entryDateStr != nil && ![entryDateStr isKindOfClass:[NSNull class]]) {
                [entryDateArray addObject:entryDateStr];
            }
        }
        
        
        for (int k=0; k<[entryDateArray count]; k++)
        {
            NSString *str=[entryDateArray objectAtIndex:k];
            NSString *dictKeyToStore=nil;
            NSMutableArray *shiftEntryToStore=nil;
            NSMutableDictionary *dataToStore=[[NSMutableDictionary alloc] init];
            for (int j=0; j<[shiftArray count]; j++)
            {
                
                NSString *dictKey=[[[shiftArray objectAtIndex:j] allKeys] objectAtIndex:0];
                if ([str isEqualToString:dictKey])
                {
                    dictKeyToStore=dictKey;
                    shiftEntryToStore =[[shiftArray objectAtIndex:j]objectForKey:dictKey];
                    break;
                }
            }
            
            if (dictKeyToStore==nil || [dictKeyToStore isKindOfClass:[NSNull class]]||shiftEntryToStore==nil||[shiftEntryToStore isKindOfClass:[NSNull class]])
            {
                [dataToStore setObject:str forKey:@"shiftDay"];
                [dataToStore setObject:[NSString stringWithFormat:@"%@",RPLocalizedString(NO_SHIFT, @"")] forKey:@"ShiftEntry"];
                [shiftSummaryArray addObject:dataToStore];
            }
            else
            {
                for (int index= 0; index<[shiftEntryToStore count]; index++) {
                    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                    tempDict = [shiftEntryToStore objectAtIndex:index];
                    NSString *status= @"";
                    status = [tempDict objectForKey:@"timeOffApprovalStatus"];
                }
                if ([shiftEntryToStore count] == 0) {
                    [dataToStore setObject:str forKey:@"shiftDay"];
                    [dataToStore setObject:[NSString stringWithFormat:@"%@",RPLocalizedString(NO_SHIFT, @"")] forKey:@"ShiftEntry"];
                }
                else
                {
                    [dataToStore setObject:dictKeyToStore forKey:@"shiftDay"];
                    [dataToStore setObject:shiftEntryToStore forKey:@"ShiftEntry"];
                }
                
                [shiftSummaryArray addObject:dataToStore];
            }
            
        }
        

        if( self.shiftSummaryPresenter && shiftSummaryArray) {
            self.shiftPresenters = [self.shiftSummaryPresenter shiftItemPresenterSectionsForShiftDataList: shiftSummaryArray];
        }
        
        [shiftSummaryTableView reloadData];
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
    
    NSMutableArray *shiftByIdArr=[shiftModel getShiftByIDFromDB:shiftSummaryIdentity];
    SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
    NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
    BOOL hasTimeoffBookingAccess=FALSE;
    
    if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
    {
        NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
        
        hasTimeoffBookingAccess        = [[userDetailsDict objectForKey:@"hasTimeoffBookingAccess"]boolValue];//Implemented as per
    }
    
    
    if ([shiftByIdArr count]>0 && hasTimeoffBookingAccess)
    {
        NSDictionary *shiftDict=[shiftByIdArr objectAtIndex:0];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *startDate=[dateFormatter dateFromString:[shiftDict objectForKey:@"startDate"]];
        NSDate *endDate=[dateFormatter dateFromString:[shiftDict objectForKey:@"endDate"]];
        [[RepliconServiceManager shiftsService]fetchTimeoffDataForStartDate:startDate andEndDate:endDate andShiftId:shiftSummaryIdentity];
        
        //         return;
    }
    
    else if ([shiftByIdArr count]>0)
    {
        NSDictionary *shiftDict=[shiftByIdArr objectAtIndex:0];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        NSDate *startDate=[dateFormatter dateFromString:[shiftDict objectForKey:@"startDate"]];
        NSDate *endDate=[dateFormatter dateFromString:[shiftDict objectForKey:@"endDate"]];
        [[RepliconServiceManager shiftsService]fetchOnlyBulkGetUserHolidaySeriesForStartDate:startDate andEndDate:endDate andShiftId:shiftSummaryIdentity];
    }
    
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SHIFT_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        
        return;
    }
}


#pragma mark -
#pragma mark - UITableView Delegates


#pragma mark - Header shiftPresenters

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.shiftPresenters.count;
}


- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section >= self.shiftPresenters.count ) {
        return [[UIView alloc] init];
    }
    
    ShiftItemsSectionPresenter *sectionPresenter = [self.shiftPresenters objectAtIndex:section];
    ShiftSectionHeaderView *sectionHeaderView = [ShiftSectionHeaderView createView];
    if (!sectionHeaderView) {
        return [[UIView alloc] init];
    }
    __weak ShiftsSummaryViewController *weakSelf = self;
    
    sectionHeaderView.didSelectSectionHeader =  ^(void){
        [weakSelf navigateToShiftMainPageWithIndex:section];
    };
    [sectionHeaderView updateWithSectionPresenter:sectionPresenter];
    return sectionHeaderView;
    
}


#pragma mark - Table view cells
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.shiftPresenters.count ){
        ShiftItemsSectionPresenter *sectionPresenter = [self.shiftPresenters objectAtIndex:section];
        return sectionPresenter.shiftItemPresenters.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= self.shiftPresenters.count ) {
        return [[UITableViewCell alloc] init];
    }
    
    ShiftItemsSectionPresenter *sectionPresenter = [self.shiftPresenters objectAtIndex:indexPath.section];
    if( indexPath.row >= sectionPresenter.shiftItemPresenters.count){
        return [[UITableViewCell alloc] init];
    }
    
    ShiftItemPresenter *shiftItemPresenter = [sectionPresenter.shiftItemPresenters objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier = shiftItemPresenter.cellReuseIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    if([cell isKindOfClass: [BaseShiftCell class]]) {
        BaseShiftCell *shiftCell = (BaseShiftCell *)cell;
        [shiftCell updateWithShiftItemPresenter:shiftItemPresenter];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedIndexPath=indexPath;
    [self navigateToShiftMainPageWithIndex:indexPath.section];
}


- (void) navigateToShiftMainPageWithIndex:(NSInteger)index {
    
    ShiftMainPageViewController *tmpShiftMainPageController= [self.injector getInstance:[ShiftMainPageViewController class]];
    self.shiftMainPageController=tmpShiftMainPageController;
    self.shiftMainPageController.shiftWeekDatesArray=allEntriesArray;
    self.shiftMainPageController.pageControl.currentPage=index;
    self.shiftMainPageController.currentlySelectedPage=index;
    self.shiftMainPageController.delegate = self;
    [self.navigationController pushViewController:self.shiftMainPageController animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.shiftSummaryTableView.delegate = nil;
    self.shiftSummaryTableView.dataSource = nil;
}

@end
