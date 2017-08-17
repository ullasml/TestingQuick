#import "TimeOffBalanceView.h"
#import "Constants.h"
#import "HolidayAndBalanceCellView.h"
#import "SVPullToRefresh.h"
#import "AppProperties.h"
#import "ErrorBannerViewParentPresenterHelper.h"

#define Each_Cell_Row_Height 44
#define HeightOfNoTOMsgLabel 80

@interface TimeOffBalanceView () <UITableViewDataSource,UITableViewDelegate>
{
    CGPoint currentContentOffset;
}
@property(nonatomic,strong) UITableView *timeOffBalnceTableView;
@property (nonatomic,strong) NSMutableArray *balanceAvailableArr;
@property (nonatomic,strong) NSMutableArray *balanceUsedArr;
@property (nonatomic,strong) NSMutableArray *balanceTrackedArr;
@property (nonatomic,strong) NSMutableArray *sectionsArr;
@property (nonatomic,strong) UILabel *msgLabel;
@property (nonatomic,assign) BOOL shouldShowNoTimeOffPlaceholder;
@property (nonatomic)        ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;

@end

@implementation TimeOffBalanceView

- (instancetype)initWithFrame:(CGRect)frame errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper*)errorBannerViewParentPresenterHelper {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:RepliconStandardBackgroundColor];
        self.errorBannerViewParentPresenterHelper = errorBannerViewParentPresenterHelper;
        [self setup_TimeOffBalanceView];
    }
    return self;
}

-(void)setup_TimeOffBalanceView
{
    CGFloat height = 165.0f;
    if (self.timeOffBalnceTableView==nil) {
        UITableView *temptimeSheetsTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-height) style:UITableViewStylePlain];
        self.timeOffBalnceTableView=temptimeSheetsTableView;
        self.timeOffBalnceTableView.separatorColor=[UIColor clearColor];

    }
    self.timeOffBalnceTableView.delegate=self;
    self.timeOffBalnceTableView.dataSource=self;
    [self addSubview:self.timeOffBalnceTableView];
    [self configureTableForPullToRefresh];
    [self refreshTableViewWithContentOffsetReset:NO];

    UIView *bckView = [UIView new];
    [bckView setBackgroundColor:RepliconStandardBackgroundColor];
    [self.timeOffBalnceTableView setBackgroundView:bckView];
    
    [self. errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.timeOffBalnceTableView];
}

- (void)setUpTimeOffBalceArray:(NSMutableArray *)availableArr :(NSMutableArray *)usedArr :(NSMutableArray *)trackedArr :(NSMutableArray *)sectionsArr{
    [self setBalanceAvailableArr:availableArr];
    [self setBalanceTrackedArr:trackedArr];
    [self setBalanceUsedArr:usedArr];
    [self setSectionsArr:sectionsArr];
    [self setShouldShowNoTimeOffPlaceholder:NO];
}

/************************************************************************************************************
 @Function Name   : animate_TableRows_AfterMoreAction
 @Purpose         : To animate tableview with new records requested through more action
 @param           : (NSNotification*)notification
 @return          : nil
 *************************************************************************************************************/


-(void)refreshTableViewAfterPulltoRefresh
{
    [self setUserInteractionEnabled:YES];
    TimeOffBalanceView *weakSelf = self;
    [weakSelf.timeOffBalnceTableView.pullToRefreshView stopAnimating];
    [self refreshTableViewWithContentOffsetReset:NO];
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
    TimeOffBalanceView *weakSelf = self;
    [weakSelf.timeOffBalnceTableView.infiniteScrollingView stopAnimating];
    if (isErrorOccured)
    {
        self.timeOffBalnceTableView.showsInfiniteScrolling=NO;
    }
    else
    {
        [self refreshTableViewWithContentOffsetReset:NO];
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
    TimeOffBalanceView *weakSelf = self;

    //setup pull to refresh widget
    [self.timeOffBalnceTableView addPullToRefreshWithActionHandler:^{
        [weakSelf setUserInteractionEnabled:NO];

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.timeOffBalnceTableView.pullToRefreshView startAnimating];
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

-(void)refreshTableViewWithContentOffsetReset:(BOOL)isContentOffsetReset
{

    [self.timeOffBalnceTableView reloadData];
    if (isContentOffsetReset) {
        [self.timeOffBalnceTableView setContentOffset:currentContentOffset];
    }
    [self showMessageLabel];
}


/************************************************************************************************************
 @Function Name   : stopAnimating_Indicator
 @Purpose         : To stop animating indicators of pull to refresh and more action
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)stopAnimatingIndicator {
    [self setUserInteractionEnabled:YES];
    [self.timeOffBalnceTableView.pullToRefreshView stopAnimating];
    [self.timeOffBalnceTableView.infiniteScrollingView stopAnimating];
    self.timeOffBalnceTableView.showsInfiniteScrolling=YES;
}


/************************************************************************************************************
 @Function Name   : refresh_Action
 @Purpose         : To fetch modified records of timesheet when tableview is pulled to refresh
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

- (void)refreshAction {
    if ([self.timeOffBalanceViewDelegate respondsToSelector:@selector(listOfTimeOffBalanceView:refreshAction:)]) {
        [self.timeOffBalanceViewDelegate listOfTimeOffBalanceView:self refreshAction:self];
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

    if ([self.balanceAvailableArr count]>0 || [self.balanceAvailableArr count]>0 || [self.balanceAvailableArr count]>0)
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


#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [self.sectionsArr count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSString *sectionHeaderStr=[self.sectionsArr objectAtIndex:section];

    if ([sectionHeaderStr isEqualToString:RPLocalizedString(BOOKED_TIMEOFF_AVAILABLE, BOOKED_TIMEOFF_AVAILABLE)])
    {
        return [self.balanceAvailableArr count];
    }
    else if ([sectionHeaderStr isEqualToString:RPLocalizedString(BOOKED_TIMEOFF_USED, BOOKED_TIMEOFF_USED)])
    {
        return [self.balanceUsedArr count];
    }
    else if ([sectionHeaderStr isEqualToString:RPLocalizedString(BOOKED_TIMEOFF_UNTRACKED, BOOKED_TIMEOFF_UNTRACKED)])
    {
        return [self.balanceTrackedArr count];
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Each_Cell_Row_Height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)index
{
    UILabel *sectionHeaderlabel=[[UILabel alloc]initWithFrame:CGRectMake(12.0,0.0,SCREEN_WIDTH-24,20.0)];
    sectionHeaderlabel.text = self.sectionsArr[index];
    sectionHeaderlabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14];

    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 30)];
    sectionHeader.backgroundColor=[Util colorWithHex:@"#eeeeee" alpha:1];
    [sectionHeader addSubview:sectionHeaderlabel];
    return sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


    static NSString *CellIdentifier = @"HolidayAndBalanceCellViewIdentifier";

    HolidayAndBalanceCellView *cell = (HolidayAndBalanceCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[HolidayAndBalanceCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    NSString *fieldType=nil;
    NSString *fieldValue=nil;
    NSDictionary *dict;
    NSString *timeOffDisplayFormatUri=nil;

    NSString *sectionHeaderStr=[self.sectionsArr objectAtIndex:indexPath.section];

    if ([sectionHeaderStr isEqualToString:RPLocalizedString(BOOKED_TIMEOFF_AVAILABLE, BOOKED_TIMEOFF_AVAILABLE)])
    {
        if ([self.balanceAvailableArr count]>indexPath.row) {
            dict=[self.balanceAvailableArr objectAtIndex:indexPath.row];
            fieldType=[dict objectForKey:@"timeOffTypeName"];
            timeOffDisplayFormatUri = dict[@"timeOffDisplayFormatUri"];
            if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI]) {
                fieldValue=[Util getRoundedValueFromDecimalPlaces:[[dict objectForKey:@"timeTakenOrRemainingDurationDays"]newDoubleValue]withDecimalPlaces:2];
                if (fabs([fieldValue newDoubleValue]) != 1.00)
                    fieldValue=[NSString stringWithFormat:@"%@ %@",fieldValue,RPLocalizedString(@"days", @"")];
                else
                    fieldValue=[NSString stringWithFormat:@"%@ %@",fieldValue,RPLocalizedString(@"day", @"")];
            }
            else{
                fieldValue=[Util getRoundedValueFromDecimalPlaces:[[dict objectForKey:@"timeTakenOrRemainingDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
                if (fabs([fieldValue newDoubleValue]) != 1.00)
                    fieldValue=[NSString stringWithFormat:@"%@ %@",fieldValue,RPLocalizedString(@"hours", @"")];
                else
                    fieldValue=[NSString stringWithFormat:@"%@ %@",fieldValue,RPLocalizedString(@"hour", @"")];
            }
        }
    }
    else if ([sectionHeaderStr isEqualToString:RPLocalizedString(BOOKED_TIMEOFF_USED, BOOKED_TIMEOFF_USED)])
    {
        if([self.balanceUsedArr count]>indexPath.row)
        {
            dict=[self.balanceUsedArr objectAtIndex:indexPath.row];
            fieldType=[dict objectForKey:@"timeOffTypeName"];
            timeOffDisplayFormatUri = dict[@"timeOffDisplayFormatUri"];
            if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI]) {
                fieldValue=[Util getRoundedValueFromDecimalPlaces:[[dict objectForKey:@"timeTakenOrRemainingDurationDays"]newDoubleValue]withDecimalPlaces:2];
                if (fabs([fieldValue newDoubleValue]) != 1.00)
                    fieldValue=[NSString stringWithFormat:@"%@ %@",fieldValue,RPLocalizedString(@"days", @"")];
                else
                    fieldValue=[NSString stringWithFormat:@"%@ %@",fieldValue,RPLocalizedString(@"day", @"")];
            }
            else{
                fieldValue=[Util getRoundedValueFromDecimalPlaces:[[dict objectForKey:@"timeTakenOrRemainingDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
                if (fabs([fieldValue newDoubleValue]) != 1.00)
                    fieldValue=[NSString stringWithFormat:@"%@ %@",fieldValue,RPLocalizedString(@"hours", @"")];
                else
                    fieldValue=[NSString stringWithFormat:@"%@ %@",fieldValue,RPLocalizedString(@"hour", @"")];
            }
        }
    }
    else if ([sectionHeaderStr isEqualToString:RPLocalizedString(BOOKED_TIMEOFF_UNTRACKED, BOOKED_TIMEOFF_UNTRACKED)])
    {
        if ([self.balanceTrackedArr count]>indexPath.row)
        {
            dict=[self.balanceTrackedArr objectAtIndex:indexPath.row];
            fieldType=[dict objectForKey:@"timeOffTypeName"];
            fieldValue=@"";
        }
    }

    [cell timeOffBalanceAndHoliday:fieldType totalHrs:fieldValue];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)dealloc
{
    self.timeOffBalnceTableView.delegate = nil;
    self.timeOffBalnceTableView.dataSource = nil;
}

@end
