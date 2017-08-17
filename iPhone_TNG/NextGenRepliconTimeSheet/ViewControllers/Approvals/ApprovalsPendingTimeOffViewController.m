#import "ApprovalsPendingTimeOffViewController.h"
#import "Constants.h"
#import "Util.h"
#import "ApprovalsNavigationController.h"
#import "ApprovalsPendingCustomCell.h"
#import "SVPullToRefresh.h"
#import <QuartzCore/QuartzCore.h>
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "ApprovalsModel.h"
#import "ApprovalsPendingTimeOffTableViewHeader.h"
#import "ApproveRejectHeaderStylist.h"
#import "UIViewController+NavigationAndTabAwareness.h"
#import "LoginModel.h"
#import "ApprovalsService.h"
#import "ApprovalCommentsController.h"
#import <Blindside/BSInjector.h>
#import "ErrorBannerViewParentPresenterHelper.h"

static NSString *tableviewHeaderReuseIdentifier = @"™";


@interface ApprovalsPendingTimeOffViewController () 

@property (nonatomic) NSNotificationCenter                 *notificationCenter;
@property (nonatomic) ApprovalsModel                       *approvalsModel;
@property (nonatomic) ApprovalsService                     *approvalsService;
@property (nonatomic, weak) id<SpinnerDelegate>            spinnerDelegate;
@property (nonatomic) LoginModel                           *loginModel;
@property (nonatomic) id<BSInjector>                       injector;

@property (nonatomic) ApproveRejectHeaderStylist           *tableviewHeaderStylist;
@property (nonatomic) LoginService                         *loginService;
@property (nonatomic) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@end


@implementation ApprovalsPendingTimeOffViewController

@synthesize approvalpendingTSTableView;
@synthesize sectionHeaderlabel;
@synthesize sectionHeader;
@synthesize selectedIndexPath;
@synthesize timeOffsArray;
@synthesize leftButton;
@synthesize selectedSheetsIDsArr;
@synthesize msgLabel;
@synthesize footerView;
@synthesize commentsTextView;
@synthesize scrollViewController;
@synthesize selectedUserIndexpath;
@synthesize footerBtn;//Implemented As Per US8194

#define WidthOfTextView 300
#define HeightFooter 310
#define HeightTable5 270
#define HeightTable4 189
#define HeightOFMsgLabel 80
#define HeightTextView 80
#define ButtonSpace 11
#define Each_Cell_Row_Height_58 58
#define hexcolor_code @"#333333"

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                      tableviewHeaderStylist:(ApproveRejectHeaderStylist *)tableviewHeaderStylist
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                            approvalsService:(ApprovalsService *)approvalsService
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                              approvalsModel:(ApprovalsModel *)approvalsModel
                                                loginService:(LoginService *)loginService
                                                  loginModel:(LoginModel *)loginModel {
    self = [super init];
    if (self) {
        self.errorBannerViewParentPresenterHelper = errorBannerViewParentPresenterHelper;
        self.tableviewHeaderStylist = tableviewHeaderStylist;
        self.notificationCenter = notificationCenter;
        self.approvalsService = approvalsService;
        self.spinnerDelegate = spinnerDelegate;
        self.approvalsModel = approvalsModel;
        self.loginService = loginService;
        self.loginModel = loginModel;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self];
    self.approvalpendingTSTableView.delegate = nil;
    self.approvalpendingTSTableView.dataSource = nil;
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar setTranslucent:NO];
    [self createListArrays];

    if ([self.listOfUsersArr count] == 0)
    {

        self.approvalpendingTSTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    self.approvalpendingTSTableView.frame = [self contentViewFrame];
    [self refreshTableView];
    [self reloadPendingApprovalsWhenLaunchedFromDeepLink];

    // MI-558: No need to clear selected everytime view appear
    //[self.selectedSheetsIDsArr removeAllObjects];

    [self.approvalpendingTSTableView reloadData];
    [self changeTableViewInset];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setTranslucent:YES];
}

- (void)changeTableViewInset
{
    [self.errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.approvalpendingTSTableView];
}

- (void)createListArrays {
    self.listOfUsersArr = [self.approvalsModel getAllPendingTimeoffs];
}

- (void)showMessageLabel {
    [self.msgLabel removeFromSuperview];
    UILabel *tempMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, HeightOFMsgLabel)];
    tempMsgLabel.text = RPLocalizedString(APPROVAL_NO_TIMEOFFS_PENDING_VALIDATION, APPROVAL_NO_TIMEOFFS_PENDING_VALIDATION);
    self.msgLabel = tempMsgLabel;
    self.msgLabel.backgroundColor = [UIColor clearColor];
    self.msgLabel.numberOfLines = 2;
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    self.msgLabel.font = [UIFont fontWithName:RepliconFontFamily
                                         size:16];

    [self.view addSubview:self.msgLabel];

    [self.approvalpendingTSTableView.tableHeaderView setHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];

    [self.notificationCenter removeObserver:self
                                       name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION
                                     object:nil];
    //Implemented As Per US8194
    NSInteger tag = self.footerBtn.tag;
    if (tag == 5002) {
        [self resetView:NO];

        [UIView beginAnimations:nil
                        context:NULL];
        [UIView setAnimationDuration:0.30];
        self.approvalpendingTSTableView.frame = [self contentViewFrame];
        self.footerView.frame = CGRectMake(0.0,
                                           self.approvalpendingTSTableView.frame.origin.y + approvalpendingTSTableView.frame.size.height,
                                           self.approvalpendingTSTableView.frame.size.width,
                                           HeightFooter);
        UIImage *handlerUPImage = [Util thumbnailImage:HANDLER_UP_IMAGE];
        [self.footerBtn setBackgroundImage:handlerUPImage
                                  forState:UIControlStateNormal];
        self.footerBtn.tag = 5001;
        [UIView commitAnimations];
        [self.commentsTextView resignFirstResponder];
    }

}

- (void)intialiseTableViewWithFooter {
    [self.approvalpendingTSTableView removeFromSuperview];

    self.approvalpendingTSTableView = [[UITableView alloc] initWithFrame:[self contentViewFrame]
                                                                   style:UITableViewStylePlain];

    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = [[ApprovalsPendingTimeOffTableViewHeader alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.approvalpendingTSTableView.frame), 50)];
    approvalsPendingTimeOffTableViewHeader.delegate = self;
    self.approvalpendingTSTableView.tableHeaderView = approvalsPendingTimeOffTableViewHeader;

    [self.tableviewHeaderStylist styleApproveRejectHeader:approvalsPendingTimeOffTableViewHeader];

   self.approvalpendingTSTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.approvalpendingTSTableView.delegate = self;
    self.approvalpendingTSTableView.dataSource = self;
    [self.view addSubview:approvalpendingTSTableView];

    [self configureTableForPullToRefresh];
    [self checkToShowMoreButton];
}

//Implemented As Per US8194
- (void)addfooter:(id)sender {
    if ([sender tag] == 5001) {
        if ([self.listOfUsersArr count] > 0) {

            int height = 0;
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            float aspectRatio = (screenRect.size.height / screenRect.size.width);
            if (aspectRatio < 1.7)
                height = HeightTable4;
            else
                height = HeightTable5;

            [UIView beginAnimations:nil
                            context:NULL];
            [UIView setAnimationDuration:0.30];
            CGFloat heightOfTabBar = CGRectGetHeight(self.tabBarController.tabBar.frame);
            self.approvalpendingTSTableView.frame = [self contentViewFrame];
            self.footerView.frame = CGRectMake(0.0,
                                               self.approvalpendingTSTableView.frame.origin.y + approvalpendingTSTableView.frame.size.height - heightOfTabBar,
                                               self.approvalpendingTSTableView.frame.size.width,
                                               HeightFooter);
            UIImage *handlerDownImage = [Util thumbnailImage:HANDLER_DOWN_IMAGE];
            [self.footerBtn setBackgroundImage:handlerDownImage
                                      forState:UIControlStateNormal];
            self.footerBtn.tag = 5002;
            [UIView commitAnimations];

        }
    }
    else {
        [self resetView:NO];

        [UIView beginAnimations:nil
                        context:NULL];
        [UIView setAnimationDuration:0.30];
        //Fix for ios7//JUHI
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float version = [[UIDevice currentDevice].systemVersion newFloatValue];
        float height = 37;
        if (version >= 7.0) {
            CGRect frame = self.view.frame;
            frame.size.height = screenRect.size.height;
            self.view.frame = frame;
            height = 100;

        }
        CGFloat heightOfTabBar = CGRectGetHeight(self.tabBarController.tabBar.frame);
        self.approvalpendingTSTableView.frame = [self contentViewFrame];
        self.footerView.frame = CGRectMake(0.0,
                                           self.approvalpendingTSTableView.frame.origin.y + approvalpendingTSTableView.frame.size.height - heightOfTabBar,
                                           self.approvalpendingTSTableView.frame.size.width,
                                           HeightFooter);
        UIImage *handlerUPImage = [Util thumbnailImage:HANDLER_UP_IMAGE];
        [self.footerBtn setBackgroundImage:handlerUPImage
                                  forState:UIControlStateNormal];
        self.footerBtn.tag = 5001;
        [UIView commitAnimations];
        [self.commentsTextView resignFirstResponder];
    }
}

- (void)createFooter {

    NSArray *viewsToRemove = [self.footerView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    [self.footerView removeFromSuperview];

    CGFloat heightOfTabBar = CGRectGetHeight(self.tabBarController.tabBar.frame);
    UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                      self.approvalpendingTSTableView.frame.origin.y + approvalpendingTSTableView.frame.size.height - heightOfTabBar,
                                                                      self.approvalpendingTSTableView.frame.size.width,
                                                                      HeightFooter)];
    self.footerView = tempfooterView;

    [footerView setBackgroundColor:RepliconStandardWhiteColor];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    lineView.backgroundColor = [UIColor blackColor];
    [self.footerView addSubview:lineView];

    //Implemented As Per US8194
    UIImage *handlerUPImage = [Util thumbnailImage:HANDLER_UP_IMAGE];
    UIButton *tempfooterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.footerBtn = tempfooterBtn;
    self.footerBtn.frame = CGRectMake(0, 1.2, handlerUPImage.size.width, handlerUPImage.size.height);
    [self.footerBtn setBackgroundImage:handlerUPImage
                              forState:UIControlStateNormal];
    [self.footerBtn addTarget:self
                       action:@selector(addfooter:)
             forControlEvents:UIControlEventTouchUpInside];
    self.footerBtn.tag = 5001;
    [self.footerView addSubview:self.footerBtn];

    UILabel *approvalCommentLB = [[UILabel alloc] initWithFrame:CGRectMake(12.0, handlerUPImage.size.height + 4.0, self.view.frame.size.width, 30.0)];//Implemented As Per US8194
    [approvalCommentLB setText:RPLocalizedString(APPROVAL_COMMENT, @"")];
    [approvalCommentLB setTextColor:[Util colorWithHex:hexcolor_code
                                                 alpha:1]];
    [approvalCommentLB setFont:[UIFont fontWithName:RepliconFontFamilyBold
                                               size:RepliconFontSize_14]];
    [approvalCommentLB setBackgroundColor:[UIColor clearColor]];
    [self.footerView addSubview:approvalCommentLB];

    if (self.commentsTextView == nil) {
        UITextView *temptextField = [[UITextView alloc] initWithFrame:CGRectMake(10.0,
                                                                                 approvalCommentLB.frame.origin.y + approvalCommentLB.frame.size.height + 1,
                                                                                 WidthOfTextView,
                                                                                 HeightTextView)];//Implemented As Per US8194
        self.commentsTextView = temptextField;

    }
    self.commentsTextView.delegate = self;

    // For the border and rounded corners

    [[self.commentsTextView layer] setBorderColor:[[UIColor colorWithRed:153 / 255.0
                                                                   green:153 / 255.0
                                                                    blue:153 / 255.0
                                                                   alpha:0.7] CGColor]];
    [[self.commentsTextView layer] setBorderWidth:1.0];
    [[self.commentsTextView layer] setCornerRadius:9];
    [self.commentsTextView setClipsToBounds:YES];
    [self.commentsTextView setScrollEnabled:TRUE];
    self.commentsTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.commentsTextView.returnKeyType = UIReturnKeyDone;
    self.commentsTextView.keyboardType = UIKeyboardTypeASCIICapable;
    self.commentsTextView.textAlignment = NSTextAlignmentLeft;
    self.commentsTextView.textColor = RepliconStandardBlackColor;
    [self.commentsTextView setFont:[UIFont fontWithName:RepliconFontFamily
                                                   size:RepliconFontSize_14]];

    [self.footerView addSubview:self.commentsTextView];

    UIButton *rejectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *normalImg = [Util thumbnailImage:REJECT_UNPRESSED_IMG];
    UIImage *highlightedImg = [Util thumbnailImage:REJECT_PRESSED_IMG];

    [rejectButton setTitle:RPLocalizedString(REJECT_TEXT, REJECT_TEXT)
                  forState:UIControlStateNormal];
    [rejectButton setBackgroundImage:normalImg
                            forState:UIControlStateNormal];
    [rejectButton setBackgroundImage:highlightedImg
                            forState:UIControlStateHighlighted];

    [rejectButton setFrame:CGRectMake(12.0, commentsTextView.frame.origin.y + commentsTextView.frame.size.height + ButtonSpace, normalImg.size.width, normalImg.size.height)];
    [rejectButton addTarget:self
                     action:@selector(rejectAction:)
           forControlEvents:UIControlEventTouchUpInside];
    //rejectButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
    [rejectButton setTag:REJECT_BUTTON_TAG];

    [self.footerView addSubview:rejectButton];

    UIButton *approveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    normalImg = [Util thumbnailImage:APPROVE_UNPRESSED_IMG];
    highlightedImg = [Util thumbnailImage:APPROVE_PRESSED_IMG];

    [approveButton setTitle:RPLocalizedString(APPROVE_TEXT, APPROVE_TEXT)
                   forState:UIControlStateNormal];
    [approveButton setBackgroundImage:normalImg
                             forState:UIControlStateNormal];
    [approveButton setBackgroundImage:highlightedImg
                             forState:UIControlStateHighlighted];
    [approveButton setFrame:CGRectMake(165.0, commentsTextView.frame.origin.y + commentsTextView.frame.size.height + ButtonSpace, normalImg.size.width, normalImg.size.height)];
    [approveButton addTarget:self
                      action:@selector(approveAction:)
            forControlEvents:UIControlEventTouchUpInside];
    //approveButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
    [approveButton setTag:APPROVE_BUTTON_TAG];
    [approveButton setTitleColor:RepliconStandardBlackColor
                        forState:UIControlStateNormal];
    [self.footerView addSubview:approveButton];
    [self.view addSubview:self.footerView];

}

- (void)loadView {
    [super loadView];

    [self intialiseTableViewWithFooter];

    [Util setToolbarLabel:self
                 withText:RPLocalizedString(PENDING_APPROVALS_TIMEOFFS, PENDING_APPROVALS_TIMEOFFS)];

    NSMutableArray *tempselectedSheetsIDsArr = [[NSMutableArray alloc] init];
    self.selectedSheetsIDsArr = tempselectedSheetsIDsArr;
}

#pragma mark -
#pragma mark - UITableView Delegates

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)tableViewcell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableViewcell setBackgroundColor:[UIColor whiteColor]];
}

- (CGFloat)   tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Each_Cell_Row_Height_58;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.listOfUsersArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PendingApprovalsCellIdentifier";

    cell = (ApprovalsPendingCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ApprovalsPendingCustomCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CellIdentifier];
    }
    NSString *leftStr = @"";
    NSString *leftLowerStr = @"";

    NSMutableDictionary *userDict = [self.listOfUsersArr objectAtIndex:indexPath.row];
    leftStr = [userDict objectForKey:@"username"];
    leftLowerStr = [userDict objectForKey:@"timeoffTypeName"];

    NSString *time = nil;

    //Implemented As Per US7524

    NSDate *startDate = [Util convertTimestampFromDBToDate:[userDict objectForKey:@"startDate"]];
    NSDate *endDate = [Util convertTimestampFromDBToDate:[userDict objectForKey:@"endDate"]];

    NSDateFormatter *temp = [[NSDateFormatter alloc] init];
    [temp setDateFormat:@"MMM dd"];

    NSLocale *locale = [NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [temp setTimeZone:timeZone];
    [temp setLocale:locale];

    NSString *startDateStr = [temp stringFromDate:startDate];
    NSString *endDateStr = [temp stringFromDate:endDate];
    [temp setDateFormat:@"yyyy"];
    NSString *year = [temp stringFromDate:endDate];

    NSString *date = nil;
    [temp setDateFormat:@"yyyy-MM-dd"];

    
    NSDate *stDt = [temp dateFromString:[temp stringFromDate:startDate]];
    NSDate *endDt = [temp dateFromString:[temp stringFromDate:endDate]];
    
    if ((stDt != nil && endDt != nil) && [stDt compare:endDt] == NSOrderedSame) {
        date = [Util convertPickerDateToStringShortStyle:startDate];
    }
    else
        date = [NSString stringWithFormat:@"%@ - %@ , %@",
                startDateStr,
                endDateStr,year];
    
    NSString *timeOffDisplayFormatUri = userDict[@"timeOffDisplayFormatUri"];
    if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI]) {
        if (fabs([[userDict objectForKey:@"totalTimeoffDays"] newDoubleValue]) != 1.00) {
            time = [NSString stringWithFormat:@"%@ %@",
                    [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalTimeoffDays"] newDoubleValue]
                                         withDecimalPlaces:2], RPLocalizedString(@"days", @"")];
        }
        else {
            time = [NSString stringWithFormat:@"%@ %@",
                    [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalTimeoffDays"] newDoubleValue]
                                         withDecimalPlaces:2], RPLocalizedString(@"day", @"")];
        }
    }
    else{
        if (fabs([[userDict objectForKey:@"totalDurationDecimal"] newDoubleValue]) != 1.00) {
            time = [NSString stringWithFormat:@"%@ %@",
                    [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalDurationDecimal"] newDoubleValue]
                                         withDecimalPlaces:2], RPLocalizedString(@"hours", @"")];
        }
        else {
            time = [NSString stringWithFormat:@"%@ %@",
                    [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalDurationDecimal"] newDoubleValue]
                                         withDecimalPlaces:2], RPLocalizedString(@"hour", @"")];
        }
    }
    
    [cell setDelegate:self];
    [cell setTableDelegate:self];

    [cell createCellLayoutWithParams:leftStr
                     leftLowerString:leftLowerStr
                            rightstr:time
                    rightLowerString:date
                      radioButtonTag:indexPath.row];

    cell.userSelected = [self.selectedSheetsIDsArr containsObject:[userDict objectForKey:@"timeoffUri"]];

    UIImage *radioButtonImage = nil;
    if (cell.userSelected) {
        radioButtonImage = [UIImage imageNamed:@"icon_crewCheck"];
    }
    else {
        radioButtonImage = [UIImage imageNamed:@"icon_crewEmpty"];
    }

    [cell.radioButton setImage:radioButtonImage
                      forState:UIControlStateNormal];

    return cell;
}

- (void)      tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
        [Util showOfflineAlert];
        return;

    }
    CLS_LOG(@"-----Row selected on ApprovalsPendingTimeOffViewController -----");
    NSMutableDictionary *userDict = [self.listOfUsersArr objectAtIndex:indexPath.row];
    NSString *timeoffUri = [userDict objectForKey:@"timeoffUri"];

    //Implemented Approvals Pending DrillDown Loading UI
    self.selectedUserIndexpath = indexPath;

    [self viewAllTimeOffEntriesScreen];

    [self.notificationCenter removeObserver:self
                                       name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION
                                     object:nil];
    [self.notificationCenter addObserver:self.scrollViewController
                                selector:@selector(viewAllEntriesScreen:)
                                    name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION
                                  object:nil];

    NSArray *dbTimesheetArray = [self.approvalsModel getAllPendingTimeoffFromDBForTimeoff:timeoffUri];
    if ([dbTimesheetArray count] == 0) {
        [self.spinnerDelegate showTransparentLoadingOverlay];

        [self.approvalsService fetchApprovalPendingTimeoffEntryDataForBookedTimeoff:timeoffUri
                                                                       withDelegate:self];

    }
    else {
        [self.notificationCenter postNotificationName:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION
                                               object:nil];
    }

}

#pragma mark -
#pragma mark view update Methods

- (void)updatePreviouslySelectedTimeoffsRadioButtonStatus {
    for (int k = 0; k < [self.listOfUsersArr count]; k++) {
        NSString *timeoffUri = [[self.listOfUsersArr objectAtIndex:k] objectForKey:@"timeoffUri"];
        if ([self.selectedSheetsIDsArr containsObject:timeoffUri]) {
            NSMutableDictionary *userDict = [self.listOfUsersArr objectAtIndex:k];
            [userDict setObject:[NSNumber numberWithBool:YES]
                         forKey:@"IsSelected"];
            [self.listOfUsersArr replaceObjectAtIndex:k
                                           withObject:userDict];
        }
        else {
            NSMutableDictionary *userDict = [self.listOfUsersArr objectAtIndex:k];
            [userDict setObject:[NSNumber numberWithBool:NO]
                         forKey:@"IsSelected"];
            [self.listOfUsersArr replaceObjectAtIndex:k
                                           withObject:userDict];
        }
    }
}

- (void)handlePendingApprovalsDataReceivedAction {

    [self.notificationCenter removeObserver:self
                                       name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                     object:nil];
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [self.view setUserInteractionEnabled:YES];

    [self createListArrays];
    [self updatePreviouslySelectedTimeoffsRadioButtonStatus];
    if ([self.listOfUsersArr count] > 0)
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGRect frame = self.view.frame;
        frame.size.height = screenRect.size.height;
        self.view.frame = frame;

        self.approvalpendingTSTableView.frame = [self contentViewFrame];

        [self.msgLabel removeFromSuperview];
        self.approvalpendingTSTableView.scrollEnabled = TRUE;
       [self.approvalpendingTSTableView.tableHeaderView setHidden:NO];
    }
    else
    {
        [self showMessageLabel];
        self.approvalpendingTSTableView.frame = [self contentViewFrame];
    }



    [self checkToShowMoreButton];

    [self refreshTableView];
    
    // MI-558: After receiving more rows, "Select All" button is enabled instead of "Clear All"
    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    [approvalsPendingTimeOffTableViewHeader.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
}

- (void)approve_reject_Completed {
     [self.navigationController popViewControllerAnimated:YES];
    [self.notificationCenter removeObserver:self
                                       name:APPROVAL_REJECT_DONE_NOTIFICATION
                                     object:nil];
    self.commentsTextView.text = @"";

    [self handlePendingApprovalsDataReceivedAction];


    [self.selectedSheetsIDsArr removeAllObjects];

    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CLEAR_ALL_BUTTON_TAG;
    [approvalsPendingTimeOffTableViewHeader didToggleButtonForSelectOrClearAll:nil];
}

- (void)refreshTableView {
    [self.approvalpendingTSTableView reloadData];

    if ([self.listOfUsersArr count] == 0) {
        self.approvalpendingTSTableView.tableFooterView = nil;
        [self.footerView removeFromSuperview];
        [self showMessageLabel];
        [self.approvalpendingTSTableView setFrame:[self contentViewFrame]];
    } else
    {
        [self.msgLabel removeFromSuperview];
        [self.approvalpendingTSTableView.tableHeaderView setHidden:NO];

    }

    // MI-558: No need to clear selected everytime view referesh
    //[self.selectedSheetsIDsArr removeAllObjects];

    //ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    // approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CLEAR_ALL_BUTTON_TAG;
    // [approvalsPendingTimeOffTableViewHeader didToggleButtonForSelectOrClearAll:nil];
}

#pragma mark - <ApprovalsPendingTimeOffTableViewHeaderDelegate>

- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader
{
    [self approveAction:nil];
}

- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader
{
    [self rejectAction:nil];
}

- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader
{
    for (int i = 0; i < [self.listOfUsersArr count]; i++)
    {
        NSMutableDictionary *userDict = [self.listOfUsersArr objectAtIndex:i];
        if ([[userDict objectForKey:@"IsSelected"] intValue] != 1)
        {
            [userDict setObject:[NSNumber numberWithBool:YES] forKey:@"IsSelected"];
            [self.listOfUsersArr replaceObjectAtIndex:i withObject:userDict];
            [self.selectedSheetsIDsArr addObject:[userDict objectForKey:@"timeoffUri"]];
        }

    }

    [self.approvalpendingTSTableView reloadData];
}

- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToClearAll:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader
{
    for (int i = 0; i < [self.listOfUsersArr count]; i++)
    {
        NSMutableDictionary *userDict = [self.listOfUsersArr objectAtIndex:i];
        if ([[userDict objectForKey:@"IsSelected"] intValue] != 0)
        {
            [userDict setObject:[NSNumber numberWithBool:NO] forKey:@"IsSelected"];
            [self.listOfUsersArr replaceObjectAtIndex:i withObject:userDict];
            [self.selectedSheetsIDsArr removeObject:[userDict objectForKey:@"timeoffUri"]];
        }
    }

    [self.selectedSheetsIDsArr removeAllObjects];
    [self.approvalpendingTSTableView reloadData];
}

#pragma mark -
#pragma mark Other Methods

- (void)configureTableForPullToRefresh {
    ApprovalsPendingTimeOffViewController *weakSelf = self;

    [self.approvalpendingTSTableView addPullToRefreshWithActionHandler:^{

        int64_t delayInSeconds = 0.0;
        [weakSelf.approvalpendingTSTableView.pullToRefreshView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [weakSelf refreshAction];
        });
    }];

    [self.approvalpendingTSTableView addInfiniteScrollingWithActionHandler:^{
        int64_t delayInSeconds = 0.0;
        [weakSelf.approvalpendingTSTableView.infiniteScrollingView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [weakSelf moreAction];
        });
    }];

}

- (void)refreshAction {
    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
        [self.view setUserInteractionEnabled:YES];
        ApprovalsPendingTimeOffViewController *weakSelf = self;
        [weakSelf.approvalpendingTSTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Update record fetch action ApprovalsPendingTimeOffViewController -----");
    [self.notificationCenter removeObserver:self
                                       name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                     object:nil];
    [self.notificationCenter addObserver:self
                                selector:@selector(refreshViewFromPullToRefreshedData)
                                    name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                  object:nil];
    [self.approvalsService fetchSummaryOfTimeOffPendingApprovalsForUser:self];
    [self.loginService fetchGetMyNotificationSummary];
}

- (void)refreshActionForUriNotFoundError {

    if (![NetworkMonitor isNetworkAvailableForListener:self]) {

        [Util showOfflineAlert];

        return;

    }

    [self.spinnerDelegate showTransparentLoadingOverlay];

    CLS_LOG(@"-----Check for update action triggered on ApprovalsPendingTimeOffViewController-----");

    [self.notificationCenter addObserver:self
                                selector:@selector(refreshViewFromPullToRefreshedData)

                                    name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION

                                  object:nil];

    [self.approvalsService fetchSummaryOfTimeOffPendingApprovalsForUser:self];
}

- (void)refreshViewFromPullToRefreshedData {

    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    [approvalsPendingTimeOffTableViewHeader.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [self.view setUserInteractionEnabled:YES];
    [self.notificationCenter removeObserver:self
                                       name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                     object:nil];
    ApprovalsPendingTimeOffViewController *weakSelf = self;
    [weakSelf.approvalpendingTSTableView.pullToRefreshView stopAnimating];
    
    // MI-558: Need to clear all everytime view refresh
    [self.selectedSheetsIDsArr removeAllObjects];
    self.approvalpendingTSTableView.frame = [self contentViewFrame];
    [self handlePendingApprovalsDataReceivedAction];

}

- (void)moreAction {
    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
        [self.view setUserInteractionEnabled:YES];
        ApprovalsPendingTimeOffViewController *weakSelf = self;
        weakSelf.approvalpendingTSTableView.showsInfiniteScrolling = FALSE;
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----More record fetch action ApprovalsPendingTimeOffViewController -----");
    [self.notificationCenter removeObserver:self
                                       name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                     object:nil];
    [self.notificationCenter addObserver:self
                                selector:@selector(reloadViewAfterMoreDataFetchForPendingTimeOffs)
                                    name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                  object:nil];
    [self.approvalsService fetchSummaryOfNextPendingTimeOffsApprovalsForUser:self];
}

- (void)reloadViewAfterMoreDataFetchForPendingTimeOffs {
    [self.notificationCenter removeObserver:self
                                       name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                     object:nil];
    ApprovalsPendingTimeOffViewController *weakSelf = self;
    [weakSelf.approvalpendingTSTableView.infiniteScrollingView stopAnimating];
    self.approvalpendingTSTableView.frame = [self contentViewFrame];
    [self handlePendingApprovalsDataReceivedAction];
}

- (void)checkToShowMoreButton {

    NSNumber *timeOffsCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"pendingApprovalsTODownloadCount"];
    NSNumber *fetchCount = [[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];

    if (([timeOffsCount intValue] < [fetchCount intValue])) {
        self.approvalpendingTSTableView.showsInfiniteScrolling = FALSE;
    }
    else {
        self.approvalpendingTSTableView.showsInfiniteScrolling = TRUE;
    }
    [self changeTableViewInset];
}

- (void)handleButtonClickforSelectedUser:(NSIndexPath *)indexPath
                              isSelected:(BOOL)isSelected {

    NSMutableDictionary *userDict = [self.listOfUsersArr objectAtIndex:indexPath.row];
    [userDict setObject:[NSNumber numberWithBool:isSelected]
                 forKey:@"IsSelected"];
    [self.listOfUsersArr replaceObjectAtIndex:indexPath.row
                                   withObject:userDict];

    if (isSelected) {
        [self.selectedSheetsIDsArr addObject:[userDict objectForKey:@"timeoffUri"]];
    }
    else {
        [self.selectedSheetsIDsArr removeObject:[userDict objectForKey:@"timeoffUri"]];
    }

    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    if (self.selectedSheetsIDsArr.count== self.listOfUsersArr.count)
    {
        approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
        [approvalsPendingTimeOffTableViewHeader didToggleButtonForSelectOrClearAll:nil];
    }
    else if (self.selectedSheetsIDsArr.count== 0)
    {
        approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CLEAR_ALL_BUTTON_TAG;
        [approvalsPendingTimeOffTableViewHeader didToggleButtonForSelectOrClearAll:nil];
    }
    else if(self.selectedSheetsIDsArr.count < self.listOfUsersArr.count)
    {
        approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
        [approvalsPendingTimeOffTableViewHeader.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self resetView:YES];

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView setSelectedRange:NSMakeRange(0, 0)];
    return YES;
}

- (BOOL)       textView:(UITextView *)txtView
shouldChangeTextInRange:(NSRange)range
        replacementText:(NSString *)text {
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
        return YES;
    }
    [self resetView:NO];
    [txtView resignFirstResponder];
    return NO;
}

- (void)resetView:(BOOL)isReset {
    if (isReset) {
        approvalpendingTSTableView.userInteractionEnabled = NO;
        CGRect frame = self.footerView.frame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float aspectRatio = (screenRect.size.height / screenRect.size.width);

        if (aspectRatio >= 1.7)
            frame.origin.y = 60;
        else
            frame.origin.y = -10;

        [self.footerView setFrame:frame];
    }
    else {
        approvalpendingTSTableView.userInteractionEnabled = YES;
        CGRect frame = self.footerView.frame;
        frame.origin.y = self.approvalpendingTSTableView.frame.origin.y + approvalpendingTSTableView.frame.size.height;
        [self.footerView setFrame:frame];

    }
}

- (void)viewAllTimeOffEntriesScreen {
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [self.notificationCenter removeObserver:self
                                       name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION
                                     object:nil];

    NSUInteger countOfUsers = 0;
    NSMutableArray *allPendingTSArray = [NSMutableArray array];
    for (int i = 0; i < [self.listOfUsersArr count]; i++) {
        NSMutableDictionary *userDict = [self.listOfUsersArr objectAtIndex:i];

        [allPendingTSArray addObject:userDict];

    }
    countOfUsers = [self.listOfUsersArr count];
    if (countOfUsers > 0) {
        NSInteger indexCount = 0;
        for (int i = 0; i < [self.listOfUsersArr count]; i++) {
            NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:i];
            if (self.selectedUserIndexpath.section == i) {
                indexCount = indexCount + self.selectedUserIndexpath.row + 1;
                break;
            }
            else {
                indexCount = indexCount + [sectionedUsersArr count];
            }

        }
        indexCount = indexCount - 1;
        if (indexCount < 0) {
            indexCount = 0;
        }

        ApprovalsScrollViewController *tempscrollViewController = [[ApprovalsScrollViewController alloc] init];
        self.scrollViewController = tempscrollViewController;

        [self.scrollViewController setIndexCount:indexCount];
        [self.scrollViewController setListOfPendingItemsArray:allPendingTSArray];
        self.scrollViewController.currentViewIndex = 0;
        self.scrollViewController.sheetStatus = WAITING_FOR_APRROVAL_STATUS;
        self.scrollViewController.delegate = self;

        if (indexCount == 0) {
            self.scrollViewController.hasPreviousTimeSheets = FALSE;
        }
        else {
            self.scrollViewController.hasPreviousTimeSheets = TRUE;
        }

        if (indexCount == countOfUsers - 1 || countOfUsers == 0) {
            self.scrollViewController.hasNextTimeSheets = FALSE;
        }
        else {
            self.scrollViewController.hasNextTimeSheets = TRUE;
        }

        [scrollViewController setHidesBottomBarWhenPushed:NO];
        [self.navigationController pushViewController:self.scrollViewController
                                             animated:YES];

    }

}

#pragma mark -
#pragma mark approve and reject methods

- (void)rejectAction:(id)sender {
    if ([self.selectedSheetsIDsArr count] == 0) {

        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(APPROVAL_TIMEOFFS_VALIDATION_MSG, @"")
                                                  title:nil
                                                    tag:0];

        return;
    }
    else {

        NSArray *allDetailsArray = [self.loginModel getAllUserDetailsInfoFromDb];
        BOOL isCommentsRequiredForApproval = [[allDetailsArray.firstObject objectForKey:@"areTimeOffRejectCommentsRequired"] boolValue];
        if (isCommentsRequiredForApproval) {
            ApprovalCommentsController *approvalCommentsController = [self.injector getInstance:[ApprovalCommentsController class]];
            [approvalCommentsController setUpApprovalActionType:RejectActionType delegate:self  commentsRequired:isCommentsRequiredForApproval];
            [self.navigationController pushViewController:approvalCommentsController animated:YES];
        }
        else
        {
            [self rejectTimeoffsWithComments:(id)[NSNull null]];
        }
    }
}

- (void)approveAction:(id)sender {

    if ([self.selectedSheetsIDsArr count] == 0) {

        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(APPROVAL_TIMEOFFS_VALIDATION_MSG, @"")
                                                  title:nil
                                                    tag:0];

        return;
    }
    else
    {
        CLS_LOG(@"-----Approve action on ApprovalsPendingTimeOffViewController -----");
        [self resetView:NO];
        [self approveTimeOffsWithComments:(id)[NSNull null]];
    }

}

#pragma mark NetworkMonitor

- (void)networkActivated {
}


#pragma mark - <ApprovalCommentsControllerDelegate>

- (void)approvalsCommentsControllerDidRequestApproveAction:(ApprovalCommentsController *)approvalCommentsController withComments:(NSString *)comments
{
    [self approveTimeOffsWithComments:comments];
    [self.navigationController popToViewController:self animated:YES];
}

- (void)approvalsCommentsControllerDidRequestRejectAction:(ApprovalCommentsController *)approvalCommentsController withComments:(NSString *)comments
{
    [self rejectTimeoffsWithComments:comments];
    [self.navigationController popToViewController:self animated:YES];
}

- (void)approveTimeOffsWithComments:(NSString *)comments
{
    [self.spinnerDelegate showTransparentLoadingOverlay];
    [self.approvalsService sendRequestToApproveTimeOffsWithURI:self.selectedSheetsIDsArr
                                                  withComments:comments
                                                   andDelegate:self];
    [self.notificationCenter removeObserver:self
                                       name:APPROVAL_REJECT_DONE_NOTIFICATION
                                     object:nil];
    [self.notificationCenter addObserver:self
                                selector:@selector(approve_reject_Completed)
                                    name:APPROVAL_REJECT_DONE_NOTIFICATION
                                  object:nil];

}

- (void) rejectTimeoffsWithComments:(NSString *) comments
{
    [self resetView:NO];
    [self.spinnerDelegate showTransparentLoadingOverlay];

    [self.approvalsService sendRequestToRejectTimeOffsWithURI:self.selectedSheetsIDsArr
                                                 withComments:comments
                                                  andDelegate:self];
    [self.notificationCenter removeObserver:self
                                       name:APPROVAL_REJECT_DONE_NOTIFICATION
                                     object:nil];
    [self.notificationCenter addObserver:self
                                selector:@selector(approve_reject_Completed)
                                    name:APPROVAL_REJECT_DONE_NOTIFICATION
                                  object:nil];

}

-(void)reloadPendingApprovalsWhenLaunchedFromDeepLink{
    if(self.isFromDeepLink && [self.listOfUsersArr count] == 0){
        [self.msgLabel removeFromSuperview];
        if ([NetworkMonitor isNetworkAvailableForListener:self]){
            [self.spinnerDelegate showTransparentLoadingOverlay];
        }
        [self refreshAction];
        self.isFromDeepLink = NO;
    }
}

@end
