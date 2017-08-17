//
//  TimeOffHolidayView.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/29/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffHolidayView.h"
#import "Constants.h"
#import "HolidayAndBalanceCellView.h"
#import "SVPullToRefresh.h"
#import "AppProperties.h"
#import "ErrorBannerViewParentPresenterHelper.h"
#import "UIView+Additions.h"

#define Each_Cell_Row_Height 44
#define HeightOfNoTOMsgLabel 80

@interface TimeOffHolidayView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *companyHolidayTableView;
@property (nonatomic,strong) NSMutableDictionary *companyHolidayDict;
@property (nonatomic,strong) NSArray *holidayNamesArray;
@property (nonatomic,strong) UILabel *msgLabel;
@property (nonatomic,assign) BOOL shouldShowNoTimeOffPlaceholder;
@property (nonatomic,assign) BOOL isPullToFresh;
@property (nonatomic)        ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@end

@implementation TimeOffHolidayView


- (instancetype)initWithFrame:(CGRect)frame errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper*)errorBannerViewParentPresenterHelper
 {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:RepliconStandardBackgroundColor];
        self.errorBannerViewParentPresenterHelper = errorBannerViewParentPresenterHelper;
        [self setup_TimeOffView];
    }
    return self;
}

-(void)setup_TimeOffView
{
    CGFloat height = 165.0f;
    if (self.companyHolidayTableView==nil) {
        UITableView *holidaysTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, CGRectGetHeight(self.bounds)-height) style:UITableViewStylePlain];
        self.companyHolidayTableView=holidaysTableView;
        self.companyHolidayTableView.separatorColor=[UIColor clearColor];
    }
    self.companyHolidayTableView.delegate=self;
    self.companyHolidayTableView.dataSource=self;
    [self addSubview:self.companyHolidayTableView];
    [self configureTableForPullToRefresh];
    [self refreshTableViewWithContentOffsetReset];
    
    UIView *bckView = [UIView new];
    [bckView setBackgroundColor:RepliconStandardBackgroundColor];
    [self.companyHolidayTableView setBackgroundView:bckView];
    
    [self. errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.companyHolidayTableView];
}

- (void)setUpCompanyHolidays:(NSMutableDictionary *)companyHolidaysDict
{
    [self setCompanyHolidayDict:companyHolidaysDict];
    [self setShouldShowNoTimeOffPlaceholder:NO];
}
-(void)scrollTableview
{
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [NSDate date];
    NSDateComponents *todaydateComponents = [calendar components:unitFlags fromDate:date];
    
    
    NSInteger year = [todaydateComponents year];
    
    int scrollSectionIndex=0;
    
    NSArray* keys = [self.companyHolidayDict allKeys];
    NSMutableArray *tempKeysArr=[NSMutableArray arrayWithCapacity:3];
    
    
    int count=0;
    
    for(NSString* key in keys)
    {
        if (![[self.companyHolidayDict objectForKey:key] isKindOfClass:[NSNull class]])
        {
            count++;
            [tempKeysArr addObject:key];
        }
    }

    
    if ([tempKeysArr containsObject:[NSString stringWithFormat:@"%d",(int)year-1]])
    {
        scrollSectionIndex=1;
    }
    
    if (!self.isPullToFresh)
    {
        NSLog(@"%@",self.companyHolidayDict);
        if ([self.companyHolidayDict objectForKey:[NSString stringWithFormat:@"%ld",(long)year]]!=nil && ![[self.companyHolidayDict objectForKey:[NSString stringWithFormat:@"%ld",(long)year]] isKindOfClass:[NSNull class]])
        {
            [self.companyHolidayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:scrollSectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:FALSE];
        }
        else
        {
            if ([self.holidayNamesArray count]>0) {
                [self.companyHolidayTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:FALSE];
            }
        }
    }

}
/************************************************************************************************************
 @Function Name   : animate_TableRows_AfterMoreAction
 @Purpose         : To animate tableview with new records requested through more action
 @param           : (NSNotification*)notification
 @return          : nil
 *************************************************************************************************************/


-(void)refreshTableViewAfterPulltoRefresh
{
    self.isPullToFresh = YES;
    [self setUserInteractionEnabled:YES];
    TimeOffHolidayView *weakSelf = self;
    [weakSelf.companyHolidayTableView.pullToRefreshView stopAnimating];
    [self refreshTableViewWithContentOffsetReset];
}

/************************************************************************************************************
 @Function Name   : refreshView_From_RefreshedData
 @Purpose         : To reload tableview everytime when pull to refresh action is made
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshTableViewAfterMoreAction:(BOOL)isErrorOccured
{
    [self setUserInteractionEnabled:YES];
    TimeOffHolidayView *weakSelf = self;
    [weakSelf.companyHolidayTableView.infiniteScrollingView stopAnimating];
    if (isErrorOccured)
    {
        self.companyHolidayTableView.showsInfiniteScrolling=NO;
    }
    else
    {
        [self refreshTableViewWithContentOffsetReset];
    }
}

#pragma mark Pull To Refresh/ More action
/************************************************************************************************************
 @Function Name   : configure_TableFor_PullToRefresh
 @Purpose         : To extend tableview to add pull to refresh and infinite scrolling capabilities
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)configureTableForPullToRefresh
{
    TimeOffHolidayView *weakSelf = self;
    
    //setup pull to refresh widget
    [self.companyHolidayTableView addPullToRefreshWithActionHandler:^{
        [weakSelf setUserInteractionEnabled:NO];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.companyHolidayTableView.pullToRefreshView startAnimating];
            [weakSelf refreshAction];
        });
    }];
    
}

/************************************************************************************************************
 @Function Name   : refreshTableView_WithContentOffsetReset
 @Purpose         : To refresh tableview data with latest data from service
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshTableViewWithContentOffsetReset
{

        self.userInteractionEnabled = YES;
        [self.companyHolidayTableView reloadData];
//        if (isContentOffsetReset) {
//            [self.companyHolidayTableView setContentOffset:currentContentOffset];
//        }
        [self showMessageLabel];

     [self scrollTableview];
}


/************************************************************************************************************
 @Function Name   : stopAnimating_Indicator
 @Purpose         : To stop animating indicators of pull to refresh and more action
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)stopAnimatingIndicator {
    [self setUserInteractionEnabled:YES];
    [self.companyHolidayTableView.pullToRefreshView stopAnimating];
    [self.companyHolidayTableView.infiniteScrollingView stopAnimating];
    self.companyHolidayTableView.showsInfiniteScrolling=YES;
}

/************************************************************************************************************
 @Function Name   : refresh_Action
 @Purpose         : To fetch modified records of timesheet when tableview is pulled to refresh
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

- (void)refreshAction {
    if ([self.timeOffHolidayDelegate respondsToSelector:@selector(listOfTimeOffHolidayView:refreshAction:)]) {
        [self.timeOffHolidayDelegate listOfTimeOffHolidayView:self refreshAction:self];
    }
}

/************************************************************************************************************
 @Function Name   : show_MessageLabel
 @Purpose         : To show message label when there are no timeOff available
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)showMessageLabel
{
    if (!self.shouldShowNoTimeOffPlaceholder)
    {
        [self.msgLabel removeFromSuperview];
        return;
    }
    
    if ([self.holidayNamesArray count]>0)
    {
        [self.msgLabel removeFromSuperview];
    }
    else
    {
        [self.msgLabel removeFromSuperview];
        UILabel *tempMsgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.frame.size.width, HeightOfNoTOMsgLabel)];
        tempMsgLabel.text=RPLocalizedString(_NO_TIMESHEETS_AVAILABLE, _NO_TIMESHEETS_AVAILABLE);
        self.msgLabel=tempMsgLabel;
        self.msgLabel.backgroundColor=[UIColor clearColor];
        self.msgLabel.numberOfLines=3;
        self.msgLabel.textAlignment=NSTextAlignmentCenter;
        self.msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];
        [self addSubview:self.msgLabel];
    }
    
}




-(void)createTableHeader{
    
    UIView *tableHeaderView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    
    UILabel *tableHeaderLb= [[UILabel alloc]initWithFrame:CGRectMake(0, 3, tableHeaderView.width, 20)];
    tableHeaderView.backgroundColor=RepliconStandardBlackColor;
    tableHeaderLb.text=[NSString stringWithFormat:@"%@",RPLocalizedString(CompanyHolidayTitle,@"")];
    tableHeaderLb.textColor=RepliconStandardWhiteColor;
    tableHeaderLb.textAlignment=NSTextAlignmentCenter;
    [tableHeaderLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
    [tableHeaderLb setBackgroundColor:[UIColor clearColor]];
    [tableHeaderView addSubview:tableHeaderLb];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, tableHeaderView.width, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    [tableHeaderView addSubview:lineView];
    
    [self.companyHolidayTableView setTableHeaderView:tableHeaderView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSArray* keys = [self.companyHolidayDict allKeys];
    NSMutableArray *tempKeysArr=[NSMutableArray arrayWithCapacity:3];
    
    
    int count=0;
    
    for(NSString* key in keys)
    {
        if (![[self.companyHolidayDict objectForKey:key] isKindOfClass:[NSNull class]])
        {
            count++;
            [tempKeysArr addObject:key];
        }
    }
    
    self.holidayNamesArray = [tempKeysArr sortedArrayUsingComparator: ^(id id1, id id2) {
        
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
    NSString *key=[self.holidayNamesArray objectAtIndex:section];
    
    
    if (![[self.companyHolidayDict objectForKey:key] isKindOfClass:[NSNull class]])
    {
        count=(int) [[self.companyHolidayDict objectForKey:key] count] ;
    }
    
    
    return count;
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Each_Cell_Row_Height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HolidayAndBalanceCellViewIdentifier";
    
    HolidayAndBalanceCellView *cell = (HolidayAndBalanceCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HolidayAndBalanceCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    NSString *key=[self.holidayNamesArray objectAtIndex:indexPath.section];
    
    NSArray *holidayListArray=nil;
    if (![[self.companyHolidayDict objectForKey:key] isKindOfClass:[NSNull class]])
    {
        holidayListArray=(NSArray *) [self.companyHolidayDict objectForKey:key] ;
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
        
        [cell timeOffBalanceAndHoliday:fieldName totalHrs:fieldValue];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
    UILabel *sectionHeaderlabel=[[UILabel alloc]initWithFrame:CGRectMake(12.0,0.0,tableView.bounds.size.width - 24,20.0)];
    sectionHeaderlabel.backgroundColor=[UIColor clearColor];
    NSString *key=[self.holidayNamesArray objectAtIndex:section];
    sectionHeaderlabel.text=key;
    
    [sectionHeaderlabel setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_14]];
    [sectionHeaderlabel setTextAlignment:NSTextAlignmentLeft];
    
    UIView *sectionHeader= [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    sectionHeader.backgroundColor=[Util colorWithHex:@"#eeeeee" alpha:1];

    [sectionHeader addSubview:sectionHeaderlabel];
    return sectionHeader;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(void)dealloc
{
    self.companyHolidayTableView.delegate=nil;
    self.companyHolidayTableView.dataSource=nil;

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
