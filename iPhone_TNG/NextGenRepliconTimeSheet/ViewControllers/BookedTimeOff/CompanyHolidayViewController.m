//
//  CompanyHolidayViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 16/04/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "CompanyHolidayViewController.h"
#import "Constants.h"
#import "Util.h"
#import "BookedTimeOffBalancesCellView.h"
#import "TimeoffModel.h"
#import "AppDelegate.h"
#import "BookedTimeOffEntryViewController.h"
#import "BookedTimeOffEntry.h"
#import "SVPullToRefresh.h"
#import <QuartzCore/QuartzCore.h>

@implementation CompanyHolidayViewController
@synthesize companyHolidayList;
@synthesize companyHolidayTableView;
@synthesize bookedTimeOffBalancesViewCtrl;
@synthesize keyNamesArray;
@synthesize isPullToFresh;//Implemented PullToRefresh Functionality

#define Each_Cell_Row_Height 44
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark -
#pragma mark View lifeCycle Methods

- (void)loadView
{
	[super loadView];
	[self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [Util setToolbarLabel: self withText: RPLocalizedString(BookedTimeOffList_Title, BookedTimeOffList_Title)];
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    
    UIImage *homeButtonImage1=[Util thumbnailImage:HomeTransparentButtonImage];
    UIBarButtonItem *templeftButton1 = [[UIBarButtonItem alloc]initWithImage:homeButtonImage1 style:UIBarButtonItemStylePlain
                                                                      target:self action:@selector(goBack:)];
    
    [self.navigationItem setLeftBarButtonItem:templeftButton1 animated:NO];
    
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(addBookTimeOffEntryAction)];
    [self.navigationItem setRightBarButtonItem:addButton animated:NO];
   
    
    
    
    if (companyHolidayTableView==nil) {
        //Fix for ios7//JUHI
        float version= [[UIDevice currentDevice].systemVersion newFloatValue];
        float height=95.0;
        if (version>=7.0)
        {
            height=115.0;
        }
		UITableView *temptimeSheetsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-height) style:UITableViewStylePlain];
		self.companyHolidayTableView=temptimeSheetsTableView;
        self.companyHolidayTableView.separatorColor=[UIColor clearColor];
       
	}
	self.companyHolidayTableView.delegate=self;
	self.companyHolidayTableView.dataSource=self;
	[self.view addSubview:companyHolidayTableView];
	
    UIView *bckView = [UIView new];
	[bckView setBackgroundColor:RepliconStandardBackgroundColor];
	[self.companyHolidayTableView setBackgroundView:bckView];
	
    //Implemented PullToRefresh Functionality
    [self configureTableForPullToRefresh];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self createCompanyHolidayList];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSString *holidayCalendarUri=[defaults objectForKey:@"holidayCalendarURI"];
        
        if (holidayCalendarUri==nil || [holidayCalendarUri isKindOfClass:[NSNull class]])
        {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(HOLIDAY_CALENDAR_NOT_SET_ERROR_MSG, HOLIDAY_CALENDAR_NOT_SET_ERROR_MSG)];
           self.companyHolidayTableView.showsPullToRefresh=FALSE;
            return;
        }
        
        
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;
        }
        TimeoffModel *timeoffModel = [[TimeoffModel alloc]init];
        
        NSMutableDictionary *tempCompanyHolidayList=[timeoffModel getCompanyHolidayInfoDict];
        
        NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDate *date = [NSDate date];
        NSDateComponents *todaydateComponents = [calendar components:unitFlags fromDate:date];
       
        
        NSInteger year = [todaydateComponents year];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createCompanyHolidayList)
                                                     name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION
                                                   object:nil];
        
        if (![[tempCompanyHolidayList objectForKey:[NSString stringWithFormat:@"%ld",(long)year]] isKindOfClass:[NSNull class]]&&[tempCompanyHolidayList objectForKey:[NSString stringWithFormat:@"%ld",(long)year]]!=nil &&![[tempCompanyHolidayList objectForKey:[NSString stringWithFormat:@"%@",@(year-1)]] isKindOfClass:[NSNull class]]&&[tempCompanyHolidayList objectForKey:[NSString stringWithFormat:@"%@",@(year-1)]]!=nil)
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
    if ([companyHolidayList count] > 0) {
		[companyHolidayList removeAllObjects];
	}
    
   

    TimeoffModel *timeoffModel = [[TimeoffModel alloc]init];
    
    self.companyHolidayList=[timeoffModel getCompanyHolidayInfoDict];
    
  
    
    [self.companyHolidayTableView reloadData];
    
    
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [NSDate date];
    NSDateComponents *todaydateComponents = [calendar components:unitFlags fromDate:date];
   
    
    NSInteger year = [todaydateComponents year];
    
    int scrollSectionIndex=0;
    
    if ([self.keyNamesArray containsObject:[NSString stringWithFormat:@"%@",@(year-1)]])
    {
        scrollSectionIndex=1;
    }
    
    if (!isPullToFresh)
    {
        if (![[self.companyHolidayList objectForKey:[NSString stringWithFormat:@"%ld",(long)year]] isKindOfClass:[NSNull class]])
        {
            [self.companyHolidayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:scrollSectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:FALSE];
        }
        else
        {
            if ([self.keyNamesArray count]>0) {
                [self.companyHolidayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:FALSE];
            }
        }
    }
    
}
-(void)createTableHeader{
    
    UIView *tableHeaderView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    
    UILabel *tableHeaderLb= [[UILabel alloc]initWithFrame:CGRectMake(0, 3, 320, 20)];
    
    tableHeaderView.backgroundColor=RepliconStandardBlackColor;
    
    tableHeaderLb.text=[NSString stringWithFormat:@"%@",RPLocalizedString(CompanyHolidayTitle,@"")];
    tableHeaderLb.textColor=RepliconStandardWhiteColor;
    tableHeaderLb.textAlignment=NSTextAlignmentCenter;
    [tableHeaderLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
    [tableHeaderLb setBackgroundColor:[UIColor clearColor]];
    
    [tableHeaderView addSubview:tableHeaderLb];
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 320, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [tableHeaderView addSubview:lineView];
    
    
    [self.companyHolidayTableView setTableHeaderView:tableHeaderView];
   
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSArray* keys = [self.companyHolidayList allKeys];
    NSMutableArray *tempKeysArr=[NSMutableArray arrayWithCapacity:3];
   
    
    int count=0;
    
    for(NSString* key in keys)
    {
        if (![[self.companyHolidayList objectForKey:key] isKindOfClass:[NSNull class]])
        {
            count++;
            [tempKeysArr addObject:key];
        }
    }
    
    self.keyNamesArray = [tempKeysArr sortedArrayUsingComparator: ^(id id1, id id2) {
        
        if ([id1 integerValue] == 0 && [id2 integerValue] == 0)
        {
            return (NSComparisonResult)NSOrderedSame;
        }
        if ([id1 integerValue] == 0)
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([id2 integerValue] == 0)
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if ([id1 integerValue] > [id2 integerValue])
        {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([id1 integerValue] < [id2 integerValue])
        {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
	return count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
   
    
    int count=0;
    NSString *key=[self.keyNamesArray objectAtIndex:section];
    
        
    if (![[self.companyHolidayList objectForKey:key] isKindOfClass:[NSNull class]])
    {
        count=(int) [(NSMutableArray *)[self.companyHolidayList objectForKey:key] count] ;
    }
    
    
    return count;
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Each_Cell_Row_Height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    
    static NSString *CellIdentifier = @"CompanyHolidayCellIdentifier";
	
	BookedTimeOffBalancesCellView *cell = (BookedTimeOffBalancesCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[BookedTimeOffBalancesCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
    }
    
    NSString *key=[self.keyNamesArray objectAtIndex:indexPath.section];
    
    
    NSArray *holidayListArray=nil;
    if (![[self.companyHolidayList objectForKey:key] isKindOfClass:[NSNull class]])
    {
        holidayListArray=(NSArray *) [self.companyHolidayList objectForKey:key] ;
        
        NSMutableDictionary *infoDict=[holidayListArray objectAtIndex:indexPath.row];
        NSString *fieldName=[infoDict objectForKey:@"holidayName"];
        NSDate *date=[Util convertTimestampFromDBToDate:[[infoDict objectForKey:@"holidayDate"] stringValue]];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        
        NSLocale *locale=[NSLocale currentLocale];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [df setLocale:locale];
        [df setTimeZone:timeZone];
        
        
        [df setDateFormat:@"MMM d"];
        
        NSString *fieldValue=[df stringFromDate:date];
        
        
        [cell bookedTimeOffBalanceCelllayout:fieldName totalHrs:fieldValue];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        

    }
    
    	return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    
	
	UILabel *sectionHeaderlabel=[[UILabel alloc]initWithFrame:CGRectMake(12.0,
                                                                         0.0,
                                                                         300.0,
                                                                         20.0)];
    
    
	sectionHeaderlabel.backgroundColor=[UIColor clearColor];
    
    NSString *key=[self.keyNamesArray objectAtIndex:section];
    
    sectionHeaderlabel.text=key;
    
	//Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
        [sectionHeaderlabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
        [sectionHeaderlabel setTextColor:[Util colorWithHex:@"#333333" alpha:1]];//RepliconTimeEntryHeaderTextColor
    }
    else{
        [sectionHeaderlabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
        [sectionHeaderlabel setTextColor:[UIColor whiteColor]];//RepliconTimeEntryHeaderTextColor
    }
	[sectionHeaderlabel setTextAlignment:NSTextAlignmentLeft];//Implemented as per US7992
    
	
    
    UIView *sectionHeader= [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    
    
    //Fix for ios7//JUHI
    if (version>=7.0)
    {
        sectionHeader.backgroundColor=[Util colorWithHex:@"#e8e8e8" alpha:1];
    }
    else{
        sectionHeader.backgroundColor=RepliconStandardBlackColor;
    }
    
    
    [sectionHeader addSubview:sectionHeaderlabel];
    
    
    return sectionHeader;
    
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

         [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
    
   
}
//Implemented PullToRefresh Functionality
/************************************************************************************************************
 @Function Name   : configureTableForPullToRefresh
 @Purpose         : To extend tableview to add pull to refresh and infinite scrolling view
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)configureTableForPullToRefresh
{
    CompanyHolidayViewController *weakSelf = self;
    
    
    //setup pull to refresh widget
    [self.companyHolidayTableView addPullToRefreshWithActionHandler:^{
        
        int64_t delayInSeconds = 0.0;
        [weakSelf.companyHolidayTableView.pullToRefreshView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           
                           [weakSelf refreshAction];
                           
                           
                       });
    }];
    
    
}

/************************************************************************************************************
 @Function Name   : refreshAction
 @Purpose         : To fetch modified records of timeoff when tableview is pulled to refresh
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [self.view setUserInteractionEnabled:YES];
        CompanyHolidayViewController *weakSelf = self;
        [weakSelf.companyHolidayTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromRefreshedData)
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

-(void)refreshViewFromRefreshedData
{
    self.isPullToFresh=YES;
    [self.view setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:COMPANY_HOLIDAY_RECEIVED_NOTIFICATION object:nil];
    CompanyHolidayViewController *weakSelf = self;
    [weakSelf.companyHolidayTableView.pullToRefreshView stopAnimating];
    [self createCompanyHolidayList];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
