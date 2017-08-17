#import "ListOfExpenseEntriesViewController.h"
#import "Constants.h"
#import "Util.h"
#import "AppDelegate.h"
#import "ExpenseEntryViewController.h"
#import "ExpenseEntryObject.h"
#import "ApprovalActionsViewController.h"
#import "ApprovalsScrollViewController.h"
#import "LoginModel.h"
#import "ApproverCommentViewController.h"
#import "ListOfTimeSheetsViewController.h"
#import "ListOfExpenseSheetsViewController.h"
#import "ListOfBookedTimeOffViewController.h"
#import "AttendanceViewController.h"
#import "TeamTimeViewController.h"
#import "ShiftsViewController.h"
#import "ApprovalsCountViewController.h"
#import "MoreViewController.h"
#import "DefaultTableViewCellStylist.h"
#import "SpinnerDelegate.h"
#import "SearchTextFieldStylist.h"
#import "DefaultTheme.h"
#import "ApprovalStatusPresenter.h"
#import <Blindside/BSInjector.h>
#import "UIView+Additions.h"

@interface  ListOfExpenseEntriesViewController ()

@property(nonatomic) DefaultTableViewCellStylist *defaultTableViewCellStylist;

@property (nonatomic) id <SpinnerDelegate> spinnerDelegate;
@property (nonatomic) SearchTextFieldStylist *searchTextFieldStylist;
@property (nonatomic) UILabel *attestationDesclabel,*attestationTitlelabel;
@property (weak, nonatomic) id<BSInjector> injector;

@end


@implementation ListOfExpenseEntriesViewController
@synthesize expenseSheetTitle;
@synthesize expenseSheetStatus;
@synthesize expenseSheetURI;
@synthesize expenseEntriesArray;
@synthesize expenseEntriesTableView;
@synthesize footerView;
@synthesize totalIncurredAmountString;
@synthesize reimburseAmountString;
@synthesize actionType;
@synthesize  messageLabel;
@synthesize deleteButton;
@synthesize isFirstTimeLoad;
@synthesize isCalledFromTabBar;
@synthesize parentDelegate;
@synthesize userName;
@synthesize currentViewTag;
@synthesize currentNumberOfView;
@synthesize totalNumberOfView;
@synthesize sheetPeriod;
@synthesize approverComments;
@synthesize approvalsModuleName;
//Implementation as per US9172//JUHI
@synthesize disclaimerSelected;
@synthesize disclaimerTitleLabel;
@synthesize radioButton;
//Implementation For EXP-151//JUHI
@synthesize reimbursementCurrencyName;
@synthesize reimbursementCurrencyURI;


#define HeightOfNoTOMsgLabel 80
#define Each_Cell_Row_Height_58 58
#define Expense_Code_Cell_Row_Height_50 50
#define Total_Label_Height_50 50
#define buttonSpace 30
#define DELETE_EXPENSESHEET_ALERT_TAG 9999
#define ResetHeightios4 115-84.0
#define ResetHeightios5 170-84.0
#define Approval_Header_Height 55.0
#define WithRadioSpaceHeight 100
#define WithOutRadioSpaceHeight 60
#define LABEL_PADDING 12

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithDefaultTableViewCellStylist:(DefaultTableViewCellStylist *)defaultTableViewCellStylist
                             searchTextFieldStylist:(SearchTextFieldStylist *)searchTextFieldStylist
                                    spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate {
    self = [super init];
    if (self) {
        self.defaultTableViewCellStylist = defaultTableViewCellStylist;
        self.expenseEntriesArray = [NSMutableArray array];
        self.searchTextFieldStylist = searchTextFieldStylist;
        self.spinnerDelegate = spinnerDelegate;
    }
    return self;
}

#pragma mark -
#pragma mark View lifeCycle Methods

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:TRUE];


    if (!isCalledFromTabBar)
    {
        [self displayAllExpenseEntries:isFirstTimeLoad];
        isFirstTimeLoad=YES;
        [self.expenseEntriesTableView reloadData];
        if ([self.expenseEntriesArray count] > 0)
        {
            [self.expenseEntriesTableView removeFromSuperview];
            [self.view addSubview:self.expenseEntriesTableView];

        }
    }

    self.isCalledFromTabBar = NO;
}

-(void)loadView
{
    [super loadView];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    [Util setToolbarLabel:self withText:expenseSheetTitle];
    DefaultTheme *theme = [[DefaultTheme alloc] init];
    [self.view setBackgroundColor:[theme expenseEntriesTableBackgroundColor]];

    if ([expenseSheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[expenseSheetStatus isEqualToString:REJECTED_STATUS])
    {
        UIBarButtonItem *addButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewExpenseEntryAction:)];
        [self.navigationItem setRightBarButtonItem:addButton];

    }

    self.expenseEntriesTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightForTableView]) style:UITableViewStylePlain];
    self.expenseEntriesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.expenseEntriesTableView.delegate = self;
    self.expenseEntriesTableView.dataSource = self;
    [self.view addSubview:expenseEntriesTableView];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNSUBMITTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSE_SHEET_DELETED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION object:nil];
}

/************************************************************************************************************
 @Function Name   : displayAllTimeEntries
 @Purpose         : To create timeEntry objects from the list of timesheets array from DB
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)displayAllExpenseEntries:(BOOL)showEmptyPlaceHolder
{
    if ([expenseEntriesArray count] > 0) {
        [expenseEntriesArray removeAllObjects];

    }
    NSArray *dbexpenseEntriesArray=nil;
    if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
    {
        ExpenseModel *expensesModel = [[ExpenseModel alloc] init];
        dbexpenseEntriesArray = [expensesModel getAllExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetURI];

    }
    else
    {
        ApprovalsModel *approvalsModel = [[ApprovalsModel alloc] init];
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            dbexpenseEntriesArray = [approvalsModel getAllPendingExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetURI];
        }
        else
        {
            dbexpenseEntriesArray = [approvalsModel getAllPreviousExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetURI];
        }


    }


    if ([dbexpenseEntriesArray count] > 0)
    {
        if(messageLabel!=nil)
        {
            [messageLabel removeFromSuperview];
        }
        [self createFooter];
    }
    else
    {
        if (footerView !=nil) {
            [footerView setHidden:YES];
        }
        if (showEmptyPlaceHolder)
        {
            [self addDeleteButtonWithMessage];
        }


    }

    for (int i=0; i<[dbexpenseEntriesArray count]; i++)
    {
        NSDictionary *expenseDict=[dbexpenseEntriesArray objectAtIndex:i];
        ExpenseEntryObject *expenseEntryObj   = [[ExpenseEntryObject alloc] init];

        expenseEntryObj.expenseEntryIncurredDate=[Util convertTimestampFromDBToDate:[[expenseDict objectForKey:@"incurredDate"] stringValue]];
        expenseEntryObj.expenseEntryDescription=[expenseDict objectForKey:@"expenseEntryDescription"];

        expenseEntryObj.expenseEntryApprovalStatus=[expenseDict objectForKey:@"approvalStatus"];
        expenseEntryObj.expenseEntryBillingUri=[expenseDict objectForKey:@"billingUri"];
        expenseEntryObj.expenseEntryExpenseCodeName=[expenseDict objectForKey:@"expenseCodeName"];
        expenseEntryObj.expenseEntryExpenseCodeUri=[expenseDict objectForKey:@"expenseCodeUri"];
        expenseEntryObj.expenseEntryExpenseEntryUri=[expenseDict objectForKey:@"expenseEntryUri"];
        expenseEntryObj.expenseEntryExpenseReceiptName=[expenseDict objectForKey:@"expenseReceiptName"];
        expenseEntryObj.expenseEntryExpenseReceiptUri=[expenseDict objectForKey:@"expenseReceiptUri"];
        expenseEntryObj.expenseEntryExpenseSheetUri=[expenseDict objectForKey:@"expenseSheetUri"];
        expenseEntryObj.expenseEntryIncurredAmountNet=[expenseDict objectForKey:@"incurredAmountNet"];
        expenseEntryObj.expenseEntryIncurredAmountNetCurrencyName=[expenseDict objectForKey:@"incurredAmountNetCurrencyName"];
        expenseEntryObj.expenseEntryIncurredAmountNetCurrencyUri=[expenseDict objectForKey:@"incurredAmountNetCurrencyUri"];
        expenseEntryObj.expenseEntryIncurredAmountTotal=[expenseDict objectForKey:@"incurredAmountTotal"];
        expenseEntryObj.expenseEntryIncurredAmountTotalCurrencyName=[expenseDict objectForKey:@"incurredAmountTotalCurrencyName"];
        expenseEntryObj.expenseEntryIncurredAmountTotalCurrencyUri=[expenseDict objectForKey:@"incurredAmountTotalCurrencyUri"];
        expenseEntryObj.expenseEntryPaymentMethodName=[expenseDict objectForKey:@"paymentMethodName"];
        expenseEntryObj.expenseEntryPaymentMethodUri=[expenseDict objectForKey:@"paymentMethodUri"];
        expenseEntryObj.expenseEntryProjectName=[expenseDict objectForKey:@"projectName"];
        expenseEntryObj.expenseEntryProjectUri=[expenseDict objectForKey:@"projectUri"];
        expenseEntryObj.expenseEntryQuantity=[expenseDict objectForKey:@"quantity"];
        expenseEntryObj.expenseEntryRateAmount=[expenseDict objectForKey:@"rateAmount"];
        expenseEntryObj.expenseEntryRateCurrencyName=[expenseDict objectForKey:@"rateCurrencyName"];
        expenseEntryObj.expenseEntryRateCurrencyUri=[expenseDict objectForKey:@"rateCurrencyUri"];
        expenseEntryObj.expenseEntryReimbursementUri=[expenseDict objectForKey:@"reimbursementUri"];
        expenseEntryObj.expenseEntryTaskName=[expenseDict objectForKey:@"taskName"];
        expenseEntryObj.expenseEntryTaskUri=[expenseDict objectForKey:@"taskUri"];
        expenseEntryObj.expenseEntryClientName=[expenseDict objectForKey:@"clientName"];
        expenseEntryObj.expenseEntryClientUri=[expenseDict objectForKey:@"clientUri"];
        expenseEntryObj.receiptImageData=nil;
        NSNumber *displayBillToClient = [expenseDict objectForKey:@"displayBillToClient"];
        NSNumber  *disableBillToClient = [expenseDict objectForKey:@"disableBillToClient"];
        if (disableBillToClient != nil && disableBillToClient != (id)[NSNull null]) {
            expenseEntryObj.disableBillToClient =  [disableBillToClient boolValue];
        }
        else{
            expenseEntryObj.disableBillToClient =  FALSE;
        }
        
        if (displayBillToClient != nil && displayBillToClient != (id)[NSNull null]) {
            expenseEntryObj.displayBillToClient =  [displayBillToClient boolValue];
        }
        else{
            expenseEntryObj.displayBillToClient =  TRUE;
        }
        
        NSMutableArray *incurredAmountTaxesArray=[NSMutableArray array];
        NSMutableDictionary *tempIncurredAmountDict1=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict2=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict3=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict4=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict5=[NSMutableDictionary dictionary];

        NSString *taxAmount1        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount1"]];
        NSString *taxCurrencyName1  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName1"]];
        NSString *taxCurrencyUri1   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri1"]];
        NSString *taxCodeUri1       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri1"]];

        [tempIncurredAmountDict1 setObject:taxAmount1       forKey:@"taxAmount"];
        [tempIncurredAmountDict1 setObject:taxCurrencyName1 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict1 setObject:taxCurrencyUri1  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict1 setObject:taxCodeUri1       forKey:@"taxCodeUri"];

        NSString *taxAmount2        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount2"]];
        NSString *taxCurrencyName2  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName2"]];
        NSString *taxCurrencyUri2   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri2"]];
        NSString *taxCodeUri2       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri2"]];

        [tempIncurredAmountDict2 setObject:taxAmount2       forKey:@"taxAmount"];
        [tempIncurredAmountDict2 setObject:taxCurrencyName2 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict2 setObject:taxCurrencyUri2  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict2 setObject:taxCodeUri2       forKey:@"taxCodeUri"];

        NSString *taxAmount3        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount3"]];
        NSString *taxCurrencyName3  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName3"]];
        NSString *taxCurrencyUri3   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri3"]];
        NSString *taxCodeUri3       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri3"]];

        [tempIncurredAmountDict3 setObject:taxAmount3       forKey:@"taxAmount"];
        [tempIncurredAmountDict3 setObject:taxCurrencyName3 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict3 setObject:taxCurrencyUri3  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict3 setObject:taxCodeUri3       forKey:@"taxCodeUri"];

        NSString *taxAmount4        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount4"]];
        NSString *taxCurrencyName4  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName4"]];
        NSString *taxCurrencyUri4   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri4"]];
        NSString *taxCodeUri4       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri4"]];

        [tempIncurredAmountDict4 setObject:taxAmount4       forKey:@"taxAmount"];
        [tempIncurredAmountDict4 setObject:taxCurrencyName4 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict4 setObject:taxCurrencyUri4  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict4 setObject:taxCodeUri4       forKey:@"taxCodeUri"];

        NSString *taxAmount5        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount5"]];
        NSString *taxCurrencyName5  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName5"]];
        NSString *taxCurrencyUri5   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri5"]];
        NSString *taxCodeUri5       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri5"]];

        [tempIncurredAmountDict5 setObject:taxAmount5       forKey:@"taxAmount"];
        [tempIncurredAmountDict5 setObject:taxCurrencyName5 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict5 setObject:taxCurrencyUri5  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict5 setObject:taxCodeUri5       forKey:@"taxCodeUri"];


        [incurredAmountTaxesArray addObject:tempIncurredAmountDict1];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict2];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict3];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict4];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict5];
        expenseEntryObj.expenseEntryBaseCurrency=@"$";
        expenseEntryObj.expenseEntryIncurredTaxesArray=incurredAmountTaxesArray;
        [self.expenseEntriesArray addObject:expenseEntryObj];


    }



}
/************************************************************************************************************
 @Function Name   : createTableHeader
 @Purpose         : To extend tableview to configure its header
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)createTableHeader
{
    if (![parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        NSString *labelText=nil;
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        NSMutableArray *approvalArray=nil;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            approvalArray=[approvalsModel getPendingLastSubmittedExpenseSheetApprovalFromDB:expenseSheetURI];
        }
        else
        {
            approvalArray=[approvalsModel getPreviousLastSubmittedExpenseSheetApprovalFromDB:expenseSheetURI];
        }

        if ([approvalArray count]>0)
        {
            NSDictionary *dataDict=[approvalArray objectAtIndex:0];
            NSDate *nowDateFromLong = [Util convertTimestampFromDBToDate:[[dataDict objectForKey:@"timestamp"] stringValue]];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            myDateFormatter.dateFormat = @" MMM dd , yyyy";
            labelText=[myDateFormatter stringFromDate:nowDateFromLong];


        }
        //Implemented Approvals Pending DrillDown Loading UI
        NSString *submittedOnStr=@"";
        if (approvalArray!=nil)
        {
            submittedOnStr=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(APPROVAL_SUBMITTED_ON, @""),labelText];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_EXPENSES_MODULE])
            {
                if ([expenseSheetStatus isEqualToString:APPROVED_STATUS ]) {
                    submittedOnStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
                }
                else if ([expenseSheetStatus isEqualToString:REJECTED_STATUS ]){
                    submittedOnStr=RPLocalizedString(REJECTED_STATUS,@"");
                }

                //expenseSheetStatus=APPROVED_STATUS;
            }
        }



        ApprovalTablesHeaderView *headerView=[[ApprovalTablesHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 55.0 ) withStatus:expenseSheetStatus userName:self.userName dateString:self.sheetPeriod labelText:submittedOnStr withApprovalModuleName:self.approvalsModuleName isWidgetTimesheet:NO withErrorsAndWarningView:nil];
        ApprovalsScrollViewController *scrollCtrl=(ApprovalsScrollViewController *)parentDelegate;
        if (!scrollCtrl.hasPreviousTimeSheets) {
            headerView.previousButton.hidden=TRUE;
        }
        if (!scrollCtrl.hasNextTimeSheets) {
            headerView.nextButton.hidden=TRUE;
        }
        self.expenseEntriesTableView.tableHeaderView = headerView;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            headerView.countLbl.text=[NSString stringWithFormat:@"%li of %lu",(long)currentNumberOfView,(unsigned long)totalNumberOfView];
        }
        else
        {
            headerView.countLbl.text=@"";
        }

        headerView.delegate=self;

    }

}
/************************************************************************************************************
 @Function Name   : createFooter
 @Purpose         : To create footer with a total Label and delete & submit buttons
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)createFooter
{
    NSDictionary *expenseSheetDict=nil;
    if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
    {
        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
        expenseSheetDict=(NSDictionary *)[[expenseModel getExpenseSheetInfoSheetIdentity:expenseSheetURI] objectAtIndex:0];

    }
    else
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            expenseSheetDict=(NSDictionary *)[[approvalsModel getPendingExpenseSheetInfoSheetIdentity:expenseSheetURI] objectAtIndex:0];

        }
        else
        {
            expenseSheetDict=(NSDictionary *)[[approvalsModel getPreviousExpenseSheetInfoSheetIdentity:expenseSheetURI] objectAtIndex:0];
        }


    }

    NSString *reimburseAmount   =[expenseSheetDict objectForKey:@"reimbursementAmount"];
    NSString *reimburseCurrency =[expenseSheetDict objectForKey:@"reimbursementAmountCurrencyName"];
    NSString *reimburseAmountStr=[NSString stringWithFormat:@"%@ %@",reimburseCurrency,reimburseAmount];
    self.reimburseAmountString=reimburseAmountStr;
    NSString *incurredAmount   =[expenseSheetDict objectForKey:@"incurredAmount"];
    NSString *incurredCurrency =[expenseSheetDict objectForKey:@"incurredAmountCurrencyName"];
    NSString *incurredAmountStr=[NSString stringWithFormat:@"%@ %@",incurredCurrency,incurredAmount];
    self.totalIncurredAmountString=incurredAmountStr;


    float footerHeight = 0.0;
    UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      self.expenseEntriesTableView.frame.size.width,
                                                                      footerHeight)];
    self.footerView=tempfooterView;



    UIView *totallbView=[[UIView alloc]initWithFrame:CGRectMake(0,
                                                                0,
                                                                self.expenseEntriesTableView.frame.size.width,
                                                                Total_Label_Height_50)];
    footerHeight=Total_Label_Height_50+100;
    [totallbView setBackgroundColor:TimesheetTotalHoursBackgroundColor];
    
    CGFloat smallLabelWidth = (self.expenseEntriesTableView.width-(3*LABEL_PADDING))/2;

    UILabel *totalLabel=[[UILabel alloc]initWithFrame:CGRectMake(LABEL_PADDING, 2.0,smallLabelWidth ,25.0)];
    [totalLabel setText:[NSString stringWithFormat:@"%@",RPLocalizedString(TOTAL_INCURRED, @"") ]];;
    [totalLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
    [totalLabel setBackgroundColor:[UIColor clearColor]];
    [totallbView addSubview:totalLabel];


    UILabel *totalValueLabel=[[UILabel alloc]initWithFrame: CGRectMake(totalLabel.right+LABEL_PADDING, 2.0,smallLabelWidth ,25.0)];
    [totalValueLabel setText:self.totalIncurredAmountString];
    [totalValueLabel setTextAlignment: NSTextAlignmentRight];
    [totalValueLabel setBackgroundColor:[UIColor clearColor]];
    [totalValueLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
    [totallbView addSubview:totalValueLabel];


    UILabel *reimburseLabel=[[UILabel alloc]initWithFrame:CGRectMake(LABEL_PADDING,23.0,smallLabelWidth ,25.0)];
    [reimburseLabel setText:[NSString stringWithFormat:@"%@",RPLocalizedString(Reimbursement_string, @"") ]];
    [reimburseLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
    [reimburseLabel setBackgroundColor:[UIColor clearColor]];
    [totallbView addSubview:reimburseLabel];


    UILabel *reimburseValueLabel=[[UILabel alloc]initWithFrame: CGRectMake(reimburseLabel.right+LABEL_PADDING,23.0,smallLabelWidth ,25.0)];
    [reimburseValueLabel setText:self.reimburseAmountString];
    [reimburseValueLabel setTextAlignment: NSTextAlignmentRight];
    [reimburseValueLabel setBackgroundColor:[UIColor clearColor]];
    [reimburseValueLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
    [totallbView addSubview:reimburseValueLabel];



    [self.footerView addSubview:totallbView];

    //Implementation as per US9172//JUHI
    float y=Total_Label_Height_50;

    BOOL isDisclaimer=YES;
    NSArray *disclaimerDetailsArr=nil;
    NSString *disclaimerStatusString=nil;

    if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
    {
        LoginModel *loginModel=[[LoginModel alloc]init];

        disclaimerStatusString=[loginModel getStatusForDisclaimerPermissionForColumnName:@"disclaimerExpensesheetNoticePolicyUri"];



        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
        disclaimerDetailsArr=[expenseModel getAllDisclaimerDetailsFromDBForModule:ExpenseModuleName];


    }
    else
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            disclaimerDetailsArr=[approvalsModel getAllPendingDisclaimerDetailsFromDBForModule:ExpenseModuleName];
            disclaimerStatusString=[approvalsModel getPendingStatusForDisclaimerPermissionForColumnName:@"disclaimerExpenseNoticePolicyUri" forSheetUri:expenseSheetURI];
        }
        else
        {


            disclaimerDetailsArr=[approvalsModel getAllPreviousDisclaimerDetailsFromDBForModule:ExpenseModuleName];
            disclaimerStatusString=[approvalsModel getPreviousStatusForDisclaimerPermissionForColumnName:@"disclaimerExpenseNoticePolicyUri" forSheetUri:expenseSheetURI];
        }


    }

    NSString *disclamerTitle=nil;
    NSString *disclaimerDesc=nil;

    if (disclaimerDetailsArr!=nil)
    {
        NSDictionary *disclaimerDict=[disclaimerDetailsArr objectAtIndex:0];
        if ([disclaimerDict objectForKey:@"title"]!=nil && ![[disclaimerDict objectForKey:@"title"] isKindOfClass:[NSNull class]] && ![[disclaimerDict objectForKey:@"title"] isEqualToString:@"<null>"]) {
            disclamerTitle=[disclaimerDict objectForKey:@"title"];
        }
        else
            disclamerTitle=@"";

        if ([disclaimerDict objectForKey:@"description"]!=nil && ![[disclaimerDict objectForKey:@"description"] isKindOfClass:[NSNull class]] && ![[disclaimerDict objectForKey:@"description"] isEqualToString:@"<null>"]) {
            disclaimerDesc=[disclaimerDict objectForKey:@"description"];
        }
        else
            disclaimerDesc=@"";
    }

    if ((disclamerTitle!=nil && ![disclamerTitle isKindOfClass:[NSNull class]] && ![disclamerTitle isEqualToString:@"<null>"]) || (disclaimerDesc!=nil && ![disclaimerDesc isKindOfClass:[NSNull class]] && ![disclaimerDesc isEqualToString:@"<null>"]))
    {
        isDisclaimer=YES;
    }
    else
    {
        isDisclaimer=NO;
    }


    BOOL isDisclaimerCheck=FALSE;

    CGSize expectedAttestationTitleLabelSize;

    CGSize expectedAttestationDescLabelSize ;
    heightofDisclaimerText=0.0;
    CGFloat labelWidth = self.expenseEntriesTableView.width-(2*LABEL_PADDING);
    if (isDisclaimer)
    {


        NSString *disclaimerAccepted=nil;
        
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:disclamerTitle];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        expectedAttestationTitleLabelSize = [attributedString boundingRectWithSize:CGSizeMake(labelWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        self.attestationTitlelabel=[[UILabel alloc] init];
        self.attestationTitlelabel.text=disclamerTitle;
        self.attestationTitlelabel.textColor=RepliconStandardBlackColor;
        [self.attestationTitlelabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        [self.attestationTitlelabel setBackgroundColor:[UIColor clearColor]];
        self.attestationTitlelabel.frame=CGRectMake(LABEL_PADDING,
                                               y+30,
                                               labelWidth,
                                               expectedAttestationTitleLabelSize.height);
        self.attestationTitlelabel.numberOfLines=100;

        [footerView addSubview:self.attestationTitlelabel];



        // Let's make an NSAttributedString first
        attributedString = [[NSMutableAttributedString alloc] initWithString:disclaimerDesc];
        //Add LineBreakMode
        paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        expectedAttestationDescLabelSize = [attributedString boundingRectWithSize:CGSizeMake(labelWidth, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        self.attestationDesclabel=[[UILabel alloc] init];
        self.attestationDesclabel.text=disclaimerDesc ;
        self.attestationDesclabel.textColor=RepliconStandardBlackColor;
        [self.attestationDesclabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
        [self.attestationDesclabel setBackgroundColor:[UIColor clearColor]];

        self.attestationDesclabel.frame=CGRectMake(LABEL_PADDING,
                                              self.attestationTitlelabel.frame.origin.y+10+self.attestationTitlelabel.frame.size.height,
                                              labelWidth,
                                              expectedAttestationDescLabelSize.height);



        self.attestationDesclabel.numberOfLines=100;

        [footerView addSubview:self.attestationDesclabel];

        if (disclaimerStatusString!=nil && ![disclaimerStatusString isKindOfClass:[NSNull class]]) {
            if ([disclaimerStatusString isEqualToString:@"urn:replicon:policy:expense:expense-notice-acceptance:expense-notice-acceptance-required"])
            {
                isDisclaimerCheck=TRUE;
            }
        }





        if (isDisclaimerCheck)
        {
            NSArray *dbexpenseEntriesArray=nil;
            if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
            {
                ExpenseModel *expensesModel = [[ExpenseModel alloc] init];
                dbexpenseEntriesArray = [expensesModel getAllExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetURI];

            }
            else
            {
                ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
                {
                    dbexpenseEntriesArray=[approvalsModel getAllPendingExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetURI];
                }
                else
                {
                    dbexpenseEntriesArray=[approvalsModel getAllPreviousExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetURI];
                }



            }

            int noticeExplicitlyAccepted=0;
            if ([dbexpenseEntriesArray count]>0 && dbexpenseEntriesArray!=nil)
            {
                noticeExplicitlyAccepted=[[[dbexpenseEntriesArray objectAtIndex:0] objectForKey:@"noticeExplicitlyAccepted"] intValue];
            }
            UIImage *radioDeselectedImage=nil;
            if (noticeExplicitlyAccepted==0)
            {
                radioDeselectedImage = [Util thumbnailImage:CheckBoxDeselectedImage];
                [self setDisclaimerSelected:NO];
                disclaimerAccepted=RPLocalizedString(@"Accept", @"");
            }
            else
            {
                radioDeselectedImage = [Util thumbnailImage:CheckBoxSelectedImage];
                [self setDisclaimerSelected:YES];
                disclaimerAccepted=RPLocalizedString(@"Accepted", @"");
            }
            self.radioButton = [UIButton buttonWithType:UIButtonTypeCustom];


            [self.radioButton setFrame:CGRectMake(4.0,
                                                  self.attestationDesclabel.frame.origin.y+expectedAttestationDescLabelSize.height+5,
                                                  radioDeselectedImage.size.width+20.0,
                                                  radioDeselectedImage.size.height+19.0)];



            [self.radioButton setImage:radioDeselectedImage forState:UIControlStateNormal];
            //[self.radioButton setImage:radioSelected forState:UIControlStateHighlighted];
            [self.radioButton setBackgroundColor:[UIColor clearColor]];

            [self.radioButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [self.radioButton setUserInteractionEnabled:YES];
            [self.radioButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 8.0, -6, 0.0)];


            [self.radioButton addTarget:self action:@selector(selectRadioButton:) forControlEvents:UIControlEventTouchUpInside];

            [self.footerView addSubview:radioButton];


            // Let's make an NSAttributedString first
            attributedString = [[NSMutableAttributedString alloc] initWithString:disclaimerAccepted];
            //Add LineBreakMode
            paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            CGSize expectedDisclaimerTitleLabelSize  = [attributedString boundingRectWithSize:CGSizeMake((labelWidth-(radioDeselectedImage.size.width+10.0)), 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

            UILabel *tempDisclaimerTitleLabel=[[UILabel alloc] init];
            self.disclaimerTitleLabel=tempDisclaimerTitleLabel;

            self.disclaimerTitleLabel.text=disclaimerAccepted ;
            self.disclaimerTitleLabel.textColor=RepliconStandardBlackColor;
            [self.disclaimerTitleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
            [self.disclaimerTitleLabel setBackgroundColor:[UIColor clearColor]];

            self.disclaimerTitleLabel.frame=CGRectMake(radioDeselectedImage.size.width+20.0,
                                                       self.attestationDesclabel.frame.origin.y+25.0+expectedAttestationDescLabelSize.height,
                                                       (labelWidth-(radioDeselectedImage.size.width+10.0)),
                                                       expectedDisclaimerTitleLabelSize.height);




            self.disclaimerTitleLabel.numberOfLines=100;





            [footerView addSubview:disclaimerTitleLabel];

            y=radioButton.frame.origin.y+radioDeselectedImage.size.height+15;
        }

        else
        {
            y=self.attestationDesclabel.frame.origin.y+self.attestationDesclabel.frame.size.height+15;
        }

        heightofDisclaimerText=expectedAttestationDescLabelSize.height+650;




    }

    if ([expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[expenseSheetStatus isEqualToString:APPROVED_STATUS ]||![parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
    {
        [radioButton setUserInteractionEnabled:NO];
    }





    if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
    {
        SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
        NSDictionary *permittedApprovalAcionsDict=[supportDataModel getExpensePermittedApprovalActionsDataToDBWithUri:expenseSheetURI];


        BOOL canSubmit=FALSE;
        BOOL canUnsubmit=FALSE;

        if (permittedApprovalAcionsDict!=nil &&  ![permittedApprovalAcionsDict isKindOfClass:[NSNull class]])
        {
            canSubmit=[[permittedApprovalAcionsDict objectForKey:@"canSubmit"]boolValue];
            canUnsubmit=[[permittedApprovalAcionsDict objectForKey:@"canUnsubmit"]boolValue];
        }

        UIButton *submitButton =[UIButton buttonWithType:UIButtonTypeCustom];
        submitButton.frame=CGRectZero;

        static CGFloat submitButtonWidth = 237.5f;
        static CGFloat submitButtonHeight = 42.5f;
        CGFloat xsubmitButton=(CGRectGetWidth(self.view.bounds)-submitButtonWidth)/2;

        if (canSubmit||canUnsubmit)
        {
            [submitButton setFrame:CGRectMake(xsubmitButton, y+buttonSpace, submitButtonWidth, submitButtonHeight)];
            footerHeight += submitButtonHeight;

            if(canSubmit)
            {
                BOOL canResubmit=[self canResubmitExpenseSheetForURI:self.expenseSheetURI];
                if (canResubmit)
                {
                    [submitButton setTitle:RPLocalizedString(Resubmit_Button_title, @"")  forState:UIControlStateNormal];
                    [submitButton addTarget:self action:@selector(reSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
                    self.actionType=@"Re-Submit";

                }
                else
                {
                    [submitButton setTitle:RPLocalizedString(Submit_Button_title, @"")  forState:UIControlStateNormal];
                    [submitButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
                    self.actionType=@"Submit";
                }

            }
            else if(canUnsubmit)
            {
                //implemented as per US8709//JUHI
                [submitButton setTitle:RPLocalizedString(Reopen_Button_title, @"")  forState:UIControlStateNormal];
                [submitButton addTarget:self action:@selector(unSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
                self.actionType=@"Unsubmit";
            }


            submitButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_17];
            [submitButton setTitleColor:BUTTON_BLUE_TEXT_COLOR forState:UIControlStateNormal];
            submitButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            submitButton.layer.borderWidth = 0.50f;
            submitButton.layer.cornerRadius = submitButtonHeight/2;
            submitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            submitButton.backgroundColor=[UIColor whiteColor];
            [submitButton addTarget:self action:@selector(submitExpenseSheetAction:) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:submitButton];
        }

        if (![expenseSheetStatus isEqualToString:APPROVED_STATUS] && ![expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] )
        {
            static CGFloat deleteButtonWidth = 237.5f;
            static CGFloat deleteButtonHeight = 42.5f;
            CGFloat xdeleteButton=(CGRectGetWidth(self.view.bounds)-deleteButtonWidth)/2;
            if (deleteButton==nil)
            {
                UIButton *tmpdeleteButton =[UIButton buttonWithType:UIButtonTypeCustom];
                self.deleteButton=tmpdeleteButton;
            }
            if (canSubmit||canUnsubmit)
            {
                [deleteButton setFrame:CGRectMake(xdeleteButton,submitButton.frame.size.height+submitButton.frame.origin.y+buttonSpace-10,deleteButtonWidth, deleteButtonHeight)];
            }
            else
            {
                [deleteButton setFrame:CGRectMake(xdeleteButton,y+buttonSpace,deleteButtonWidth, CGRectGetHeight(submitButton.bounds))];//Ullas DE17842
            }

            footerHeight=footerHeight+deleteButtonHeight+buttonSpace;
            [deleteButton setTitle:RPLocalizedString(Delete_Button_title, @"")  forState:UIControlStateNormal];
            [deleteButton setTitleColor:BUTTON_TEXT_COLOR forState:UIControlStateNormal];
            deleteButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_17];
            self.deleteButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            self.deleteButton.layer.borderWidth = 0.5f;
            self.deleteButton.layer.cornerRadius = deleteButtonHeight/2;
            deleteButton.backgroundColor=[UIColor whiteColor];
            deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [deleteButton addTarget:self action:@selector(deleteExpenseSheetAction:) forControlEvents:UIControlEventTouchUpInside];


            [footerView addSubview:deleteButton];
        }
        CGRect frame=footerView.frame;
        int buttonHeight=footerHeight+buttonSpace-88.0;
        if (isDisclaimer)
        {

            if (isDisclaimerCheck)
            {
                buttonHeight=buttonHeight+expectedAttestationTitleLabelSize.height+expectedAttestationDescLabelSize.height+WithRadioSpaceHeight;
            }
            else
            {
                buttonHeight=buttonHeight+expectedAttestationTitleLabelSize.height+expectedAttestationDescLabelSize.height+WithOutRadioSpaceHeight;
            }

        }

        frame.size.height=buttonHeight;
        footerView.frame=frame;

    }
    else
    {
        
        if (![self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_EXPENSES_MODULE])
        {
            int approvalsFooterViewHeight=205.0;
            ApprovalTablesFooterView *approvalTablesfooterView=[[ApprovalTablesFooterView alloc]initWithFrame:CGRectMake(0, y, self.view.width, approvalsFooterViewHeight ) withStatus:expenseSheetStatus];
            approvalTablesfooterView.delegate=self;
            [footerView addSubview:approvalTablesfooterView];
            
            
            CGRect frame=footerView.frame;
            frame.size.height = approvalTablesfooterView.frame.size.height+100.0;
            footerView.frame=frame;
        }
        else
        {
            CGRect frame=footerView.frame;
            int buttonHeight=footerHeight+buttonSpace-88.0;
            if (isDisclaimer)
            {

                if (isDisclaimerCheck)
                {
                    buttonHeight=buttonHeight+expectedAttestationTitleLabelSize.height+expectedAttestationDescLabelSize.height+WithRadioSpaceHeight;
                }
                else
                {
                    buttonHeight=buttonHeight+expectedAttestationTitleLabelSize.height+expectedAttestationDescLabelSize.height+WithOutRadioSpaceHeight+80.0;
                }

            }

            frame.size.height=buttonHeight;
            footerView.frame=frame;
        }

    }


    DefaultTheme *theme = [[DefaultTheme alloc] init];
    self.expenseEntriesTableView.backgroundColor = [theme expenseEntriesTableBackgroundColor];
    self.expenseEntriesTableView.tableFooterView = footerView;
}

#pragma mark
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.expenseEntriesArray count]>0)
    {
        //Implementation for MOBI-261//JUHI
        if (indexPath.row==0)
        {
            return 44;
        }
        else{
            NSInteger index=indexPath.row-1;
            NSString *expenseEntryExpenseCodeName=[[expenseEntriesArray objectAtIndex:index] expenseEntryExpenseCodeName];
            if (expenseEntryExpenseCodeName)
            {
                return Expense_Code_Cell_Row_Height_50;
            }
        }

    }

    return Each_Cell_Row_Height_58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{//Implementation for MOBI-261//JUHI
    if ([expenseEntriesArray count]>0)
    {
        return [expenseEntriesArray count]+1;
    }

    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimeSheetCellIdentifier";
    cell = (ListOfExpenseEntriesCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[ListOfExpenseEntriesCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.contentView.backgroundColor = [UIColor whiteColor];

    }

    if ([self.expenseEntriesArray count]>0)
    {

        //Implementation for MOBI-261//JUHI
        if (indexPath.row==0)

        {
            CGFloat statusLabelHeight = 20;
            UILabel *statusLb= [[UILabel alloc]initWithFrame:CGRectMake(0, (cell.contentView.height-statusLabelHeight)/2, self.expenseEntriesTableView.width, statusLabelHeight)];
            NSString *statusStr=nil;
            
            ExpenseModel *timesheetModel=[[ExpenseModel alloc]init];
            NSMutableArray *arrayFromDB=nil;
            if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
            {
                arrayFromDB=[timesheetModel getAllApprovalHistoryForExpenseSheetUri:expenseSheetURI];
            }
            else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE]){
                    arrayFromDB=[apprvalModel getAllPendingExpenseSheetApprovalFromDBForExpenseSheet:expenseSheetURI];
                }
                else if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_EXPENSES_MODULE])
                {
                    arrayFromDB=[apprvalModel getAllPreviousExpenseSheetApprovalFromDBForExpenseSheet:expenseSheetURI];

                }
            }


            if ([expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ])
            {
                statusStr=RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
            }
            else if ([expenseSheetStatus isEqualToString:APPROVED_STATUS ]) {
                statusStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
            }
            else if ([expenseSheetStatus isEqualToString:REJECTED_STATUS ]){
                statusStr=RPLocalizedString(REJECTED_STATUS,@"");
            }
            else{
                statusStr=RPLocalizedString(NOT_SUBMITTED_STATUS, @"");
            }

            id<Theme> theme = [[DefaultTheme alloc] init];
            ApprovalStatusPresenter *approvalStatusPresenter = [[ApprovalStatusPresenter alloc] initWithTheme:theme];
            [statusLb setTextColor:[approvalStatusPresenter colorForStatus:expenseSheetStatus]];
            
            cell.contentView.backgroundColor=[UIColor whiteColor];
            statusLb.textAlignment=NSTextAlignmentCenter;
            [statusLb setBackgroundColor:[UIColor clearColor]];
            [cell.contentView addSubview:statusLb];
            
            NSMutableAttributedString *statusAttributedStr= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",statusStr]];
            
            UIView *separatorView = [[UIView alloc]initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-2, CGRectGetWidth(self.view.bounds), 1)];
            [separatorView setBackgroundColor:[theme punchDetailsBorderLineColor]];
            [cell.contentView addSubview:separatorView];


            if ([arrayFromDB count]>0)
            {
                UIImage *approvalCommentImg = [UIImage imageNamed:@"icon_comments_blue"];
                NSTextAttachment *attachment = [NSTextAttachment new];
                [attachment setImage:approvalCommentImg];
                CGFloat attachmentPadding = 2;
                attachment.bounds = CGRectMake(0, -attachmentPadding, approvalCommentImg.size.width, approvalCommentImg.size.height);
                NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
                NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
                [statusAttributedStr appendAttributedString:space];
                [statusAttributedStr appendAttributedString:attachmentString];
                [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            }
            else
            {
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            [statusAttributedStr addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]
                                        range:NSMakeRange(0, statusAttributedStr.length)];
            [statusLb setAttributedText:statusAttributedStr];

        }
        else{
            //Implementation for MOBI-261//JUHI
            NSInteger index=indexPath.row-1;
            NSString *expenseEntryExpenseCodeName      =[[expenseEntriesArray objectAtIndex:index] expenseEntryExpenseCodeName];
            NSString *incurredAmount   =[[expenseEntriesArray objectAtIndex:index] expenseEntryIncurredAmountTotal];
            NSString *incurredCurrency =[[expenseEntriesArray objectAtIndex:index] expenseEntryIncurredAmountTotalCurrencyName];
            NSString *convertedIncurredAmount=[Util getRoundedValueFromDecimalPlaces:[incurredAmount newDoubleValue] withDecimalPlaces:2];
            NSString *incurredAmountStr=[NSString stringWithFormat:@"%@ %@",incurredCurrency,convertedIncurredAmount];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            myDateFormatter.dateFormat = @"MMM dd, yyyy";
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            NSString *expenseDate =[myDateFormatter stringFromDate:[[expenseEntriesArray objectAtIndex:index] expenseEntryIncurredDate]];


            NSString *expenseReceiptUri =[[expenseEntriesArray objectAtIndex:index] expenseEntryExpenseReceiptUri];
            BOOL isReceiptAvailable=NO;
            if (expenseReceiptUri!=nil && ![expenseReceiptUri isKindOfClass:[NSNull class]])
            {
                isReceiptAvailable=YES;
            }
            NSString *expenseReimbursementUri =[[expenseEntriesArray objectAtIndex:index] expenseEntryReimbursementUri];
            BOOL isReimburesmentAvailable=NO;
            if (expenseReimbursementUri!=nil && ![expenseReimbursementUri isKindOfClass:[NSNull class]])
            {
                if ([expenseReimbursementUri isEqualToString:@"urn:replicon:expense-reimbursement-option:reimburse-employee"])
                {
                    isReimburesmentAvailable=YES;
                }
            }

            [cell createCellLayoutWithParams:expenseEntryExpenseCodeName upperrightstr:incurredAmountStr lowerrightStr:expenseDate isReceiptAvailable:isReceiptAvailable isReimburesmentAvailable:isReimburesmentAvailable width:CGRectGetWidth(self.view.bounds)];


            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
    }




    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLS_LOG(@"-----Row selected on ListOfExpenseEntriesViewController -----");
    //Implementation for MOBI-261//JUHI
    if (indexPath.row==0)
    {
        ApproverCommentViewController *approverCommentCtrl=[[ApproverCommentViewController alloc]init];
        approverCommentCtrl.sheetIdentity=expenseSheetURI;
        approverCommentCtrl.viewType=@"Expense";
        if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
        {
            approverCommentCtrl.delegate=self;
        }
        else
        {
            approverCommentCtrl.delegate=parentDelegate;
            approverCommentCtrl.approvalsModuleName=self.approvalsModuleName ;

        }
        ExpenseModel *timesheetModel=[[ExpenseModel alloc]init];
        NSMutableArray *arrayFromDB=nil;
        if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
        {
            arrayFromDB=[timesheetModel getAllApprovalHistoryForExpenseSheetUri:expenseSheetURI];
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE]){
                arrayFromDB=[apprvalModel getAllPendingExpenseSheetApprovalFromDBForExpenseSheet:expenseSheetURI];
            }
            else if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_EXPENSES_MODULE])
            {
                arrayFromDB=[apprvalModel getAllPreviousExpenseSheetApprovalFromDBForExpenseSheet:expenseSheetURI];

            }
        }


        if ([arrayFromDB count]>0)
        {
            if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
            {
                [self.navigationController pushViewController:approverCommentCtrl animated:YES];
            }
            else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                [parentDelegate pushToViewController:approverCommentCtrl];
            }

        }


    }
    else
    {
        //Implementation for MOBI-261//JUHI
        NSInteger index=indexPath.row-1;
        ExpenseEntryViewController *expenseEntryVC = nil;
        if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
        {
            expenseEntryVC = [self.injector getInstance:[ExpenseEntryViewController class]];
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            expenseEntryVC= [[ExpenseEntryViewController alloc] initWithDefaultTableViewCellSylist:self.defaultTableViewCellStylist
                                                                                                        searchTextFieldStylist:self.searchTextFieldStylist
                                                                                                               spinnerDelegate:self.spinnerDelegate];
        }
        
        
        [expenseEntryVC setUpWithExpenseEntryObject:[expenseEntriesArray objectAtIndex:index] screenMode:EDIT_EXPENSE_ENTRY];
        BOOL cannotEdit = YES;
        NSString *tmpexpenseSheetStatus=expenseSheetStatus;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_EXPENSES_MODULE]||[self.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            tmpexpenseSheetStatus=APPROVED_STATUS;
        }

        if ([tmpexpenseSheetStatus isEqualToString:NOT_SUBMITTED_STATUS] ||[tmpexpenseSheetStatus isEqualToString:REJECTED_STATUS])
        {
            cannotEdit= NO;
        }
        [expenseEntryVC setCanNotEdit:cannotEdit];
        expenseEntryVC.isDisclaimerRequired=self.disclaimerSelected;//Implementation as per US9172//JUHI
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_EXPENSES_MODULE])
        {
            [expenseEntryVC setExpenseSheetStatus:APPROVED_STATUS];
        }
        else
        {
            [expenseEntryVC setExpenseSheetStatus:expenseSheetStatus];
        }


        //[expenseEntryVC setHidesBottomBarWhenPushed:TRUE];
        if ([parentDelegate isKindOfClass:[ListOfExpenseSheetsViewController class]])
        {
            expenseEntryVC.parentDelegate=self;
            [self.navigationController pushViewController:expenseEntryVC animated:YES];
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            expenseEntryVC.parentDelegate=parentDelegate;
            [parentDelegate pushToViewController:expenseEntryVC];
        }
    }




    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark -
#pragma mark Other Methods

-(void)reSubmitAction:(id)sender
{

    ApprovalActionsViewController *approvalActionsViewController = [[ApprovalActionsViewController alloc] init];
    [approvalActionsViewController setSheetIdentity:self.expenseSheetURI];
    [approvalActionsViewController setSelectedSheet:self.expenseSheetTitle];
    [approvalActionsViewController setAllowBlankComments:YES];
    [approvalActionsViewController setActionType:@"Re-Submit"];
    [approvalActionsViewController setDelegate:self];
    //Implementation as per US9172//JUHI
    [approvalActionsViewController setIsDisclaimerRequired:disclaimerSelected];
    [approvalActionsViewController setArrayOfEntriesForSave:[self getArrayOfExpenseEntryObjectsFromAllTheEntriesFromDB]];
    [self.navigationController pushViewController:approvalActionsViewController animated:YES];


}

-(void)submitAction:(id)sender
{

    if ([[NetworkMonitor sharedInstance] networkAvailable] == NO)
    {

        [Util showOfflineAlert];
    }
    else
    {

        CLS_LOG(@"-----Submit expense sheet action on ListOfExpenseEntriesViewController -----");
        //Implementation as per US9172//JUHI
        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];


        NSArray *expenseSheetDetailsArray = [expenseModel getExpensesInfoForSheetIdentity:expenseSheetURI];
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




        //        NSMutableArray *arrayOfEntriesForSave=[self getArrayOfExpenseEntryObjectsFromAllTheEntriesFromDB];


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




        [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitExpenseReceivedData) name:SUBMITTED_NOTIFICATION object:nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

        [[RepliconServiceManager expenseService] sendRequestToSaveExpenseSheetForExpenseSheetDict:expenseDetailsDict withExpenseEntriesArray:expenseEntriesArray withDelegate:self isProjectAllowed:isProjectAllowed isProjectRequired:isProjectRequired isDisclaimerAccepted:disclaimerSelected isExpenseSubmit:YES withComments:nil];//Implementation as per US9172//JUHI



    }
}

-(void)unSubmitAction:(id)sender
{
    if ([[NetworkMonitor sharedInstance] networkAvailable] == NO)
    {

        [Util showOfflineAlert];
    }
    else
    {
        CLS_LOG(@"-----Reopen expense sheet action on ListOfExpenseEntriesViewController -----");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UNSUBMITTED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unSubmitExpenseReceivedData) name:UNSUBMITTED_NOTIFICATION object:nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[RepliconServiceManager expenseService]sendRequestToUnsubmitExpensesDataForExpenseURI:expenseSheetURI withComments:nil withDelegate:self];


    }

}

-(void)RecievedData
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION object:nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self displayAllExpenseEntries:YES];
    self.isFirstTimeLoad=YES;
    ExpenseModel *expensesModel = [[ExpenseModel alloc] init];
    NSArray *dbexpenseEntriesArray = [expensesModel getAllExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetURI];


    if ([dbexpenseEntriesArray count] == 0)
    {
        if (footerView !=nil) {
            [footerView setHidden:YES];
        }
        [self.expenseEntriesTableView removeFromSuperview];
        [self addDeleteButtonWithMessage];
    }

    if ([expenseEntriesArray count] > 0)
    {
        if(messageLabel!=nil)
        {
            [messageLabel removeFromSuperview];
            [self.deleteButton removeFromSuperview];
        }
        [self createFooter];
    }

    [self.expenseEntriesTableView reloadData];

}

-(void)submitExpenseReceivedData
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self popToListOfExpenseSheets];
}


-(void)unSubmitExpenseReceivedData
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNSUBMITTED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self popToListOfExpenseSheets];
}


-(void)deleteExpenseReceivedData
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSE_SHEET_DELETED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
    [expenseModel deleteExpenseSheetFromDBForSheetUri:expenseSheetURI];


    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

-(void)popToListOfExpenseSheets
{
    SQLiteDB *myDB = [SQLiteDB getInstance];

    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];

    NSArray *expensesArr = [expenseModel getExpensesInfoForSheetIdentity:self.expenseSheetURI];



    if ([expensesArr count]>0)
    {
        NSMutableDictionary *expensesDict=[[expensesArr objectAtIndex:0]mutableCopy];
        if ([self.actionType isEqualToString:@"Submit"])
        {
            [expensesDict setObject:WAITING_FOR_APRROVAL_STATUS forKey:@"approvalStatus" ];
        }
        else if ([self.actionType isEqualToString:@"Unsubmit"])
        {
            [expensesDict setObject:NOT_SUBMITTED_STATUS forKey:@"approvalStatus" ];
        }

        [myDB deleteFromTable:@"ExpenseSheets" where:[NSString stringWithFormat:@"expenseSheetUri = '%@'",self.expenseSheetURI] inDatabase:@""];
        [myDB insertIntoTable:@"ExpenseSheets" data:expensesDict intoDatabase:@""];

    }


    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

/************************************************************************************************************
 @Function Name   : addNewExpenseEntryAction
 @Purpose         : Call back for pressing on add new expense entry action
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)addNewExpenseEntryAction:(id)sender
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Add new expense entry action on ListOfExpenseEntriesViewController -----");
    ExpenseEntryViewController *expenseEntryViewController = [self.injector getInstance:[ExpenseEntryViewController class]];
    [expenseEntryViewController setUpWithExpenseEntryObject:[self createEmptyEntryObjectForAddNewExpense] screenMode:ADD_EXPENSE_ENTRY];
    expenseEntryViewController.parentDelegate=self;
    expenseEntryViewController.isDisclaimerRequired=self.disclaimerSelected;//Implementation as per US9172//JUHI

    //Implementation For EXP-151//JUHI
    expenseEntryViewController.reimbursementCurrencyName=reimbursementCurrencyName;
    expenseEntryViewController.reimbursementCurrencyURI=reimbursementCurrencyURI;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:expenseEntryViewController] animated:YES completion:nil];
}

/************************************************************************************************************
 @Function Name   : submitExpenseSheetAction
 @Purpose         : Call back for pressing submit expense sheet action
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)submitExpenseSheetAction:(id)sender
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
}

/************************************************************************************************************
 @Function Name   : deleteExpenseSheetAction
 @Purpose         : Call back for pressing delete expense sheet action
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)deleteExpenseSheetAction:(id)sender
{

    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"No", @"No")
                                   otherButtonTitle:RPLocalizedString(@"Yes", @"Yes")
                                           delegate:self
                                            message:RPLocalizedString(Delet_ExpenseSheet_Confirmation, Delet_ExpenseSheet_Confirmation)
                                              title:nil
                                                tag:DELETE_EXPENSESHEET_ALERT_TAG];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 1 && alertView.tag==DELETE_EXPENSESHEET_ALERT_TAG)
    {


        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;
        }
        else
        {
            CLS_LOG(@"-----Delete Expensesheet action on ListOfExpenseEntriesViewController -----");
            [(UIAlertView *)alertView dismissWithClickedButtonIndex:[(UIAlertView *)alertView cancelButtonIndex] animated:NO];

            [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSE_SHEET_DELETED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteExpenseReceivedData) name:EXPENSE_SHEET_DELETED_NOTIFICATION object:nil];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [[RepliconServiceManager expenseService]sendRequestToDeleteExpensesSheetForExpenseURI:expenseSheetURI];



        }
    }
}

-(ExpenseEntryObject *)createEmptyEntryObjectForAddNewExpense
{
    ExpenseEntryObject *expenseEntryObj   = [[ExpenseEntryObject alloc] init];
    expenseEntryObj.expenseEntryIncurredDate=nil;
    expenseEntryObj.expenseEntryDescription=nil;
    expenseEntryObj.expenseEntryApprovalStatus=nil;
    expenseEntryObj.expenseEntryBillingUri=nil;
    expenseEntryObj.expenseEntryExpenseCodeName=nil;
    expenseEntryObj.expenseEntryExpenseCodeUri=nil;
    expenseEntryObj.expenseEntryExpenseEntryUri=nil;
    expenseEntryObj.expenseEntryExpenseReceiptName=nil;
    expenseEntryObj.expenseEntryExpenseReceiptUri=nil;
    expenseEntryObj.expenseEntryExpenseSheetUri=expenseSheetURI;
    expenseEntryObj.expenseEntryIncurredAmountNet=@"0.00";
    expenseEntryObj.expenseEntryIncurredAmountNetCurrencyName=nil;
    expenseEntryObj.expenseEntryIncurredAmountNetCurrencyUri=nil;
    expenseEntryObj.expenseEntryIncurredAmountTotal=nil;
    expenseEntryObj.expenseEntryIncurredAmountTotalCurrencyName=nil;
    expenseEntryObj.expenseEntryIncurredAmountTotalCurrencyUri=nil;
    expenseEntryObj.expenseEntryPaymentMethodName=nil;
    expenseEntryObj.expenseEntryPaymentMethodUri=nil;
    expenseEntryObj.expenseEntryProjectName=nil;
    expenseEntryObj.expenseEntryProjectUri=nil;
    expenseEntryObj.expenseEntryQuantity=nil;
    expenseEntryObj.expenseEntryRateAmount=nil;
    expenseEntryObj.expenseEntryRateCurrencyName=nil;
    expenseEntryObj.expenseEntryRateCurrencyUri=nil;
    expenseEntryObj.expenseEntryReimbursementUri=nil;
    expenseEntryObj.expenseEntryTaskName=nil;
    expenseEntryObj.expenseEntryTaskUri=nil;
    expenseEntryObj.expenseEntryClientName=nil;
    expenseEntryObj.expenseEntryClientUri=nil;
    expenseEntryObj.expenseEntryBaseCurrency=@"$";
    expenseEntryObj.receiptImageData=nil;
    ExpenseModel *expensemodel=[[ExpenseModel alloc]init];
    NSArray *taxCodeArray=[expensemodel getAllExpenseTaxCodesFromDB];
    NSMutableArray *incurredAmountTaxesArray=[NSMutableArray array];
    for (int i=0; i<[taxCodeArray count]; i++)
    {
        NSMutableDictionary *tempIncurredAmountDict=[NSMutableDictionary dictionary];
        [tempIncurredAmountDict setObject:@"0.00" forKey:@"taxAmount"];
        [tempIncurredAmountDict setObject:@"" forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict setObject:@""  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict setObject:[[taxCodeArray objectAtIndex:i] objectForKey:@"uri"] forKey:@"taxCodeUri"];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict];
    }
    expenseEntryObj.expenseEntryIncurredTaxesArray=incurredAmountTaxesArray;

    return expenseEntryObj;

}

-(BOOL)canResubmitExpenseSheetForURI:(NSString *)sheetUri
{
    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
    NSArray *approvalDetailsDataArr=[expenseModel getAllApprovalHistoryForExpenseSheetUri:sheetUri];

    for (NSDictionary *approvalDetailsDataDict in approvalDetailsDataArr)
    {
        if ([[approvalDetailsDataDict objectForKey:@"actionUri"] isEqualToString:@"urn:replicon:approval-action:submit"])
        {
            return YES;
        }
    }

    return NO;
}

-(void)addDeleteButtonWithMessage
{

    if (![expenseSheetStatus isEqualToString:APPROVED_STATUS] && ![expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];

        //Arrow IMAGE VIEW
        UIImage *arrowImage = [Util thumbnailImage:ADD_DIRECTION_ARROW];

        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-60,(screenRect.size.height/screenRect.size.width)*8.82, arrowImage.size.width,arrowImage.size.height)];
        [arrowImageView setImage:arrowImage];
        [self.view addSubview:arrowImageView];




        [self.messageLabel removeFromSuperview];
        if (messageLabel == nil)
        {
            UILabel *tempmessageLabel = [[UILabel alloc] init];
            self.messageLabel=tempmessageLabel;

        }
        self.messageLabel.frame=CGRectMake(45,arrowImageView.bottom-10, CGRectGetWidth(self.view.bounds)-90, 60);
        [self.messageLabel setText:RPLocalizedString(NoSheetsAvailable, "") ];
        messageLabel.numberOfLines=2;
        self.messageLabel.textAlignment=NSTextAlignmentCenter;
        [messageLabel setTextColor:RepliconStandardBlackColor];
        [messageLabel  setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
        [messageLabel setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:messageLabel];
        [self addDeleteButtonToViewwithPosition:self.view.bottom-self.tabBarController.tabBar.height andParentView:self.view];
    }



}

-(void)addDeleteButtonToViewwithPosition:(float)position andParentView:(UIView*)viewToAdd
{
    if (![expenseSheetStatus isEqualToString:APPROVED_STATUS] && ![expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
    {


        [self.deleteButton removeFromSuperview];
        UIImage *deleteBtnImg =[Util thumbnailImage:DeleteTimesheetButtonImage] ;
        CGFloat xDeleteButton=(CGRectGetWidth(self.view.bounds)-deleteBtnImg.size.width)/2;
        self.deleteButton =[UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.deleteButton.layer.borderWidth = 1.0f;
        [self.deleteButton setFrame:CGRectMake(xDeleteButton,position-(2*deleteBtnImg.size.height), deleteBtnImg.size.width, deleteBtnImg.size.height)];
        self.deleteButton.layer.cornerRadius = deleteBtnImg.size.height/2;
        self.deleteButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_17];
        [self.deleteButton setTitle:RPLocalizedString(Delete_Button_title, @"")  forState:UIControlStateNormal];
        [self.deleteButton setTitleColor:[Util colorWithHex:@"#FF6B53" alpha:1.0] forState:UIControlStateNormal];
        self.deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.deleteButton addTarget:self action:@selector(deleteExpenseSheetAction:) forControlEvents:UIControlEventTouchUpInside];
        [viewToAdd addSubview:self.deleteButton];
    }


}

#pragma mark Approval headerview Action
- (void)handleButtonClickForHeaderView:(NSInteger)senderTag
{

    if ([parentDelegate respondsToSelector:@selector(handlePreviousNextButtonFromApprovalsListforViewTag:forbuttonTag:)])
    {
        [parentDelegate handlePreviousNextButtonFromApprovalsListforViewTag:currentViewTag forbuttonTag:senderTag];
    }


}
#pragma mark Approval Footerview Action
- (void)handleButtonClickForFooterView:(NSInteger)senderTag
{
    if ([parentDelegate respondsToSelector:@selector(handleApproveOrRejectActionWithApproverComments:andSenderTag:)])
    {
        [parentDelegate handleApproveOrRejectActionWithApproverComments:self.approverComments andSenderTag:senderTag];
    }

}
-(void)resetViewForApprovalsCommentsAction:(BOOL)isReset andComments:(NSString *)approverCommentsStr forParentView:(ApprovalTablesFooterView *)approvalTablesFooterView
{
    self.approverComments=approverCommentsStr;
    if(isReset){
        self.expenseEntriesTableView.scrollEnabled=NO;
        int disclaimerHeight=self.attestationTitlelabel.frame.size.height+self.attestationDesclabel.frame.size.height;
        CGPoint newContentOffset = CGPointZero;
        if (disclaimerHeight>0)
        {
             newContentOffset = CGPointMake(0, [self.expenseEntriesTableView contentSize].height -(self.expenseEntriesTableView.tableFooterView.frame.size.height-disclaimerHeight-20.0));
        }
        else
        {
             newContentOffset = CGPointMake(0, [self.expenseEntriesTableView contentSize].height -self.expenseEntriesTableView.tableFooterView.frame.size.height);
        }
       
        [self.expenseEntriesTableView setContentOffset:newContentOffset animated:NO];

    }
    else{
        self.expenseEntriesTableView.scrollEnabled=YES;
        CGRect frame=self.expenseEntriesTableView.frame;
        frame.origin.y=0;
        [self.expenseEntriesTableView setFrame:frame];
    }

}
-(void)showMessageLabel
{

    UILabel *msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, HeightOfNoTOMsgLabel)];
    msgLabel.text=RPLocalizedString(APPROVAL_EXPENSESHEET_NOT_WAITINGFORAPPROVAL, @"");
    msgLabel.backgroundColor=[UIColor clearColor];
    msgLabel.numberOfLines=2;
    msgLabel.textAlignment=NSTextAlignmentCenter;
    msgLabel.font=[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17];
    [self.view addSubview:msgLabel];


}
//Implementation as per US9172//JUHI
-(void)selectRadioButton:(id)sender {

    UIImage *currentRadioButtonImage= [sender imageForState:UIControlStateNormal];

    if (currentRadioButtonImage == [Util thumbnailImage:CheckBoxSelectedImage]) {
        UIImage *deselectedRadioImage = [Util thumbnailImage:CheckBoxDeselectedImage];
        if (sender != nil) {
            [sender setImage:deselectedRadioImage forState:UIControlStateNormal];
            [sender setImage:deselectedRadioImage forState:UIControlStateHighlighted];
            [self setDisclaimerSelected:FALSE];
            [self.disclaimerTitleLabel setText:RPLocalizedString(@"Accept", @"") ];
        }
    }
    else
    {
        UIImage *selectedRadioImage = [Util thumbnailImage:CheckBoxSelectedImage];
        if (sender != nil) {
            [sender setImage:selectedRadioImage forState:UIControlStateNormal];
            [sender setImage:selectedRadioImage forState:UIControlStateHighlighted];
            [self.disclaimerTitleLabel setText:RPLocalizedString(@"Accepted", @"") ];
            [self setDisclaimerSelected:TRUE];
        }
    }


}
//Implementation as per US9172//JUHI
-(NSMutableArray *)getArrayOfExpenseEntryObjectsFromAllTheEntriesFromDB
{
    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];

    NSArray *expenseEntriesDbArray=[expenseModel getAllExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetURI];
    NSMutableArray *arrayOfTimeEntriesObjectsForSave=[NSMutableArray array];
    for (int i=0; i<[expenseEntriesDbArray count]; i++)
    {
        NSDictionary *expenseDict=[expenseEntriesDbArray objectAtIndex:i];
        ExpenseEntryObject *expenseEntryObj   = [[ExpenseEntryObject alloc] init];

        expenseEntryObj.expenseEntryIncurredDate=[Util convertTimestampFromDBToDate:[[expenseDict objectForKey:@"incurredDate"] stringValue]];
        expenseEntryObj.expenseEntryDescription=[expenseDict objectForKey:@"expenseEntryDescription"];

        expenseEntryObj.expenseEntryApprovalStatus=[expenseDict objectForKey:@"approvalStatus"];
        expenseEntryObj.expenseEntryBillingUri=[expenseDict objectForKey:@"billingUri"];
        expenseEntryObj.expenseEntryExpenseCodeName=[expenseDict objectForKey:@"expenseCodeName"];
        expenseEntryObj.expenseEntryExpenseCodeUri=[expenseDict objectForKey:@"expenseCodeUri"];
        expenseEntryObj.expenseEntryExpenseEntryUri=[expenseDict objectForKey:@"expenseEntryUri"];
        expenseEntryObj.expenseEntryExpenseReceiptName=[expenseDict objectForKey:@"expenseReceiptName"];
        expenseEntryObj.expenseEntryExpenseReceiptUri=[expenseDict objectForKey:@"expenseReceiptUri"];
        expenseEntryObj.expenseEntryExpenseSheetUri=[expenseDict objectForKey:@"expenseSheetUri"];
        expenseEntryObj.expenseEntryIncurredAmountNet=[expenseDict objectForKey:@"incurredAmountNet"];
        expenseEntryObj.expenseEntryIncurredAmountNetCurrencyName=[expenseDict objectForKey:@"incurredAmountNetCurrencyName"];
        expenseEntryObj.expenseEntryIncurredAmountNetCurrencyUri=[expenseDict objectForKey:@"incurredAmountNetCurrencyUri"];
        expenseEntryObj.expenseEntryIncurredAmountTotal=[expenseDict objectForKey:@"incurredAmountTotal"];
        expenseEntryObj.expenseEntryIncurredAmountTotalCurrencyName=[expenseDict objectForKey:@"incurredAmountTotalCurrencyName"];
        expenseEntryObj.expenseEntryIncurredAmountTotalCurrencyUri=[expenseDict objectForKey:@"incurredAmountTotalCurrencyUri"];
        expenseEntryObj.expenseEntryPaymentMethodName=[expenseDict objectForKey:@"paymentMethodName"];
        expenseEntryObj.expenseEntryPaymentMethodUri=[expenseDict objectForKey:@"paymentMethodUri"];
        expenseEntryObj.expenseEntryProjectName=[expenseDict objectForKey:@"projectName"];
        expenseEntryObj.expenseEntryProjectUri=[expenseDict objectForKey:@"projectUri"];
        expenseEntryObj.expenseEntryQuantity=[expenseDict objectForKey:@"quantity"];
        expenseEntryObj.expenseEntryRateAmount=[expenseDict objectForKey:@"rateAmount"];
        expenseEntryObj.expenseEntryRateCurrencyName=[expenseDict objectForKey:@"rateCurrencyName"];
        expenseEntryObj.expenseEntryRateCurrencyUri=[expenseDict objectForKey:@"rateCurrencyUri"];
        expenseEntryObj.expenseEntryReimbursementUri=[expenseDict objectForKey:@"reimbursementUri"];
        expenseEntryObj.expenseEntryTaskName=[expenseDict objectForKey:@"taskName"];
        expenseEntryObj.expenseEntryTaskUri=[expenseDict objectForKey:@"taskUri"];
        expenseEntryObj.expenseEntryTaskName=[expenseDict objectForKey:@"taskName"];
        expenseEntryObj.expenseEntryTaskUri=[expenseDict objectForKey:@"taskUri"];
        expenseEntryObj.expenseEntryClientName=[expenseDict objectForKey:@"clientName"];
        expenseEntryObj.expenseEntryClientUri=[expenseDict objectForKey:@"clientUri"];


        NSMutableArray *incurredAmountTaxesArray=[NSMutableArray array];
        NSMutableDictionary *tempIncurredAmountDict1=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict2=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict3=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict4=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict5=[NSMutableDictionary dictionary];

        NSString *taxAmount1        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount1"]];
        NSString *taxCurrencyName1  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName1"]];
        NSString *taxCurrencyUri1   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri1"]];
        NSString *taxCodeUri1       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri1"]];

        [tempIncurredAmountDict1 setObject:taxAmount1       forKey:@"taxAmount"];
        [tempIncurredAmountDict1 setObject:taxCurrencyName1 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict1 setObject:taxCurrencyUri1  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict1 setObject:taxCodeUri1       forKey:@"taxCodeUri"];

        NSString *taxAmount2        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount2"]];
        NSString *taxCurrencyName2  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName2"]];
        NSString *taxCurrencyUri2   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri2"]];
        NSString *taxCodeUri2       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri2"]];

        [tempIncurredAmountDict2 setObject:taxAmount2       forKey:@"taxAmount"];
        [tempIncurredAmountDict2 setObject:taxCurrencyName2 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict2 setObject:taxCurrencyUri2  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict2 setObject:taxCodeUri2       forKey:@"taxCodeUri"];

        NSString *taxAmount3        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount3"]];
        NSString *taxCurrencyName3  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName3"]];
        NSString *taxCurrencyUri3   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri3"]];
        NSString *taxCodeUri3       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri3"]];

        [tempIncurredAmountDict3 setObject:taxAmount3       forKey:@"taxAmount"];
        [tempIncurredAmountDict3 setObject:taxCurrencyName3 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict3 setObject:taxCurrencyUri3  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict3 setObject:taxCodeUri3       forKey:@"taxCodeUri"];

        NSString *taxAmount4        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount4"]];
        NSString *taxCurrencyName4  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName4"]];
        NSString *taxCurrencyUri4   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri4"]];
        NSString *taxCodeUri4       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri4"]];

        [tempIncurredAmountDict4 setObject:taxAmount4       forKey:@"taxAmount"];
        [tempIncurredAmountDict4 setObject:taxCurrencyName4 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict4 setObject:taxCurrencyUri4  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict4 setObject:taxCodeUri4       forKey:@"taxCodeUri"];

        NSString *taxAmount5        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount5"]];
        NSString *taxCurrencyName5  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName5"]];
        NSString *taxCurrencyUri5   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri5"]];
        NSString *taxCodeUri5       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri5"]];

        [tempIncurredAmountDict5 setObject:taxAmount5       forKey:@"taxAmount"];
        [tempIncurredAmountDict5 setObject:taxCurrencyName5 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict5 setObject:taxCurrencyUri5  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict5 setObject:taxCodeUri5       forKey:@"taxCodeUri"];


        [incurredAmountTaxesArray addObject:tempIncurredAmountDict1];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict2];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict3];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict4];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict5];


        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];

        if ([userDetailsArray count]!=0)
        {
            NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
            NSString *tempBaseCurrencyName=[userDict objectForKey:@"baseCurrencyName"];
            NSString *tempBaseCurrencyUri=[userDict objectForKey:@"baseCurrencyUri"];

            if (tempBaseCurrencyName!=nil && tempBaseCurrencyUri!=nil && ![tempBaseCurrencyName isKindOfClass:[NSNull class]] && ![tempBaseCurrencyUri isKindOfClass:[NSNull class]] )
            {
                expenseEntryObj.expenseEntryBaseCurrency=tempBaseCurrencyName;
            }
        }

        expenseEntryObj.expenseEntryIncurredTaxesArray=incurredAmountTaxesArray;
        NSArray *tempUdfArray=[expenseModel getExpenseCustomFieldsForExpenseSheetURI:[expenseDict objectForKey:@"expenseSheetUri"] moduleName:EXPENSES_UDF entryURI:[expenseDict objectForKey:@"expenseEntryUri"]];
        NSMutableArray *udfArray=[NSMutableArray array];
        for (int k=0; k<[tempUdfArray count]; k++)
        {
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            NSMutableDictionary *dict=[tempUdfArray objectAtIndex:k];
            NSString *fieldType=[dict objectForKey:@"entry_type"];
            NSString *fieldUri=[dict objectForKey:@"udf_uri"];
            NSString *fieldValue=[dict objectForKey:@"udfValue"];
            if ([fieldType isEqualToString:TEXT_UDF_TYPE])
            {
                [dataDict setObject:UDFType_TEXT forKey:@"udfType"];
            }
            else if ([fieldType isEqualToString:NUMERIC_UDF_TYPE])
            {
                [dataDict setObject:UDFType_NUMERIC forKey:@"udfType"];
            }
            else if ([fieldType isEqualToString:DATE_UDF_TYPE])
            {
                [dataDict setObject:UDFType_DATE forKey:@"udfType"];
            }
            else if ([fieldType isEqualToString:DROPDOWN_UDF_TYPE])
            {
                [dataDict setObject:UDFType_DROPDOWN forKey:@"udfType"];
                fieldValue=[dict objectForKey:@"dropDownOptionURI"];
            }
            if (fieldValue==nil || [fieldValue isKindOfClass:[NSNull class]]|| [fieldValue isEqualToString:@""]|| [fieldValue isEqualToString:NULL_STRING])
            {
                fieldValue=RPLocalizedString(NONE_STRING, @"");
            }
            [dataDict setObject:fieldValue forKey:@"udfValue"];
            [dataDict setObject:fieldUri forKey:@"udfUri"];
            [udfArray addObject:dataDict];

        }
        expenseEntryObj.expenseEntryUdfArray=udfArray;
        [arrayOfTimeEntriesObjectsForSave addObject:expenseEntryObj];


    }

    return arrayOfTimeEntriesObjectsForSave;
}



#pragma mark NetworkMonitor

-(void) networkActivated
{

}

#pragma mark -
#pragma mark Memory Based Methods

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.footerView=nil;
    self.expenseEntriesTableView=nil;
    self.messageLabel=nil;
    self.deleteButton=nil;
}

#pragma mark - Frame math

- (CGFloat)heightForTableView
{
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame));
}

-(void)dealloc
{
    self.expenseEntriesTableView.delegate = nil;
    self.expenseEntriesTableView.dataSource = nil;
}
@end
