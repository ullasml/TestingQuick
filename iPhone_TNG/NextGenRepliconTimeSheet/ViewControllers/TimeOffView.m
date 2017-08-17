//
//  TimeOffView.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/27/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffView.h"
#import "Constants.h"
#import "AppProperties.h"
#import "TimeOffCellView.h"
#import "SVPullToRefresh.h"
#import "ErrorBannerViewParentPresenterHelper.h"

#define Each_Cell_Row_Height 58
#define HeightOfNoTOMsgLabel 80

@interface TimeOffView () <UITableViewDelegate,UITableViewDataSource>
{
    
}
@property (nonatomic,strong) UITableView *timeOffTableView;
@property (nonatomic,strong) NSMutableArray *timeOffArray;
@property (nonatomic,strong) UILabel *msgLabel;
@property (nonatomic,assign) BOOL shouldShowNoTimeOffPlaceholder;
@property (nonatomic)        ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@end

@implementation TimeOffView


- (instancetype)initWithFrame:(CGRect)frame errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper*)errorBannerViewParentPresenterHelper
 {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:RepliconStandardBackgroundColor];
        self.errorBannerViewParentPresenterHelper =  errorBannerViewParentPresenterHelper;
        [self setup_TimeOffView];
    }
    return self;
}

-(void)setup_TimeOffView
{
    CGFloat height = 165.0f;
    if (self.timeOffTableView==nil) {
        self.timeOffTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(self.bounds)-height) style:UITableViewStylePlain];
        self.timeOffTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    self.timeOffTableView.delegate = self;
    self.timeOffTableView.dataSource = self;
    [self addSubview:self.timeOffTableView];
    [self configureTableForPullToRefresh];
    [self refreshTableViewWithContentOffsetReset:YES];
    [self changeTableViewInset];
}

- (void)changeTableViewInset
{
    [self. errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.timeOffTableView];
}

- (void)setUpTimeOffObjectsArray:(NSMutableArray *)timeOffArray {
    [self setTimeOffArray:timeOffArray];
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
    TimeOffView *weakSelf = self;
    [weakSelf.timeOffTableView.pullToRefreshView stopAnimating];
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
    TimeOffView *weakSelf = self;
    [weakSelf.timeOffTableView.infiniteScrollingView stopAnimating];
    if (isErrorOccured)
    {
        self.timeOffTableView.showsInfiniteScrolling=NO;
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
    TimeOffView *weakSelf = self;

    //setup pull to refresh widget
    [self.timeOffTableView addPullToRefreshWithActionHandler:^{
        [weakSelf setUserInteractionEnabled:NO];

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.timeOffTableView.pullToRefreshView startAnimating];
            [weakSelf refreshAction];
        });
    }];

    // setup infinite scrolling
    [self.timeOffTableView addInfiniteScrollingWithActionHandler:^{

        [weakSelf setUserInteractionEnabled:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.timeOffTableView.infiniteScrollingView startAnimating];
            [weakSelf moreAction];
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
    [self checkToShowMoreButton];
    [self.timeOffTableView reloadData];
    if (isContentOffsetReset) {
        [self.timeOffTableView setContentOffset:self.currentContentOffset];
    }
    [self showMessageLabel];
}


/************************************************************************************************************
 @Function Name   : checkToShowMoreButton
 @Purpose         : To check to enable more action or not everytime view appears
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)checkToShowMoreButton
{

    NSNumber *timeoffCount =	[[NSUserDefaults standardUserDefaults]objectForKey:@"timeoffDownloadCount"];
    NSNumber *fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"timeoffDownloadCount"];

    if (([timeoffCount intValue]<[fetchCount intValue]))
    {
        self.timeOffTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        self.timeOffTableView.showsInfiniteScrolling=TRUE;
    }
    [self changeTableViewInset];
}
/************************************************************************************************************
 @Function Name   : stopAnimating_Indicator
 @Purpose         : To stop animating indicators of pull to refresh and more action
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)stopAnimatingIndicator {
    [self setUserInteractionEnabled:YES];
    [self.timeOffTableView.pullToRefreshView stopAnimating];
    [self.timeOffTableView.infiniteScrollingView stopAnimating];
    self.timeOffTableView.showsInfiniteScrolling=YES;
}

/************************************************************************************************************
 @Function Name   : more_Action
 @Purpose         : To fetch more records of timesheet when tableview is scrolled to bottom
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

- (void)moreAction {
    if ([self.timeOffBookingViewDelegate respondsToSelector:@selector(listOfTimeOffBookView:moreAction:)]) {
        [self.timeOffBookingViewDelegate listOfTimeOffBookView:self moreAction:self];
    }
}

/************************************************************************************************************
 @Function Name   : refresh_Action
 @Purpose         : To fetch modified records of timesheet when tableview is pulled to refresh
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

- (void)refreshAction {
    if ([self.timeOffBookingViewDelegate respondsToSelector:@selector(listOfTimeOffBookView:refreshAction:)]) {
        [self.timeOffBookingViewDelegate listOfTimeOffBookView:self refreshAction:self];
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

    if ([self.timeOffArray count]>0)
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeOffArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Each_Cell_Row_Height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimeOffCellIdentifier";

    TimeOffCellView *cell = (TimeOffCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TimeOffCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if (indexPath.row<[self.timeOffArray count]) {
        [cell createCellLayoutForTimeOffView:[self.timeOffArray objectAtIndex:[indexPath row]]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentContentOffset=self.timeOffTableView.contentOffset;
    if ([self.timeOffBookingViewDelegate respondsToSelector:@selector(listofTimeOFfBookView:selectedIndexPath:withTimeOffObject:withContentOffset:)]) {
        [self.timeOffBookingViewDelegate listofTimeOFfBookView:self selectedIndexPath:indexPath withTimeOffObject:[self.timeOffArray objectAtIndex:indexPath.row]withContentOffset:self.currentContentOffset];
    }
}

- (void)dealloc
{
    self.timeOffTableView.delegate = nil;
    self.timeOffTableView.dataSource = nil;
}

@end
