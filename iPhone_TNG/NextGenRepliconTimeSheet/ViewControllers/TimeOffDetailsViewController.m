//
//  TimeOffDetailsViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 2/2/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffDetailsViewController.h"
#import "TimeoffModel.h"
#import "TimeOffDetailsObject.h"
#import "BookedTimeOffDateSelectionViewController.h"
#import "FrameworkImport.h"
#import "Constants.h"
#import "RepliconServiceManager.h"
#import "UdfDropDownViewController.h"
#import "AddDescriptionViewController.h"
#import "ApproverCommentViewController.h"
#import "ApprovalActionsViewController.h"
#import "LoginModel.h"
#import "ApprovalsModel.h"
#import "ApprovalsScrollViewController.h"
#import "ListOfTimeSheetsViewController.h"
#import "ErrorBannerViewParentPresenterHelper.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"


#define DELETE_TIMEOFF_ALERT_TAG 5555
#define NO_TIMEOFF_TYPES_ALERT_TAG 6666
@interface TimeOffDetailsViewController ()<CommentsActionDelegate,UdfDropDownViewDelegate,TimeOffDetailsDateSelectionDelegate,BookedTimeOffDateSelectionDelegate,UdfUpdateDelegate,ApprovalDelegate>
@property(nonatomic,strong)TimeOffDetailsView *timeOffDetailsView;

@property (nonatomic,assign)BOOL isEditAcess;
@property (nonatomic,assign)BOOL isDeleteAcess;
@property (nonatomic,strong)UILabel *commentsTextLbl;
@property (nonatomic,strong)NSMutableArray *customFieldsArray;
@property (nonatomic,strong) NSMutableArray *customFieldsObjectsArray;
@property (nonatomic,strong) NSMutableArray *timesheetTimeoffEntryArray;
@property (nonatomic,strong) NSMutableArray *timesheetTimeoffCustomFieldArray;
@property (nonatomic,strong) NSString *timesheetFormat;
@end

@implementation TimeOffDetailsViewController

- (id)initWithEntryDetails :(TimeOffObject *)timeOffObj sheetId:(NSString *)_sheetIdentity screenMode:(NSInteger)_screenMode
{
    self = [super init];
    if (self != nil) {

        if (timeOffObj != nil) {
            [self setTimeOffObj:timeOffObj];
        }

        if (_sheetIdentity != nil) {
            [timeOffObj setSheetId:_sheetIdentity];
        }
        [self set_screenMode:_screenMode];
    }
    if(self._screenMode == ADD_BOOKTIMEOFF)
    {
        self.timeOffObj.isDeviceSupportedEntryConfiguration = TRUE;
    }
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    self.timesheetFormat=[timesheetModel getTimesheetFormatInfoFromDBForTimesheetUri:self.timesheetURI];
    [self registerForKeyboardNotification];
}

-(void)registerForKeyboardNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillBeOnScreen:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)deregisterKeyboardNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)keyboardWillBeOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:keyboardFrame.size.height forKey:@"KeyBoardHeight"];
    [userDefaults synchronize];
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
    NSUInteger topWindow = [allWindows count] - 1;
    UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
    for (UIView *view in keyboardWindow.subviews){
        if([view isKindOfClass:[UIButton class]] && (view.tag == DONE_BUTTON_TAG || view.tag == DOT_BUTTON_TAG)){
            CGRect buttonFrame = view.frame;
            buttonFrame.size.height = keyboardFrame.size.height/4;
            buttonFrame.origin.y = SCREEN_HEIGHT - buttonFrame.size.height;
            [UIView animateWithDuration:0.2f animations:^{
                view.frame = buttonFrame;
            }];
        }
    }
}

-(void)setNavigationButtonsForScreenMode:(NSInteger )mode{
    if (mode == VIEW_BOOKTIMEOFF){
    }else{
        //1.Add Cancel Button
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self action:@selector(cancelAction:)];
        if (mode == EDIT_BOOKTIMEOFF) {
            [cancelButton setTag:EDIT_BOOKTIMEOFF];
        }else {
            [cancelButton setTag:ADD_BOOKTIMEOFF];
        }
        [self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
    }
}

-(void)cancelAction:(id)sender
{
    CLS_LOG(@"-----Cancel Action on AddDescriptionViewController -----");
    if([sender tag]==EDIT_BOOKTIMEOFF)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([sender tag]==ADD_BOOKTIMEOFF)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.tabBarController.tabBar setHidden:NO];
    [self.timeOffDetailsView deselectTableViewSelection];
    [self registerForKeyboardNotifications];
    if ([self _screenMode]==ADD_BOOKTIMEOFF) {
        //self.timeOffDetailsView.timeOffDetailsTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    }

    if (self.timeOffDetailsView != nil && ![self.timeOffDetailsView isKindOfClass:[NSNull class]]) {
        [self.timeOffDetailsView  setTableViewInset];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
    [self removeRegisteredKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideTabBar:NO];
    [self.timeOffDetailsView endEditing:YES];
    [self deregisterKeyboardNotification];
}

-(void)TimeOffDetailsReceived
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    NSArray* dataArray=[NSArray array];
    [self setNavigationButtonsForScreenMode:self._screenMode];
    
        TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
        NSMutableArray *timeOffTypesArray=[timeoffModel getAllTimeOffTypesFromDB];
        if ([timeOffTypesArray count]==0 && [self _screenMode]==ADD_BOOKTIMEOFF)
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:self
                                                    message:RPLocalizedString(noTimeOffTypesAssigned, @"")
                                                      title:nil
                                                        tag:NO_TIMEOFF_TYPES_ALERT_TAG];
            return;
        }

    
    if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
       dataArray=[approvalsModel getAllPendingTimeoffFromDBForTimeoff:self.sheetIdString];
    }
    else if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMEOFF_MODULE])
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
         dataArray=[approvalsModel getAllPreviousTimeoffFromDBForTimeoff:self.sheetIdString];
    }
    else
    {
       dataArray=[timeoffModel getTimeoffInfoSheetIdentity:self.sheetIdString];
    }
    
    
    NSMutableDictionary *timeOffDataDict = [dataArray objectAtIndex:0];


    if ([timeOffDataDict objectForKey:@"hasTimeOffEditAcess"]!=nil && ![[timeOffDataDict objectForKey:@"hasTimeOffEditAcess"] isKindOfClass:[NSNull class]])
    {
         self.isEditAcess=[[timeOffDataDict objectForKey:@"hasTimeOffEditAcess"] boolValue];
    }
    if ([timeOffDataDict objectForKey:@"hasTimeOffDeletetAcess"]!=nil && ![[timeOffDataDict objectForKey:@"hasTimeOffDeletetAcess"] isKindOfClass:[NSNull class]])
    {
        self.isDeleteAcess=[[timeOffDataDict objectForKey:@"hasTimeOffDeletetAcess"] boolValue];
    }
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper = [appDelegate.injector getInstance:[ErrorBannerViewParentPresenterHelper class]];

    
    self.timeOffDetailsView = [[TimeOffDetailsView alloc] initWithFrame:self.view.bounds errorBannerViewParentPresenterHelper:errorBannerViewParentPresenterHelper];
    self.timeOffDetailsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.timeOffDetailsView setTimeOffDateSelectionDelegate:self];
    [self.timeOffDetailsView setUdfDropDownDelegate:self];
    self.timeOffDetailsView.timeOffViewDelegate = self.approvalDelegate;
    self.timeOffDetailsView.screenMode = self._screenMode;
    [self.view addSubview:self.timeOffDetailsView];

    [Util setToolbarLabel: self withText: RPLocalizedString(BOOKED_TIMEOFF_CHOOSE_DATES_TITLE, BOOKED_TIMEOFF_CHOOSE_DATES_TITLE)];
    NSString *toolbarTitleText = @"";
    if(self._screenMode == ADD_BOOKTIMEOFF)
    {
        toolbarTitleText = RPLocalizedString(AddBookTimeOffTitle, @"");
        self.timeOffDetailsView.add_Edit = TIMEOFF_ADD;
        self.timeOffObj.isDeviceSupportedEntryConfiguration = TRUE;
    }
    else
    {
        if(self._screenMode == EDIT_BOOKTIMEOFF)
        {
            toolbarTitleText = RPLocalizedString( ViewBookTimeOffTitle, @"");
            self.timeOffDetailsView.add_Edit = TIMEOFF_EDIT;
        }
        else if(self._screenMode == VIEW_BOOKTIMEOFF)
        {
            toolbarTitleText = RPLocalizedString(ViewBookTimeOffTitle, @"");
            self.timeOffDetailsView.add_Edit = TIMEOFF_VIEW;
        }
    }

    [Util setToolbarLabel: self withText: toolbarTitleText];
    self.customFieldsArray = [self _createTimeOffUdfsDetailsArray];
    [self.timeOffDetailsView setCustomFieldArray:self.customFieldsArray];

    if (self.navigationFlow==TIMEOFF_BOOKING_NAVIGATION) {

    }
    else if (self.navigationFlow==PREVIOUS_APPROVER_NAVIGATION || self.navigationFlow==PENDING_APPROVER_NAVIGATION) {
        NSMutableArray *dataArray = [NSMutableArray array];
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            dataArray=[approvalsModel getAllPendingTimeoffFromDBForTimeoff:self.sheetIdString];
        }
        else
        {
            dataArray=[approvalsModel getAllPreviousTimeoffFromDBForTimeoff:self.sheetIdString];
        }

    }
    
        for (int i=0; i<[dataArray count]; i++)
        {
            TimeOffObject *tempObj = [[TimeOffObject alloc] init];
            NSDictionary *dict= [dataArray objectAtIndex:i];
            if([dict objectForKey:@"totalTimeoffDays"]!=nil && ![[dict objectForKey:@"totalTimeoffDays"]isKindOfClass:[NSNull class]])
            {
               
                tempObj.totalTimeOffDays =  [Util getRoundedValueFromDecimalPlaces:[[dict objectForKey:@"totalTimeoffDays"]newDoubleValue]withDecimalPlaces:2];
            }

            if([dict objectForKey:@"totalDurationDecimal"]!=nil && ![[dict objectForKey:@"totalDurationDecimal"]isKindOfClass:[NSNull class]])
            {

                tempObj.numberOfHours =  [Util getRoundedValueFromDecimalPlaces:[[dict objectForKey:@"totalDurationDecimal"]newDoubleValue]withDecimalPlaces:2];;
            }
            if ([dict objectForKey:@"isDeviceSupportedEntryConfiguration"]!=nil && ![[dict objectForKey:@"isDeviceSupportedEntryConfiguration"] isKindOfClass:[NSNull class]])
            {
                tempObj.isDeviceSupportedEntryConfiguration = [[dict objectForKey:@"isDeviceSupportedEntryConfiguration"] boolValue];
            }
            tempObj.timeOffDisplayFormatUri=[dict objectForKey:@"timeOffDisplayFormatUri"];
            tempObj.sheetId=[dict objectForKey:@"timeoffUri"];
            tempObj.approvalStatus=[dict objectForKey:@"approvalStatus"];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMEOFF_MODULE])
            {
                self._screenMode=VIEW_BOOKTIMEOFF;
                self.isStatusView=YES;


            }

            if ([dict objectForKey:@"comments"]!=nil && ![[dict objectForKey:@"comments"]isKindOfClass:[NSNull class]] && ![[dict objectForKey:@"comments"] isEqualToString:@"<null>"]) {
                tempObj.comments=[dict objectForKey:@"comments"];
            }
            else
                tempObj.comments=@"";
            tempObj.bookedEndDate=[Util convertTimestampFromDBToDate:[[dict objectForKey:@"endDate"] stringValue]];
            if ([[dict objectForKey:@"endEntryDurationUri"] isEqualToString:FULLDAY_DURATION_TYPE_KEY])
            {
                tempObj.endDurationEntryType=FULLDAY_DURATION_TYPE_KEY;
            }
            else if ([[dict objectForKey:@"endEntryDurationUri"] isEqualToString:HALFDAY_DURATION_TYPE_KEY])
            {
                tempObj.endDurationEntryType=HALFDAY_DURATION_TYPE_KEY;
            }
            else if ([[dict objectForKey:@"endEntryDurationUri"] isEqualToString:THREEQUARTERDAY_DURATION_KEY])
            {
                tempObj.endDurationEntryType=THREEQUARTERDAY_DURATION_KEY;
            }
            else if([[dict objectForKey:@"endEntryDurationUri"] isEqualToString:QUARTERDAY_DURATION_KEY])
            {
                tempObj.endDurationEntryType=QUARTERDAY_DURATION_KEY;
            }
            else
                tempObj.endDurationEntryType=PARTIAL ;

            if ([dict objectForKey:@"endDateTime"]!=nil && ![[dict objectForKey:@"endDateTime"]isKindOfClass:[NSNull class]]) {
                tempObj.endTime=[dict objectForKey:@"endDateTime"];
            }

            tempObj.endNumberOfHours=[Util getRoundedValueFromDecimalPlaces:[[dict objectForKey:@"endDateDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
            tempObj.bookedStartDate=[Util convertTimestampFromDBToDate:[[dict objectForKey:@"startDate"] stringValue]];
            if ([[dict objectForKey:@"startEntryDurationUri"] isEqualToString:FULLDAY_DURATION_TYPE_KEY])
            {
                tempObj.startDurationEntryType=FULLDAY_DURATION_TYPE_KEY;
            }
            else if ([[dict objectForKey:@"startEntryDurationUri"] isEqualToString:HALFDAY_DURATION_TYPE_KEY])
            {
                tempObj.startDurationEntryType=HALFDAY_DURATION_TYPE_KEY;
            }
            else if ([[dict objectForKey:@"startEntryDurationUri"] isEqualToString:THREEQUARTERDAY_DURATION_KEY])
            {
                tempObj.startDurationEntryType=THREEQUARTERDAY_DURATION_KEY;
            }
            else if([[dict objectForKey:@"startEntryDurationUri"] isEqualToString:QUARTERDAY_DURATION_KEY])
            {
                tempObj.startDurationEntryType=QUARTERDAY_DURATION_KEY;
            }
            else
                tempObj.startDurationEntryType=PARTIAL ;

            if ([dict objectForKey:@"startDateTime"]!=nil && ![[dict objectForKey:@"startDateTime"]isKindOfClass:[NSNull class]]) {
                tempObj.startTime=[dict objectForKey:@"startDateTime"];
            }
            tempObj.startNumberOfHours=[Util getRoundedValueFromDecimalPlaces:[[dict objectForKey:@"startDateDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
            tempObj.typeName=[dict objectForKey:@"timeoffTypeName"];
            tempObj.typeIdentity=[dict objectForKey:@"timeoffTypeUri"];
            tempObj.numberOfHours=[Util getRoundedValueFromDecimalPlaces:[[dict objectForKey:@"totalDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
            
            self.isEditAcess=[[dict objectForKey:@"hasTimeOffEditAcess"] boolValue];
            self.isDeleteAcess=[[dict objectForKey:@"hasTimeOffDeletetAcess"] boolValue];
            
            self.timeOffDetailsView.userName =self.userName;
            self.timeOffDetailsView.timeoffType=self.timeoffType;
            self.timeOffDetailsView.isStatusView=YES;
            self.timeOffDetailsView.screenMode=VIEW_BOOKTIMEOFF;
            [self.timeOffDetailsView setSheetIdString:self.sheetIdString];
            [self.timeOffDetailsView setSheetStatus:self.sheetStatus];
            self.timeOffDetailsView.currentViewTag = self.currentViewTag;
            [self.timeOffDetailsView setDueDate:self.sheetStatus];

            [self.timeOffDetailsView setCurrentNumberOfView:self.currentNumberOfView];
            [self.timeOffDetailsView setTotalNumberOfView:self.totalNumberOfView];
            [self.timeOffDetailsView setNavigationFlow:self.navigationFlow];
            if(self.navigationFlow == PENDING_APPROVER_NAVIGATION)
            {
                [self.timeOffDetailsView setApprovalsModuleName:APPROVALS_PENDING_TIMEOFF_MODULE];
            }
            else if(self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
            {
                [self.timeOffDetailsView setApprovalsModuleName:APPROVALS_PREVIOUS_TIMEOFF_MODULE];
            }
            self.timeOffObj =tempObj;
        }
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    self.timeOffDetailsView.parentDelegate = self.parentDelegate;
    self.timeOffDetailsView.approvalDelegate = self.approvalDelegate;
    [self.timeOffDetailsView setIsStatusView:self.isStatusView];
    self.timeOffDetailsView.isEditAccess = self.isEditAcess;
    self.timeOffDetailsView.isDeleteAccess = self.isDeleteAcess;
    [self.timeOffDetailsView setUpTimeOffDetailsView:self.timeOffObj :self.navigationFlow];
    [self.timeOffDetailsView reloadTableViewFromTimeOffDetails];
    

}



-(void)TimeOffDetailsResponse
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TimeOffDetailsReceived) name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];

    if (self._screenMode==ADD_BOOKTIMEOFF || [self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE] || [self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMEOFF_MODULE])
    {   AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    }
    else
    {
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[RepliconServiceManager timesheetService]fetchTimeoffEntryDataForBookedTimeoff:self.sheetIdString withTimeSheetUri:self.timesheetURI];
    }

}


#pragma mark - Keyboard Notifications Used for TimeOff Comments
-(void)timeOffCommentsNavigation
{
    AddDescriptionViewController *tempaddDescriptionViewController  = [[AddDescriptionViewController alloc]init];
    tempaddDescriptionViewController.fromTimeoffEntryComments =YES;
    if([self.timeOffObj comments]!=nil)
    {
        if([self.timeOffObj comments]!=nil && ![[self.timeOffObj comments] isKindOfClass:[NSNull class]])
        {
            [tempaddDescriptionViewController setDescTextString:[self.timeOffObj comments]];
        }
        else
        {
            [tempaddDescriptionViewController setDescTextString:RPLocalizedString(ADD, @"")];
        }
    }
    else
    {
        [tempaddDescriptionViewController setDescTextString:@""];
    }
    [tempaddDescriptionViewController setViewTitle: RPLocalizedString(Comments,@"")];
    tempaddDescriptionViewController.descControlDelegate=self;
    tempaddDescriptionViewController.navigationFlow = TIMEOFF_BOOKING_NAVIGATION;
    [tempaddDescriptionViewController setIsNonEditable:NO];
    [self.navigationController pushViewController:tempaddDescriptionViewController animated:YES];

}

-(void)updateComments:(NSString *)commentsText
{
    [self.timeOffDetailsView UpdateComments:commentsText];
}

#pragma mark - Keyboard Notifications Used for UDF
/************************************************************************************************************
 @Function Name   : register_For_KeyboardNotifications
 @Purpose         : To register for keyboard appear/disappear Notifications and to resize tableview to see selected content
 @param           : nil
 @Source          : https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
 *************************************************************************************************************/

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self.timeOffDetailsView
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self.timeOffDetailsView
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

-(void)removeRegisteredKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.timeOffDetailsView name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.timeOffDetailsView name:UIKeyboardWillHideNotification object:nil];

}

- (void)_keyboardWillShow:(NSNotification *)note {
    [self.timeOffDetailsView showToolBarWithAnimation:YES];
}

- (void)_keyboardWillHide:(NSNotification *)note {
    [self.timeOffDetailsView hideToolBarWithAnimation:YES];
}

-(void)createViewWithTimeOffObject:(TimeOffObject *)timeOffObj
{

}

-(void)didSelectDateSelection:(NSIndexPath *)selectedIndex timeOffObj:(TimeOffObject *)timeOffObj
{
    self.timeOffObj = timeOffObj;
    BookedTimeOffDateSelectionViewController *bookedTimeOffDateSelectionViewController=[[BookedTimeOffDateSelectionViewController alloc]init];
    bookedTimeOffDateSelectionViewController.delegate=self;
    bookedTimeOffDateSelectionViewController.navigationFlow = TIMEOFF_BOOKING_NAVIGATION;
    bookedTimeOffDateSelectionViewController.entryDelegate=self;
    if ([self.timeOffObj bookedStartDate]!=nil && [self.timeOffObj bookedEndDate]!=nil) {
        if (selectedIndex.row==1)
        {
            bookedTimeOffDateSelectionViewController.selectedStartDate=[self.timeOffObj bookedStartDate];
            bookedTimeOffDateSelectionViewController.selectedEndDate=[self.timeOffObj bookedEndDate];
            bookedTimeOffDateSelectionViewController.screenMode=SELECT_START_DATE_SCREEN;
        }
        else if (selectedIndex.row==2)
        {
            bookedTimeOffDateSelectionViewController.selectedStartDate=[self.timeOffObj bookedStartDate];
            bookedTimeOffDateSelectionViewController.selectedEndDate=[self.timeOffObj bookedEndDate];
            bookedTimeOffDateSelectionViewController.screenMode=SELECT_END_DATE_SCREEN;
        }
    }
    else {
        if (selectedIndex.row==1)
        {
            bookedTimeOffDateSelectionViewController.screenMode=SELECT_START_DATE_SCREEN;
        }
        else if (selectedIndex.row==2)
        {
            bookedTimeOffDateSelectionViewController.screenMode=SELECT_END_DATE_SCREEN;
        }
        bookedTimeOffDateSelectionViewController.selectedStartDate=[self.timeOffObj bookedStartDate];
        bookedTimeOffDateSelectionViewController.selectedEndDate=[self.timeOffObj bookedEndDate];
    }
    [self.navigationController pushViewController:bookedTimeOffDateSelectionViewController animated:TRUE];
}


- (void)didSelectStartAndEndDate:(NSDate *)startDate forEndDate:(NSDate *)endDate
{
    if (startDate!=nil && endDate!=nil) {
        BOOL isStartEndDateNotSame=[self checkForStartAndEndDate];
        if(isStartEndDateNotSame)
        {
            self.timeOffObj.endDurationEntryType = DAYMODE;
//            if ([startDate isEqualToDate:self.timeOffObj.bookedStartDate]) {
//            self.timeOffObj.startDurationEntryType = DAYMODE;
//            }
        }
        if ([startDate compare:endDate]==NSOrderedAscending)
        {
            self.timeOffObj.bookedStartDate=startDate;
            self.timeOffObj.bookedEndDate=endDate;
        }
        else {
            self.timeOffObj.bookedStartDate=endDate;
            self.timeOffObj.bookedEndDate=startDate;
        }
    }
    else {
        if (startDate!=nil) {
            self.timeOffObj.bookedStartDate=startDate;
        }
        if (endDate!=nil) {
            self.timeOffObj.bookedEndDate=endDate;
        }
    }

    [self.timeOffDetailsView updateStartAndDate:self.timeOffObj];
    [self requestForBalance];
    [self.timeOffDetailsView deselectTableViewSelection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)balanceCalculationMethod:(NSInteger)startDurationEntryTypeMode :(NSInteger)endDurationEntryMode :(TimeOffObject *)timeoffObject
{
    if (timeoffObject.isDeviceSupportedEntryConfiguration) {
        BOOL checkForBalanceValidation = [self checkForBalnaceValidation:startDurationEntryTypeMode :endDurationEntryMode :timeoffObject];
        if(checkForBalanceValidation)
        {
            [self requestForBalance];
        }
    }
}

-(BOOL)checkForBalnaceValidation :(NSInteger)startDurationEntryTypeMode :(NSInteger)endDurationEntryMode :(TimeOffObject *)timeoffObject
{
    [self setTimeOffObj:timeoffObject];
    if ([self.timeOffObj bookedEndDate]!=nil && [self.timeOffObj bookedStartDate]!=nil && (([self.timeOffObj typeIdentity]!=nil &&![[self.timeOffObj typeIdentity] isKindOfClass:[NSNull class]]) && ([self.timeOffObj typeName]!=nil &&![[self.timeOffObj typeName] isKindOfClass:[NSNull class]]))) {
        BOOL isStartEndDateNotSame=[self checkForStartAndEndDate];
        if (!isStartEndDateNotSame && startDurationEntryTypeMode!=PARTIALDAYMODE)
        {
            return YES;
        }
        else if (!isStartEndDateNotSame && startDurationEntryTypeMode==PARTIALDAYMODE)
        {
//            if(([self.timeOffObj startTime]!=nil && ![[self.timeOffObj startTime]isEqualToString:@""]) &&([self.timeOffObj startNumberOfHours]!=nil && ![[self.timeOffObj startNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]))
//            {
//                return YES;
//            }
//            else
//                return NO;
            return YES;
        }
        else if (!isStartEndDateNotSame && startDurationEntryTypeMode!=PARTIALDAYMODE)
        {
            if (startDurationEntryTypeMode!=DAYMODE)
            {
                if(([self.timeOffObj startTime]!=nil && ![[self.timeOffObj startTime]isEqualToString:@""]))
                {
                    return YES;
                }
                else
                    return NO;
            }

        }
        else{
            if (startDurationEntryTypeMode==PARTIALDAYMODE && endDurationEntryMode ==PARTIALDAYMODE)
            {
                if (([self.timeOffObj startTime]!=nil && ![[self.timeOffObj startTime]isEqualToString:@""]) && ([self.timeOffObj endTime]!=nil && ![[self.timeOffObj endTime]isEqualToString:@""]) && ([self.timeOffObj startNumberOfHours]!=nil && ![[self.timeOffObj startNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]) && ([self.timeOffObj endNumberOfHours]!=nil &&![[self.timeOffObj endNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]))
                {
                    return YES;
                }

                else
                    return NO;
            }
            else if (startDurationEntryTypeMode==PARTIALDAYMODE && endDurationEntryMode !=PARTIALDAYMODE)
            {
                if (endDurationEntryMode==DAYMODE)
                {
//                    if(([self.timeOffObj startTime]!=nil && ![[self.timeOffObj startTime]isEqualToString:@""]) &&([self.timeOffObj startNumberOfHours]!=nil && ![[self.timeOffObj startNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]))
//                    {
//                        return YES;
//                    }
//                    else
//                        return NO;
                    return YES;
                }
                else
                {
                    if(([self.timeOffObj startTime]!=nil && ![[self.timeOffObj startTime]isEqualToString:@""]) &&([self.timeOffObj startNumberOfHours]!=nil && ![[self.timeOffObj startNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]])&&([self.timeOffObj endTime]!=nil && ![[self.timeOffObj endTime]isEqualToString:@""]))
                    {
                        return YES;
                    }
                    else
                        return NO;
                }


            }
            else if (startDurationEntryTypeMode!=PARTIALDAYMODE && endDurationEntryMode ==PARTIALDAYMODE )
            {
                if (startDurationEntryTypeMode==DAYMODE)
                {
                    if (([self.timeOffObj endTime]!=nil && ![[self.timeOffObj endTime]isEqualToString:@""]) && ([self.timeOffObj endNumberOfHours]!=nil &&![[self.timeOffObj endNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]))
                    {
                        return YES;
                    }
                    else
                        return NO;
                }
                else
                {
                    if(([self.timeOffObj startTime]!=nil && ![[self.timeOffObj startTime]isEqualToString:@""]) &&([self.timeOffObj endNumberOfHours]!=nil &&![[self.timeOffObj endNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]])&&([self.timeOffObj endTime]!=nil && ![[self.timeOffObj endTime]isEqualToString:@""]))
                    {
                        return YES;
                    }
                    else
                        return NO;
                }
            }
            else if (startDurationEntryTypeMode!=PARTIALDAYMODE && endDurationEntryMode !=PARTIALDAYMODE )
            {
                if (startDurationEntryTypeMode!=DAYMODE && endDurationEntryMode ==DAYMODE ) {
//                    if (([self.timeOffObj startTime]!=nil && ![[self.timeOffObj startTime]isEqualToString:@""]) )
//                    {
//                        return YES;
//                    }
//                    else
//                        return NO;
                    return YES;
                }
                else if (startDurationEntryTypeMode==DAYMODE && endDurationEntryMode !=DAYMODE ) {
                    if (([self.timeOffObj endTime]!=nil && ![[self.timeOffObj endTime]isEqualToString:@""]) )
                    {
                        return YES;
                    }
                    else
                        return NO;
                }
                else if (startDurationEntryTypeMode!=DAYMODE && endDurationEntryMode !=DAYMODE ) {
                    if (([self.timeOffObj endTime]!=nil && ![[self.timeOffObj endTime]isEqualToString:@""])&& ([self.timeOffObj startTime]!=nil && ![[self.timeOffObj startTime]isEqualToString:@""]) )
                    {
                        return YES;
                    }
                    else
                        return NO;
                }
                else if (startDurationEntryTypeMode==DAYMODE && endDurationEntryMode ==DAYMODE )
                {
                    return YES;
                }
            }
            else if (startDurationEntryTypeMode==DAYMODE && endDurationEntryMode ==DAYMODE )
            {
                return YES;
            }
        }
    }
    else if (self.timeOffDetailsView.isShowingPicker)
        return YES;
    return NO;
}

-(void)requestForBalance{

    NSMutableArray *dataArray=[NSMutableArray arrayWithObject:self.timeOffObj];
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    if([self.timeOffObj bookedEndDate]!=nil && [self.timeOffObj bookedStartDate]!=nil)
    {
        self.timeOffDetailsView.balanceValueLbl.text=RPLocalizedString(@"Loading...", @" ") ;
        self.timeOffDetailsView.requestedValueLbl.text=RPLocalizedString(@"Loading...", @" ") ;
    }
    else
    {
        self.timeOffDetailsView.balanceValueLbl.text=RPLocalizedString(@"N/A", @" ") ;
        self.timeOffDetailsView.requestedValueLbl.text=RPLocalizedString(@"N/A", @" ") ;
    }
    if (self.navigationFlow==TIMEOFF_BOOKING_NAVIGATION)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recievedBalanceNotification:) name:TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];

        /*if (([[self.timeOffObj approvalStatus] isEqualToString:WAITING_FOR_APRROVAL_STATUS] && !self.isEditAcess)||[[self.timeOffObj approvalStatus] isEqualToString:APPROVED_STATUS ]) {
            [[RepliconServiceManager timeoffService]sendRequestToGetTimeOffBalanceSummaryForBookedTimeoff:[self.timeOffObj sheetId] withDelegate:self];
        }
        else*/
            [[RepliconServiceManager timeoffService]sendRequestToBookedTimeOffBalancesDataForTimeoffURI:@"" withEntryArray:dataArray withDelegate:UNKNOWN_NAVIGATION];
    }
    else if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
    {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recievedBalanceNotification:) name:TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];

        if (([[self.timeOffObj approvalStatus] isEqualToString:WAITING_FOR_APRROVAL_STATUS] && !self.isEditAcess)||[[self.timeOffObj approvalStatus] isEqualToString:APPROVED_STATUS ]||[[self.timeOffObj approvalStatus] isEqualToString:REJECTED_STATUS])
        {
            if ([self.approvalDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(recievedBalanceNotification:) name:APPROVALS_TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];

                [[RepliconServiceManager approvalsService]sendRequestToBookedTimeOffBalancesDataForTimeoffURI:[self.timeOffObj sheetId] withEntryArray:dataArray withUserUri:self.userUri];
            }
            else
            {
                [[RepliconServiceManager timeoffService]sendRequestToBookedTimeOffBalancesDataForTimeoffURI:@"" withEntryArray:dataArray withDelegate:UNKNOWN_NAVIGATION];
            }

        }
        else
        {

            if ([self.approvalDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(recievedBalanceNotification:) name:APPROVALS_TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];

                [[RepliconServiceManager approvalsService]sendRequestToBookedTimeOffBalancesDataForTimeoffURI:[self.timeOffObj sheetId] withEntryArray:dataArray withUserUri:self.userUri];
            }
            else
            {
              [[RepliconServiceManager timeoffService]sendRequestToBookedTimeOffBalancesDataForTimeoffURI:@"" withEntryArray:dataArray withDelegate:self.navigationFlow];
            }



        }
    }
    else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recievedBalanceNotification:) name:APPROVALS_TIMEOFF_BALANCESUMMARY_RECEIVED_NOTIFICATION object:nil];

         [[RepliconServiceManager approvalsService]sendRequestToBookedTimeOffBalancesDataForTimeoffURI:[self.timeOffObj sheetId] withEntryArray:dataArray withUserUri:self.userUri];
    }
}

-(void)recievedBalanceNotification:(NSNotification *)notificationObject
{
    NSDictionary *dataDict = [notificationObject userInfo];
    NSLog(@"%@",dataDict);
    [self.timeOffDetailsView updateBalanceValue:dataDict :self._screenMode];
}

-(BOOL)checkForStartAndEndDate{
    NSDateFormatter *temp = [[NSDateFormatter alloc] init];
    [temp setDateFormat:@"yyyy-MM-dd"];

    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [temp setTimeZone:timeZone];
    [temp setLocale:locale];

    NSDate *stDt = [temp dateFromString:[temp stringFromDate:[self.timeOffObj bookedStartDate]]];
    NSDate *endDt =  [temp dateFromString:[temp stringFromDate:[self.timeOffObj bookedEndDate]]];



    if ((stDt!=nil && endDt!=nil) && [stDt compare:endDt]==NSOrderedSame)
    {
        return YES;
    }

    return NO;
}


#pragma mark -
#pragma mark Creating UDF Objects for Table Row methods
/************************************************************************************************************
 @Function Name   : Create UDF objects
 @Purpose         : Called to create UDF objects for tableview.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(NSArray *)_createTimeOffUdfsDetailsArray
{
    int decimalPlace=0;
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:TIMEOFF_UDF];


    NSMutableArray *customFieldArray=[[NSMutableArray alloc]init];
    NSString *sheetApprovalStatus=[self.timeOffObj approvalStatus];

    for (int i=0; i<[udfArray count]; i++)
    {
        NSDictionary *udfDict = [udfArray objectAtIndex: i];
        NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
        [dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
        [dictInfo setObject:[udfDict objectForKey:@"uri"] forKey:@"identity"];
        if ([[udfDict objectForKey:@"udfType"] isEqualToString: NUMERIC_UDF_TYPE])
        {
            [dictInfo setObject:NUMERIC_UDF_TYPE forKey:@"fieldType"];

            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"numericDecimalPlaces"]!=nil && !([[udfDict objectForKey:@"numericDecimalPlaces"] isKindOfClass:[NSNull class]])){
                decimalPlace=[[udfDict objectForKey:@"numericDecimalPlaces"] intValue];
                [dictInfo setObject:[udfDict objectForKey:@"numericDecimalPlaces"] forKey:@"defaultDecimalValue"];
            }
            if ([udfDict objectForKey:@"numericMinValue"]!=nil && !([[udfDict objectForKey:@"numericMinValue"] isKindOfClass:[NSNull class]])) {
                [dictInfo setObject:[udfDict objectForKey:@"numericMinValue"] forKey:@"defaultMinValue"];
            }
            if ([udfDict objectForKey:@"numericMaxValue"]!=nil && !([[udfDict objectForKey:@"numericMaxValue"] isKindOfClass:[NSNull class]])) {
                [dictInfo setObject:[udfDict objectForKey:@"numericMaxValue"] forKey:@"defaultMaxValue"];
            }

            if ([udfDict objectForKey:@"numericDefaultValue"]!=nil && !([[udfDict objectForKey:@"numericDefaultValue"] isKindOfClass:[NSNull class]])&&![[udfDict objectForKey:@"numericDefaultValue"] isEqualToString:@""])
            {
                [dictInfo setObject:[Util getRoundedValueFromDecimalPlaces:[[udfDict objectForKey:@"numericDefaultValue"] newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"defaultValue"];
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:TEXT_UDF_TYPE])
        {
            [dictInfo setObject:TEXT_UDF_TYPE forKey:@"fieldType"];
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:@"" forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"textDefaultValue"]!=nil && ![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]]){
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""]&& (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@"null"])) {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                }
            }

            if ([udfDict objectForKey:@"textMaxValue"]!=nil && !([[udfDict objectForKey:@"textMaxValue"] isKindOfClass:[NSNull class]]))
                [dictInfo setObject:[udfDict objectForKey:@"textMaxValue"] forKey:@"defaultMaxValue"];
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DATE_UDF_TYPE])
        {
            [dictInfo setObject: DATE_UDF_TYPE forKey: @"fieldType"];

            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"dateMaxValue"]!=nil && !([[udfDict objectForKey:@"dateMaxValue"] isKindOfClass:[NSNull class]]))
            {
                [dictInfo setObject:[udfDict objectForKey:@"dateMaxValue"] forKey:@"defaultMaxValue"];
            }
            if ([udfDict objectForKey:@"dateMinValue"]!=nil && !([[udfDict objectForKey:@"dateMinValue"] isKindOfClass:[NSNull class]]))
            {
                [dictInfo setObject:[udfDict objectForKey:@"dateMinValue"] forKey:@"defaultMinValue"];
            }

            if ([udfDict objectForKey:@"isDateDefaultValueToday"]!=nil && !([[udfDict objectForKey:@"isDateDefaultValueToday"] isKindOfClass:[NSNull class]]))
            {
                if ([[udfDict objectForKey:@"isDateDefaultValueToday"]intValue]==1)
                {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormat setLocale:locale];
                    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                    NSString *dateStr = [dateFormat stringFromDate:[NSDate date]];
                    NSDate *dateToBeUsed=[dateFormat dateFromString:dateStr];
                    [dictInfo setObject:dateToBeUsed forKey:@"defaultValue"];


                }else
                {
                    if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];

                    }
                    else
                    {
                        if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                            [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        }
                        else
                            [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
                    }
                }
            }
            else {
                if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormat setLocale:locale];
                    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormat setDateFormat:@"MMMM dd, yyyy"];

                    NSDate *dateToBeUsed = [Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]];
                    NSString *dateStr = [dateFormat stringFromDate:dateToBeUsed];
                    dateToBeUsed=[dateFormat dateFromString:dateStr];

                    if (dateToBeUsed==nil) {
                        [dateFormat setDateFormat:@"d MMMM yyyy"];
                        dateToBeUsed = [dateFormat dateFromString:dateStr];

                    }


                    NSString *dateDefaultValueFormatted = [Util convertPickerDateToString:dateToBeUsed];

                    if(dateDefaultValueFormatted != nil)
                    {
                        [dictInfo setObject:dateToBeUsed forKey:@"defaultValue"];

                    }
                    else
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];
                    }
                }
                else
                {
                    if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                        [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else
                        [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
                }
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DROPDOWN_UDF_TYPE])
        {
            [dictInfo setObject:DROPDOWN_UDF_TYPE forKey:@"fieldType"];
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
            if ([udfDict objectForKey:@"textDefaultValue"]!=nil &&![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]])
            {
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""])
                {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"dropDownOptionDefaultURI"] forKey:@"dropDownOptionUri"];

                }
            }
        }
        NSArray *selectedudfArray=nil;
        if (self.navigationFlow==PENDING_APPROVER_NAVIGATION||self.navigationFlow==PREVIOUS_APPROVER_NAVIGATION)
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if (self.navigationFlow==PENDING_APPROVER_NAVIGATION)
            {
                selectedudfArray=[approvalsModel getPendingTimeOffCustomFieldsForSheetURI:self.sheetIdString moduleName:TIMEOFF_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];
            }
            else
            {
                selectedudfArray=[approvalsModel getPreviousTimeOffCustomFieldsForSheetURI:self.sheetIdString moduleName:TIMEOFF_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];
            }
        }
        else
        {
            TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
            selectedudfArray=[timeoffModel getTimeOffCustomFieldsForSheetURI:self.sheetIdString moduleName:TIMEOFF_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];

        }
        if ([selectedudfArray count]>0)
        {
            NSMutableDictionary *selUDFDataDict=[selectedudfArray objectAtIndex:0];
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            if (selUDFDataDict!=nil && ![selUDFDataDict isKindOfClass:[NSNull class]]) {
                NSString *udfvaleFormDb=[selUDFDataDict objectForKey: @"udfValue"];
                if (udfvaleFormDb!=nil && ![udfvaleFormDb isKindOfClass:[NSNull class]])
                {
                    if (![udfvaleFormDb isEqualToString:@""]) {
                        if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DATE_UDF_TYPE])
                        {
                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

                            NSLocale *locale=[NSLocale currentLocale];
                            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [dateFormat setLocale:locale];
                            [dateFormat setDateFormat:@"yyyy-MM-dd"];
                            NSDate *setDate=[dateFormat dateFromString:udfvaleFormDb];
                            if (!setDate) {
                                [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                                setDate=[dateFormat dateFromString:udfvaleFormDb];

                                if (setDate==nil) {
                                    [dateFormat setDateFormat:@"d MMMM yyyy"];
                                    setDate = [dateFormat dateFromString:udfvaleFormDb];
                                    if (setDate==nil)
                                    {
                                        [dateFormat setDateFormat:@"d MMMM, yyyy"];
                                        setDate = [dateFormat dateFromString:udfvaleFormDb];

                                    }
                                }

                            }
                            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                            udfvaleFormDb=[dateFormat stringFromDate:setDate];
                            NSDate *dateToBeUsed = [dateFormat dateFromString:udfvaleFormDb];

                            [udfDetailDict setObject:dateToBeUsed forKey:@"defaultValue"];
                        }
                        else{
                            if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:NUMERIC_UDF_TYPE])
                            {
                                [udfDetailDict setObject:[Util getRoundedValueFromDecimalPlaces:[udfvaleFormDb newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"defaultValue"];
                            }
                            else
                                [udfDetailDict setObject:udfvaleFormDb forKey:@"defaultValue"];
                            if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                            {
                                [udfDetailDict setObject:[selUDFDataDict objectForKey: @"dropDownOptionURI" ] forKey:@"dropDownOptionUri"];
                            }
                        }
                    }
                    else
                    {
                        if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])) {
                            [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        }
                        else
                            [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];
                    }

                }
                else
                {
                    if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])) {
                        [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else
                        [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

                }
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];

                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
                [udfDetailDict setObject:[dictInfo objectForKey: @"identity"] forKey:@"uri"];
                if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultDecimalValue" ] forKey:@"defaultDecimalValue"];
                }
                if ([dictInfo objectForKey: @"defaultMinValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMinValue" ] forKey:@"defaultMinValue"];
                }
                if ([dictInfo objectForKey: @"defaultMaxValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMaxValue" ] forKey:@"defaultMaxValue"];
                }

                if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                {
                    if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
                    {
                        [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
                    }
                }
                [customFieldArray addObject:udfDetailDict];
            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])) {
                [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];

            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
            [udfDetailDict setObject:[dictInfo objectForKey: @"identity"] forKey:@"uri"];
            if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultDecimalValue" ] forKey:@"defaultDecimalValue"];
            }
            if ([dictInfo objectForKey: @"defaultMinValue" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMinValue" ] forKey:@"defaultMinValue"];
            }
            if ([dictInfo objectForKey: @"defaultMaxValue" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMaxValue" ] forKey:@"defaultMaxValue"];
            }
            if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
            }
            [customFieldArray addObject:udfDetailDict];
        }
    }
    return customFieldArray;
}

#pragma mark - Navigation Actions callback from View
- (void)textUdfNavigation:(TimeOffDetailsView *)timeOffDetailsView withUdfObject:(UdfObject *)udfObject{
    CLS_LOG(@"-----Text UDF clicked on TimesheetDetailsViewController-----");
    [self removeRegisteredKeyboardNotifications];
    CommentsViewController *commentsViewController=[[CommentsViewController alloc]init];
    [commentsViewController setCommentsActionDelegate:self.timeOffDetailsView];
    [commentsViewController setUpCommentsViewControllerWithUdfObject:udfObject withNavigationFlow:self.navigationFlow withTimesheetListObject:nil withTimeOffObj:self.timeOffObj];
    
    if (self.navigationFlow==TIMEOFF_BOOKING_NAVIGATION)
    {
        [self.navigationController pushViewController:commentsViewController animated:YES];
    }
    else if (self.navigationFlow==TIMESHEET_PERIOD_NAVIGATION)
    {
        [self.navigationController pushViewController:commentsViewController animated:YES];
    }
    else if (self.navigationFlow==PREVIOUS_APPROVER_NAVIGATION || self.navigationFlow==PENDING_APPROVER_NAVIGATION)
    {
        [self.approvalDelegate pushToViewController:commentsViewController];
    }
    
}

- (void)dropdownUdfNavigation:(TimeOffDetailsView *)timeOffDetailsView withUdfObject:(UdfObject *)udfObject{
    CLS_LOG(@"-----Dropdown UDF clicked on TimesheetDetailsViewController-----");
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    UdfDropDownViewController *dropDownViewCtrl=[[UdfDropDownViewController alloc]init];
    [dropDownViewCtrl setDelegate:self.timeOffDetailsView];
    [dropDownViewCtrl intialiseDropDownViewWithUdfObject:udfObject withNaviagtion:self.navigationFlow withTimesheetListObject:nil withTimeOffObj:self.timeOffObj];
    [self.navigationController pushViewController:dropDownViewCtrl animated:YES];
}

- (void)updateUdfValue:(TimeOffDetailsView *)timeOffDetailsView withUdfObject:(UdfObject *)udfObject
{
    if ([udfObject udfType]==UDF_TYPE_TEXT) {
        NSLog(@"Text UDF Selected For UDF:::%@",[udfObject defaultValue]);
    }
    else if ([udfObject udfType]==UDF_TYPE_NUMERIC){

        NSLog(@"Number UDF Selected For UDF:::%@",[udfObject defaultValue]);
    }
    else if ([udfObject udfType]==UDF_TYPE_DATE) {

        NSLog(@"Date UDF Selected For UDF:::%@",[udfObject defaultValue]);
    }
    else if ([udfObject udfType]==UDF_TYPE_DROPDOWN){

        NSLog(@"Dropdown UDF Selected For UDF:::%@",[udfObject defaultValue]);
    }
}
#pragma mark - Handle Table Header tap
/************************************************************************************************************
 @Function Name   : Table Header tap
 @Purpose         : Load all timeOff when tapped on the tableHeader
 @param           : nil
 @Source          : nil
 *************************************************************************************************************/

-(void)approvalCommentDetailAction{
    NSMutableArray *arrayFromDB=nil;
    ApproverCommentViewController *approverCommentCtrl=[[ApproverCommentViewController alloc]init];
    approverCommentCtrl.sheetIdentity=self.sheetIdString;
    approverCommentCtrl.viewType=@"BookedTimeoff";

    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];

    if (self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION || self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
    {
        arrayFromDB=[timeoffModel getAllApprovalHistoryForTimeoffUri:self.sheetIdString];
        approverCommentCtrl.delegate=self;
    }
    else if(self.navigationFlow == PENDING_APPROVER_NAVIGATION || self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
    {
        approverCommentCtrl.delegate=self.approvalDelegate;
        ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMEOFF_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPendingTimeoffApprovalFromDBForTimeoff:self.sheetIdString];
        }
        else if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMEOFF_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPreviousTimeoffApprovalFromDBForTimeoff:self.sheetIdString];
        }
        approverCommentCtrl.approvalsModuleName=self.approvalsModuleName;
    }

    if ([arrayFromDB count]>0)
    {
        if (self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION || self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
        {
            [self.navigationController pushViewController:approverCommentCtrl animated:YES];
        }
        else if(self.navigationFlow == PENDING_APPROVER_NAVIGATION || self.navigationFlow == PREVIOUS_APPROVER_NAVIGATION)
        {
            [self.approvalDelegate pushToViewController:approverCommentCtrl];
        }
    }
}

#pragma mark - Handle Save Action
/************************************************************************************************************
 @Function Name   : Table Header tap
 @Purpose         : Load all timeOff when tapped on the tableHeader
 @param           : nil
 @Source          : nil
 *************************************************************************************************************/
-(void)validateAndSumbit :(NSInteger)startDurationEntryTypeMode :(NSInteger)endDurationEntryMode :(TimeOffObject *)timeoffObject :(NSInteger)screenMode :(NSMutableArray *)customFieldsObj
{
    [self setCustomFieldsObjectsArray:customFieldsObj];
    [self set_screenMode:screenMode];
    if ([self.timeOffObj bookedEndDate]!=nil && [self.timeOffObj bookedStartDate]!=nil) {

        BOOL isStartEndDateNotSame=[self checkForStartAndEndDate];

        if (!isStartEndDateNotSame && startDurationEntryTypeMode!=PARTIALDAYMODE){
            [self requestForSubmit];

        }

        else if (!isStartEndDateNotSame && startDurationEntryTypeMode==PARTIALDAYMODE)
        {
            if(([self.timeOffObj startNumberOfHours]==nil ||[[self.timeOffObj startNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]))
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(StartHourErrorMsg,@"")];
                return;
            }
            else{
                [self requestForSubmit];
            }
        }
        else{
            if (startDurationEntryTypeMode==PARTIALDAYMODE && endDurationEntryMode ==PARTIALDAYMODE) {

                if (([self.timeOffObj startNumberOfHours]==nil ||[[self.timeOffObj startNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]) && ([self.timeOffObj endNumberOfHours]==nil||[[self.timeOffObj endNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]))
                {
                    [Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@"%@ \n  & \n  %@",RPLocalizedString(StartHourErrorMsg,@""),RPLocalizedString(EndHourErrorMsg,@"")]];
                    return;
                }
                else if(([self.timeOffObj startNumberOfHours]!=nil &&![[self.timeOffObj startNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]) && ([self.timeOffObj endNumberOfHours]==nil||[[self.timeOffObj endNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]))
                {
                    [Util errorAlert:@"" errorMessage:RPLocalizedString(EndHourErrorMsg,@"")];
                    return;
                }

                else if(([self.timeOffObj startNumberOfHours]==nil ||[[self.timeOffObj startNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]) && ([self.timeOffObj endNumberOfHours]!=nil&&![[self.timeOffObj endNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]]))
                {
                    [Util errorAlert:@"" errorMessage:RPLocalizedString(StartHourErrorMsg,@"")];
                    return;
                }
                else{
                    [self requestForSubmit];
                }
            }
            else if (startDurationEntryTypeMode==PARTIALDAYMODE && endDurationEntryMode !=PARTIALDAYMODE)
            {
                if([self.timeOffObj startNumberOfHours]==nil ||[[self.timeOffObj startNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]])
                {
                    [Util errorAlert:@"" errorMessage:RPLocalizedString(StartHourErrorMsg,@"")];
                    return;
                }
                else{
                    [self requestForSubmit];
                }
            }
            else if (startDurationEntryTypeMode!=PARTIALDAYMODE && endDurationEntryMode ==PARTIALDAYMODE)
            {
                if([self.timeOffObj endNumberOfHours]==nil||[[self.timeOffObj endNumberOfHours]isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]])
                {
                    [Util errorAlert:@"" errorMessage:RPLocalizedString(EndHourErrorMsg,@"")];

                }
                else{
                    [self requestForSubmit];
                }
            }

            else{
                [self requestForSubmit];
            }

        }
    }
}
-(void)requestForSubmit{

    NSMutableArray *dataArray=[NSMutableArray arrayWithObject:self.timeOffObj];

    if (self._screenMode==EDIT_BOOKTIMEOFF || self._screenMode==VIEW_BOOKTIMEOFF)
    {
        CLS_LOG(@"-----Resubmit button clicked on BookedTimeOffEntryViewController-----");

        ApprovalActionsViewController *approvalActionsViewController = [[ApprovalActionsViewController alloc] init];
        NSDateFormatter *temp = [[NSDateFormatter alloc] init];
        [temp setDateFormat:@"yyyy-MM-dd"];

        NSLocale *locale=[NSLocale currentLocale];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [temp setTimeZone:timeZone];
        [temp setLocale:locale];

        NSDate *stDt = [temp dateFromString:[temp stringFromDate:[self.timeOffObj bookedStartDate]]];
        NSDate *endDt =  [temp dateFromString:[temp stringFromDate:[self.timeOffObj bookedEndDate]]];

        NSString *date=nil;
        if ((stDt!=nil && endDt!=nil) && [stDt compare:endDt]==NSOrderedSame)
        {
            date=[Util convertPickerDateToStringShortStyle:self.timeOffObj.bookedStartDate];
        }
        else
        {
            NSString *startDate=[Util convertPickerDateToStringShortStyle:self.timeOffObj.bookedStartDate];
            NSString *endDate=[Util convertPickerDateToStringShortStyle:self.timeOffObj.bookedEndDate];
            date =[NSString stringWithFormat:@"%@ - %@",startDate,endDate];
        }

        [approvalActionsViewController setSelectedSheet:date];
        [approvalActionsViewController setAllowBlankComments:NO];
        [approvalActionsViewController setActionType:@"Re-Submit"];
        [approvalActionsViewController setDelegate:self];
        [approvalActionsViewController setArrayOfEntriesForSave:dataArray];
        [self.navigationController pushViewController:approvalActionsViewController animated:YES];
    }

    else
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;

        }
        CLS_LOG(@"-----Submit timeoff entry on BookedTimeOffEntryViewController -----");
        [self submitRequestForTimeOffSubmissionAndSave:dataArray];

    }


}



-(void)submitRequestForTimeOffSubmissionAndSave:(NSMutableArray *)dataArray
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(TimeOffSubmittedAction) name:TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    if (self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION) {
        if (([[self.timeOffObj approvalStatus] isEqualToString:WAITING_FOR_APRROVAL_STATUS]||[[self.timeOffObj approvalStatus] isEqualToString:APPROVED_STATUS])&& self._screenMode==EDIT_BOOKTIMEOFF)
        {
            [[RepliconServiceManager timeoffService]sendRequestToResubmitBookedTimeOffDataForTimeoffURI:@"" withEntryArray:dataArray andUdfArray:self.customFieldsObjectsArray withDelegate:self];
        }
        else
        {
            [[RepliconServiceManager timeoffService]sendRequestToSaveBookedTimeOffDataForTimeoffURI:@"" withEntryArray:dataArray andUdfArray:self.customFieldsObjectsArray withDelegate:self];
        }
    }

    else if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION){
        if (([[self.timeOffObj approvalStatus] isEqualToString:WAITING_FOR_APRROVAL_STATUS]||[[self.timeOffObj approvalStatus] isEqualToString:APPROVED_STATUS])&& self._screenMode==EDIT_BOOKTIMEOFF)
        {
            [[RepliconServiceManager timesheetService]sendRequestToResubmitBookedTimeOffDataForTimeoffURI:@"" withEntryArray:dataArray andUdfArray:self.customFieldsObjectsArray withDelegate:self];
        }
        else
        {
            [[RepliconServiceManager timesheetService]sendRequestToSaveBookedTimeOffDataForTimeoffURI:@"" withEntryArray:dataArray andUdfArray:self.customFieldsObjectsArray withDelegate:self];
        }
    }
}
-(void)TimeOffSubmittedAction
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_SAVEDATA_RECEIVED_NOTIFICATION object:nil];
   
    if (self._screenMode==EDIT_BOOKTIMEOFF||self._screenMode==VIEW_BOOKTIMEOFF) {
        if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataForSave) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];

            [[RepliconServiceManager timesheetService]fetchTimeSheetSummaryDataForTimesheet:self.timesheetURI withDelegate:self];
        }
        else
        {
             [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else if (self._screenMode == ADD_BOOKTIMEOFF) {
        if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataForSave) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];

            [[RepliconServiceManager timesheetService]fetchTimeSheetSummaryDataForTimesheet:self.timesheetURI withDelegate:self];
        }
        else
        {
             [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
         [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
        {
            [self.navigationController popToViewController:self.parentDelegate animated:YES];
        }
        else
            [self.navigationController popToRootViewControllerAnimated:self.parentDelegate];
    }
}

-(void)receivedDataForSave
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

    if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
    {
        BOOL isGen4Timesheet=NO;

        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]]&& ([self.timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET]))
        {
            isGen4Timesheet=YES;
        }

        if (isGen4Timesheet)
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",self.timesheetURI];
            NSArray *arrayDict=[timesheetModel getTimeSheetInfoSheetIdentity:self.timesheetURI];

            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:self.timesheetFormat forKey:@"timesheetFormat"];
                [myDB updateTable:@"Timesheets" data:updateDataDict where:updateWhereStr intoDatabase:@""];
            }

        }

    }


    if([self.parentDelegate isKindOfClass:[TimesheetMainPageController class]] || [self.timeSheetMainDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *timesheetMainPageController=nil;
        if ([self.parentDelegate isKindOfClass:[TimesheetMainPageController class]])
        {
            timesheetMainPageController=(TimesheetMainPageController *)self.parentDelegate;
        }
        else
        {
            timesheetMainPageController=(TimesheetMainPageController *)self.timeSheetMainDelegate;
        }
        
//        [self.parentDelegate navigationTitle];
        [timesheetMainPageController setHasUserChangedAnyValue:YES];
        [timesheetMainPageController reloadViewWithRefreshedDataAfterBookedTimeoffSave];
    }
    if (self._screenMode == ADD_BOOKTIMEOFF) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [self.navigationController popViewControllerAnimated:TRUE];

}
-(void)deleteTimeOff:(TimeOffObject *)timeoffObj
{
    self.timeOffObj = timeoffObj;
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{

#ifdef PHASE1_US2152
        [Util showOfflineAlert];
        return;
#endif
    }
    NSString * message = [NSString stringWithFormat:@"%@",RPLocalizedString(DELETE_BOOKTIMEOFF_MSG, DELETE_BOOKTIMEOFF_MSG)];

    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"No", @"No")
                                   otherButtonTitle:RPLocalizedString(@"Yes", @"Yes")
                                           delegate:self
                                            message:message
                                              title:nil
                                                tag:DELETE_TIMEOFF_ALERT_TAG];
}



/*
 Localization for the button title and the message should be done by the calling method
 */
-(void)confirmAlert:(NSString *)_buttonTitle confirmMessage:(NSString*)message {

    UIAlertView *confirmAlertView = [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(Cancel_Button_Title, Cancel_Button_Title)
                                   otherButtonTitle:RPLocalizedString(_buttonTitle,@"")
                                           delegate:self
                                            message:message
                                              title:nil
                                                tag:0];

    if (_buttonTitle == RPLocalizedString(Delete_Button_title, Delete_Button_title)) {
        confirmAlertView.tag=1;
    }
 }


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 1 && alertView.tag==DELETE_TIMEOFF_ALERT_TAG)
    {


        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;
        }
        else
        {
            [(UIAlertView *)alertView dismissWithClickedButtonIndex:[(UIAlertView *)alertView cancelButtonIndex] animated:NO];

            [[NSNotificationCenter defaultCenter] removeObserver:self name:BOOKEDTIMEOFF_DELETED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeleteAction) name:BOOKEDTIMEOFF_DELETED_NOTIFICATION object:nil];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            //Implemented as per TOFF-115//JUHI
            if (self.navigationFlow == TIMEOFF_BOOKING_NAVIGATION)
            {
                [[RepliconServiceManager timeoffService]sendRequestToDeleteTimeoffDataForURI:self.timeOffObj.sheetId];
            }

            else if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
            {
                [[RepliconServiceManager timesheetService]sendRequestToDeleteTimeoffDataForURI:self.timeOffObj.sheetId];
            }
        }
    }
    else if (buttonIndex == 0 && alertView.tag==NO_TIMEOFF_TYPES_ALERT_TAG)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(void)handleDeleteAction
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BOOKEDTIMEOFF_DELETED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

    TimeoffModel *timeOffModel=[[TimeoffModel alloc]init];
    [timeOffModel deleteTimeOffBalanceSummaryForMultiday:self.timeOffObj.sheetId];
    [timeOffModel deleteTimeOffFromDBForSheetUri:self.timeOffObj.sheetId];

    if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
    {
        BOOL isGen4Timesheet=NO;

        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]]&& ([self.timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET]))
        {
            isGen4Timesheet=YES;
        }

        if (isGen4Timesheet)
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",self.timesheetURI];
            NSArray *arrayDict=[timesheetModel getTimeSheetInfoSheetIdentity:self.timesheetURI];

            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:self.timesheetFormat forKey:@"timesheetFormat"];
                [myDB updateTable:@"Timesheets" data:updateDataDict where:updateWhereStr intoDatabase:@""];
            }
            
        }
        
    }


    if (self._screenMode == ADD_BOOKTIMEOFF)
    {
        if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
        {
            //Implemented as per TIME-495//JUHI
            SQLiteDB *myDB = [SQLiteDB getInstance];
            [myDB deleteFromTable:@"Time_entries" where:[NSString stringWithFormat:@"timesheetUri = '%@'",self.timesheetURI]inDatabase:@""];
            BOOL isGen4Timesheet=NO;

            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]]&& ([self.timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET]))
            {
                isGen4Timesheet=YES;
            }

            if (isGen4Timesheet)
            {
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

                [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedTimesheetApprovalSummaryInfoNotification:) name:TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION object:nil];
                [[RepliconServiceManager timesheetService]sendRequestToGetTimesheetApprovalSummaryForTimesheetUri:self.timesheetURI delegate:self];
            }
            else{

                 [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataForSave) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];

                [[RepliconServiceManager timesheetService]fetchTimeSheetSummaryDataForTimesheet:self.timesheetURI withDelegate:self];
            }

        }
        else
            [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if (self.navigationFlow == TIMESHEET_PERIOD_NAVIGATION)
        {
            //Fix as suggested by juhi
            if (self._screenMode==EDIT_BOOKTIMEOFF || (self._screenMode==VIEW_BOOKTIMEOFF && self.isDeleteAcess))
            {
                //Implemented as per TIME-495//JUHI
                SQLiteDB *myDB = [SQLiteDB getInstance];
                [myDB deleteFromTable:@"Time_entries" where:[NSString stringWithFormat:@"timesheetUri = '%@' AND rowUri = '%@' AND timeOffUri = '%@'",self.timesheetURI,self.timeOffObj.sheetId,self.timeOffObj.typeIdentity]inDatabase:@""];
                BOOL isGen4Timesheet=NO;
                if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]]&&([self.timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET]))
                {
                    isGen4Timesheet=YES;
                }
                if (isGen4Timesheet)
                {
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

                    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedTimesheetApprovalSummaryInfoNotification:) name:TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION object:nil];
                    [[RepliconServiceManager timesheetService]sendRequestToGetTimesheetApprovalSummaryForTimesheetUri:self.timesheetURI delegate:self];

                }
                else{

                   [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

                    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDataForSave) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];

                    [[RepliconServiceManager timesheetService]fetchTimeSheetSummaryDataForTimesheet:self.timesheetURI withDelegate:self];
                }


            }
            else
            {
                [self.navigationController popToViewController:self.parentDelegate animated:TRUE];
            }

        }
        else
        {
            [self.navigationController popToRootViewControllerAnimated:TRUE];
        }

    }

   if (self.navigationFlow != TIMESHEET_PERIOD_NAVIGATION)
   {
     [self.navigationController popToRootViewControllerAnimated:TRUE];
   }


}


#pragma mark - Handle Table Footer tap
/************************************************************************************************************
 @Function Name   : Table Header tap
 @Purpose         : Approvals Approve/Reject action
 @param           : approval comments and button id
 @Source          : nil
 *************************************************************************************************************/
-(void)handleApprovalsAction:(NSInteger)sender withApprovalComments:(NSString *)approvalComments
{
    if ([self.approvalDelegate respondsToSelector:@selector(handleApproveOrRejectActionWithApproverComments:andSenderTag:)])
    {
        [self.approvalDelegate handleApproveOrRejectActionWithApproverComments:approvalComments andSenderTag:sender];
    }
}

-(void)handleTableHeaderAction:(NSInteger)currentViewTag :(NSInteger)buttonTag
{
    if ([self.approvalDelegate respondsToSelector:@selector(handlePreviousNextButtonFromApprovalsListforViewTag:forbuttonTag:)])
    {
        [self.approvalDelegate handlePreviousNextButtonFromApprovalsListforViewTag:self.currentViewTag forbuttonTag:buttonTag];
    }
}

-(void)hideTabBar:(BOOL)hideTabBar
{
    if (hideTabBar)
        [self.tabBarController.tabBar setHidden:YES];
    else
        [self.tabBarController.tabBar setHidden:NO];

}

-(void)receivedTimesheetApprovalSummaryInfoNotification:(NSNotification*)not
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_APPROVAL_SUMMARY_GEN4_RECEIVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    if([self.parentDelegate isKindOfClass:[TimesheetMainPageController class]] || [self.timeSheetMainDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *timesheetMainPageController=nil;
        if ([self.parentDelegate isKindOfClass:[TimesheetMainPageController class]])
        {
            timesheetMainPageController=(TimesheetMainPageController *)self.parentDelegate;
        }
        else
        {
             timesheetMainPageController=(TimesheetMainPageController *)self.timeSheetMainDelegate;
        }
        
        
        //[timesheetMainPageController navigationTitle];
        [timesheetMainPageController setHasUserChangedAnyValue:YES];
        [timesheetMainPageController reloadViewWithRefreshedDataAfterBookedTimeoffSave];
    }
    if (self._screenMode == ADD_BOOKTIMEOFF) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
        [self.navigationController popViewControllerAnimated:TRUE];
}



@end
