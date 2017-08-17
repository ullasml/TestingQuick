//
//  ApprovalActionsViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 3/28/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ApprovalActionsViewController.h"
#import "Util.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "CurrentTimesheetViewController.h"
#import "LoginModel.h"
#import "ExpenseEntryObject.h"
#import "TimesheetSubmitReasonViewController.h"
#import "WidgetTSViewController.h"
#import "TimeOffDetailsViewController.h"
#import "TimesheetSyncOperationManager.h"
#import "ResponseHandler.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "ApproveTimesheetContainerController.h"
#import "LegacyTimesheetApprovalInfo.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "TimesheetContainerController.h"
#import "SupervisorTimesheetDetailsSeriesController.h"
#import <repliconkit/repliconkit.h>

@interface ApprovalActionsViewController ()

@property (nonatomic) LegacyTimesheetApprovalInfo *legacyTimesheetApprovalInfo;

@end

@implementation ApprovalActionsViewController
@synthesize submitTextView;
@synthesize resubmitButton;
@synthesize reasonLabel;
@synthesize cancelButton;
@synthesize sheetIdentity;
@synthesize selectedSheet;
@synthesize allowBlankComments;
@synthesize actionType;
@synthesize delegate;
@synthesize timesheetLevelUdfArray;
@synthesize isReopenClicked;
@synthesize isMultiDayInOutTimesheetUser;
@synthesize arrayOfEntriesForSave;
@synthesize isDisclaimerRequired;
@synthesize isExtendedInoutUser;
#define RESUBMIT_TAG 0
#define REOPEN_TAG 1
#define SUBMIT_TAG 2
#define SUBMIT_TAG_ASTRO 3

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)setUpWithSheetUri:(NSString *)sheetUri selectedSheet:(NSString *)sheet allowBlankComments:(BOOL)commentsAllow actionType:(NSString *)action delegate:(id)parentDelegate
{
    self.sheetIdentity = sheetUri;
    self.selectedSheet = sheet;
    self.allowBlankComments = commentsAllow;
    self.actionType = action;
    self.delegate = parentDelegate;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

     [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [Util setToolbarLabel:self withText: RPLocalizedString(Resubmit_Button_title,@" ")];

    if ([delegate isKindOfClass:[ApproveTimesheetContainerController class]] || [delegate isKindOfClass:[TimesheetContainerController class]] )
    {

        if ([actionType isEqualToString:@"Re-Submit_Astro"])
        {
             [Util setToolbarLabel:self withText: RPLocalizedString(@"Re-Submit",@" ")];
        }
        else
        {
             [Util setToolbarLabel:self withText: RPLocalizedString(self.actionType,@" ")];
        }

    }
    
    
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    //1.Add SubmitTextView
    if (submitTextView == nil) {
        UITextView *tempsubmitTextView = [[UITextView alloc] init];
        
        self.submitTextView=tempsubmitTextView;
        
        submitTextView.frame = CGRectMake(10.0, 54.0, SCREEN_WIDTH-20, 126.0);
    }
    
    CGRect screenRect =[[UIScreen mainScreen] bounds];
    float aspectRatio=(screenRect.size.height/screenRect.size.width);
    
    if (aspectRatio>=1.7)
    {
        CGRect frame=submitTextView.frame;
        frame.size.height=186.0;
        frame.origin.y=64.0;
        submitTextView.frame = frame;
    }
    
    
    
    
    
    submitTextView.textColor = RepliconStandardBlackColor;//US4275//Juhi
    [submitTextView setShowsVerticalScrollIndicator:YES];
    submitTextView.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15];
    submitTextView.delegate = self;
    submitTextView.backgroundColor = [UIColor whiteColor];
    submitTextView.returnKeyType = UIReturnKeyDone;
    submitTextView.keyboardType = UIKeyboardTypeASCIICapable;
    submitTextView.scrollEnabled = YES;
    [[submitTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[submitTextView layer] setBorderWidth:1.0];
    [[submitTextView layer] setCornerRadius:9];
    [submitTextView setClipsToBounds: YES];
    //[submitTextView setScrollEnabled:FALSE];
    //submitTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:submitTextView];
    
    //2.Add SheetLabel
    //US4275//Juhi
    UILabel *sheetLabel= [[UILabel alloc]initWithFrame:SheetLabelFrame];
    sheetLabel.font =[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15];
    [sheetLabel setText:selectedSheet];
    [sheetLabel setTextAlignment:NSTextAlignmentCenter];
    [sheetLabel setNumberOfLines:1];
    [sheetLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:sheetLabel];
    
    
    //3.Add ReasonLabel
    if (reasonLabel == nil) {
        UILabel *tempreasonLabel = [[UILabel alloc] init];
        self.reasonLabel=tempreasonLabel;
        
    }
    reasonLabel.frame = ReasonLabelFrame;
    reasonLabel.font =[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16];
    
    [reasonLabel setText:RPLocalizedString(PleaseIndicateReasons,@" ")];
    
    [reasonLabel setTextAlignment:NSTextAlignmentCenter];
    [reasonLabel setNumberOfLines:1];
    [reasonLabel setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:reasonLabel];
    
    //4. Add ResubmitButton
    if (resubmitButton == nil) {
        resubmitButton =[UIButton buttonWithType:UIButtonTypeCustom];
    }
    UIImage *submitBtnImg =[Util thumbnailImage:SubmitTimesheetButtonImage] ;
    UIImage *submitPressedBtnImg =[Util thumbnailImage:SubmitTimesheetPressedButtonImage] ;
    
    
    if (aspectRatio>=1.7)
    {
        [resubmitButton setFrame:CGRectMake((SCREEN_WIDTH-submitBtnImg.size.width)/2,submitTextView.frame.origin.y+submitTextView.frame.size.height+10.0, submitBtnImg.size.width, submitBtnImg.size.height)];
    }
    else
    {
        [resubmitButton setFrame:CGRectMake((SCREEN_WIDTH-submitBtnImg.size.width)/2,submitTextView.frame.origin.y+submitTextView.frame.size.height + 10, submitBtnImg.size.width, submitBtnImg.size.height)];
    }
    
    [resubmitButton setBackgroundImage:submitBtnImg forState:UIControlStateNormal];
    [resubmitButton setBackgroundImage:submitPressedBtnImg forState:UIControlStateHighlighted];
    
    [resubmitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    resubmitButton.titleEdgeInsets = UIEdgeInsetsMake(-2.0, 0, 0, 0);
    
    
    resubmitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    if ([actionType isEqualToString:@"Re-Submit"]) {
        [resubmitButton setTitle:RPLocalizedString(Resubmit_Button_title,@"") forState:UIControlStateNormal];
        resubmitButton.tag=RESUBMIT_TAG;
    }

    else if ([actionType isEqualToString:@"Reopen"]) {
        [resubmitButton setTitle:RPLocalizedString(Reopen_Button_title,@"") forState:UIControlStateNormal];
        resubmitButton.tag=REOPEN_TAG;
    }

    else if ([actionType isEqualToString:@"Submit"]) {
        [resubmitButton setTitle:RPLocalizedString(Submit_Button_title,@"") forState:UIControlStateNormal];
        resubmitButton.tag=SUBMIT_TAG;
    }

    else if ([actionType isEqualToString:@"Re-Submit_Astro"]) {
        [resubmitButton setTitle:RPLocalizedString(Resubmit_Button_title,@"") forState:UIControlStateNormal];
        resubmitButton.tag=SUBMIT_TAG;
    }
    
    [resubmitButton addTarget:self action:@selector(reSubmitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resubmitButton];
    
    if (allowBlankComments) {
        [resubmitButton setEnabled:YES];
    }
    else {
        [resubmitButton setEnabled:NO];
    }
    
    
    //5.Add CancelButton
    UIBarButtonItem *tempcancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction)];
    self.cancelButton=tempcancelButton;
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    self.isReopenClicked=NO;
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    NSString *textString = [textView text];
    //ravi - DE3034
    if ((textString == nil || [textString isKindOfClass:[NSNull class]] ||
         [[textString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
        && !allowBlankComments) {
        [self.resubmitButton setEnabled:NO];
    }else {
        [self.resubmitButton setEnabled:YES];
    }
    
    
    //Remove 255 characters limitation from all textviews for defect DE14226//JUHI
    
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //Remove 255 characters limitation from all textviews for defect DE14226//JUHI
    
}

-(BOOL)textViewShouldEndEditing :(UITextView*) textField{
    
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;{
    [resubmitButton setEnabled:YES];
    return YES;
}

-(void)cancelButtonAction{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)reSubmitButtonAction:(id)sender
{
    UIButton *button =(UIButton *)sender;
    if (button.tag==RESUBMIT_TAG)
    {
        CLS_LOG(@"-----Resubmit button clicked For Timesheets on ApprovalActionsViewController-----");
        if ([delegate isKindOfClass:[WidgetTSViewController class]] )
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            NSArray *timeSheetsArr = [timesheetModel getTimeSheetInfoSheetIdentity:self.sheetIdentity];
            if (timeSheetsArr.count>0)
            {
                NSMutableDictionary *timeSheetDict=timeSheetsArr[0];
                NSString *timesheetFormat=timeSheetDict[@"timesheetFormat"];
                if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                {

                    NSMutableArray *enableWidgetsArr=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
                    for (NSDictionary *enableWidgetDict in enableWidgetsArr)
                    {
                        NSString *widgetUri = enableWidgetDict[@"widgetUri"];
                        if ([widgetUri isEqualToString:INOUT_WIDGET_URI])
                        {
                            timesheetFormat=GEN4_INOUT_TIMESHEET;
                            break;
                            
                        }
                    }

                    if([[NetworkMonitor sharedInstance] networkAvailable] == NO||
                       [timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                    {
                        [timesheetModel updateTimesheetWithOperationName:TIMESHEET_RESUBMIT_OPERATION andTimesheetURI:sheetIdentity];
                        [timesheetModel updateAttestationStatusForTimesheetIdentity:sheetIdentity withStatus:YES];

                        SQLiteDB *myDB = [SQLiteDB getInstance];
                        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                        [dataDict setObject:self.submitTextView.text forKey:@"lastResubmitComments" ];
                        [dataDict setObject:TIMESHEET_PENDING_SUBMISSION forKey:@"approvalStatus" ];
                        [dataDict setObject:timeSheetDict[@"approvalStatus"] forKey:@"lastKnownApprovalStatus"];
                        [dataDict setObject:[NSNumber numberWithInt:0]  forKey:@"canEditTimesheet" ];
                        [myDB updateTable:@"Timesheets" data:dataDict where:[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity] intoDatabase:@""];

                        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                        [[appDelegate.injector getInstance:[BaseSyncOperationManager class]] startSync];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    }
                    else
                    {
                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                        [self callServiceWithName:WIDGET_TIMESHEET_RESUBMIT_SERVICE andTimeSheetURI:self.sheetIdentity];
                    }
                }
            }

            
        }
        
        else
        {
            if ([[NetworkMonitor sharedInstance] networkAvailable] == NO)
            {
                
                [Util showOfflineAlert];
            }
            else
            {
                if ([delegate isKindOfClass:[TimeOffDetailsViewController class]] || [delegate isKindOfClass:[MultiDayTimeOffViewController class]])
                {
                    if(submitTextView.text==nil || [submitTextView.text isEqualToString:@""])
                    {
                        [Util errorAlert:@"" errorMessage:RPLocalizedString(TIMEOFF_RESUBMISSION_COMMENTS_MSG, @"")];
                        return;
                    }
                    
                    CLS_LOG(@"-----Resubmit button clicked For Timeoffs on ApprovalActionsViewController-----");
                    if([delegate isKindOfClass:[TimeOffDetailsViewController class]]){
                        TimeOffDetailsViewController *timeOffDetailsViewController=(TimeOffDetailsViewController *)delegate;
                        TimeOffObject *bookedTimeOffEntry=[self.arrayOfEntriesForSave objectAtIndex:0];
                        bookedTimeOffEntry.resubmitComments=submitTextView.text;
                        [self.arrayOfEntriesForSave replaceObjectAtIndex:0 withObject:bookedTimeOffEntry];
                        [timeOffDetailsViewController  submitRequestForTimeOffSubmissionAndSave:self.arrayOfEntriesForSave];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    else{
                        if([delegate conformsToProtocol:@protocol(TimeOffResubmitProtocol)]){
                            [delegate resubmitComments:submitTextView.text];
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }
                }
                
                else
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reSubmitTimeSheetReceivedData:) name:SUBMITTED_NOTIFICATION object:nil];
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                    {
                        CLS_LOG(@"-----Resubmit button clicked For Timesheets on ApprovalActionsViewController-----");
                        [[RepliconServiceManager timesheetService]sendRequestToSaveTimesheetDataForTimesheetURI:self.sheetIdentity  withEntryArray:self.arrayOfEntriesForSave withDelegate:self isMultiInOutTimeSheetUser:self.isMultiDayInOutTimesheetUser isNewAdhocEntryDict:nil isTimesheetSubmit:YES sheetLevelUdfArray:self.timesheetLevelUdfArray submitComments:self.submitTextView.text isAutoSave:@"NO" isDisclaimerAccepted:self.isDisclaimerRequired rowUri:nil actionMode:0 isExtendedInOutUser:self.isExtendedInoutUser reasonForChange:nil];
                        
                        
                        
                    }
                    else
                    {
                        CLS_LOG(@"-----Resubmit button clicked For Expensesheets on ApprovalActionsViewController-----");
                        //Implementation as per US9172//JUHI
                        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
                        
                        
                        NSArray *expenseSheetDetailsArray = [expenseModel getExpensesInfoForSheetIdentity:self.sheetIdentity];
                        NSString *sheetUri=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"expenseSheetUri"];
                        NSString *sheetDateString=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"expenseDate"];
                        NSString *sheetDescription=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"description"];
                        NSString *sheetReimburseCurrencyUri=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"reimbursementAmountCurrencyUri"];
                        
                        
                        
                        NSDate *sheetDate = [Util convertTimestampFromDBToDate:sheetDateString];
                        NSDictionary *dateDict=[Util convertDateToApiDateDictionary:sheetDate];
                        NSMutableDictionary *expenseDetailsDict=[NSMutableDictionary dictionary];
                        
                        [expenseDetailsDict setObject:sheetUri forKey:@"expenseSheetUri"];
                        [expenseDetailsDict setObject:dateDict forKey:@"date"];
                        [expenseDetailsDict setObject:sheetDescription forKey:@"description"];
                        [expenseDetailsDict setObject:sheetReimburseCurrencyUri forKey:@"reimbursementCurrencyUri"];
                        
                        
                        
                        
                        
                        LoginModel *loginModel=[[LoginModel alloc]init];
                        NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
                        BOOL isProjectAllowed=NO;
                        BOOL isProjectRequired=NO;
                        
                        if ([userDetailsArray count]!=0)
                        {
                            NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
                            isProjectAllowed =[[userDict objectForKey:@"expenseEntryAgainstProjectsAllowed"] boolValue];
                            isProjectRequired=[[userDict objectForKey:@"expenseEntryAgainstProjectsRequired"] boolValue];
                        }
                        
                        
                        [[RepliconServiceManager expenseService] sendRequestToSaveExpenseSheetForExpenseSheetDict:expenseDetailsDict withExpenseEntriesArray:arrayOfEntriesForSave withDelegate:self isProjectAllowed:isProjectAllowed isProjectRequired:isProjectRequired isDisclaimerAccepted:isDisclaimerRequired isExpenseSubmit:YES withComments:submitTextView.text];
                        
                    }
                    
                }
                
            }
        }
        
        
    }

    else if (button.tag==REOPEN_TAG)
    {
        if ([delegate isKindOfClass:[ApproveTimesheetContainerController class]] || [delegate isKindOfClass:[TimesheetContainerController class]] )
        {
            if ([[NetworkMonitor sharedInstance] networkAvailable] == NO)
            {

                [Util showOfflineAlert];
            }
            else
            {
                CLS_LOG(@"-----Reopen button clicked For Timesheets on ApprovalActionsViewController-----");

                [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                [self callServiceWithName:WIDGET_TIMESHEET_REOPEN_SERVICE andTimeSheetURI:self.sheetIdentity];

            }

        }

    }

    else if (button.tag==SUBMIT_TAG)
    {
        if ([delegate isKindOfClass:[ApproveTimesheetContainerController class]] || [delegate isKindOfClass:[TimesheetContainerController class]]  )
        {
            if ([[NetworkMonitor sharedInstance] networkAvailable] == NO)
            {

                [Util showOfflineAlert];
            }
            else
            {
                CLS_LOG(@"-----Reopen button clicked For Timesheets on ApprovalActionsViewController-----");

                [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                [self callServiceWithName:WIDGET_TIMESHEET_SUBMIT_SERVICE andTimeSheetURI:self.sheetIdentity];

            }
            
        }
        
    }

    
    
}

-(void)reSubmitTimeSheetReceivedData:(NSNotification *) notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    if ([delegate isKindOfClass:[CurrentTimesheetViewController class]] )
    {
        id dict = notification.userInfo;
        if (dict!=nil && ![dict isKindOfClass:[NSNull class]])
        {
            //Implementation for JM-35734_DCAA compliance support//JUHI
            
            
            TimesheetSubmitReasonViewController *approvalActionsViewController = [[TimesheetSubmitReasonViewController alloc] init];
            if ([[dict objectForKey:@"timesheetModificationsRequiringChangeReason"] isKindOfClass:[NSArray class]])
            {
                NSMutableArray *responseArray=[dict objectForKey:@"timesheetModificationsRequiringChangeReason"];
                [approvalActionsViewController setReasonDetailArray:responseArray];
            }
            [approvalActionsViewController setDelegate:self];
            [approvalActionsViewController setIsDisclaimerRequired:self.isDisclaimerRequired];
            [approvalActionsViewController setActionType:@"Re-Submit"];
            [approvalActionsViewController setSubmitComments:self.submitTextView.text];
            [approvalActionsViewController setSheetIdentity:self.sheetIdentity];
            [approvalActionsViewController setIsMultiDayInOutTimesheetUser:self.isMultiDayInOutTimesheetUser];
            [approvalActionsViewController setTimesheetLevelUdfArray:timesheetLevelUdfArray];
            [approvalActionsViewController setArrayOfEntriesForSave:arrayOfEntriesForSave];
            [approvalActionsViewController setIsExtendedInoutUser:isExtendedInoutUser];
            [self.navigationController pushViewController:approvalActionsViewController animated:YES];
            
        }
        else
            [self popToListOfTimeSheets];
    }
    else
    {
        [self popToListOfExpenseSheets];
    }
    
    
    
}


-(void)popToListOfTimeSheets
{

    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

-(void)popToListOfExpenseSheets
{
    SQLiteDB *myDB = [SQLiteDB getInstance];
    
    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
    
    NSArray *expensesArr = [expenseModel getExpensesInfoForSheetIdentity:self.sheetIdentity];
    
    
    
    if ([expensesArr count]>0)
    {
        NSMutableDictionary *expensesDict=[[expensesArr objectAtIndex:0]mutableCopy];
        if ([self.actionType isEqualToString:@"Re-Submit"])
        {
            [expensesDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus" ];
        }
        
        [myDB deleteFromTable:@"ExpenseSheets" where:[NSString stringWithFormat:@"expenseSheetUri = '%@'",self.sheetIdentity] inDatabase:@""];
        [myDB insertIntoTable:@"ExpenseSheets" data:expensesDict intoDatabase:@""];
        
    }
    
    
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}


-(void)callServiceWithName:(ServiceName)_serviceName andTimeSheetURI:(NSString *)timeSheetURI
{
    if (_serviceName==WIDGET_TIMESHEET_RESUBMIT_SERVICE)
    {
        NSString *comments=self.submitTextView.text;

        [self syncPendingQueueForTimesheetWithUri:self.sheetIdentity];

        AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]sendRequestToSubmitWidgetTimesheetWithTimesheetURI:timeSheetURI comments:comments hasAttestationPermission:self.hasAttestationWidgetPermission andAttestationStatus:self.isAttestationSelected];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {


            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received ::::: %@",operation.responseString);
            NSDictionary *errorDict = [responseObject objectForKey:@"error"];
            if (errorDict == nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    [[RepliconServiceManager timesheetService] handleTimesheetsSummaryFetchData:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"] isFromSave:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
                    
                    [self popToListOfTimeSheets];
                    
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                    
                });
            }
            else
            {
                // server response error
                BOOL showExceptionMessage= [[ResponseHandler sharedResponseHandler] checkForExceptions:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4SubmitTimesheetData"]];
                if (!showExceptionMessage)
                {
                    [[ResponseHandler sharedResponseHandler] handleServerResponseError:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4SubmitTimesheetData"]];
                }
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

             CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

             [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

             CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);

             [self handleNonBusinessLogicFailures:operation error:error];
         }];
        [operation start];
        
    }

    else if (_serviceName==WIDGET_TIMESHEET_REOPEN_SERVICE)
    {

        if ([delegate isKindOfClass:[ApproveTimesheetContainerController class]] || [delegate isKindOfClass:[TimesheetContainerController class]]  )
        {

            NSString *comments=self.submitTextView.text;


            AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]sendRequestToReopenWidgetTimesheetWithTimesheetURI:timeSheetURI comments:comments];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received ::::: %@",operation.responseString);

                NSDictionary *errorDict = [responseObject objectForKey:@"error"];
                if (errorDict == nil) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        NSString *moduleName = nil;

                        if ([delegate isKindOfClass:[ApproveTimesheetContainerController class]])
                        {
                            ApproveTimesheetContainerController *approveTimesheetContainerController = (ApproveTimesheetContainerController *)delegate;
                            if (approveTimesheetContainerController.legacyTimesheetApprovalInfo.isFromPendingApprovals)
                            {
                                moduleName = APPROVALS_PENDING_TIMESHEETS_MODULE;
                            }
                            else if (approveTimesheetContainerController.legacyTimesheetApprovalInfo.isFromPreviousApprovals)
                            {
                                moduleName = APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
                            }
                        }
                        else
                        {
                            moduleName = APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
                        }


                        [[RepliconServiceManager approvalsService] handleApprovalsTimeSheetSummaryDataForTimesheet:@{@"response":responseObject} module:moduleName];


                        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];

                        NSLog(@"%@",self.navigationController.viewControllers);

                        for(UIViewController *vc in self.navigationController.viewControllers)
                        {
                            if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                            {
                                if ([vc isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
                                {
                                    ApprovalsPendingTimesheetViewController *approvalsPendingTimesheetViewController = (ApprovalsPendingTimesheetViewController *)vc;
                                    [self.navigationController popToViewController:approvalsPendingTimesheetViewController animated:NO];
                                    ApprovalsModel *approvalsModel =[[ApprovalsModel alloc]init];

                                    approvalsPendingTimesheetViewController.listOfUsersArr = [approvalsModel getAllPendingTimeSheetsGroupedByDueDatesWithStatus:nil];

                                    [approvalsPendingTimesheetViewController tableView:approvalsPendingTimesheetViewController.approvalpendingTSTableView didSelectRowAtIndexPath:approvalsPendingTimesheetViewController.selectedUserIndexpath];
                                    break;
                                }
                            }

                            else if ([moduleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
                            {
                                if ([vc isKindOfClass:[ApprovalsTimesheetHistoryViewController class]])
                                {
                                    ApprovalsTimesheetHistoryViewController *approvalsTimesheetHistoryViewController = (ApprovalsTimesheetHistoryViewController *)vc;
                                    [self.navigationController popToViewController:approvalsTimesheetHistoryViewController animated:NO];
                                    
                                    [approvalsTimesheetHistoryViewController tableView:approvalsTimesheetHistoryViewController.approvalHistoryTableView didSelectRowAtIndexPath:approvalsTimesheetHistoryViewController.selectedIndexPath];
                                    break;
                                }
                                else if ([vc isKindOfClass:[SupervisorTimesheetDetailsSeriesController class]])
                                {

                                    [self.navigationController popToViewController:vc animated:NO];

                                    for(UIViewController *vc1 in vc.childViewControllers)
                                    {
                                        if ([vc1 isKindOfClass:[SupervisorTimesheetDetailsController class]])
                                        {
                                            SupervisorTimesheetDetailsController *supervisorTimesheetDetailsController = (SupervisorTimesheetDetailsController *)vc1;
                                            [supervisorTimesheetDetailsController refreshSelectedGoldenAndNonGoldenTimesheetsControllerAfterApprovalActions];
                                            
                                            break;
                                        }
                                    }

                                    break;
                                }
                            }


                        }


                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

                    });
                }
                else
                {
                    // server response error
                    BOOL showExceptionMessage= [[ResponseHandler sharedResponseHandler] checkForExceptions:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4UnSubmitTimesheetData"]];
                    if (!showExceptionMessage)
                    {
                        [[ResponseHandler sharedResponseHandler] handleServerResponseError:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4UnSubmitTimesheetData"]];
                    }
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

                 CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

                 [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                 CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);

                 [self handleNonBusinessLogicFailures:operation error:error];
                 
             }];
            [operation start];
        }
        
    }

    else if (_serviceName==WIDGET_TIMESHEET_SUBMIT_SERVICE)
    {

        if ([delegate isKindOfClass:[ApproveTimesheetContainerController class]] || [delegate isKindOfClass:[TimesheetContainerController class]] )
        {


            NSString *comments=self.submitTextView.text;


            AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]sendRequestToSubmitWidgetTimesheetWithTimesheetURI:timeSheetURI comments:comments hasAttestationPermission:NO andAttestationStatus:YES];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received ::::: %@",operation.responseString);

                NSDictionary *errorDict = [responseObject objectForKey:@"error"];
                if (errorDict == nil) {

                    dispatch_async(dispatch_get_main_queue(), ^{

                        NSString *moduleName = nil;
                        if ([delegate isKindOfClass:[ApproveTimesheetContainerController class]])
                        {
                            ApproveTimesheetContainerController *approveTimesheetContainerController = (ApproveTimesheetContainerController *)delegate;
                            if (approveTimesheetContainerController.legacyTimesheetApprovalInfo.isFromPendingApprovals)
                            {
                                moduleName = APPROVALS_PENDING_TIMESHEETS_MODULE;
                            }
                            else if (approveTimesheetContainerController.legacyTimesheetApprovalInfo.isFromPreviousApprovals)
                            {
                                moduleName = APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
                            }
                        }
                        else
                        {
                            moduleName = APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
                        }

                        [[RepliconServiceManager approvalsService] handleApprovalsTimeSheetSummaryDataForTimesheet:@{@"response":responseObject} module:moduleName];


                        [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];


                        for(UIViewController *vc in self.navigationController.viewControllers)
                        {
                            if ([moduleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                            {
                                if ([vc isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
                                {
                                    ApprovalsPendingTimesheetViewController *approvalsPendingTimesheetViewController = (ApprovalsPendingTimesheetViewController *)vc;
                                    [self.navigationController popToViewController:approvalsPendingTimesheetViewController animated:NO];
                                    ApprovalsModel *approvalsModel =[[ApprovalsModel alloc]init];

                                    approvalsPendingTimesheetViewController.listOfUsersArr = [approvalsModel getAllPendingTimeSheetsGroupedByDueDatesWithStatus:nil];

                                    [approvalsPendingTimesheetViewController tableView:approvalsPendingTimesheetViewController.approvalpendingTSTableView didSelectRowAtIndexPath:approvalsPendingTimesheetViewController.selectedUserIndexpath];
                                    break;
                                }
                            }

                            else if ([moduleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
                            {
                                if ([vc isKindOfClass:[ApprovalsTimesheetHistoryViewController class]])
                                {
                                    ApprovalsTimesheetHistoryViewController *approvalsTimesheetHistoryViewController = (ApprovalsTimesheetHistoryViewController *)vc;
                                    [self.navigationController popToViewController:approvalsTimesheetHistoryViewController animated:NO];

                                    [approvalsTimesheetHistoryViewController tableView:approvalsTimesheetHistoryViewController.approvalHistoryTableView didSelectRowAtIndexPath:approvalsTimesheetHistoryViewController.selectedIndexPath];
                                    break;
                                }

                                else if ([vc isKindOfClass:[SupervisorTimesheetDetailsSeriesController class]])
                                {
                                    [self.navigationController popToViewController:vc animated:NO];

                                    for(UIViewController *vc1 in vc.childViewControllers)
                                    {
                                        if ([vc1 isKindOfClass:[SupervisorTimesheetDetailsController class]])
                                        {
                                            SupervisorTimesheetDetailsController *supervisorTimesheetDetailsController = (SupervisorTimesheetDetailsController *)vc1;
                                            [supervisorTimesheetDetailsController refreshSelectedGoldenAndNonGoldenTimesheetsControllerAfterApprovalActions];

                                            break;
                                        }
                                    }

                                    break;
                                }
                            }


                        }


                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

                    });
                }
                else
                {
                    // server response error
                    BOOL showExceptionMessage= [[ResponseHandler sharedResponseHandler] checkForExceptions:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4SubmitTimesheetData"]];
                    if (!showExceptionMessage)
                    {
                        [[ResponseHandler sharedResponseHandler] handleServerResponseError:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4SubmitTimesheetData"]];
                    }
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

                 CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

                 [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                 CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);
                 
                 [self handleNonBusinessLogicFailures:operation error:error];
                 
             }];
            [operation start];
        }
        
    }
    
}

-(void)syncPendingQueueForTimesheetWithUri:(NSString *)timesheetUri
{
    TimesheetModel *tsModel=[[TimesheetModel alloc]init];
    NSArray *enabledWidgetsUriArray=enabledWidgetsUriArray=[tsModel getAllSupportedAndNotSupportedWidgetsForTimesheetUri:self.sheetIdentity];

    NSString *tsFormat=@"";

    for (NSDictionary *enabledWidgetsDict in enabledWidgetsUriArray)
    {


        if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            tsFormat=GEN4_STANDARD_TIMESHEET;
        }
        else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            tsFormat=GEN4_INOUT_TIMESHEET;
            break;
        }
        else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            tsFormat=GEN4_EXT_INOUT_TIMESHEET;
        }
        else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            tsFormat=GEN4_PUNCH_WIDGET_TIMESHEET;
        }
    }

    if([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET])
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [[appDelegate.injector getInstance:[BaseSyncOperationManager class]] startSync];
    }
}

-(void)handleNonBusinessLogicFailures:(AFHTTPRequestOperation *)operation error:(NSError *)error
{

    NSDictionary *errorDict = [[operation responseObject] objectForKey:@"error"];

    id errorUserInfoDict=[error userInfo];
    NSString *failedUrl=@"";

    if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
    {
        failedUrl=[errorUserInfoDict objectForKey:@"NSErrorFailingURLStringKey"];
        if (!failedUrl)
        {
            if ([errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]!=nil)
            {
                failedUrl=[[errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]absoluteString];
            }

            if (!failedUrl)
            {
                failedUrl=@"";
            }

        }
    }

    if (errorDict != nil) {

        // server response error
        BOOL showExceptionMessage= [[ResponseHandler sharedResponseHandler] checkForExceptions:errorDict serviceURL:failedUrl];
        if (!showExceptionMessage)
        {
            [[ResponseHandler sharedResponseHandler] handleServerResponseError:errorDict serviceURL:failedUrl];
        }
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    }
    else
    {
        NSInteger statusCode=[operation.response statusCode];
        NSString *description=operation.response.description;
        NSDictionary *headerFields = operation.request.allHTTPHeaderFields;
        ApplicateState applicationState = [[headerFields objectForKey:ApplicationStateHeaders]intValue];
        [[ResponseHandler sharedResponseHandler] handleHTTPResponseError:statusCode andDescription:description andError:error applicationState:applicationState];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    }


}


#pragma mark NetworkMonitor

-(void) networkActivated {


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.reasonLabel=nil;
    self.submitTextView=nil;
    
    self.cancelButton=nil;
}




@end
