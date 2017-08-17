#import "TimeOffDetailsView.h"
#import "Constants.h"
#import "TimeOffDetailsCellView.h"
#import "EntryCellDetails.h"
#import "TimeOffDetailsTableFooterView.h"
#import "Constants.h"
#import "TimeoffModel.h"
#import "LoginModel.h"
#import "ApprovalsModel.h"
#import "UdfObject.h"
#import "TimeOffRequestedCellView.h"
#import "ApprovalsScrollViewController.h"
#import "ApprovalTablesHeaderView.h"
#import "ErrorBannerViewParentPresenterHelper.h"
#import "UIView+Additions.h"

#define ROW_HEIGHT 58.0
#define UDF_ROW_HEIGHT 44.0
#define BALANCE_ROW_HEIGHT 75.0
#define FOOTER_HEIGHT 150.0
#define FOOTER_HEIGHT_APPROVALS 200.0
#define Toolbar_Height 45
#define Tabbar_Height 49
#define Picker_Height 225
#define Data_Picker_Height 162
#define PICKER_ROW_HEIGHT 40

#define ResetHeightios5 170
#define ResetHeightios4 175
#define visibleContenoffSetforIos4 673
#define visibleContenoffSetforIos5 585

#define TIMEOFF_DETAILS_CELL @"TimeOffDetailsCellView"
#define TIMEOFF_UDF_CELL @"TimeSheetsUdfCell"
#define TIMEOFF_REQUESTED_CELL @"TimeOffRequestedCellView"

#define Each_Cell_Row_Height_44 44

@interface TimeOffDetailsView ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,TimeOffBalanceCalculationDelegate,TimeOffSaveDeleteDelegate,UdfDropDownNavigationDelegate,approvalTablesFooterViewDelegate,approvalTablesHeaderViewDelegate>
{
    NSInteger startDurationEntryTypeMode;
    NSInteger endDurationEntryMode;
    BOOL isStartDayButtonClicked;
    BOOL isEndDayButtonClicked;
    NSMutableArray *cellsArray;
}

@property(nonatomic,assign) BOOL isEditClicked;
@property(nonatomic,assign) BOOL isTypeAvailable;
@property(nonatomic,strong) NSMutableArray *timeOffTypesArray;
@property(nonatomic,strong) NSMutableArray *timeOffDayTypeArray;
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,strong) UIBarButtonItem *spaceButton;
@property(nonatomic,strong) UIToolbar *toolbar;
@property(nonatomic,strong) UIPickerView *dataPicker;
@property(nonatomic,strong) UIDatePicker *datePicker;
@property(nonatomic,strong) NSMutableArray *rowObjectsArray;
@property(nonatomic,strong) id rowDetails;
@property(nonatomic,strong) TimeOffDetailsTableFooterView *timeOffDetailsTablefooter;
@property(nonatomic,strong) NSString *policyKey;
@property(nonatomic,strong) NSArray *fullDayArray;
@property(nonatomic,strong) NSArray *halfDayArray;
@property(nonatomic,strong) NSArray *quarterDayArray;
@property(nonatomic,strong) NSArray *noneDayArray;
@property(nonatomic,strong) NSArray *fullHourArray;
@property(nonatomic,strong) NSIndexPath *selectedIndex;
@property (nonatomic,strong) UISegmentedControl *toolbarSegmentControl;
@property(nonatomic,strong) UILabel *balanceLbl;
@property(nonatomic,strong) UILabel *requestedbl;
@property (nonatomic,strong) ApprovalsModel *approvalsModel;


@property (nonatomic,strong) DateUdfPickerView *customDateUdfPickerView;
@property (nonatomic,strong) UITextField *activeField;
@property(nonatomic,strong)UILabel *commentsTextLbl;
@property(nonatomic,strong) UIView *statusView;

@property(nonatomic,strong)NSString *balanceValue;
@property(nonatomic,strong)NSString *requestedValue;
@property(nonatomic,strong)NSString *approverComments;

@property(nonatomic,assign) BOOL hasFullDay;
@property(nonatomic,assign) BOOL isHalfPermission;
@property(nonatomic,assign) BOOL isHourPermission;
@property(nonatomic,assign) BOOL isQuarterPermission;
@property(nonatomic,assign) BOOL isNonePermission;
@property(nonatomic,strong) NSString *previousType;
@property(nonatomic,assign) BOOL isStartDateEnableDateSelection;
@property(nonatomic,assign) BOOL isEndDateEnableDateSelection;
@property (nonatomic)       ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;

@end

@implementation TimeOffDetailsView


- (instancetype)initWithFrame:(CGRect)frame errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper*)errorBannerViewParentPresenterHelper{
    self = [super initWithFrame:frame];
    if (self) {
        self.rowObjectsArray = [[NSMutableArray alloc] init];
        self.timeOffDetailsObj = [[TimeOffObject alloc] init];
        self.fullHourArray=[NSMutableArray arrayWithObjects:RPLocalizedString(DAY, @""),RPLocalizedString(PARTIAL, @""), nil];
        self.fullDayArray=[NSMutableArray arrayWithObjects:RPLocalizedString(DAY, @""), nil];
        self.halfDayArray=[NSMutableArray arrayWithObjects:RPLocalizedString(DAY, @""),RPLocalizedString(HALF, @""), nil];
        self.quarterDayArray=[NSMutableArray arrayWithObjects:RPLocalizedString(DAY, @""),RPLocalizedString(HALF, @""),RPLocalizedString(ONEFOURTH, @""),RPLocalizedString(THREEQUARTER, @""), nil];
        self.noneDayArray=[NSMutableArray arrayWithObjects:RPLocalizedString(DAY, @""),RPLocalizedString(HALF, @""),RPLocalizedString(PARTIAL, @""), nil];
        
        TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
        self.timeOffTypesArray=[timeoffModel getAllTimeOffTypesFromDB];
        self.errorBannerViewParentPresenterHelper = errorBannerViewParentPresenterHelper;
    }
    return self;
}

-(void)setup_TimeOffView
{
    
//    if(self.screenMode == ADD_BOOKTIMEOFF)
//    {
//        self.isTypeAvailable = NO;
//    }
    if(self.screenMode == VIEW_BOOKTIMEOFF || self.screenMode == EDIT_BOOKTIMEOFF)
    {
        self.isTypeAvailable = YES;
    }
    
    if (self.timeOffDetailsTableView == nil) {
        self.timeOffDetailsTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.timeOffDetailsTableView.separatorInset = UIEdgeInsetsZero;
        //self.timeOffDetailsTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        self.timeOffDetailsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.timeOffDetailsTableView registerClass:[TimeOffDetailsCellView class] forCellReuseIdentifier:TIMEOFF_DETAILS_CELL];
        [self.timeOffDetailsTableView registerClass:[TimeSheetsUdfCell class] forCellReuseIdentifier:TIMEOFF_UDF_CELL];
        [self.timeOffDetailsTableView registerClass:[TimeOffRequestedCellView class] forCellReuseIdentifier:TIMEOFF_REQUESTED_CELL];
        self.timeOffDetailsTableView.delegate=self;
        self.timeOffDetailsTableView.dataSource=self;
        [self addSubview:self.timeOffDetailsTableView];
        [self.timeOffDetailsTableView setAccessibilityIdentifier:@"uia_timeoff_table_identifier"];
    }
    [self setTableViewInset];
}


-(void)setTableViewInset
{
    [self. errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.timeOffDetailsTableView];
 }

-(void)setUpTimeOffDetailsView:(TimeOffObject *)timeOffdetailsObj :(NavigationFlow)navigationType
{
    [self setTimeOffDetailsObj:timeOffdetailsObj];
    [self setNavigationFlow:navigationType];
    [self createRowObjects];
    [self setup_TimeOffView];
    [self createToolbar];
    [self createTableHeader];
    [self createTableFooterView];
    self.requestedValue = @"";
    self.balanceValue = @"";
    if(self.timeOffDetailsObj.isDeviceSupportedEntryConfiguration == TRUE)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if([self.timeOffDateSelectionDelegate respondsToSelector:@selector(balanceCalculationMethod:::)])
            {
                [self.timeOffDateSelectionDelegate balanceCalculationMethod:startDurationEntryTypeMode :endDurationEntryMode :self.timeOffDetailsObj];
            }
            
        });
    }
    else
    {
        TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
        NSDictionary *balanceDataDictioanry = [timeoffModel getTimeoffBalanceForMultidayBooking:self.timeOffDetailsObj.sheetId];
        if(balanceDataDictioanry!=nil && balanceDataDictioanry!=(id)[NSNull null])
        {
            [self updateBalanceValue:balanceDataDictioanry :VIEW_BOOKTIMEOFF];
        }
    }
    
    if(([[self.timeOffDetailsObj approvalStatus] isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS]) && self.screenMode == VIEW_BOOKTIMEOFF)
    {
        self.timeOffStatus = YES;
    }

}



/************************************************************************************************************
 @Function Name   : refreshTableView_WithContentOffsetReset
 @Purpose         : To refresh tableview data with latest data from service
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)reloadTableViewFromTimeOffDetails
{
    self.userInteractionEnabled = YES;
    [self.timeOffDetailsTableView reloadData];
    [self createTableFooterView];
    [self createTableHeader];
}

-(void)updateStartAndDate :(TimeOffObject *)timeOffObj
{
    self.timeOffDetailsObj = timeOffObj;
    NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
    TimeOffDetailsCellView *cell=(TimeOffDetailsCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:index];
    EntryCellDetails *detailsObj =(EntryCellDetails *)[cell rowDetailsValue];
    
    NSDate *entryDate  = [self.timeOffDetailsObj bookedStartDate];
    NSDate *endDate = [self.timeOffDetailsObj bookedEndDate];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [df setLocale:locale];
    [df setTimeZone:timeZone];
    NSString *startDateValue=nil;
    NSString *endDateValue=nil;
    [df setDateFormat:@"EEE,MMM,dd,yyyy"];
    if (entryDate != nil) {
        startDateValue=[NSString stringWithFormat:@"%@",[df stringFromDate:entryDate]];
    }
    else {
        startDateValue=RPLocalizedString(@"START DATE", @"");
    }
    if (endDate != nil) {
        endDateValue=[NSString stringWithFormat:@"%@",[df stringFromDate:endDate]];
    }
    else {
        endDateValue=RPLocalizedString(@"END DATE", @"");
    }
    [detailsObj setFieldName:startDateValue];
    
    NSIndexPath *index2 = [NSIndexPath indexPathForRow:2 inSection:0];
    TimeOffDetailsCellView *cell2=(TimeOffDetailsCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:index2];
    detailsObj =(EntryCellDetails *)[cell2 rowDetailsValue];
    [detailsObj setFieldName:endDateValue];
    [self createRowObjects];
    [self reloadTableViewFromTimeOffDetails];
    
}

#pragma mark -
#pragma mark Creating Objects for Table Header/Footer methods
/************************************************************************************************************
 @Function Name   : Create row objects
 @Purpose         : Called to create row objects for tableview.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)createTableFooterView
{
    CGRect rect;
    if(self.navigationFlow == PENDING_APPROVER_NAVIGATION || self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
    {
        rect = CGRectMake(0, 0, self.timeOffDetailsTableView.frame.size.width, FOOTER_HEIGHT_APPROVALS);
    }
    else
    {
        rect = CGRectMake(0, 0, self.timeOffDetailsTableView.frame.size.width, FOOTER_HEIGHT);
    }
    self.timeOffDetailsTablefooter = [[TimeOffDetailsTableFooterView alloc] initWithFrame:rect];
    
    NSLog(@"%@",[self.timeOffDetailsObj comments]);
    self.timeOffDetailsTablefooter.timeOffSaveDeleteDelegate = self;
    if(self.screenMode == ADD_BOOKTIMEOFF)
    {
        self.timeOffDetailsTablefooter.add_editFlow = TIMEOFF_ADD;
    }
    else
        if(self.screenMode == EDIT_BOOKTIMEOFF)
        {
            self.timeOffDetailsTablefooter.add_editFlow = TIMEOFF_EDIT;
        }
        else if(self.screenMode == VIEW_BOOKTIMEOFF)
        {
            self.timeOffDetailsTablefooter.add_editFlow = TIMEOFF_VIEW;
        }
    //self.timeOffDetailsTablefooter.approvalsDelegate = self.approvalDelegate;
    self.timeOffDetailsTablefooter.approvalsDelegate = self.approvalDelegate;
    self.timeOffDetailsTablefooter.navigationFlow = self.navigationFlow;
    self.timeOffDetailsTablefooter.isEditAcess = self.isEditAccess;
    self.timeOffDetailsTablefooter.isDeleteAcess = self.isDeleteAccess;
    self.timeOffDetailsTablefooter.timeOffDetailsViewControllerDelegate  = self;
    if(self.navigationFlow == PENDING_APPROVER_NAVIGATION)
    {
        self.timeOffDetailsTablefooter.approvalsModuleName = APPROVALS_PENDING_TIMEOFF_MODULE;
    }
    else if(self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
    {
        self.timeOffDetailsTablefooter.approvalsModuleName = APPROVALS_PREVIOUS_TIMEOFF_MODULE;
    }
    [self.timeOffDetailsTablefooter setUpTimeOffTableFooterView:self.timeOffDetailsObj :@"" :self.navigationFlow :@""];
    [self.timeOffDetailsTableView setTableFooterView:self.timeOffDetailsTablefooter];
}

-(void)createTableHeader
{
    self.statusView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    
    UIButton *viewButton=[UIButton buttonWithType:UIButtonTypeCustom];
    viewButton.backgroundColor=[UIColor clearColor];
    viewButton.frame=CGRectMake(0, 0, self.frame.size.width, 44);
    [viewButton setUserInteractionEnabled:NO];
    NSString *statusStr=nil;

    NSMutableArray *arrayFromDB=nil;
    NSString *colorStr=nil;
    NSString *statsuStrColor = nil;
    
    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    if (self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION || self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
    {
        arrayFromDB=[timeoffModel getAllApprovalHistoryForTimeoffUri:[self.timeOffDetailsObj sheetId]];
    }
    else if(self.navigationFlow == PENDING_APPROVER_NAVIGATION || self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
    {
        ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPendingTimeoffApprovalFromDBForTimeoff:[self.timeOffDetailsObj sheetId]];
            
        }
        else if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMEOFF_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPreviousTimeoffApprovalFromDBForTimeoff:[self.timeOffDetailsObj sheetId]];
        }
    }
    
    if ([[self.timeOffDetailsObj approvalStatus] isEqualToString:WAITING_FOR_APRROVAL_STATUS ])
    {
        statusStr=RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
        colorStr=@"#FCC58D";
        statsuStrColor = @"#333333";
    }
    else if ([[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS ]) {
        statusStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
        colorStr=@"#86BC3B";
        statsuStrColor = @"#333333";
    }
    else if ([[self.timeOffDetailsObj approvalStatus] isEqualToString:REJECTED_STATUS ]){
        statusStr=RPLocalizedString(REJECTED_STATUS,@"");
        colorStr=@"#F4694B";
        statsuStrColor = @"#FFFFFF";
    }
    else
    {
        if (self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION || self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
        {
            statusStr=RPLocalizedString(NOT_SUBMITTED_STATUS, @"");
            colorStr=@"#DADADA";
            statsuStrColor = @"#333333";
        }
    }
    
    NSMutableAttributedString *statusAttributedStr= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",statusStr]];

    if ([arrayFromDB count]>0)
    {
        UIImage *approcalIcon = [Util thumbnailImage:Approval_Comments_Img];
        NSTextAttachment *attachment = [NSTextAttachment new];
        [attachment setImage:approcalIcon];
        CGFloat attachmentPadding = 2;
        attachment.bounds = CGRectMake(0, -attachmentPadding, approcalIcon.size.width, approcalIcon.size.height);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
        [statusAttributedStr appendAttributedString:space];
        [statusAttributedStr appendAttributedString:attachmentString];
        [viewButton addTarget:self action:@selector(approvalCommentDetailAction) forControlEvents:UIControlEventTouchUpInside];
        [viewButton setUserInteractionEnabled:YES];
    }
    
    [statusAttributedStr addAttribute:NSFontAttributeName
                                value:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]
                                range:NSMakeRange(0, statusAttributedStr.length)];
    [viewButton setAttributedTitle:statusAttributedStr forState:UIControlStateNormal];
    
    if (colorStr!=nil)
    {
        [self.statusView setBackgroundColor:[Util colorWithHex:colorStr alpha:1]];
        
    }
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, self.width, 1)];
    lineView.backgroundColor = [UIColor grayColor];
    if (colorStr!=nil)
    {
        [self.statusView addSubview:lineView];
    }
    
    [self.statusView addSubview:viewButton];
    
    if (self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION || self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
    {
        if (self.screenMode==VIEW_BOOKTIMEOFF)
        {
            [self.timeOffDetailsTableView setTableHeaderView:self.statusView];
        }
        else if(self.screenMode==EDIT_BOOKTIMEOFF)
        {
            self.timeOffDetailsTableView.tableHeaderView = nil;
        }
    }
    else
    {
        UIView *headrView=[[UIView alloc]init];
        
        ApprovalTablesHeaderView *headerView=[[ApprovalTablesHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 55.0 ) withStatus:self.sheetStatus userName:self.userName dateString:self.timeoffType labelText:self.dueDate withApprovalModuleName:self.approvalsModuleName isWidgetTimesheet:NO withErrorsAndWarningView:nil];
        
        ApprovalsScrollViewController *scrollCtrl=(ApprovalsScrollViewController *)self.timeOffViewDelegate;
        if (!scrollCtrl.hasPreviousTimeSheets) {
            headerView.previousButton.hidden=TRUE;
        }
        if (!scrollCtrl.hasNextTimeSheets) {
            headerView.nextButton.hidden=TRUE;
        }
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            headerView.countLbl.text=[NSString stringWithFormat:@"%li of %li",(long)self.currentNumberOfView,(long)self.totalNumberOfView];
        }
        else
        {
            headerView.countLbl.text=@"";
        }
        headerView.delegate=self;
        CGRect frame=self.statusView.frame;
        frame.origin.y=headerView.frame.origin.y+headerView.frame.size.height;
        self.statusView.frame=frame;
        headrView.frame=CGRectMake(0, 0, 360,frame.origin.y+frame.size.height);
        
        [headrView addSubview:headerView];
        [headrView addSubview:self.statusView];
        [self.timeOffDetailsTableView setTableHeaderView:headrView];
        
    }
    
}


#pragma mark Table DataSource methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        cell.preservesSuperviewLayoutMargins = NO;
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    cellsArray=[NSMutableArray array];
    
    return [self.rowObjectsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row==1 || indexPath.row==2)
    {
        if (indexPath.row==1)
        {
            if (startDurationEntryTypeMode==PARTIALDAYMODE)
            {
                return (ROW_HEIGHT*3)-5;
            }
            if(startDurationEntryTypeMode==DAYMODE){
                return ROW_HEIGHT;
            }
            else {
                return (ROW_HEIGHT*3)-5;
            }
        }
        else {
            if (endDurationEntryMode==PARTIALDAYMODE)
            {
                return (ROW_HEIGHT*3)-5;
            }
            if(endDurationEntryMode==DAYMODE){
                
                return ROW_HEIGHT-1;
            }
            else {
                return (ROW_HEIGHT*3)-5;
            }
        }
    }
    else if(indexPath.row==3)
    {
        if ([self.balanceTrackingOption isEqualToString:TIME_OFF_AVAILABLE_KEY] && ![[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS ])
            return BALANCE_ROW_HEIGHT;
        else
            return  46;
    }
    else if(indexPath.row==4)
    {
        if([[self timeOffDetailsObj] comments]!=nil && ![[[self timeOffDetailsObj] comments] isKindOfClass:[NSNull class]])
        {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[[self timeOffDetailsObj] comments]];
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];
            CGSize size = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            return size.height + ROW_HEIGHT;
        }
        else
        {
            return ROW_HEIGHT;
        }
    }
    else if(indexPath.row>4)
    {
        return UDF_ROW_HEIGHT;
    }
    return ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier=nil;
    if(indexPath.row<3)
        CellIdentifier=TIMEOFF_DETAILS_CELL;
    else if(indexPath.row>=3 && indexPath.row<5)
        CellIdentifier=TIMEOFF_REQUESTED_CELL;
    else if(indexPath.row>=5)
        CellIdentifier=TIMEOFF_UDF_CELL;
    
    
    
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    if(indexPath.row==0 || indexPath.row==1 || indexPath.row==2)
    {
        NSLog(@"%ld",(long)indexPath.row);
        TimeOffDetailsCellView *cell = (TimeOffDetailsCellView *)[tableView dequeueReusableCellWithIdentifier:[[NSString alloc] init]];
        if (cell == nil) {
            cell = [[TimeOffDetailsCellView  alloc] initWithFrame:self.frame Style:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        cell.timeOffBalanceCalculationDelegate=self;
        NSString *timeStr=nil;
        NSString *hours=nil;
        id fieldName = nil;
        id fieldValue = nil;
        self.rowDetails = (EntryCellDetails *)[self.rowObjectsArray objectAtIndex:indexPath.row];
        [(TimeOffDetailsCellView *)cell setTimeOffCellDelegate:self];
        if (indexPath.row == 0) {
            fieldName =  [self.rowDetails fieldName];
            fieldValue = [self.rowDetails fieldValue];
            if (fieldValue==nil)
            {
                fieldValue=RPLocalizedString(@"Select", @"Select") ;
            }
        }
        else {
            
            fieldName=[self.rowDetails fieldName];
            fieldValue = [self.rowDetails fieldValue];
        }
        if (indexPath.row==1 || indexPath.row==2)
        {
            
            if (indexPath.row==1) {
                timeStr=[self.timeOffDetailsObj startTime];
                hours=[self.timeOffDetailsObj startNumberOfHours];
            }
            else if(indexPath.row==2){
                timeStr=[self.timeOffDetailsObj endTime];
                hours=[self.timeOffDetailsObj endNumberOfHours];
            }
        }
        [(TimeOffDetailsCellView *)cell setSelectedTag:indexPath.row];
        [(TimeOffDetailsCellView *)cell setRowDetailsValue:self.rowDetails];
        [(TimeOffDetailsCellView *)cell setIsStatus:self.isStatusView];
        [(TimeOffDetailsCellView *)cell createCellLayoutWithParamsfiledname:fieldName fieldbutton:fieldValue time:timeStr hours:hours rowHeight:cellRect.size.height];
        [[(TimeOffDetailsCellView *)cell fieldButton] addTarget:self action:@selector(actionForPicker: withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [[(TimeOffDetailsCellView *)cell timeEntryButton] addTarget:self action:@selector(handleTimeEntry:) forControlEvents:UIControlEventTouchUpInside];
        BOOL isSameday = [self checkForStartAndEndDate];
        
        [[(TimeOffDetailsCellView *)cell HourEntryField] setHidden:NO];
        [[(TimeOffDetailsCellView *)cell timeEntryButton] setHidden:NO];
        [[(TimeOffDetailsCellView *)cell setHourLb] setHidden:NO];
        [[(TimeOffDetailsCellView *)cell setTimeLb] setHidden:NO];
        [[(TimeOffDetailsCellView *)cell rightLb] setHidden:NO];
        [[(TimeOffDetailsCellView *)cell fieldButton] setHidden:NO];
        
        if (indexPath.row==1 && self.add_Edit == TIMEOFF_ADD && ([self.timeOffDetailsObj bookedStartDate]==nil || [[self.timeOffDetailsObj bookedStartDate]isKindOfClass:[NSNull class]]))
        {
            [(TimeOffDetailsCellView *)cell fieldButton].hidden=YES;
            [(TimeOffDetailsCellView *)cell rightLb].hidden=NO;
            [[(TimeOffDetailsCellView *)cell rightLb] setText:@"-"];
        }
        
        if(indexPath.row==1 && startDurationEntryTypeMode==DAYMODE)
        {
            [[(TimeOffDetailsCellView *)cell HourEntryField] setHidden:YES];
            [[(TimeOffDetailsCellView *)cell timeEntryButton] setHidden:YES];
            [[(TimeOffDetailsCellView *)cell setHourLb] setHidden:YES];
            [[(TimeOffDetailsCellView *)cell setTimeLb] setHidden:YES];
        }
        if(indexPath.row==1 && (startDurationEntryTypeMode==HALFDAYMODE || startDurationEntryTypeMode==ONEFOURTHDAYMODE || startDurationEntryTypeMode==THREEFOURTHDAYMODE))
        {
            [[(TimeOffDetailsCellView *)cell HourEntryField] setHidden:YES];
            [[(TimeOffDetailsCellView *)cell timeEntryButton] setHidden:NO];
            [[(TimeOffDetailsCellView *)cell setHourLb] setHidden:YES];
            [[(TimeOffDetailsCellView *)cell setTimeLb] setHidden:NO];
        }
        
        if(indexPath.row==2 && endDurationEntryMode==DAYMODE)
        {
            if(isSameday==YES)
            {
                [[(TimeOffDetailsCellView *)cell HourEntryField] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell timeEntryButton] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell setHourLb] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell setTimeLb] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell rightLb] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell fieldButton] setHidden:YES];
            }
            else
            {
                [[(TimeOffDetailsCellView *)cell HourEntryField] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell timeEntryButton] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell setHourLb] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell setTimeLb] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell rightLb] setHidden:YES];
                [[(TimeOffDetailsCellView *)cell fieldButton] setHidden:NO];
            }
            
        }
        if(indexPath.row==2 && (endDurationEntryMode==HALFDAYMODE || endDurationEntryMode==ONEFOURTHDAYMODE || endDurationEntryMode==THREEFOURTHDAYMODE))
        {
            [[(TimeOffDetailsCellView *)cell HourEntryField] setHidden:YES];
            [[(TimeOffDetailsCellView *)cell timeEntryButton] setHidden:NO];
            [[(TimeOffDetailsCellView *)cell setHourLb] setHidden:YES];
            [[(TimeOffDetailsCellView *)cell setTimeLb] setHidden:NO];
            [[(TimeOffDetailsCellView *)cell rightLb] setHidden:YES];
            [[(TimeOffDetailsCellView *)cell fieldButton] setHidden:NO];
        }
        if (indexPath.row==2 && self.add_Edit == TIMEOFF_ADD && ([self.timeOffDetailsObj bookedEndDate]==nil || [[self.timeOffDetailsObj bookedEndDate]isKindOfClass:[NSNull class]]))
        {
            [(TimeOffDetailsCellView *)cell fieldButton].hidden=YES;
            [(TimeOffDetailsCellView *)cell rightLb].hidden=NO;
            [[(TimeOffDetailsCellView *)cell rightLb] setText:@"-"];
        }
        if(self.screenMode == ADD_BOOKTIMEOFF)
        {
            if (self.isTypeAvailable==NO && indexPath.row!=0) {
                cell.userInteractionEnabled =NO;
            }
            else
            {
                cell.userInteractionEnabled = YES;
            }
        }
        else if(self.screenMode == EDIT_BOOKTIMEOFF || self.screenMode == VIEW_BOOKTIMEOFF)
        {
            if(self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
            {
                cell.userInteractionEnabled =NO;
            }
            else
            {
                if (self.isEditClicked==NO && ![[self.timeOffDetailsObj approvalStatus] isEqualToString:REJECTED_STATUS]) {
                    cell.userInteractionEnabled =NO;
                }
                else
                {
                    cell.userInteractionEnabled =YES;
                }
            }
        }
        if (timeStr==nil || [timeStr isKindOfClass:[NSNull class]]||[timeStr isEqualToString:@""])
        {
            [[(TimeOffDetailsCellView *)cell timeEntryButton] setTitle:RPLocalizedString(@"Select Time", @"") forState:UIControlStateNormal];
        }

        [cellsArray addObject:cell];
        
        return cell;
    }
    else if (indexPath.row==3||indexPath.row==4)
    {
        TimeOffRequestedCellView *cell = (TimeOffRequestedCellView *)[tableView dequeueReusableCellWithIdentifier:[[NSString alloc] init]];
        if (cell == nil) {
            cell = [[TimeOffRequestedCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        NSString *type = @"";
        if(indexPath.row==3)
        {
            type = @"Requested";
            [cell.contentView setBackgroundColor:[Util colorWithHex:@"#EEEEEE" alpha:1]];
        }
        else
        {
            type = @"comments";
        }

        [cell createRequestedBalanceCellView:self.balanceTrackingOption :type :[self.timeOffDetailsObj comments] :[self.timeOffDetailsObj approvalStatus] ];
        if(indexPath.row==3)
        {

            NSString *timeOffDisplayFormatUri=self.timeOffDetailsObj.timeOffDisplayFormatUri;

            if (self.timeOffDetailsObj.typeIdentity != nil && ![self.timeOffDetailsObj.typeIdentity isKindOfClass:[NSNull class]]) {
                
                if (timeOffDisplayFormatUri!=nil && ![timeOffDisplayFormatUri isKindOfClass:[NSNull class]])
                {
                    if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI])
                    {
                        if ([self.timeOffDetailsObj totalTimeOffDays]!=nil &&![[self.timeOffDetailsObj totalTimeOffDays]isKindOfClass:[NSNull class]])
                        {
                            if (fabs([self.timeOffDetailsObj.totalTimeOffDays newDoubleValue])!=1.00) {
                                cell.requestedValueLbl.text=[NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.totalTimeOffDays,RPLocalizedString(@"days", @"")];
                            }
                            else{
                                cell.requestedValueLbl.text=[NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.totalTimeOffDays,RPLocalizedString(@"day", @"")];
                            }
                        }
                        else {
                            cell.requestedValueLbl.text=RPLocalizedString(@"N/A", @" ") ;
                            if (![[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS ])
                                cell.balanceValueLbl.text=RPLocalizedString(@"N/A", @" ") ;
                        }
                    }
                    
                    else if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_HOURS_FORMAT_URI])
                    {
                        if ([self.timeOffDetailsObj numberOfHours]!=nil &&![[self.timeOffDetailsObj numberOfHours]isKindOfClass:[NSNull class]])
                        {
                            if (fabs([self.timeOffDetailsObj.numberOfHours newDoubleValue])!=1.00) {
                                cell.requestedValueLbl.text=[NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.numberOfHours,RPLocalizedString(@"hours", @"")];
                            }
                            else{
                                cell.requestedValueLbl.text=[NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.numberOfHours,RPLocalizedString(@"hour", @"")];
                            }
                        }
                        else {
                            cell.requestedValueLbl.text=RPLocalizedString(@"N/A", @" ") ;
                            if (![[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS ])
                                cell.balanceValueLbl.text=RPLocalizedString(@"N/A", @" ") ;
                        }
                    }
                }
            }
            else{
                cell.requestedValueLbl.text=RPLocalizedString(@"N/A", @" ") ;
                if (![[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS ])
                    cell.balanceValueLbl.text=RPLocalizedString(@"N/A", @" ") ;
            }


            if([self.balanceTrackingOption isEqualToString:TIME_OFF_AVAILABLE_KEY] && ![[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS ])
            {
                if(self.balanceValue!=nil && ![self.balanceValue isKindOfClass:[NSNull class]] && ![self.balanceValue isEqualToString:@""])
                {
                    cell.balanceValueLbl.text = [NSString stringWithFormat:@"%@",self.balanceValue];
                }
            }
        }
        
        if(indexPath.row==3)
        {
            cell.userInteractionEnabled = NO;
        }
        if(indexPath.row==4)
        {
            if(self.screenMode == ADD_BOOKTIMEOFF)
            {
                if (self.isTypeAvailable==NO && indexPath.row!=0) {
                    cell.userInteractionEnabled =NO;
                }
            }
            else if(self.screenMode == EDIT_BOOKTIMEOFF || self.screenMode == VIEW_BOOKTIMEOFF)
            {
                if(self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
                {
                    cell.userInteractionEnabled =NO;
                }
                else
                {
                if (self.isEditClicked==NO && ![[self.timeOffDetailsObj approvalStatus] isEqualToString:REJECTED_STATUS]) {
                    cell.userInteractionEnabled =NO;
                }
                else
                {
                    cell.userInteractionEnabled =YES;
                }
                }
            }
        }
        
         [cellsArray addObject:cell];
        
        return cell;
    }
    else
    {
        self.timeOffDetailsObj.canEdit = YES;
        
        UdfObject *_udfObject=(UdfObject *)[self.rowObjectsArray objectAtIndex:indexPath.row];
        TimeSheetsUdfCell *cell = (TimeSheetsUdfCell *)[tableView dequeueReusableCellWithIdentifier:[[NSString alloc] init]];
        if (cell == nil) {
            cell = [[TimeSheetsUdfCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }

        [cell setUdfActionDelegate:self];
        [cell createTimesheetUdfViewCellWithUdfObject:_udfObject withTimesheetListObject:nil];

        if(self.screenMode == ADD_BOOKTIMEOFF)
        {
            if (self.isTypeAvailable==NO && indexPath.row!=0) {
                cell.userInteractionEnabled =NO;
            }
        }
        else if(self.screenMode == EDIT_BOOKTIMEOFF || self.screenMode == VIEW_BOOKTIMEOFF)
        {
            if(self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
            {
                cell.userInteractionEnabled =NO;
            }
            else
            {
                if (self.isEditClicked==NO && ![[self.timeOffDetailsObj approvalStatus] isEqualToString:REJECTED_STATUS]) {
                    self.timeOffDetailsObj.canEdit = NO;
                    
                    if (!([_udfObject udfType]==UDF_TYPE_TEXT))
                    {
                        cell.userInteractionEnabled =NO;
                    }
                    else
                    {
                        cell.userInteractionEnabled =YES;
                    }
                }
                else
                {
                    self.timeOffDetailsObj.canEdit = YES;
                    cell.userInteractionEnabled =YES;
                }
            }
        }
        
         [cellsArray addObject:cell];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self endEditing:YES];
    [self _removeCustomDateUdfPickerViewFromTheView];
    self.selectedIndex = indexPath;
    if(indexPath.row==0)
    {
        [self handleDidSelectRowSelection:indexPath :nil];
    }
    else if(indexPath.row==1 || indexPath.row==2)
    {
        if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(didSelectDateSelection:timeOffObj:)]) {
            [self.timeOffDateSelectionDelegate didSelectDateSelection:indexPath timeOffObj:self.timeOffDetailsObj];
        }
    }
    else if(indexPath.row==4)
    {
        if([self.timeOffDateSelectionDelegate respondsToSelector:@selector(timeOffCommentsNavigation)])
        {
            [self.timeOffDateSelectionDelegate timeOffCommentsNavigation];
        }
    }
    if (indexPath.row !=0)
        [self doneDataPickerAction];
}

#pragma mark -
#pragma mark Header method
/************************************************************************************************************
 @Function Name   : Table header tapped
 @Purpose         : Called when user taps on the table header
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/
-(void)approvalCommentDetailAction
{
    if([self.timeOffDateSelectionDelegate respondsToSelector:@selector(approvalCommentDetailAction)])
    {
        [self.timeOffDateSelectionDelegate approvalCommentDetailAction];
    }
}

#pragma mark -
#pragma mark Toolbar methods
/************************************************************************************************************
 @Function Name   : createToolbar
 @Purpose         : Called to create toolbar with done button.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/
- (void)createToolbar {
    if(self.toolbar)
    {
        [self.toolbar removeFromSuperview];
        self.toolbar=nil;
    }
    UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height, 320.0, 45.0)];
    self.toolbar=temptoolbar;
    self.datePicker.backgroundColor=[UIColor whiteColor];
    UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
    [self.toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [self.toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
    [self.toolbar setBarStyle:UIBarStyleBlackTranslucent];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(_doneButtonAction:)];
    UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:nil
                                                                                 action:nil];
    [self.toolbarSegmentControl setFrame:ToolbarSegmentControlFrame];
    [self.toolbarSegmentControl setMomentary:YES];
    [self.toolbarSegmentControl setTintColor:[UIColor clearColor]];
    
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    
    [self.toolbar setItems:toolArray];
    [self addSubview:self.toolbar];
    [self.toolbar addSubview:self.toolbarSegmentControl];
    [self.toolbar setHidden:YES];
}

- (void)showToolBarWithAnimation:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
    }
    
    [self.toolbar setHidden:NO];
    float keyBoardHeight = 260.0;
    CGRect frame = self.toolbar.frame;
    frame.origin.y = self.frame.size.height - keyBoardHeight;
    self.toolbar.frame = frame;
    
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)hideToolBarWithAnimation:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
    }
    
    [self.toolbar setHidden:YES];
    CGRect frame = self.toolbar.frame;
    frame.origin.y = self.frame.size.height;
    self.toolbar.frame = frame;
    
    if (animated) {
        [UIView commitAnimations];
    }
}


- (void)_doneButtonAction:(id)sender
{
    [self endEditing:YES];
}

-(void)handleTimeEntry:(id)sender
{
    [self endEditing:YES];
    [self _removeCustomDateUdfPickerViewFromTheView];
    [self doneDataPickerAction];
    if(self.datePicker!=nil)
    {
        [self.datePicker removeFromSuperview];
        [self.toolbar removeFromSuperview];
    }
    if([sender tag]==1 || [sender tag]==2)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"hh:mm a"];
        NSString * dateStr=[dateFormatter stringFromDate:[NSDate date]];

        NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:[sender tag] inSection:0];
        if([sender tag]==1)
        {
            [self.timeOffDetailsTableView scrollToRowAtIndexPath:tmpIndexpath
                                 atScrollPosition:UITableViewScrollPositionTop
                                         animated:YES];
            [self.timeOffDetailsObj setStartTime:dateStr];
        }
        else if([sender tag]==2)
        {
            [self.timeOffDetailsTableView scrollToRowAtIndexPath:tmpIndexpath
                                                atScrollPosition:UITableViewScrollPositionTop
                                                        animated:YES];
            [self.timeOffDetailsObj setEndTime:dateStr];
        }
        
        TimeOffDetailsCellView *cell=(TimeOffDetailsCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:tmpIndexpath];
        if (cell==nil || [cell isKindOfClass:[NSNull class]])
        {
            cell = (TimeOffDetailsCellView *)[self tableView:self.timeOffDetailsTableView cellForRowAtIndexPath:tmpIndexpath];
        }
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"hh:mm a"];
        NSString * localeDateStr=[dateFormatter stringFromDate:[NSDate date]];

        [[(TimeOffDetailsCellView *)cell timeEntryButton] setTitle:localeDateStr forState:UIControlStateNormal];
        [self calculateBalanceAfterHoursEntered:nil :0];
    }
    UIDatePicker *temppickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker=temppickerView;
    [self.datePicker setFrame:CGRectMake(0, self.frame.size.height-206, self.frame.size.width, PICKER_HEIGHT)];
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.datePicker setDatePickerMode:UIDatePickerModeTime];
    self.datePicker.hidden = NO;
    self.datePicker.tag = [sender tag];
    [self.datePicker addTarget:self  action:@selector(handleChangeinTime:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.datePicker];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneDatePickerAction)];
    self.doneButton.tag = [sender tag];
    self.spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (self.toolbar)
    {
        [self.toolbar removeFromSuperview];
        self.toolbar=nil;
    }
    UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.frame.size.height-251,self.frame.size.width,Toolbar_Height)];
    self.toolbar=temptoolbar;
    self.datePicker.backgroundColor=[UIColor whiteColor];
    self.doneButton.tintColor=RepliconStandardWhiteColor;
    UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
    [self.toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [self.toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
    [self.toolbar setBarStyle:UIBarStyleBlackTranslucent];
    NSArray *toolArray = [NSArray arrayWithObjects:self.spaceButton, self.doneButton,nil];
    [self.toolbar setItems:toolArray];
    [self addSubview:self.toolbar];
}

-(void)handleDidSelectRowSelection :(NSIndexPath*)selectedButtonIndex :(id)sender
{
    [self endEditing:YES];
    if(selectedButtonIndex.row==0 || selectedButtonIndex.row==1 ||selectedButtonIndex.row==2)
    {
        if(self.dataPicker!=nil)
        {
            [self.dataPicker removeFromSuperview];
            [self.toolbar removeFromSuperview];
        }
        //CGRect screenRect = [[UIScreen mainScreen] bounds];
        UIPickerView *temppickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [temppickerView setAccessibilityIdentifier:@"uia_time_off_type_picker_identifier"];
        self.dataPicker=temppickerView;
        
        if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(hideTabBar:)]) {
            [self.timeOffDateSelectionDelegate hideTabBar:YES];
        }
        //CGSize pickerSize = [self.dataPicker sizeThatFits:CGSizeZero];
        [self.dataPicker setFrame: CGRectMake(0, self.frame.size.height-Data_Picker_Height, self.frame.size.width, PICKER_HEIGHT)];
        self.dataPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.dataPicker.delegate = self;
        self.dataPicker.dataSource = self;
        self.dataPicker.showsSelectionIndicator = YES;
        self.dataPicker.hidden = NO;
        [self addSubview:self.dataPicker];

        UIBarButtonItem *tmpDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneDataPickerAction)];
        self.doneButton=tmpDoneButton;
        [self.doneButton setAccessibilityLabel:@"uia_timeoff_done_button_identifier"];

        self.doneButton.tag = selectedButtonIndex.row;
        UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.spaceButton=tmpSpaceButton;
        if (self.toolbar)
        {
            self.toolbar=nil;
        }
        if (self.toolbar == nil) {
            UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.frame.size.height-Data_Picker_Height-45,self.frame.size.width,Toolbar_Height)];
            self.toolbar=temptoolbar;
        }
        self.isTypeAvailable = YES;
        self.dataPicker.backgroundColor=[UIColor whiteColor];
        self.doneButton.tintColor=RepliconStandardWhiteColor;
        UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
        [self.toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
        [self.toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
        [self.toolbar setBarStyle:UIBarStyleBlackTranslucent];
        NSArray *toolArray = [NSArray arrayWithObjects:self.spaceButton, self.doneButton,nil];
        [self.toolbar setItems:toolArray];
        [self addSubview:self.toolbar];
        [self.toolbar setAccessibilityLabel:@"uia_timeoff_toobar_identifier"];
        self.isShowingPicker = YES;
        if(selectedButtonIndex.row==0)
        {
            int selectedIndexNo = [self getSelectedDayTypeRowIndex:selectedButtonIndex];
            if(selectedIndexNo > -1)
            {
                [self pickerView:self.dataPicker didSelectRow:selectedIndexNo inComponent:0];
                [self.dataPicker selectRow:selectedIndexNo inComponent:0 animated:YES];
            }
            else
            {
                [self pickerView:self.dataPicker didSelectRow:0 inComponent:0];
                [self.dataPicker selectRow:0 inComponent:0 animated:YES];
            }
        }
    }
}
#pragma mark -
#pragma mark Picker methods
/************************************************************************************************************
 @Function Name   : Picker Actions
 @Purpose         : Handle Picker Actions
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)doneDatePickerAction
{
    if (self.datePicker) {
        [self.datePicker removeFromSuperview];
        [self.toolbar setHidden:YES];
        [self endEditing:YES];
    }
}

-(void)removePickerWhileEditing
{
    [self.datePicker removeFromSuperview];
    [self.dataPicker removeFromSuperview];
    [self.toolbar setHidden:YES];
    if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(hideTabBar:)]) {
        [self.timeOffDateSelectionDelegate hideTabBar:NO];
    }
    self.isShowingPicker = NO;
}

-(void)removeDatePickerWhileEditing
{
    [self _removeCustomDateUdfPickerViewFromTheView];
}

-(void)handleChangeinTime:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];;
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString * dateStr=[dateFormatter stringFromDate:[sender date]];
    if([sender tag]==1)
    {
        [self.timeOffDetailsObj setStartTime:dateStr];
    }
    else if([sender tag]==2)
    {
        [self.timeOffDetailsObj setEndTime:dateStr];
    }
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString * localeDateStr=[dateFormatter stringFromDate:[sender date]];
    
    NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:[sender tag] inSection:0];
    TimeOffDetailsCellView *cell=(TimeOffDetailsCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:tmpIndexpath];
    if (cell==nil || [cell isKindOfClass:[NSNull class]])
    {
        cell = (TimeOffDetailsCellView *)[self tableView:self.timeOffDetailsTableView cellForRowAtIndexPath:tmpIndexpath];
    }
    [[(TimeOffDetailsCellView *)cell timeEntryButton] setTitle:localeDateStr forState:UIControlStateNormal];
    [self calculateBalanceAfterHoursEntered:nil :0];
}

-(void)doneDataPickerAction
{
    self.isTypeAvailable = YES;
    if (self.isShowingPicker) {
        [self.dataPicker removeFromSuperview];
        [self.toolbar setHidden:YES];
        [self endEditing:YES];
        TimeOffDetailsCellView *cell=(TimeOffDetailsCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
        if ([cell isKindOfClass:[TimeOffDetailsCellView class]]) {
            EntryCellDetails *detailsObj =(EntryCellDetails *)[cell rowDetailsValue];
            [self changeDayTypeAction:[detailsObj fieldValue]];
        }
        [self reloadTableViewFromTimeOffDetails];

        if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(hideTabBar:)]) {
            [self.timeOffDateSelectionDelegate hideTabBar:NO];
        }

    }
    self.isShowingPicker = NO;
}

-(void)changeDayTypeAction:(NSString *)dayTypeValue
{
    if(self.selectedIndex.row!=0)
    {
        TimeOffDetailsCellView *cell=(TimeOffDetailsCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
        if (cell==nil || [cell isKindOfClass:[NSNull class]])
        {
            cell = (TimeOffDetailsCellView *)[self tableView:self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
        }
        NSArray *temp=[NSArray arrayWithObject:self.selectedIndex];
        [self.timeOffDetailsTableView beginUpdates];
        [self.timeOffDetailsTableView deleteRowsAtIndexPaths:temp withRowAnimation:UITableViewRowAnimationNone];
        
        EntryCellDetails *detailsObj =(EntryCellDetails *)[cell rowDetailsValue];
        [detailsObj setFieldValue:dayTypeValue];
        if (self.selectedIndex.row==1)
        {
            if ([dayTypeValue isEqualToString:RPLocalizedString(DAY, @"") ])
            {
                [self.timeOffDetailsObj setStartNumberOfHours:nil];
                [self.timeOffDetailsObj setStartTime:nil];
                startDurationEntryTypeMode=DAYMODE;
                self.timeOffDetailsObj.startDurationEntryType=FULLDAY_DURATION_TYPE_KEY;
            }
            else if ([dayTypeValue isEqualToString:RPLocalizedString(PARTIAL, @"")]){
                startDurationEntryTypeMode=PARTIALDAYMODE;
                [self.timeOffDetailsObj setStartNumberOfHours:nil];
                [self.timeOffDetailsObj setStartTime:nil];
                self.timeOffDetailsObj.startDurationEntryType=PARTIAL;
            }
            else{
                [self.timeOffDetailsObj setStartNumberOfHours:nil];
                if ([dayTypeValue isEqualToString:RPLocalizedString(ONEFOURTH, @"")])
                {
                    startDurationEntryTypeMode=ONEFOURTHDAYMODE;
                    self.timeOffDetailsObj.startDurationEntryType=QUARTERDAY_DURATION_KEY;
                }
                else if ([dayTypeValue isEqualToString:RPLocalizedString(THREEQUARTER, @"")])
                {
                    startDurationEntryTypeMode=THREEFOURTHDAYMODE;
                    self.timeOffDetailsObj.startDurationEntryType=THREEQUARTERDAY_DURATION_KEY;
                }
                else if ([dayTypeValue isEqualToString:RPLocalizedString(HALF, @"")])
                {
                    startDurationEntryTypeMode=HALFDAYMODE;
                    self.timeOffDetailsObj.startDurationEntryType=HALFDAY_DURATION_TYPE_KEY;
                }
            }
        }
        else{
            if ([dayTypeValue isEqualToString:RPLocalizedString(DAY, @"")])
            {
                [self.timeOffDetailsObj setEndNumberOfHours:nil];
                [self.timeOffDetailsObj setEndTime:nil];
                endDurationEntryMode=DAYMODE;
                self.timeOffDetailsObj.endDurationEntryType=FULLDAY_DURATION_TYPE_KEY;
            }
            else if ([dayTypeValue isEqualToString:RPLocalizedString(PARTIAL, @"")]){
                endDurationEntryMode=PARTIALDAYMODE;
                [self.timeOffDetailsObj setEndNumberOfHours:nil];
                [self.timeOffDetailsObj setEndTime:nil];
                self.timeOffDetailsObj.endDurationEntryType=PARTIAL;
            }
            else{
                [self.timeOffDetailsObj setEndNumberOfHours:nil];
                if ([dayTypeValue isEqualToString:RPLocalizedString(ONEFOURTH, @"")])
                {
                    endDurationEntryMode=ONEFOURTHDAYMODE;
                    self.timeOffDetailsObj.endDurationEntryType=QUARTERDAY_DURATION_KEY;
                }
                else if ([dayTypeValue isEqualToString:RPLocalizedString(THREEQUARTER, @"")])
                {
                    endDurationEntryMode=THREEFOURTHDAYMODE;
                    self.timeOffDetailsObj.endDurationEntryType=THREEQUARTERDAY_DURATION_KEY;
                }
                else if ([dayTypeValue isEqualToString:RPLocalizedString(HALF, @"")])
                {
                    endDurationEntryMode=HALFDAYMODE;
                    self.timeOffDetailsObj.endDurationEntryType=HALFDAY_DURATION_TYPE_KEY;
                }
            }
        }
        
        [self.timeOffDetailsTableView insertRowsAtIndexPaths:temp withRowAnimation:UITableViewRowAnimationNone];
        [self.timeOffDetailsTableView endUpdates];
    }
    [self calculateBalanceAfterHoursEntered:nil :0];
    
}

-(void)updateFieldAtIndex:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue{
    TimeOffDetailsCellView *cell=(TimeOffDetailsCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:indexPath];
    
    if (cell==nil || [cell isKindOfClass:[NSNull class]])
    {
        cell = (TimeOffDetailsCellView *)[self tableView:self.timeOffDetailsTableView cellForRowAtIndexPath:indexPath];
    }
    
    EntryCellDetails *detailsObj =(EntryCellDetails *)[cell rowDetailsValue];
    [detailsObj setFieldValue:selectedValue];
    [[(TimeOffDetailsCellView *)cell rightLb] setText:selectedValue];
    [self updatePolicyKeysForTimeOffTypes:self.policyKey];
    if (![self.previousType isEqualToString:selectedValue])
    {
        
        NSIndexPath *startDayRowindexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        TimeOffDetailsCellView *startDaycell=(TimeOffDetailsCellView *)[self tableView:self.timeOffDetailsTableView cellForRowAtIndexPath:startDayRowindexPath];
        
        EntryCellDetails *detailsObj =(EntryCellDetails *)[startDaycell rowDetailsValue];
        [detailsObj setFieldValue:RPLocalizedString(DAY,@"")];

        [self.timeOffDetailsObj setStartNumberOfHours:nil];
        [self.timeOffDetailsObj setStartTime:nil];
        startDurationEntryTypeMode=DAYMODE;
        self.timeOffDetailsObj.startDurationEntryType=FULLDAY_DURATION_TYPE_KEY;
        
        [self.timeOffDetailsObj setEndNumberOfHours:nil];
        [self.timeOffDetailsObj setEndTime:nil];
        endDurationEntryMode=DAYMODE;
        self.timeOffDetailsObj.endDurationEntryType=FULLDAY_DURATION_TYPE_KEY;

        NSIndexPath *endDayRowindexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        TimeOffDetailsCellView *endDaycell=(TimeOffDetailsCellView *)[self tableView:self.timeOffDetailsTableView cellForRowAtIndexPath:endDayRowindexPath];
        
        EntryCellDetails *endDetailsObj =(EntryCellDetails *)[endDaycell rowDetailsValue];
        [endDetailsObj setFieldValue:RPLocalizedString(DAY,@"")];

        [self.timeOffDetailsTableView reloadData];
        [self.timeOffDetailsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        if([self.timeOffDateSelectionDelegate respondsToSelector:@selector(balanceCalculationMethod:::)])
        {
            [self.timeOffDateSelectionDelegate balanceCalculationMethod:startDurationEntryTypeMode :endDurationEntryMode :self.timeOffDetailsObj];
        }

    }
}


-(int)getSelectedDayTypeRowIndex:(NSIndexPath*)index
{
    int selectedIndexNo =-1;
    NSLog(@"%@",[self.timeOffDetailsObj typeName]);
    NSString *selectedtimeoffTypeName  = [self.timeOffDetailsObj typeName];
    if (selectedtimeoffTypeName!=nil && ![selectedtimeoffTypeName isKindOfClass:[NSNull class]]) {
        for (int i=0; i<[self.timeOffTypesArray count]; ++i) {
            NSRange range = [[[self.timeOffTypesArray objectAtIndex:i] objectForKey:@"timeoffTypeName"] rangeOfString: selectedtimeoffTypeName];
            if(range.length > 0){
                selectedIndexNo = i;
                break;
            }
        }
    }
    return selectedIndexNo;
}


#pragma mark -
#pragma mark Picker Delegates methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.frame.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return PICKER_ROW_HEIGHT;
}

- (NSInteger)pickerView:(UIPickerView *)pickerViews numberOfRowsInComponent:(NSInteger)component
{
    if(self.selectedIndex.row==0)
    {
        if([self.timeOffTypesArray count]>0)
        {
            return [self.timeOffTypesArray count];
        }
    }
    else if (self.selectedIndex.row==1 || self.selectedIndex.row==2)
    {
        if([self.policyKey isEqualToString:FULLDAY_POLICY_KEY])
        {
            return [self.fullDayArray count];
        }
        if([self.policyKey isEqualToString:HOUR_POLICY_KEY])
        {
            return [self.fullHourArray count];
        }
        if([self.policyKey isEqualToString:HALFDAY_POLICY_KEY])
        {
            return [self.halfDayArray count];
        }
        if([self.policyKey isEqualToString:QUARTERDAY_POLICY_KEY])
        {
            return [self.quarterDayArray count];
        }
        if([self.policyKey isEqualToString:NONE_POLICY_KEY])
        {
            return [self.noneDayArray count];
        }
    }
    return 0;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    if (self.selectedIndex.row==0) {
        if (self.timeOffTypesArray != nil && ![self.timeOffTypesArray isKindOfClass:[NSNull class]] &&[self.timeOffTypesArray count]>0)
        {
            NSString *typeName = [[self.timeOffTypesArray objectAtIndex:row] objectForKey:@"timeoffTypeName"];
            NSString *typeUri = [[self.timeOffTypesArray objectAtIndex:row] objectForKey:@"timeoffTypeUri"];
            self.timeOffDetailsObj.typeName = typeName;
            self.timeOffDetailsObj.typeIdentity = typeUri;
            self.timeOffDetailsObj.timeOffDisplayFormatUri = [[self.timeOffTypesArray objectAtIndex:row] objectForKey:@"timeOffDisplayFormatUri"];
            self.balanceTrackingOption=[[self.timeOffTypesArray objectAtIndex:row] objectForKey:@"timeoffBalanceTrackingOptionUri"];
            self.policyKey = [[self.timeOffTypesArray objectAtIndex:row] objectForKey:@"minTimeoffIncrementPolicyUri"];
            [self updateTypeOnPickerSelectionWithTypeName:typeName withTypeUri:typeUri];
        }
    }
    if (self.selectedIndex.row==1 || self.selectedIndex.row==2)
    {
        TimeOffDetailsCellView *cell = (TimeOffDetailsCellView *)[self tableView:self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
        EntryCellDetails *detailsObj =(EntryCellDetails *)[cell rowDetailsValue];
        
        if([self.policyKey isEqualToString:FULLDAY_POLICY_KEY])
        {
            [detailsObj setFieldValue:[self.fullDayArray objectAtIndex:row]];
        }
        if([self.policyKey isEqualToString:HOUR_POLICY_KEY])
        {
             [detailsObj setFieldValue:[self.fullHourArray objectAtIndex:row]];
        }
        if([self.policyKey isEqualToString:HALFDAY_POLICY_KEY])
        {
            [detailsObj setFieldValue:[self.halfDayArray objectAtIndex:row]];
        }
        if([self.policyKey isEqualToString:QUARTERDAY_POLICY_KEY])
        {
            [detailsObj setFieldValue:[self.quarterDayArray objectAtIndex:row]];
        }
        if([self.policyKey isEqualToString:NONE_POLICY_KEY])
        {
            [detailsObj setFieldValue:[self.noneDayArray objectAtIndex:row]];
        }
    }
    
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.selectedIndex.row==0)
    {
        if (self.timeOffTypesArray != nil && ![self.timeOffTypesArray isKindOfClass:[NSNull class]] &&[self.timeOffTypesArray count]>0)
        {
            return [[self.timeOffTypesArray objectAtIndex:row] objectForKey:@"timeoffTypeName"];
        }
    }
    if (self.selectedIndex.row==1 || self.selectedIndex.row==2)
    {

        if([self.policyKey isEqualToString:FULLDAY_POLICY_KEY])
        {
            return [self.fullDayArray objectAtIndex:row];
        }
        if([self.policyKey isEqualToString:HOUR_POLICY_KEY])
        {
            return [self.fullHourArray objectAtIndex:row];
        }
        if([self.policyKey isEqualToString:HALFDAY_POLICY_KEY])
        {
            return [self.halfDayArray objectAtIndex:row];
        }
        if([self.policyKey isEqualToString:QUARTERDAY_POLICY_KEY])
        {
            return [self.quarterDayArray objectAtIndex:row];
        }
        if([self.policyKey isEqualToString:NONE_POLICY_KEY])
        {
            return [self.noneDayArray objectAtIndex:row];
        }
    }
    return nil;
}

-(void)updateTypeOnPickerSelectionWithTypeName:(NSString *)typeName withTypeUri:(NSString *)typeUri
{
    TimeOffDetailsCellView *cell=(TimeOffDetailsCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
    if (cell==nil || [cell isKindOfClass:[NSNull class]])
    {
        cell = (TimeOffDetailsCellView *)[self tableView:self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
    }
    EntryCellDetails *detailsObj =(EntryCellDetails *)[cell rowDetailsValue];
    [detailsObj setFieldValue:typeName];
    [[(TimeOffDetailsCellView *)cell rightLb] setText:typeName];
    [self updateFieldAtIndex:self.selectedIndex WithSelectedValues:typeName];
}

- (void) actionForPicker: (id) sender withEvent: (UIEvent *) event{
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: self.timeOffDetailsTableView];
    NSIndexPath * indexPath = [self.timeOffDetailsTableView indexPathForRowAtPoint: location];
    
    if (indexPath.row!=0 && !self.isStatusView)
    {
        if (indexPath.row==1)
        {
            if (!isStartDayButtonClicked)
            {
                isStartDayButtonClicked=YES;
            }
            isEndDayButtonClicked=NO;
        }
        else{
            if (!isEndDayButtonClicked)
            {
                isEndDayButtonClicked=YES;
            }
            isStartDayButtonClicked=NO;
        }
    }
    
    [self _removeCustomDateUdfPickerViewFromTheView];
    self.selectedIndex = indexPath;
    [self handleDidSelectRowSelection:indexPath :sender];
    
}

-(BOOL)checkForStartAndEndDate{
    NSDateFormatter *temp = [[NSDateFormatter alloc] init];
    [temp setDateFormat:@"yyyy-MM-dd"];
    
    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [temp setTimeZone:timeZone];
    [temp setLocale:locale];
    
    NSDate *stDt = [temp dateFromString:[temp stringFromDate:[self.timeOffDetailsObj bookedStartDate]]];
    NSDate *endDt =  [temp dateFromString:[temp stringFromDate:[self.timeOffDetailsObj bookedEndDate]]];
    
    if ((stDt!=nil && endDt!=nil) && [stDt compare:endDt]==NSOrderedSame)
    {
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark Creating Objects for Table Row methods
/************************************************************************************************************
 @Function Name   : Create row objects
 @Purpose         : Called to create row objects for tableview.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/


-(void)createRowObjects
{
    [self.rowObjectsArray removeAllObjects];
    EntryCellDetails *timeOffTypeDetails = [[EntryCellDetails alloc] initWithDefaultValue:RPLocalizedString(@"Select", @"")];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(timeoffTypeName==%@)", [self.timeOffDetailsObj typeName]];
    NSArray *arr= [self.timeOffTypesArray filteredArrayUsingPredicate:pred];
    if ([arr count]>0) {
        NSDictionary *dict=[arr objectAtIndex:0];
        NSString *typeName = [dict objectForKey:@"timeoffTypeName"];
        NSString *typeUri = [dict objectForKey:@"timeoffTypeUri"];
        self.timeOffDetailsObj.typeName = typeName;
        self.timeOffDetailsObj.typeIdentity = typeUri;
        self.timeOffDetailsObj.timeOffDisplayFormatUri = [dict objectForKey:@"timeOffDisplayFormatUri"];
        self.balanceTrackingOption=[dict objectForKey:@"timeoffBalanceTrackingOptionUri"];
        self.policyKey = [dict objectForKey:@"minTimeoffIncrementPolicyUri"];
        self.isTypeAvailable = YES;
        
        self.previousType=[self.timeOffDetailsObj typeName];
    }
    if(self.screenMode == ADD_BOOKTIMEOFF && !self.isTypeAvailable)
    {
        if (self.timeOffTypesArray != nil && ![self.timeOffTypesArray isKindOfClass:[NSNull class]] &&[self.timeOffTypesArray count]>0)
        {
            self.selectedIndex=0;
            self.isTypeAvailable = YES;
            TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
            NSDictionary *defaultTimeoffType = [timeoffModel getDefaultTimeoffType];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"(timeoffTypeUri==%@)", defaultTimeoffType[@"uri"]];
            NSArray *arr= [self.timeOffTypesArray filteredArrayUsingPredicate:pred];
            NSString *typeName = nil;
            NSString *typeUri = nil;
            if (arr.count > 0) {
                typeName = [[arr objectAtIndex:0] objectForKey:@"timeoffTypeName"];
                typeUri = [[arr objectAtIndex:0] objectForKey:@"timeoffTypeUri"];
            }
            else{
                typeName = [[self.timeOffTypesArray objectAtIndex:0] objectForKey:@"timeoffTypeName"];
                typeUri = [[self.timeOffTypesArray objectAtIndex:0] objectForKey:@"timeoffTypeUri"];
            }
            self.timeOffDetailsObj.typeName = typeName;
            self.timeOffDetailsObj.typeIdentity = typeUri;
            self.timeOffDetailsObj.timeOffDisplayFormatUri = [[self.timeOffTypesArray objectAtIndex:0] objectForKey:@"timeOffDisplayFormatUri"];
            self.balanceTrackingOption=[[self.timeOffTypesArray objectAtIndex:0] objectForKey:@"timeoffBalanceTrackingOptionUri"];
            self.policyKey = [[self.timeOffTypesArray objectAtIndex:0] objectForKey:@"minTimeoffIncrementPolicyUri"];
            //[self updateTypeOnPickerSelectionWithTypeName:typeName withTypeUri:typeUri];
            [self updatePolicyKeysForTimeOffTypes:self.policyKey];
        }
    }

    
    [timeOffTypeDetails setFieldName:RPLocalizedString(BookedTimeOffTypeFieldName, @"")];
    [timeOffTypeDetails setFieldType:DATA_PICKER];
    [timeOffTypeDetails setDefaultValue:[self.timeOffDetailsObj typeName]];
    [timeOffTypeDetails setFieldValue:[self.timeOffDetailsObj typeName]];
    [self.rowObjectsArray addObject:timeOffTypeDetails];
    timeOffTypeDetails = nil;
    
    
    EntryCellDetails *timeOffStartDateDetails= [[EntryCellDetails alloc] initWithDefaultValue:RPLocalizedString(DAY, @"")];
    NSDate *entryDate  = [self.timeOffDetailsObj bookedStartDate];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [df setLocale:locale];
    [df setTimeZone:timeZone];
    
    NSString *startDateValue=nil;
    
    [df setDateFormat:@"EEE,MMM,dd,yyyy"];
    
    if (entryDate != nil) {
        startDateValue=[NSString stringWithFormat:@"%@",[df stringFromDate:entryDate]];
    }
    else {
        startDateValue=RPLocalizedString(@"START DATE", @"");
    }
    NSString *startEntryType=RPLocalizedString(DAY, @"") ;
    if ([self.timeOffDetailsObj startDurationEntryType]!=nil &&![[self.timeOffDetailsObj startDurationEntryType]isKindOfClass:[NSNull class]] )
    {
        if ([[self.timeOffDetailsObj startDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY])
        {
            startEntryType=RPLocalizedString(DAY, @"") ;
        }
        else if ([[self.timeOffDetailsObj startDurationEntryType] isEqualToString:HALFDAY_DURATION_TYPE_KEY])
        {
            startEntryType=RPLocalizedString(HALF, @"") ;
        }
        else if ([[self.timeOffDetailsObj startDurationEntryType] isEqualToString:THREEQUARTERDAY_DURATION_KEY])
        {
            startEntryType=RPLocalizedString(THREEQUARTER, @"") ;
        }
        else if([[self.timeOffDetailsObj startDurationEntryType] isEqualToString:QUARTERDAY_DURATION_KEY])
        {
            startEntryType=RPLocalizedString(ONEFOURTH, @"") ;
        }
        else if([[self.timeOffDetailsObj startDurationEntryType] isEqualToString:PARTIAL]){
            startEntryType=RPLocalizedString(PARTIAL, @"") ;
        }
    }
    if (startEntryType!=nil)
    {
        [timeOffStartDateDetails setFieldValue:startEntryType];
        if (![startEntryType isEqualToString:RPLocalizedString(DAY, @"")])
        {
            if ([startEntryType isEqualToString:RPLocalizedString(ONEFOURTH, @"")])
            {
                startDurationEntryTypeMode=ONEFOURTHDAYMODE;
            }
            else if ([startEntryType isEqualToString:RPLocalizedString(THREEQUARTER, @"")])
            {
                startDurationEntryTypeMode=THREEFOURTHDAYMODE;
            }
            else if ([startEntryType isEqualToString:RPLocalizedString(HALF, @"")])
            {
                startDurationEntryTypeMode=HALFDAYMODE;
            }
            else if ([startEntryType isEqualToString:RPLocalizedString(PARTIAL, @"")])
            {
                startDurationEntryTypeMode=PARTIALDAYMODE;
            }
            else
                startDurationEntryTypeMode=DAYMODE;
        }
        else {
            startDurationEntryTypeMode=DAYMODE;
        }
    }
    
    else {
        startDurationEntryTypeMode=DAYMODE;
    }
    
    [timeOffStartDateDetails setFieldName:startDateValue];
    [timeOffStartDateDetails setFieldType:MOVE_TO_NEXT_SCREEN];
    [self.rowObjectsArray addObject:timeOffStartDateDetails];
    timeOffStartDateDetails=nil;
    
    EntryCellDetails *timeOffEndDateDetails= [[EntryCellDetails alloc] initWithDefaultValue:RPLocalizedString(DAY, @"")];
    NSDate *entryEndDate = [self.timeOffDetailsObj bookedEndDate];
    NSString *endDateValue=nil;
    if (entryEndDate != nil) {
        endDateValue=[NSString stringWithFormat:@"%@",[df stringFromDate:entryEndDate]];
    }
    else {
        endDateValue=RPLocalizedString(@"END DATE", @"");
    }
    NSString *endEntryType=RPLocalizedString(DAY, @"");
    
    if ([self.timeOffDetailsObj endDurationEntryType]!=nil &&![[self.timeOffDetailsObj endDurationEntryType]isKindOfClass:[NSNull class]] ) {
        if ([[self.timeOffDetailsObj endDurationEntryType] isEqualToString:FULLDAY_DURATION_TYPE_KEY])
        {
            endEntryType=RPLocalizedString(DAY, @"") ;
        }
        else if ([[self.timeOffDetailsObj endDurationEntryType] isEqualToString:HALFDAY_DURATION_TYPE_KEY])
        {
            endEntryType=RPLocalizedString(HALF, @"") ;
        }
        else if ([[self.timeOffDetailsObj endDurationEntryType] isEqualToString:THREEQUARTERDAY_DURATION_KEY])
        {
            endEntryType=RPLocalizedString(THREEQUARTER, @"") ;
        }
        else if([[self.timeOffDetailsObj endDurationEntryType] isEqualToString:QUARTERDAY_DURATION_KEY])
        {
            endEntryType=RPLocalizedString(ONEFOURTH, @"") ;
        }
        else if([[self.timeOffDetailsObj endDurationEntryType] isEqualToString:PARTIAL]){
            endEntryType=RPLocalizedString(PARTIAL, @"") ;
        }
    }
    
    if (endEntryType!=nil)
    {
        [timeOffEndDateDetails setFieldValue:endEntryType];
        if (![endEntryType isEqualToString:RPLocalizedString(DAY, @"")])
        {
            if ([endEntryType isEqualToString:RPLocalizedString(ONEFOURTH, @"")])
            {
                endDurationEntryMode=ONEFOURTHDAYMODE;
            }
            else if ([endEntryType isEqualToString:RPLocalizedString(THREEQUARTER, @"")])
            {
                endDurationEntryMode=THREEFOURTHDAYMODE;
            }
            else if ([endEntryType isEqualToString:RPLocalizedString(HALF, @"")])
            {
                endDurationEntryMode=HALFDAYMODE;
            }
            else if ([endEntryType isEqualToString:RPLocalizedString(PARTIAL, @"")])
            {
                endDurationEntryMode=PARTIALDAYMODE;
            }
            else
                endDurationEntryMode=DAYMODE;
            if (endDurationEntryMode!=PARTIALDAYMODE) {
            }
        }
    }
    else {
        endDurationEntryMode=DAYMODE;
    }
    
    if ([endDateValue isEqualToString:startDateValue])
    {
        endDurationEntryMode=DAYMODE;
    }
    [timeOffEndDateDetails setFieldName:endDateValue];
    [timeOffEndDateDetails setFieldType:MOVE_TO_NEXT_SCREEN];
    [self.rowObjectsArray addObject:timeOffEndDateDetails];
    timeOffEndDateDetails = nil;
    
    [self.rowObjectsArray addObject:@"Balance"];
    [self.rowObjectsArray addObject:@"Comments"];
    
    for (NSDictionary *udfDict in self.customFieldArray)
    {
        UdfObject *udfObject=[[UdfObject alloc]initWithDictionary:udfDict];
        [self.rowObjectsArray addObject:udfObject];
    }
    
    //    }
}

-(void)updatePolicyKeysForTimeOffTypes:(NSString *)policyUri
{
    if ([policyUri isEqualToString:FULLDAY_POLICY_KEY])
    {
        self.hasFullDay=YES;
        self.isHalfPermission=NO;
        self.isHourPermission=NO;
        self.isQuarterPermission=NO;
        self.isNonePermission=NO;
        
    }
    else if ([policyUri isEqualToString:HALFDAY_POLICY_KEY])
    {
        self.hasFullDay=NO;
        self.isHalfPermission=YES;
        self.isHourPermission=NO;
        self.isQuarterPermission=NO;
        self.isNonePermission=NO;
    }
    else if ([policyUri isEqualToString:HOUR_POLICY_KEY])
    {
        self.hasFullDay=NO;
        self.isHalfPermission=NO;
        self.isHourPermission=YES;
        self.isQuarterPermission=NO;
        self.isNonePermission=NO;
    }
    else if ([policyUri isEqualToString:QUARTERDAY_POLICY_KEY])
    {
        self.hasFullDay=NO;
        self.isHalfPermission=NO;
        self.isHourPermission=NO;
        self.isQuarterPermission=YES;
        self.isNonePermission=NO;
    }
    else if ([policyUri isEqualToString:NONE_POLICY_KEY])
    {
        self.hasFullDay=NO;
        self.isHalfPermission=NO;
        self.isHourPermission=NO;
        self.isQuarterPermission=NO;
        self.isNonePermission=YES;
    }

}

#pragma mark -
#pragma mark UpdateComments after user entered
/************************************************************************************************************
 @Function Name   : Update UI based on comments
 @Purpose         : Increase/Decrease Comments cell height.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/
-(void)UpdateComments:(NSString *)commentsStr
{
    [self.timeOffDetailsObj setComments:commentsStr];
    NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:4 inSection:0];
    [self.timeOffDetailsTableView beginUpdates];
    [self.timeOffDetailsTableView reloadRowsAtIndexPaths:@[tmpIndexpath] withRowAnimation:UITableViewRowAnimationFade];
    [self.timeOffDetailsTableView endUpdates];
}



#pragma mark -
#pragma mark Calculating balance based on time Entered Hours for TimeOff
/************************************************************************************************************
 @Function Name   : Calculate time off balance
 @Purpose         : Called to get timeoff balance.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/
-(void)calculateBalanceAfterHoursEntered:(NSString *)hoursTxt :(NSInteger)selectedRow
{
    NSLog(@"%@",hoursTxt);
    if(hoursTxt!=nil && ![hoursTxt isKindOfClass:[NSNull class]])
    {
        if(selectedRow==1)
        {
            [self.timeOffDetailsObj setStartNumberOfHours:hoursTxt];
        }
        else if(selectedRow==2)
        {
            [self.timeOffDetailsObj setEndNumberOfHours:hoursTxt];
        }
    }
    if(self.timeOffDetailsObj.isDeviceSupportedEntryConfiguration == TRUE)
    {
        if([self.timeOffDateSelectionDelegate respondsToSelector:@selector(balanceCalculationMethod:::)])
        {
            [self.timeOffDateSelectionDelegate balanceCalculationMethod:startDurationEntryTypeMode :endDurationEntryMode :self.timeOffDetailsObj];
        }
    }
}

-(void)updateBalanceValue:(NSDictionary *)balDictionary :(NSInteger)_screenMod
{
    if (self.navigationFlow != TIMEOFF_BOOKING_NAVIGATION && self.navigationFlow != TIMESHEET_PERIOD_NAVIGATION)
    {
        NSString *timeOffUri = balDictionary[@"timeOffUri"];

        if (timeOffUri!=nil && ![timeOffUri isKindOfClass:[NSNull class]])
        {

            if (timeOffUri!=[self.timeOffDetailsObj sheetId])
            {
                return;
            }
        }
    }

    NSIndexPath *index = [NSIndexPath indexPathForRow:3 inSection:0];
    TimeOffRequestedCellView *cell=(TimeOffRequestedCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:index];

    if (cell==nil || [cell isKindOfClass:[NSNull class]])
    {
        for (id cellObj in cellsArray)
        {
            if ([cellObj isKindOfClass:[TimeOffRequestedCellView class]])
            {
                cell=(TimeOffRequestedCellView *)cellObj;
                break;
            }
        }
    }


    NSString *timeOffDisplayFormatUri=[balDictionary objectForKey:@"timeOffDisplayFormatUri"];




    if ([balDictionary objectForKey:@"balanceRemainingDays"]!=nil && ![[balDictionary objectForKey:@"balanceRemainingDays"] isKindOfClass:[NSNull class]] && [balDictionary objectForKey:@"balanceRemainingHours"]!=nil && ![[balDictionary objectForKey:@"balanceRemainingHours"] isKindOfClass:[NSNull class]])
    {
        NSString *balanceValue=nil;
        if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI])
        {
           balanceValue=[Util getRoundedValueFromDecimalPlaces:[[balDictionary objectForKey:@"balanceRemainingDays"]newDoubleValue]withDecimalPlaces:2];
        }

        else if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_HOURS_FORMAT_URI])
        {
            balanceValue=[balDictionary objectForKey:@"balanceRemainingHours"];
        }

        if (([[self.timeOffDetailsObj approvalStatus] isEqualToString:APPROVED_STATUS ]&&(_screenMod == VIEW_BOOKTIMEOFF)))
        {
        }
        else{
            if (self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION ||self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
            {
                if ([self.balanceTrackingOption isEqualToString:TIME_OFF_AVAILABLE_KEY])
                {
                    if (balanceValue!=nil && ![balanceValue isKindOfClass:[NSNull class]])
                    {
                        if (fabs([balanceValue newDoubleValue])!=1.00) {

                            NSString *unitStr=nil;

                            if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI])
                            {
                                unitStr=RPLocalizedString(@"days", @"");
                            }
                            
                            else if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_HOURS_FORMAT_URI])
                            {
                                unitStr=RPLocalizedString(@"hours", @"");
                            }

                            [[(TimeOffRequestedCellView *)cell balanceValueLbl] setText:[NSString stringWithFormat:@"%@ %@",balanceValue,unitStr]];
                            self.balanceValue = [NSString stringWithFormat:@"%@ %@",balanceValue,unitStr];
                        }
                        else{
                            NSString *unitStr=nil;
                            if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI])
                            {
                                unitStr=RPLocalizedString(@"day", @"");
                            }

                            else if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_HOURS_FORMAT_URI])
                            {
                                unitStr=RPLocalizedString(@"hour", @"");
                            }
                            [[(TimeOffRequestedCellView *)cell balanceValueLbl] setText:[NSString stringWithFormat:@"%@ %@",balanceValue,unitStr]];
                            self.balanceValue = [NSString stringWithFormat:@"%@ %@",balanceValue,unitStr];
                        }
                    }
                    else {
                        [[(TimeOffRequestedCellView *)cell balanceValueLbl] setText:RPLocalizedString(@"N/A", @" ") ];
                    }
                }
                else
                {
                    [[(TimeOffRequestedCellView *)cell balanceValueLbl] setText:RPLocalizedString(@"N/A", @" ") ];
                    self.balanceValue = RPLocalizedString(@"N/A", @" ");
                }
            }
            else{
                if (balanceValue!=nil && ![balanceValue isKindOfClass:[NSNull class]])
                {
                    if (fabs([balanceValue newDoubleValue])!=1.00) {
                        NSString *unitStr=nil;

                        if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI])
                        {
                            unitStr=RPLocalizedString(@"days", @"");
                        }

                        else if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_HOURS_FORMAT_URI])
                        {
                            unitStr=RPLocalizedString(@"hours", @"");
                        }
                        [[(TimeOffRequestedCellView *)cell balanceValueLbl] setText:[NSString stringWithFormat:@"%@ %@",balanceValue,unitStr]];
                        self.balanceValue = [NSString stringWithFormat:@"%@ %@",balanceValue,unitStr];
                    }
                    else{
                        NSString *unitStr=nil;
                        if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI])
                        {
                            unitStr=RPLocalizedString(@"day", @"");
                        }

                        else if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_HOURS_FORMAT_URI])
                        {
                            unitStr=RPLocalizedString(@"hour", @"");
                        }
                        [[(TimeOffRequestedCellView *)cell balanceValueLbl] setText:[NSString stringWithFormat:@"%@ %@",balanceValue,unitStr]];
                        self.balanceValue =[NSString stringWithFormat:@"%@ %@",balanceValue,unitStr];
                    }
                }
                else {
                    [[(TimeOffRequestedCellView *)cell balanceValueLbl] setText:RPLocalizedString(@"N/A", @" ") ];
                    self.balanceValue = RPLocalizedString(@"N/A", @" ");
                }
            }
        }
    }
    else if(self.balanceValue == nil || [self.balanceValue isKindOfClass:[NSNull class]])
    {
        [[(TimeOffRequestedCellView *)cell balanceValueLbl] setText:RPLocalizedString(@"N/A", @" ") ];
    }
    if ([balDictionary objectForKey:@"requestedDays"]!=nil && ![[balDictionary objectForKey:@"requestedDays"] isKindOfClass:[NSNull class]] && [balDictionary objectForKey:@"requestedHours"]!=nil && ![[balDictionary objectForKey:@"requestedHours"] isKindOfClass:[NSNull class]])
    {
        [self.timeOffDetailsObj setTotalTimeOffDays:[Util getRoundedValueFromDecimalPlaces:[[balDictionary objectForKey:@"requestedDays"]newDoubleValue]withDecimalPlaces:2]];
        [self.timeOffDetailsObj setNumberOfHours:[balDictionary objectForKey:@"requestedHours"]];
        if ([self.timeOffDetailsObj totalTimeOffDays]!=nil&& ![[self.timeOffDetailsObj totalTimeOffDays]isKindOfClass:[NSNull class]] && [self.timeOffDetailsObj numberOfHours]!=nil&& ![[self.timeOffDetailsObj numberOfHours]isKindOfClass:[NSNull class]])
        {

            if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI])
            {
                if (fabs([self.timeOffDetailsObj.totalTimeOffDays newDoubleValue])!=1.00 && [self.timeOffDetailsObj.totalTimeOffDays newDoubleValue]!=0.00) {

                    [[(TimeOffRequestedCellView *)cell requestedValueLbl] setText:[NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.totalTimeOffDays,RPLocalizedString(@"days", @"")]];
                    self.requestedValue = [NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.totalTimeOffDays,RPLocalizedString(@"days", @"")];
                }
                else if (fabs([self.timeOffDetailsObj.totalTimeOffDays newDoubleValue])==1.00)
                {
                    [[(TimeOffRequestedCellView *)cell requestedValueLbl] setText:[NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.totalTimeOffDays,RPLocalizedString(@"day", @"")]];
                    self.requestedValue = [NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.totalTimeOffDays,RPLocalizedString(@"day", @"")];
                }
            }

            else if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_HOURS_FORMAT_URI])
            {
                if (fabs([self.timeOffDetailsObj.numberOfHours newDoubleValue])!=1.00 && [self.timeOffDetailsObj.numberOfHours newDoubleValue]!=0.00) {

                    [[(TimeOffRequestedCellView *)cell requestedValueLbl] setText:[NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.numberOfHours,RPLocalizedString(@"hours", @"")]];
                    self.requestedValue = [NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.numberOfHours,RPLocalizedString(@"hours", @"")];
                }
                else if (fabs([self.timeOffDetailsObj.numberOfHours newDoubleValue])==1.00)
                {
                    [[(TimeOffRequestedCellView *)cell requestedValueLbl] setText:[NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.numberOfHours,RPLocalizedString(@"hour", @"")]];
                    self.requestedValue = [NSString stringWithFormat:@"%@ %@",self.timeOffDetailsObj.numberOfHours,RPLocalizedString(@"hour", @"")];
                }
            }


        }
        else {
            [[(TimeOffRequestedCellView *)cell requestedValueLbl] setText:RPLocalizedString(@"N/A", @" ") ];
            self.requestedValue = RPLocalizedString(@"N/A", @" ");
        }
    }
    else if(self.requestedValue == nil || [self.requestedValue isKindOfClass:[NSNull class]]) {
        [[(TimeOffRequestedCellView *)cell requestedValueLbl] setText:RPLocalizedString(@"N/A", @" ") ];
        self.balanceValue = RPLocalizedString(@"N/A", @" ");
    }


}

/************************************************************************************************************
 @Function Name   : Keyboard Show/Hide
 @Purpose         : Handle View to animate while keyboard is shown and hidden
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

#pragma mark - TableView Resize on Keyboard appear/Disappear
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if(self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION || self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION)
    {
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.timeOffDetailsTableView.contentInset = contentInsets;
        self.timeOffDetailsTableView.scrollIndicatorInsets = contentInsets;
        CGRect aRect = self.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
            [self.timeOffDetailsTableView scrollRectToVisible:self.activeField.frame animated:YES];
        }
    }
    
    else if(self.navigationFlow == PENDING_APPROVER_NAVIGATION || self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
    {
        NSTimeInterval animationDuration =
        [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect frame = self.frame;
        frame.origin.y -= 160;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.frame = frame;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if(self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION || self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION)
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        //self.timeOffDetailsTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        self.timeOffDetailsTableView.scrollIndicatorInsets = contentInsets;
        [self _resetTable:NO];
    }
    else if(self.navigationFlow == PENDING_APPROVER_NAVIGATION || self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
    {
        NSTimeInterval animationDuration =
        [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect frame = self.frame;
        frame.origin.y += 160;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.frame = frame;
        [UIView commitAnimations];
    }
}


#pragma mark - UDF Selected/Resigned Actions
/************************************************************************************************************
 @Function Name   : timeOff_UdfCell_Selected_Callback
 @Purpose         : Enables a callback after user selects a Udf cell
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)timeSheetsUdfCellSelected:(TimeSheetsUdfCell *)timeSheetsUdfCell withUdfObject:(UdfObject *)udfObject
{
    NSIndexPath *indexPath = [self.timeOffDetailsTableView indexPathForCell:timeSheetsUdfCell];
    NSLog(@"%ld",(long)indexPath.row);
    [self doneDataPickerAction];
    if ([udfObject udfType]==UDF_TYPE_NUMERIC) {
        TimeSheetsUdfCell *cell = (TimeSheetsUdfCell *)[self.timeOffDetailsTableView cellForRowAtIndexPath:indexPath];
        [self _removeCustomDateUdfPickerViewFromTheView];
        [self doneDatePickerAction];
        [[cell numberUdfTextField] becomeFirstResponder];
        self.activeField = [cell numberUdfTextField];
        self.selectedIndex=indexPath;
        [self.timeOffDetailsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else if ([udfObject udfType]==UDF_TYPE_DATE){
        [self doneDatePickerAction];
        self.selectedIndex=indexPath;
        [self _setUpAndAddCustomDateUdfPickerViewToTheViewWithUdfObject:udfObject fromIndexpath:indexPath];
        [self.timeOffDetailsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else if ([udfObject udfType]==UDF_TYPE_DROPDOWN||[udfObject udfType]==UDF_TYPE_TEXT){
        [self doneDatePickerAction];
        [self _removeCustomDateUdfPickerViewFromTheView];
        self.selectedIndex=indexPath;
        [self.timeOffDetailsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.timeOffDetailsTableView deselectRowAtIndexPath:indexPath animated:NO];
        if ([udfObject udfType]==UDF_TYPE_TEXT) {
            if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(textUdfNavigation:withUdfObject:)]) {
                [self.timeOffDateSelectionDelegate textUdfNavigation:self  withUdfObject:udfObject];
            }
        }
        else{
            if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(dropdownUdfNavigation:withUdfObject:)]) {
                [self.timeOffDateSelectionDelegate dropdownUdfNavigation:self  withUdfObject:udfObject];
            }
        }
    }
}

/************************************************************************************************************
 @Function Name   : timeOff_UdfCell_Resigned_callback
 @Purpose         : Enables a callback after user deselects/done editing with a Udf cell
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)timeSheetsUdfCellResigned:(TimeSheetsUdfCell *)timeSheetsUdfCell withUdfObject:(UdfObject *)udfObject
{
    NSIndexPath *indexPath = [self.timeOffDetailsTableView indexPathForCell:timeSheetsUdfCell];
    [self.timeOffDetailsTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([udfObject udfType]==UDF_TYPE_NUMERIC||[udfObject udfType]==UDF_TYPE_TEXT)
        [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - Number UDF Update Actions
- (void)numberUdfValueUpdatedOnCell:(TimeSheetsUdfCell *)timeSheetsUdfCell withUdfObject:(UdfObject *)udfObject
{
    TimeSheetsUdfCell *cell = (TimeSheetsUdfCell *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
    if ([cell isKindOfClass:[TimeSheetsUdfCell class]]) {
        [cell.numberUdfTextField setText:[udfObject defaultValue]];
        [self timeSheetsUdfCellResigned:timeSheetsUdfCell withUdfObject:udfObject];
        if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(updateUdfValue:withUdfObject:)]) {
            [self.timeOffDateSelectionDelegate updateUdfValue:self  withUdfObject:udfObject];
        }
    }
}
#pragma mark - Date UDF Update Actions
- (void)dateUdfPickerChanged:(DateUdfPickerView *)dateUdfPicker withUdfObject:(UdfObject *)udfObject
{
    TimeSheetsUdfCell *cell = (TimeSheetsUdfCell *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
    if ([cell isKindOfClass:[TimeSheetsUdfCell class]]) {
        [cell.udfValueLabel setText:[udfObject defaultValue]];
        if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(updateUdfValue:withUdfObject:)]) {
            [self.timeOffDateSelectionDelegate updateUdfValue:self  withUdfObject:udfObject];
        }
    }
}

- (void)dateUdfPickerCancel:(DateUdfPickerView *)dateUdfPicker withUdfObject:(UdfObject *)udfObject
{
    [self _removeCustomDateUdfPickerViewFromTheView];
}

- (void)dateUdfPickerClear:(DateUdfPickerView *)dateUdfPicker withUdfObject:(UdfObject *)udfObject
{
    TimeSheetsUdfCell *cell = (TimeSheetsUdfCell *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
    if ([cell isKindOfClass:[TimeSheetsUdfCell class]]) {
        [cell.udfValueLabel setText:[udfObject defaultValue]];
        if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(updateUdfValue:withUdfObject:)]) {
            [self.timeOffDateSelectionDelegate updateUdfValue:self  withUdfObject:udfObject];
        }
    }
}
- (void)dateUdfPickerDone:(DateUdfPickerView *)dateUdfPicker withUdfObject:(UdfObject *)udfObject
{
    TimeSheetsUdfCell *cell = (TimeSheetsUdfCell *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
    if ([cell isKindOfClass:[TimeSheetsUdfCell class]]) {
        [cell.udfValueLabel setText:[udfObject defaultValue]];
        if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(updateUdfValue:withUdfObject:)]) {
            [self.timeOffDateSelectionDelegate updateUdfValue:self  withUdfObject:udfObject];
        }
    }
    [self _removeCustomDateUdfPickerViewFromTheView];
}

#pragma mark - Dropdown Update UDF Actions
- (void)udfDropDownView:(UdfDropDownView *)udfDropDownView withUdfObject:(UdfObject *)udfObject
{
    TimeSheetsUdfCell *cell = (TimeSheetsUdfCell *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
    if ([cell isKindOfClass:[TimeSheetsUdfCell class]]) {
        [cell.udfValueLabel setText:[udfObject defaultValue]];
        if ([self.udfDropDownDelegate respondsToSelector:@selector(updateUdfValue:withUdfObject:)]) {
            [self.udfDropDownDelegate updateUdfValue:self  withUdfObject:udfObject];
        }
    }
}
#pragma mark - Text Update UDF Actions
-(void)userEnteredCommentsOnUdfObject:(UdfObject *)udfObject
{
    TimeSheetsUdfCell *cell = (TimeSheetsUdfCell *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
    if ([[udfObject defaultValue] isEqualToString:@""])
        [cell.udfValueLabel setText:RPLocalizedString(ADD_STRING, @"")];
    else
       [cell.udfValueLabel setText:[udfObject defaultValue]];
    if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(updateUdfValue:withUdfObject:)]) {
        [self.timeOffDateSelectionDelegate updateUdfValue:self  withUdfObject:udfObject];
    }
}

#pragma mark - Date UDF Picker View Methods
/************************************************************************************************************
 @Function Name   : _setUpAndAdd_CustomDateUdfPickerView_ToTheViewWithUdfObject
 @Purpose         : Add the custom Picker View to the view when date udf cell is selected
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)_setUpAndAddCustomDateUdfPickerViewToTheViewWithUdfObject:(UdfObject *)udfObject fromIndexpath:(NSIndexPath *)indexpath
{
    [self endEditing:YES];
    float pickerWithToolbarHeight = PICKER_HEIGHT+TOOL_BAR_HEIGHT;
    float yPicker = self.frame.size.height - pickerWithToolbarHeight;
    DateUdfPickerView *dateUdfPickerView = [[DateUdfPickerView alloc]initWithFrame:CGRectMake(0 ,yPicker, self.frame.size.width, pickerWithToolbarHeight)];
    [dateUdfPickerView setDateUdfActionDelegate:self];
    [dateUdfPickerView setUpDateUdfPickerViewWithUDFObject:udfObject];
    [self addSubview:dateUdfPickerView];
    self.customDateUdfPickerView=dateUdfPickerView;
    [self _resetTable:YES];
    [self.timeOffDetailsTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionNone animated:NO];
}
/************************************************************************************************************
 @Function Name   : _remove_CustomDateUdf_PickerView_FromTheView
 @Purpose         : Removes date udf picker after user deselects/done editing with a Udf cell
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)_removeCustomDateUdfPickerViewFromTheView
{
    if (self.customDateUdfPickerView) {
        TimeSheetsUdfCell *cell = (TimeSheetsUdfCell *)[self.timeOffDetailsTableView cellForRowAtIndexPath:self.selectedIndex];
        UdfObject *udfObject=[self.rowObjectsArray objectAtIndex:self.selectedIndex.row];
        [self timeSheetsUdfCellResigned:cell withUdfObject:udfObject];
        [self.timeOffDetailsTableView deselectRowAtIndexPath:self.selectedIndex animated:NO];
        [self.customDateUdfPickerView removeFromSuperview];
        self.customDateUdfPickerView=nil;
        if ([self.activeField isFirstResponder])
            [self _resetTable:YES];
        else
            [self _resetTable:NO];
        [self.timeOffDetailsTableView scrollToRowAtIndexPath:self.selectedIndex atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}


/************************************************************************************************************
 @Function Name   : reset_Table
 @Purpose         : Reset the table size height so that its scrollable
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)_resetTable:(BOOL)shouldReset
{
    float pickerWithToolbarHeight = PICKER_HEIGHT+TOOL_BAR_HEIGHT;
    if (shouldReset) {
        CGRect frame= self.timeOffDetailsTableView.frame;
        frame.size.height=frame.size.height-pickerWithToolbarHeight;
        [self.timeOffDetailsTableView setFrame:frame];
    }
    else{
        CGRect frame= self.timeOffDetailsTableView.frame;
        frame.size.height=self.frame.size.height;
        [self.timeOffDetailsTableView setFrame:frame];
    }
}

#pragma mark - Action For Delete/Edit/Save
/************************************************************************************************************
 @Function Name   : Edit_Save_Delete
 @Purpose         : Handle Edit/Delete/Save action
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)ActionForSave_Edit
{
    if (self.timeOffStatus)
    {
        if(self.timeOffDetailsObj.isDeviceSupportedEntryConfiguration)
        {
            self.isEditClicked = YES;
            self.timeOffStatus=NO;
            self.screenMode=EDIT_BOOKTIMEOFF;
            NSString *toolbarTitleText = @"";
            if (self.screenMode == EDIT_BOOKTIMEOFF)
                toolbarTitleText = RPLocalizedString(ViewBookTimeOffTitle, @"");
            for (int i=0;i< [self.rowObjectsArray count]; i++) {
                if ([[self.rowObjectsArray objectAtIndex:i] isKindOfClass:[UdfObject class]]) {
                    UdfObject *tempObject = [self.rowObjectsArray objectAtIndex:i];
                    UDFType  udfType = [tempObject udfType];
                    if ((udfType == UDF_TYPE_DATE && [tempObject.defaultValue isEqualToString:NONE_STRING]) || (udfType == UDF_TYPE_DROPDOWN && [tempObject.defaultValue isEqualToString:NONE_STRING]))
                        tempObject.defaultValue = RPLocalizedString(SELECT_STRING, @"");
                    else if((udfType == UDF_TYPE_NUMERIC && [tempObject.defaultValue isEqualToString:NONE_STRING]) || (udfType == UDF_TYPE_TEXT && [tempObject.defaultValue isEqualToString:NONE_STRING]))
                        tempObject.defaultValue = RPLocalizedString(ADD_STRING, @"");
                }
            }
            [self reloadTableViewFromTimeOffDetails];
            [self.timeOffDetailsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
        }
        else
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:nil
                                                    message:RPLocalizedString(MULTIDAY_NOT_SUPPORTED_FROM_MOBILE,@"")
                                                      title:nil
                                                        tag:LONG_MIN];
        }
    }
    else
    {
        [self endEditing:YES];
        
        if([self.timeOffDateSelectionDelegate respondsToSelector:@selector(validateAndSumbit:::::)])
        {
            NSMutableArray *udfArray = [NSMutableArray array];
            NSLog(@"%lu",(unsigned long)[self.rowObjectsArray count]);
            for (int i=0;i< [self.rowObjectsArray count]; i++) {
                if ([[self.rowObjectsArray objectAtIndex:i] isKindOfClass:[UdfObject class]]) {
                    [udfArray addObject:[self.rowObjectsArray objectAtIndex:i]];
                }
            }
            NSLog(@"%@",udfArray);
            [self.timeOffDateSelectionDelegate validateAndSumbit:startDurationEntryTypeMode :endDurationEntryMode :self.timeOffDetailsObj :self.screenMode  :udfArray];
        }
    }
    
}
-(void)ActionForDelete
{
    if([self.timeOffDateSelectionDelegate respondsToSelector:@selector(deleteTimeOff:)])
    {
        [self.timeOffDateSelectionDelegate deleteTimeOff:self.timeOffDetailsObj];
    }
}
-(void)deselectTableViewSelection
{
    [self.timeOffDetailsTableView deselectRowAtIndexPath:self.selectedIndex animated:NO];
}


-(void)enableAndDisableSelectionOfDate:(BOOL)isEnable forIndex:(NSIndexPath*)cellIndex{
    TimeOffDetailsCellView *cell = (TimeOffDetailsCellView *)[self.timeOffDetailsTableView cellForRowAtIndexPath:cellIndex];
    cell.userInteractionEnabled=YES;
    if (cellIndex.row==1|| cellIndex.row==2)
    {
        [(TimeOffDetailsCellView *)cell fieldButton].hidden=NO;
        [(TimeOffDetailsCellView *)cell fieldButton].userInteractionEnabled=YES;
        [(TimeOffDetailsCellView *)cell timeEntryButton].userInteractionEnabled=YES;
        [(TimeOffDetailsCellView *)cell HourEntryField].userInteractionEnabled=YES;
    }
    else{
        cell.timeEntryButton.userInteractionEnabled=NO;
        cell.HourEntryField.userInteractionEnabled=NO;
        
    }
    
}

-(void)resetViewForApprovalsCommentAction:(BOOL)isReset andComments:(NSString *)approverCommentsStr
{
    self.approverComments=approverCommentsStr;
    
    if(isReset){
        self.timeOffDetailsTableView.scrollEnabled=NO;
        CGRect frame=self.timeOffDetailsTableView.frame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float aspectRatio=(screenRect.size.height/screenRect.size.width);
        float heightDueToUdf=[self.customFieldArray count]*Each_Cell_Row_Height_44;
        
        if (aspectRatio<1.7)
        {
            
            self.timeOffDetailsTableView.contentOffset=CGPointMake(0.0,339+heightofDisclaimerText+heightDueToUdf);
            if (heightofDisclaimerText>0)
            {
                // frame.origin.y=-140;
                frame.origin.y=-204;
            }
            else
            {
                if(heightDueToUdf == 0)
                {
                    frame.origin.y=-ResetHeightios4+75;
                }
                else
                {
                    frame.origin.y=-ResetHeightios4;
                }
            }
            
            
        }
        else
        {
            self.timeOffDetailsTableView.contentOffset=CGPointMake(0.0,591+heightDueToUdf+heightofDisclaimerText);
            frame.origin.y=-ResetHeightios5;
        }
        
        
        [self.timeOffDetailsTableView setFrame:frame];
    }
    else{
        self.timeOffDetailsTableView.scrollEnabled=YES;
        CGRect frame=self.timeOffDetailsTableView.frame;
        frame.origin.y=0;
        [self.timeOffDetailsTableView setFrame:frame];
    }

}

#pragma mark Approval headerview Action
- (void)handleButtonClickForHeaderView:(NSInteger)senderTag
{
    if ([self.timeOffDateSelectionDelegate respondsToSelector:@selector(handleTableHeaderAction::)])
    {
        [self.timeOffDateSelectionDelegate handleTableHeaderAction:self.currentViewTag :senderTag];
    }
}
- (void)handleButtonClickForFooterView:(NSInteger)senderTag
{
    if([self.timeOffDateSelectionDelegate respondsToSelector:@selector(handleApprovalsAction:withApprovalComments:)])
    {
        [self.timeOffDateSelectionDelegate handleApprovalsAction:senderTag withApprovalComments:self.approverComments];
    }
}
-(void)dealloc
{
    self.timeOffDetailsTableView.delegate=nil;
    self.timeOffDetailsTableView.dataSource=nil;

}




@end
