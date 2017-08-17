//
//  AddNewExpenseViewController.m
//  Replicon
//
//  Created by Devi Malladi on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2AddNewExpenseViewController.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"
#import "G2ReceiptsViewController.h"
#import "QuartzCore/QuartzCore.h"

@interface G2AddNewExpenseViewController () //note the empty category name
-(NSString *)isValidEntry;
-(void) releaseCache;
@end

@implementation G2AddNewExpenseViewController
@synthesize ratedValuesArray;
@synthesize tnewExpenseEntryTable;
@synthesize amountValue;
@synthesize baseCurrency;
@synthesize kilometersUnitsValue;
@synthesize amountValuesArray;
@synthesize defaultRateAndAmountsArray;
@synthesize defaultDescription;
@synthesize numberUdfText;
@synthesize expesneSheetStatus;
@synthesize isEntriesAvailable;
@synthesize b64String;
@synthesize expenseSheetID;
@synthesize currencyIdentity;
@synthesize netAmount;
@synthesize selectedIndexPath;
@synthesize ratedCalculatedValuesArray;
@synthesize currentIndexPath;
@synthesize tnewEntryDelegate,taxExpenseChnged;
@synthesize firstSectionfieldsArray;
@synthesize secondSectionfieldsArray;
@synthesize  pickerViewC;
@synthesize  toolbarSegmentControl;
@synthesize datePicker;
@synthesize  pickerView1;
@synthesize expensesModel;
@synthesize  supportDataModel;
@synthesize receiptViewController;
@synthesize  mainScrollView;
@synthesize hasClient;
@synthesize isDataPickerChosen;
@synthesize rate;
static float keyBoardHeight=260.0;
@synthesize isComplexAmountCalucationScenario;
@synthesize rateAndAmountsArray;
@synthesize totalCalucatedAmountArray;
@synthesize dataListViewCtrl;
@synthesize fromReloaOfDataView;

int countAddExpenseUDF;
#define DEFAULT_DATE_PICKER_TAG 3000
#define FIRSTSECTION_TAG_INDEX 4000
#define SECONDSECTION_TAG_INDEX 4050
#define SAVE_TAG_INDEX 100
#define RECEIPT_TAG_INDEX 200
#define ROW_HEIGHT 44.0

//#define Image_Alert_tag_Add 50
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

- (id) initWithTitle: (NSString *)titleText sheetID:_sheetIdentity
{
	self = [super init];
	if (self != nil) {
        countAddExpenseUDF=0;
        if (expensesModel==nil) {
            G2ExpensesModel *tempexpensesModel=[[G2ExpensesModel alloc]init];
            self.expensesModel=tempexpensesModel;
            
        }
        if (supportDataModel==nil) {
            G2SupportDataModel *tempsupportDataModel=[[G2SupportDataModel alloc]init];
            self.supportDataModel=tempsupportDataModel;
           
        }
        
        
		previousWasTaxExpense = NO;
		typeAvailableForProject = YES;
		taxExpenseChnged = YES;
		
		permissionType = PermType_Invalid;
		
		permissionType = [G2PermissionsModel getProjectPermissionType];
		
		[self setExpenseSheetID:_sheetIdentity];
        
        hasClient=TRUE;
		[self getfirstSectionFields];
		[self getSecondSectionFields];
		
		[self registerForKeyBoardNotifications];
        
        int totalHeight=0;
        int scrollHeight=0;
        if (countAddExpenseUDF==0)
        {
            totalHeight=80;
        }
        else{
            totalHeight= (countAddExpenseUDF*48.0)+55;
        }
        
        if(permissionType==PermType_ProjectSpecific || permissionType==PermType_Both)
        {
            //scrollHeight=scrollHeight+ROW_HEIGHT;
            totalHeight=totalHeight+ROW_HEIGHT;
        }
        
        scrollHeight =([firstSectionfieldsArray count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT)+35.0+48.0+ROW_HEIGHT+ROW_HEIGHT;
		UITableView *temptnewExpenseEntryTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, self.view.frame.size.height+totalHeight) style:UITableViewStyleGrouped];//US4065//Juhi
        self.tnewExpenseEntryTable=temptnewExpenseEntryTable;
        
        
		[tnewExpenseEntryTable setDelegate:self];
		[tnewExpenseEntryTable setDataSource:self];
		[tnewExpenseEntryTable setBackgroundColor:G2RepliconStandardBackgroundColor];
        tnewExpenseEntryTable.backgroundView=nil;
        [self.tnewExpenseEntryTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];//DE5655 Ullas M L
        UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        //        if (countAddExpenseUDF==0) {
        //            countAddExpenseUDF++;
        //        }
        //        else if (countAddExpenseUDF<=2) {
        // countAddExpenseUDF++;
        //        }
        //        if (permissionType==PermType_NonProjectSpecific) {
        //            if (countAddExpenseUDF>=4)
        //            {
        //                scrollHeight=80-scrollHeight;
        //            }
        //            if (countAddExpenseUDF <=3)
        //            {
        //                if (countAddExpenseUDF==0) {
        //
        //                    if ([secondSectionfieldsArray count]<5)
        //                    {
        //                        scrollHeight=40;
        //                    }
        //                    else
        //                        scrollHeight=90;
        //                }
        //
        //                scrollHeight =85-scrollHeight;
        //            }
        //
        //            scrollView.contentSize= CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+((countAddExpenseUDF+1)*60.0)-scrollHeight);
        //        }
        //        else
        scrollView.contentSize= CGSizeMake(self.view.frame.size.width, scrollHeight);
        [scrollView addSubview:tnewExpenseEntryTable];
        
        //countAddExpenseUDF --;
        self.mainScrollView=scrollView;
        [self.view addSubview:self.mainScrollView];
        
        
        
        [self.tnewExpenseEntryTable setScrollEnabled:FALSE];
		[self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
		
		
		[G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(ADD_EXPENSE_TITLE, ADD_EXPENSE_TITLE)];
		
		UIBarButtonItem *leftButton1 = [[UIBarButtonItem alloc]
										initWithTitle: RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE)
										style: UIBarButtonItemStylePlain
										target: self
										action: @selector(cancelAction:)];
		[self.navigationItem setLeftBarButtonItem:leftButton1 animated:NO];
		
		
		
		UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(G2SAVE_BTN_TITLE, G2SAVE_BTN_TITLE)
																		 style:UIBarButtonItemStylePlain
																		target:self
																		action:@selector(saveAction:)];
		
		[self.navigationItem setRightBarButtonItem:rightButton1 animated:NO];
		
		UIView *footerNewExpenses = [UIView new];
		[footerNewExpenses setFrame:CGRectMake(0.0,
											   50,
											   tnewExpenseEntryTable.frame.size.width,
											   100.0)];
		[footerNewExpenses setBackgroundColor:[UIColor clearColor]];
		[tnewExpenseEntryTable setTableFooterView:footerNewExpenses];
		
		[self configurePicker];
		[self handlePermissions];
		
		//Handling Leaks
		
		
        NSString *projectdId = nil;
        NSString *typeName = nil;
        
        //-----------------------------US4234 Ullas M L-----------------------------------------------------------
        if (firstSectionfieldsArray != nil && [firstSectionfieldsArray count] >0) {
            if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific) {
                projectdId = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"projectIdentity"];
                typeName = [[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"selectedDataSource"];
            }else {
                projectdId = @"null";
                typeName = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"selectedDataSource"];
            }
            
        }
        G2SupportDataModel *supportDataMdl = [[G2SupportDataModel alloc] init];
        NSString *taxModeOfExpenseType = [supportDataMdl getExpenseModeOfTypeForTaxesFromDB:projectdId withType:typeName andColumnName:@"type"];
       
        DLog(@"%@",taxModeOfExpenseType);
        [[NSUserDefaults standardUserDefaults]setObject:taxModeOfExpenseType forKey:@"previousTaxType"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        //--------------------------------------------------------------------------------------------------
	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
	[self checkClientWithName];
	//receiptViewController.sheetStatus = [expesneSheetStatus retain];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (permissionType == PermType_ProjectSpecific)
    {
        
        
        NSMutableDictionary *clientDict =  [[self firstSectionfieldsArray] objectAtIndex:0];
        if ([clientDict objectForKey: @"clientName"] == nil || [[clientDict objectForKey: @"clientName"]  isEqualToString: RPLocalizedString(NONE_STRING, @"")])
            
        {
            
            NSMutableDictionary *projectDict =  [[self firstSectionfieldsArray] objectAtIndex:1];
            if ([projectDict objectForKey: @"projectName"] == nil || [[projectDict objectForKey: @"projectName"]  isEqualToString: RPLocalizedString(NONE_STRING, @"")])
            {
                //[self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:1 inSection:0]];
            }
            else
            {
                [self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:1 inSection:0]];
            }
            
        }
        else
        {
            [self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:1 inSection:0]];
        }
        
        
    }
    
    
    
}

-(void)checkClientWithName
{
	NSIndexPath *billClientIndex = [NSIndexPath indexPathForRow:2 inSection:1];
	if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0) {
		if ([[[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Project", @"")])
        {
			if ([[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"clientName"]!=nil && [[[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"clientName"] isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
				{
					if ([[self getBillClientInfo] intValue] == 1){
						[self DisableCellAtIndexForCheckmark:billClientIndex];
					}
				}
			}else {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific){
					if ([[self getBillClientInfo] intValue] == 1){
						//[self reloadCellAtIndex:billClientIndex];
					}
				}
			}
		}
	}
}

-(void)handlePermissions
{
	G2ExpenseEntryCellView *expenseEntryCellView=nil;
	
	if (permissionType == PermType_ProjectSpecific) {
		expenseEntryCellView =(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:
													   [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION]];
		[expenseEntryCellView.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		
		
		[expenseEntryCellView.fieldButton setTitle:RPLocalizedString(@"Select", @"") forState:UIControlStateNormal];//Ullas-ML
		if (!clientAndProjectBothPresentFromPrevious) {
            [self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
        }
		[self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION]];
		[self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
	} else if (permissionType == PermType_Both) {
		expenseEntryCellView =(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:
													   [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION]];
		[expenseEntryCellView.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[expenseEntryCellView.fieldButton setTitle: RPLocalizedString(NONE_STRING, @"") forState:UIControlStateNormal];
        clientAndProjectBothPresentFromPrevious=YES;
        [self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
        [self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION]];
		[self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
		
		
	} else if (permissionType == PermType_NonProjectSpecific){//Ullas-ML
		[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:0 inSection:G2EXPENSE_SECTION]];
        [self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION]];
		[self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
	}
}

-(NSNumber *)getBillClientInfo{
	
	BOOL isBillClient = FALSE;
	BOOL isUseBillingInformation = FALSE;
	
	
	isBillClient=[self.supportDataModel getBillingInfoFromSystemPreferences:@"BillClient"];
	isUseBillingInformation=[self.supportDataModel getBillingInfoFromSystemPreferences:@"UseBillingInformation"];
	
	if(isBillClient && isUseBillingInformation)	{
		
		return [NSNumber numberWithInt: 1];
	}
	
	
	return [NSNumber numberWithInt: 0];
}

-(NSNumber*)getReimburseInfo{
	
	BOOL isReimburse=FALSE;
	
	
	isReimburse=[self.supportDataModel getBillingInfoFromSystemPreferences:@"Reimburse"];
	
	if (isReimburse) {
		
		return [NSNumber numberWithInt:1];
	}
	
	return [NSNumber numberWithInt:0];
	
}
-(void)updateFieldAtIndex:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue{
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[entryCell.fieldButton setTitle:selectedValue forState:UIControlStateNormal];
    
    //DE7314
    if (entryCell.fieldText != nil) {
		[[entryCell fieldText] setText:selectedValue];
	}
    
    if (!pickerViewC.hidden) {
        [entryCell.fieldButton setTitleColor:iosStandaredWhiteColor forState:UIControlStateNormal];
        [entryCell.fieldName setTextColor:iosStandaredWhiteColor];
    }
    
}

-(void)updateDependentFields:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue{
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[entryCell.fieldButton setTitle:RPLocalizedString(selectedValue, @"") forState:UIControlStateNormal];
	[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	[entryCell.fieldName setTextColor:RepliconStandardBlackColor];
	
	if (entryCell.fieldText !=nil) {
		[entryCell.fieldText setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
	}
	
}

-(void)enableExpenseFieldAtIndex:(NSIndexPath *)indexPath{
	G2ExpenseEntryCellView	*expenseEntryCellView = (G2ExpenseEntryCellView *) [self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[expenseEntryCellView setUserInteractionEnabled:YES];
	[expenseEntryCellView.fieldButton setUserInteractionEnabled:YES];
    //Fix for Amount feild highlight//Juhi
    if (expenseEntryCellView!=nil && ([[[expenseEntryCellView dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Amount", @"")]||[[[expenseEntryCellView dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Currency", @"")] )){
        expenseEntryCellView.fieldName.textColor=RepliconStandardBlackColor;
        [expenseEntryCellView.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
        expenseEntryCellView.fieldText.textColor = NewRepliconStandardBlueColor;//US4065//Juhi
    }
    if ( [[[expenseEntryCellView dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Project", @"")] && currentIndexPath.row!=1)
    {
        expenseEntryCellView.fieldName.textColor=RepliconStandardBlackColor;
        [expenseEntryCellView.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
        expenseEntryCellView.fieldText.textColor = NewRepliconStandardBlueColor;//US4065//Juhi
    }
    
    if (!self.fromReloaOfDataView) {
        self.fromReloaOfDataView=NO;
        if ([[[expenseEntryCellView dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")]) {
            expenseEntryCellView.fieldName.textColor=RepliconStandardBlackColor;
            [expenseEntryCellView.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
            expenseEntryCellView.fieldText.textColor = NewRepliconStandardBlueColor;
        }//Ullas-ML

    } 
        
	//expenseEntryCellView.fieldName.textColor=RepliconStandardBlackColor;DE2991
	//[expenseEntryCellView.fieldButton setTitleColor:FieldButtonColor forState:UIControlStateNormal];DE2991
    if (expenseEntryCellView.fieldText != nil) {
		[expenseEntryCellView.fieldText setUserInteractionEnabled:YES];
		//expenseEntryCellView.fieldText.textColor = FieldButtonColor;DE2991
	}
}

-(void)disableExpenseFieldAtIndex:(NSIndexPath *)indexPath{
	G2ExpenseEntryCellView	*expenseEntryCellView = (G2ExpenseEntryCellView *) [self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	expenseEntryCellView.fieldName.textColor=[UIColor grayColor];
	[expenseEntryCellView.fieldButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
	[expenseEntryCellView setUserInteractionEnabled:NO];
	[expenseEntryCellView.fieldButton setUserInteractionEnabled:NO];
	if (expenseEntryCellView.fieldText != nil) {
		[expenseEntryCellView.fieldText setUserInteractionEnabled:NO];
		expenseEntryCellView.fieldText.textColor = RepliconStandardGrayColor;
	}
}

-(NSIndexPath *)getNextEnabledFieldFromCurrentIndex:(NSIndexPath *)_currentIndexPath {
	NSIndexPath *currentInd = nil;
	if (_currentIndexPath.section==0 && _currentIndexPath.row== [firstSectionfieldsArray count]-1) {
		currentInd=[NSIndexPath indexPathForRow:(_currentIndexPath.row -[firstSectionfieldsArray count])  inSection:G2DETAILS_SECTION];
		_currentIndexPath=currentInd;
	}else {
		currentInd=nil;
	}
	
	
	NSInteger currentRow = _currentIndexPath.row;
	NSInteger currentSection = _currentIndexPath.section;
	
	if (currentSection == G2EXPENSE_SECTION && (currentRow != [firstSectionfieldsArray count] -1)) {
		for (NSInteger i=currentRow +1; i< [firstSectionfieldsArray count]; i++) {
			NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:i inSection:currentSection];
			G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:nextIndexPath];
			if ([cell isUserInteractionEnabled]) {
				if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:CHECK_MARK]) {
					return nil;
				}
				return nextIndexPath;
			}
		}
	}
	if (currentSection == G2DETAILS_SECTION && (currentRow != [secondSectionfieldsArray count] -1)) {
		for (NSInteger i=currentRow +1; i< [secondSectionfieldsArray count]; i++) {
			NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:i inSection:currentSection];
			G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:nextIndexPath];
			if ([cell isUserInteractionEnabled]) {
				if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:CHECK_MARK]) {
					return nil;
				}
				return nextIndexPath;
			}
		}
	}
	
	return nil;
}

-(NSIndexPath *)getPreviousEnabledFieldFromCurrentIndex:(NSIndexPath *)_currentIndexPath {
	NSIndexPath *currentInd = nil;
	if (_currentIndexPath.section==1 && _currentIndexPath.row==0) {
		currentInd=[NSIndexPath indexPathForRow:[firstSectionfieldsArray count] inSection:_currentIndexPath.section-1];
		_currentIndexPath=currentInd;
	}else {
		currentInd=nil;
	}
	NSInteger currentRow = _currentIndexPath.row;
	NSInteger currentSection = _currentIndexPath.section;
	
	if (currentSection == G2EXPENSE_SECTION && currentRow != 0) {
		for (NSInteger i=currentRow -1; i< [firstSectionfieldsArray count]; i--) {
			NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:i inSection:currentSection];
			G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:previousIndexPath];
			if ([cell isUserInteractionEnabled] ) {//&&
				if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:CHECK_MARK]) {
					return nil;
				}
				return previousIndexPath;
			}
		}
	}
	if (currentSection == G2DETAILS_SECTION && (currentRow != 0)) {
		for (NSInteger i=currentRow -1; i< [secondSectionfieldsArray count]; i--) {
			NSIndexPath *previousIndexPath = [NSIndexPath indexPathForRow:i inSection:currentSection];
			G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:previousIndexPath];
			if ([cell isUserInteractionEnabled]) {//&& ![[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:CHECK_MARK]
				if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:CHECK_MARK]) {
					return nil;
				}
				
				return previousIndexPath;
			}
		}
	}
	
	return nil;
}


/*-(NSMutableArray *)getProjectsArrayforSelectedClientId:(NSString *)clientID{
 
 NSMutableArray *projectsArr=[[expensesModel getExpenseProjectsForSelectedClientID:clientID]retain];
 
 return projectsArr;
 
 }*/

-(NSMutableArray *)getfirstSectionFields{
	clientAndProjectBothPresentFromPrevious=NO;
	//NSMutableArray *firstSectionArray = [NSMutableArray array];
	if (firstSectionfieldsArray == nil) {
		NSMutableArray *tempfirstSectionfieldsArray = [[NSMutableArray alloc] init];
        self.firstSectionfieldsArray=tempfirstSectionfieldsArray;
       
	}
    else
    {
        [self.firstSectionfieldsArray   removeAllObjects];
    }
    //	NSMutableDictionary *dict0;
	NSMutableDictionary *dict1=nil;
	
	
	NSMutableArray *currenciesArray = [supportDataModel getSystemCurrenciesFromDatabase];
	NSMutableArray *baseCurrencyArray =[supportDataModel getBaseCurrencyFromDatabase];
    int currencySelectedIndex = 0;
	if (baseCurrencyArray != nil && [baseCurrencyArray count] > 0) {
		//baseCurrency = [[baseCurrencyArray objectAtIndex:0] objectForKey:@"symbol"];
		[self setBaseCurrency:[[baseCurrencyArray objectAtIndex:0] objectForKey:@"symbol"]];
		currencySelectedIndex = [G2Util getObjectIndex:currenciesArray withKey:@"symbol" forValue:baseCurrency];
	}
	else if (currenciesArray != nil && [currenciesArray count] > 0) {
		self.baseCurrency = [[currenciesArray objectAtIndex:0] objectForKey:@"symbol"];
	}
	
	NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(@"Currency", @""),@"fieldName",
								  DATA_PICKER,@"fieldType",
								  baseCurrency,@"defaultValue",
								  [NSNumber numberWithInt:currencySelectedIndex],@"selectedIndex",
								  currenciesArray,@"dataSourceArray",
								  [[baseCurrencyArray objectAtIndex:0] objectForKey:@"symbol"] ,@"selectedDataSource",
								  [[baseCurrencyArray objectAtIndex:0] objectForKey:@"identity"],@"selectedDataIdentity",
								  nil];
	
	NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(@"Amount", @""),@"fieldName",MOVE_TO_NEXT_SCREEN,@"fieldType",RPLocalizedString(@"Add", @""),@"defaultValue", nil];
	
	if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific) {
		//get last entry made for the sheet.
        
        //NSMutableArray *clientsArr = [[expensesModel getExpenseClientsFromDatabase]retain];
        
        NSMutableArray *clientsArr = [expensesModel getAllClientsforDownloadedExpenseEntries];
        
		NSMutableArray *lastEntryArray = [expensesModel getLastEntryAddedForSheet:expenseSheetID];
		
        if ([clientsArr count]==0) {
            hasClient=FALSE;
        }
        else if ([clientsArr count]==1) {
            if([[[clientsArr objectAtIndex:0] objectForKey:@"name"]  isEqualToString:RPLocalizedString(NONE_STRING, @"") ])
            {
                hasClient=FALSE;
            }
        }
		int selectedProjectIndex = 0;
		int selectedClientIndex = 0;
		NSMutableArray *projectsArr = nil;
		NSString *clientIdentity = nil;
		NSString *clientName = nil;
		NSString *projectId = nil;
		NSString *projectName = nil;
		
		if (lastEntryArray != nil && !([[[lastEntryArray objectAtIndex:0] objectForKey:@"projectName"] isEqualToString:@""] && permissionType == PermType_ProjectSpecific))
		{
			
			clientIdentity = [[lastEntryArray objectAtIndex:0] objectForKey:@"clientIdentity"];
			clientName = [[lastEntryArray objectAtIndex:0] objectForKey:@"clientName"];
			projectId = [[lastEntryArray objectAtIndex:0] objectForKey:@"projectIdentity"];
			projectName = [[lastEntryArray objectAtIndex:0] objectForKey:@"projectName"];
			
			if (clientIdentity!=nil && [clientIdentity isEqualToString:@""]) {
				clientIdentity=@"null";
                [self disableExpenseFieldAtIndex: [NSIndexPath indexPathForRow:1 inSection:0]];
			}
			if (projectId!=nil && [projectId isEqualToString:@""]) {
				projectId=@"null";
			}
			
			if ( projectName!=nil && [projectName isEqualToString:@""]) {
				projectName = RPLocalizedString(NONE_STRING, @"");
			}
			if (clientName!=nil && [clientName isEqualToString:@""]) {
                [self disableExpenseFieldAtIndex: [NSIndexPath indexPathForRow:1 inSection:0]];
				clientName = RPLocalizedString(NONE_STRING, @"");
			}
            if (clientIdentity!=nil && projectId!=nil && ![clientIdentity isEqualToString:@""] && ![projectId isEqualToString:@""] ) 
            {   clientAndProjectBothPresentFromPrevious=YES;
                [self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:0]];
            }
			
			projectsArr = [expensesModel getExpenseProjectsForSelectedClientID: clientIdentity];
			selectedProjectIndex = [G2Util getObjectIndex:projectsArr withKey:@"identity" forValue:projectId];
			selectedClientIndex = [G2Util getObjectIndex:clientsArr withKey:@"identity" forValue:clientIdentity];
			
			
		}
		else {
			clientIdentity = [[clientsArr objectAtIndex: 0] objectForKey: @"identity"];
			clientName = [[clientsArr objectAtIndex:0] objectForKey: @"name"];
			projectsArr = [expensesModel getExpenseProjectsForSelectedClientID: clientIdentity];
            if (permissionType == PermType_Both)
            {
                projectId = @"null";
                projectName = [[projectsArr objectAtIndex: 0] objectForKey: @"name"];//Ullas-ML
            }

			
		}
		
        //		NSString *_defaultValue = projectName;
        
        //
        //        NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        //                                           RPLocalizedString(CLIENT, @""),@"fieldName",
        //                                           clientsArr,@"clientsArr",
        //                                           MOVE_TO_NEXT_SCREEN, @"fieldType",
        //                                            clientName,     @"clientName",
        //                                           clientIdentity, @"clientIdentity",
        //                                            [NSNumber numberWithInt:selectedClientIndex],@"selectedClientIndex",
        //                                           RPLocalizedString(@"Select", @""), @"defaultValue", nil];
        
        NSMutableDictionary *clientDict = [NSMutableDictionary dictionary];
        [clientDict setObject:RPLocalizedString(CLIENT, @"") forKey:@"fieldName"];
        if(clientsArr!=nil)
        {
            [clientDict setObject:clientsArr forKey:@"clientsArr"];
        }
        [clientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
        if(clientName!=nil)
        {
            [clientDict setObject:clientName forKey:@"clientName"];
        }
        if (clientIdentity!=nil && ![clientIdentity isKindOfClass:[NSNull class]])
        {
            [clientDict setObject:clientIdentity forKey: @"clientIdentity"];
        }
        if (clientIdentity!=nil && ![clientIdentity isKindOfClass:[NSNull class]])
        {
            [clientDict setObject:clientName forKey: @"defaultValue"];
        }
        else
        {
            [clientDict setObject: RPLocalizedString(@"Select", @"") forKey: @"defaultValue"];
        }
        [clientDict setObject: [NSNumber numberWithInt:selectedClientIndex] forKey: @"selectedClientIndex"];
        
        
        [firstSectionfieldsArray addObject:clientDict];
        
        
        //        NSMutableDictionary *projectDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        //                                           RPLocalizedString(@"Project", @""),@"fieldName",
        //                                           projectsArr,@"projectsArray",
        //                                           MOVE_TO_NEXT_SCREEN, @"fieldType",
        //                                           projectName,     @"projectName",
        //                                           projectId, @"projectIdentity",
        //                                           [NSNumber numberWithInt:selectedClientIndex],@"selectedProjectIndex",
        //                                           RPLocalizedString(@"Select", @""), @"defaultValue", nil];
        NSMutableDictionary *projectDict = [NSMutableDictionary dictionary];
        [projectDict setObject:RPLocalizedString(@"Project", @"") forKey:@"fieldName"];
        if(projectsArr!=nil)
        {
            [projectDict setObject:projectsArr forKey:@"projectsArray"];
        }
        [projectDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
        if(projectName!=nil)
        {
            [projectDict setObject:projectName forKey:@"projectName"];
        }
        if (projectId!=nil && ![projectId isKindOfClass:[NSNull class]])
        {
            [projectDict setObject:projectId forKey: @"projectIdentity"];
        }
        if (projectId!=nil && ![projectId isKindOfClass:[NSNull class]])
        {
            if ([projectId isEqualToString:@"null"]) {
                [projectDict setObject: RPLocalizedString(@"None", @"") forKey: @"defaultValue"];
            }
            else {
                [projectDict setObject:projectName forKey: @"defaultValue"];
            }
            
        }
        else
        {
            if (permissionType == PermType_Both)
            {
              [projectDict setObject: RPLocalizedString(@"None", @"") forKey: @"defaultValue"];
            }
            else if(permissionType == PermType_ProjectSpecific)
            {
               [projectDict setObject: RPLocalizedString(@"Select", @"") forKey: @"defaultValue"]; 
            }
        }
        [projectDict setObject: [NSNumber numberWithInt:selectedProjectIndex] forKey: @"selectedProjectIndex"];
        
        
        
        [firstSectionfieldsArray addObject:projectDict];
        
        
        //		dict0 = [NSMutableDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(@"Project", @""),@"fieldName",
        //				 DATA_PICKER,    @"fieldType",
        //				 _defaultValue,  @"defaultValue",
        //				 clientsArr,     @"clientsArray",
        //				 projectsArr,    @"projectsArray",
        //				 projectId,      @"projectIdentity",
        //				 projectName,    @"projectName",
        //				 clientName,     @"clientName",
        //				 clientIdentity, @"clientIdentity",
        //				 [NSNumber numberWithInt:selectedProjectIndex],@"selectedProjectIndex",
        //				 [NSNumber numberWithInt:selectedClientIndex],@"selectedClientIndex",
        //				 nil];
		
		
		
		NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId: projectId];
		
		NSString *selectedDataSource =nil;
		NSString *selectedDataIdentity =nil;
		if (expenseTypeArr!=nil && [expenseTypeArr count]>0) {
			selectedDataSource = [[expenseTypeArr objectAtIndex:0]objectForKey:@"name"];
			selectedDataIdentity = [[expenseTypeArr objectAtIndex:0]objectForKey:@"identity"];
		}
		//TODO: what if selectedDataSource / selectDataIdentity are null? Currently, writing error to log
		
		if (selectedDataSource == nil || selectedDataIdentity == nil) {
#ifdef DEV_DEBUG
			DLog(@"Error: Either selectedDatasource or selectedDataIdentity is nil");
#endif
		}
		dict1	= [NSMutableDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(@"Type", @""),@"fieldName",
				   DATA_PICKER,@"fieldType",
				   RPLocalizedString(@"Select", @""),@"defaultValue",
				   [NSNumber numberWithInt:0],@"selectedIndex",
				   expenseTypeArr,@"dataSourceArray",
				   selectedDataSource,@"selectedDataSource",
				   selectedDataIdentity, @"selectedDataIdentity",
				   nil];
        //		[firstSectionfieldsArray addObject:dict0];
		
	}else if (permissionType == PermType_NonProjectSpecific) {
		NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:@"null"];
		NSString *selectedDataSource=nil;
		NSString *selectedDataIdentity = nil;
		if (expenseTypeArr!=nil && [expenseTypeArr count]>0) {
			selectedDataSource = [[expenseTypeArr objectAtIndex:0]objectForKey:@"name"];
			selectedDataIdentity = [[expenseTypeArr objectAtIndex:0]objectForKey:@"identity"];
		}
		dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(@"Type", @""),@"fieldName",
				 DATA_PICKER,@"fieldType",
				 RPLocalizedString(@"Select", @""),@"defaultValue",
				 [NSNumber numberWithInt:0],@"selectedIndex",
				 expenseTypeArr,@"dataSourceArray",
				 selectedDataSource,@"selectedDataSource",
				 selectedDataIdentity,@"selectedDataIdentity",
				 nil];
		
	}
	
	[firstSectionfieldsArray addObject:dict1];
	[firstSectionfieldsArray addObject:dict2];
	[firstSectionfieldsArray addObject:dict3];
	
	
	return firstSectionfieldsArray;
}


-(NSMutableArray *)getSecondSectionFields{
	
	/*
	 mandatory cells
	 1. Date
	 2. description
	 3. Receipt Image - if bill client is applicable then Receipt image should be shown after that
	 4.
	 */
	
	//NSMutableArray *secondSectionArray = [NSMutableArray array];
	if (secondSectionfieldsArray == nil) {
		NSMutableArray *tempsecondSectionfieldsArray = [[NSMutableArray alloc] init];
        self.secondSectionfieldsArray=tempsecondSectionfieldsArray;
       
	}
    else
    {
        [self.secondSectionfieldsArray removeAllObjects];
    }
	int index = 0;
	//Data for firrst cell in second section
	NSString *dateDefaultValue=	[G2Util convertPickerDateToString:[NSDate date]];
	//[Util convertPickerDateToString:[NSDate date]];
	NSMutableDictionary *dict0 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  RPLocalizedString(@"Date", @""), @"fieldName",
								  DATE_PICKER, @"fieldType",
								  dateDefaultValue, @"defaultValue",
								  nil]; //expense date (static field)
	
	[secondSectionfieldsArray insertObject: dict0 atIndex: index++];
	
	
	NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  RPLocalizedString(@"Description", @""),@"fieldName",
								  MOVE_TO_NEXT_SCREEN, @"fieldType",
								  @"", @"defaultValue", nil]; //static field
	
	
	[secondSectionfieldsArray insertObject: dict1 atIndex: index++];
	
	if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
	{
		
		if ([[self getBillClientInfo] intValue] == 1){
			NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										  RPLocalizedString(@"Bill Client", @""), @"fieldName",
										  CHECK_MARK, @"fieldType",
										  G2Check_OFF_Image, @"defaultValue", nil];  //static field
			
			//TODO: ravi - Why are we removing and adding the default value for this?
			//[dict2 removeObjectForKey: @"defaultValue"];
			//[dict2 setObject:G2Check_ON_Image forKey: @"defaultValue"];
            //DE2996 Ullas
            NSString *clientFieldName=[[firstSectionfieldsArray objectAtIndex:0] objectForKey:@"fieldName"];
            NSString *clientDefaultValue=nil;
            if ([clientFieldName isEqualToString:RPLocalizedString(@"Client", @"")])
            {
                clientDefaultValue=[[firstSectionfieldsArray objectAtIndex:0] objectForKey:@"defaultValue"];
            }
            
            NSString *projectFieldName=[[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"fieldName"];
            NSString *projectDefaultValue=nil;
            if ([projectFieldName isEqualToString:RPLocalizedString(@"Project", @"")])
            {
                projectDefaultValue=[[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"defaultValue"];
                
            }
            
            if (![clientDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&&![projectDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")] )
            {
                [dict2 setObject:G2Check_ON_Image forKey: @"defaultValue"];
            }

			
			[secondSectionfieldsArray insertObject:dict2 atIndex: index++];
		}
		
	}
	
	NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  RPLocalizedString(@"Receipt Photo",@""), @"fieldName",
								  IMAGE_PICKER, @"fieldType",
								  RPLocalizedString(@"Add", @""),@"defaultValue", nil]; //static field
	
	
	[secondSectionfieldsArray insertObject: dict3 atIndex: index++];
	
	
	if ([[self getReimburseInfo]intValue ] == 1) {
		NSMutableDictionary *dict4 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      RPLocalizedString(@"Reimburse", @""), @"fieldName",
									  CHECK_MARK, @"fieldType",
									  G2Check_ON_Image, @"defaultValue", nil]; //TODO: need confirmation if this is static/dynamic field. currently static
		
		[secondSectionfieldsArray insertObject:dict4 atIndex: index++];
	}
	
	
	NSMutableArray *_paymentMethodsArray = [supportDataModel getPaymentMethodsAllFromDatabase];
	@try {
		if (_paymentMethodsArray == nil) {
			DLog(@"Error: Payment methods not found");
		} else if (_paymentMethodsArray != nil && [_paymentMethodsArray count]>0)	{
			NSMutableDictionary *dict5 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          RPLocalizedString(@"Payment Method", @""), @"fieldName",
										  DATA_PICKER, @"fieldType",
										  RPLocalizedString(@"Select", @""), @"defaultValue",
										  _paymentMethodsArray, @"dataSourceArray",
										  [[_paymentMethodsArray objectAtIndex:0]objectForKey:@"name"],@"selectedDataSource",
										  [[_paymentMethodsArray objectAtIndex:0]objectForKey:@"identity"], @"selectedDataIdentity",
										  [NSNumber numberWithInt:0],@"selectedIndex",  nil]; //static field
            //DE4368 Ullas M L
            NSMutableArray *systemPreferencesArray=[supportDataModel getSystemPreferencesFromDatabase];
            BOOL showPaymentMethodPermission=TRUE;
            for (int k=0; k<[systemPreferencesArray count]; k++) {
                NSDictionary *dctSystemPreference=[systemPreferencesArray objectAtIndex:k];
                NSString *systemPreferenceName=[dctSystemPreference objectForKey:@"name"];
                if ([systemPreferenceName isEqualToString:@"ExpenseColumnVisible"])
                {
                    showPaymentMethodPermission=[supportDataModel getPaymnetMethodInfoFromSystemPreferences:@"PaymentMethod"];
                    
                }
            }
            
            if (showPaymentMethodPermission) {
                if (dict5 != nil && ![dict5 isKindOfClass:[NSNull class]])
                    //Fix for DE3597//juhi
                    [secondSectionfieldsArray insertObject:dict5 atIndex: index++];
            }
		}
		//DE8142
		udfStartIndex=[secondSectionfieldsArray count];
        
		//Handle UDFs
		NSArray *udfsArray = [supportDataModel getUserDefineFieldsExpensesFromDatabase];
		if (udfsArray != nil && [udfsArray count] > 0) {
			//From the api we get all the UDFs. We need to filter UDFs based on whether it is applicable to the user.
			
			for (int i=0;  i < [udfsArray count];  i++) {
				NSDictionary *udfDict = [udfsArray objectAtIndex: i];
				
				if ([supportDataModel checkExpensePermissionWithPermissionName: [udfDict objectForKey:@"name"]] == YES) {
					
					NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
					[dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
					[dictInfo setObject:[udfDict objectForKey:@"identity"] forKey:@"identity"];
					
					if ([[udfDict objectForKey:@"udfType"] isEqualToString: @"Numeric"]) {
						[dictInfo setObject:NUMERIC_KEY_PAD forKey:@"fieldType"];
						[dictInfo setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
						if ([udfDict objectForKey:@"numericDecimalPlaces"]!=nil && !([[udfDict objectForKey:@"numericDecimalPlaces"] isKindOfClass:[NSNull class]]))
							[dictInfo setObject:[udfDict objectForKey:@"numericDecimalPlaces"] forKey:@"defaultDecimalValue"];
						
						if ([udfDict objectForKey:@"numericMinValue"]!=nil && !([[udfDict objectForKey:@"numericMinValue"] isKindOfClass:[NSNull class]])) {
							[dictInfo setObject:[udfDict objectForKey:@"numericMinValue"] forKey:@"defaultMinValue"];
						}
						if ([udfDict objectForKey:@"numericMaxValue"]!=nil && !([[udfDict objectForKey:@"numericMaxValue"] isKindOfClass:[NSNull class]])) {
							[dictInfo setObject:[udfDict objectForKey:@"numericMaxValue"] forKey:@"defaultMaxValue"];
						}
						
						if ([udfDict objectForKey:@"numericDefaultValue"]!=nil && !([[udfDict objectForKey:@"numericDefaultValue"] isKindOfClass:[NSNull class]]))
							[dictInfo setObject:[udfDict objectForKey:@"numericDefaultValue"] forKey:@"defaultValue"];
						
					} else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Text"]){
						[dictInfo setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
						
						if ([[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@"null"]) {
							//[dictInfo setObject:@"Add" forKey:@"defaultValue"];
							[dictInfo setObject:@"" forKey:@"defaultValue"];
						}else {
							if ([udfDict objectForKey:@"textDefaultValue"]!=nil)
								[dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
						}
						if ([udfDict objectForKey:@"textMaxValue"]!=nil && !([[udfDict objectForKey:@"textMaxValue"] isKindOfClass:[NSNull class]]))
							[dictInfo setObject:[udfDict objectForKey:@"textMaxValue"] forKey:@"defaultMaxValue"];
						
					} else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Date"]){
						[dictInfo setObject: DATE_PICKER forKey: @"fieldType"];
						
						if ([udfDict objectForKey:@"dateMaxValue"]!=nil && !([[udfDict objectForKey:@"dateMaxValue"] isKindOfClass:[NSNull class]])){
							[dictInfo setObject:[udfDict objectForKey:@"dateMaxValue"] forKey:@"defaultMaxValue"];
						}
						if ([udfDict objectForKey:@"dateMinValue"]!=nil && !([[udfDict objectForKey:@"dateMinValue"] isKindOfClass:[NSNull class]])){
							[dictInfo setObject:[udfDict objectForKey:@"dateMinValue"] forKey:@"defaultMinValue"];
						}
						
						
						if ([udfDict objectForKey:@"isDateDefaultValueToday"]!=nil && !([[udfDict objectForKey:@"isDateDefaultValueToday"] isKindOfClass:[NSNull class]])){
							if ([[udfDict objectForKey:@"isDateDefaultValueToday"]intValue]==1) {
								[dictInfo setObject:[G2Util convertPickerDateToString:[NSDate date]] forKey:@"defaultValue"];
							}else{
								if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]])){
									[dictInfo setObject:[udfDict objectForKey:@"dateDefaultValue"] forKey:@"defaultValue"];
								}else {
									[dictInfo setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
								}
							}
						}else {
							if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]])){
                                
                                //DE3200: Default date formatting was missing
                                NSString *dateStr = [udfDict objectForKey:@"dateDefaultValue"];
                                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                                [dateFormat setLocale:locale];
                                [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                                
                                NSDate *dateToBeUsed = [dateFormat dateFromString:dateStr];
                                
                                NSString *dateDefaultValueFormatted = [G2Util convertPickerDateToString:dateToBeUsed];
                                
                                if(dateDefaultValueFormatted != nil){
                                    [dictInfo setObject:dateDefaultValueFormatted forKey:@"defaultValue"];
                                }else{
                                    [dictInfo setObject:[udfDict objectForKey:@"dateDefaultValue"] forKey:@"defaultValue"];
                                }
                                
                                //DE3200: Converted date as been added into dictionary instead of the default date value
								//[dictInfo setObject:[udfDict objectForKey:@"dateDefaultValue"] forKey:@"defaultValue"];
							}else {
								[dictInfo setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
							}
							
							
						}
					}else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"DropDown"]){
						
						[dictInfo setObject:DATA_PICKER forKey:@"fieldType"];
						[dictInfo setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
						NSMutableArray *dataSource= [supportDataModel getDropDownOptionsForUDFIdentity:[udfDict objectForKey:@"identity"]];
						
						for (int i=0; i<[dataSource count]; i++) {
							//[dataSource objectAtIndex:i];
							NSMutableDictionary *dict =[NSMutableDictionary dictionary];
							if ([[dataSource objectAtIndex:i] objectForKey:@"value"]!=nil)
								[dict setObject:[[dataSource objectAtIndex:i] objectForKey:@"value"] forKey:@"name"];
							if ([[dataSource objectAtIndex:i] objectForKey:@"defaultOption"]!=nil)
								[dict setObject:[[dataSource objectAtIndex:i] objectForKey:@"defaultOption"] forKey:@"defaultValue"];
							if ([[dataSource objectAtIndex:i] objectForKey:@"identity"]!=nil)
								[dict setObject:[[dataSource objectAtIndex:i] objectForKey:@"identity"] forKey:@"identity"];
							[dataSource replaceObjectAtIndex:i withObject:dict];
							
							if ([[dict objectForKey:@"defaultValue"]intValue]==1) {
								[dictInfo setObject:[[dataSource objectAtIndex:i] objectForKey:@"name"] forKey:@"defaultValue"];
								[dictInfo setObject:[NSNumber numberWithInt:i] forKey:@"selectedIndex"];
								[dictInfo setObject:[[dataSource objectAtIndex:i]objectForKey:@"name"] forKey:@"selectedDataSource"];
							}
						}
						if (dataSource!=nil && [dataSource count]>0) {
							[dictInfo setObject:dataSource forKey:@"dataSourceArray"];
                            
						}
					}
					countAddExpenseUDF++;
					[secondSectionfieldsArray insertObject: dictInfo atIndex: index++];
				}
			}
		}
	}	@finally {
		
	}
	return secondSectionfieldsArray;
}


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 [super loadView];
 
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	[delegate setCurrVisibleViewController: self];
	
}


#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		return 35;	  //return 55.0;
	}else {
		return 30;    //return 35;
	}
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section == 0) {
        //US4065//Juhi
		UILabel	*expenseLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.15,
                                                                         4.0,        //0.0,
																		 250.0,
																		 30.0)];
        //		UIImage *img = [Util thumbnailImage:ExpenseHeaderImage];
        //		UIImageView	*expenseImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0,
        //																				  10.0,
        //																				  img.size.width,
        //																				  img.size.height)];
        //		[expenseImage setImage:img];
		[expenseLabel setBackgroundColor:[UIColor clearColor]];
		[expenseLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];//US4065//Juhi
		[expenseLabel setTextColor:RepliconStandardBlackColor];
		//[expenseImage setBackgroundColor:[UIColor clearColor]];
		[expenseLabel setText:RPLocalizedString(@"Expense",@"Expense")];
		
		UILabel	*descExpHeaderLabel= [[UILabel alloc] initWithFrame:CGRectMake(30.0,
																			   25.0,
																			   250.0,
																			   30.0)];
		
		if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific){
			[descExpHeaderLabel setText:RPLocalizedString(@"Please select a project first",@"")];
		}else {
			[descExpHeaderLabel setText:RPLocalizedString(@"Please select an expense type first",@"")];
		}
		[descExpHeaderLabel setBackgroundColor:[UIColor clearColor]];
		[descExpHeaderLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
		UIView *expenseHeader = [UIView new];
		[expenseHeader addSubview:expenseLabel];
		//[expenseHeader addSubview:expenseImage];
        //	[expenseHeader addSubview:descExpHeaderLabel];
		
		
		
		return expenseHeader;
	} else if (section ==1) {
        //US4065//Juhi
		UILabel	*otherLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.0,    //40.0,
                                                                       0.0,
																	   250.0,
																	   30.0)];
        //		UIImage *img1 = [Util thumbnailImage:DetailsInfoHeaderImage];
        //		UIImageView	*otherImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0,
        //																				3.5,  //	0.0,
        //																				img1.size.width,
        //																				img1.size.height)];
        //		[otherImage setImage:img1];
		[otherLabel setBackgroundColor:[UIColor clearColor]];
		[otherLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];//US4065//Juhi
		[otherLabel setTextColor:RepliconStandardBlackColor];
		//[otherLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
		[otherLabel setText:RPLocalizedString(@"Detail",@"detail")];
		
		
		UIView	*otherHeader = [UIView new];
		[otherHeader addSubview:otherLabel];
		//[otherHeader addSubview:otherImage];
		
		
		return otherHeader;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	
	
	if (section == G2EXPENSE_SECTION) {
		return [firstSectionfieldsArray count];
	}
	if (section == G2DETAILS_SECTION) {
		return [secondSectionfieldsArray count];
	}
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
	G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[G2ExpenseEntryCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
	}
	// Configure the cell...
	cell.expenseEntryCellDelegate=self;
	
	
	if ( indexPath.row <[firstSectionfieldsArray count]&& indexPath.section == G2EXPENSE_SECTION) {
		NSInteger tagIndex = FIRSTSECTION_TAG_INDEX+indexPath.row;
		//[cell addFieldAtIndex:indexPath.row atSection:indexPath.section];
		[cell addFieldAtIndex:indexPath withTagIndex: tagIndex withObj: [firstSectionfieldsArray objectAtIndex:indexPath.row]];
		[cell.fieldButton addTarget:self action:@selector(buttonPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
	}
	//Ullas-ML
	if ( indexPath.row <[secondSectionfieldsArray count] && indexPath.section== G2DETAILS_SECTION) {
		NSInteger tagIndex = SECONDSECTION_TAG_INDEX+indexPath.row;
		
		//[cell addFieldAtIndex:indexPath.row atSection:indexPath.section];
		[cell addFieldAtIndex:indexPath withTagIndex: tagIndex withObj: [secondSectionfieldsArray objectAtIndex:indexPath.row]];
		[cell.fieldButton addTarget:self action:@selector(buttonPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
		
		
	}
	
	//Vijay : change frame for Project & Type to increase readability - DE2801.
	
	NSString *fieldName = [[cell dataObj] objectForKey:@"fieldName"];
	if (indexPath.section == G2EXPENSE_SECTION && ([fieldName isEqualToString:ClientProject] ||
                                                 [fieldName isEqualToString:RPLocalizedString(CLIENT, @"")])) {
		
        //[cell.fieldButton setFrame:CGRectMake(98.0, 6.0, 182.0, 30.0)];
		//US4065//Juhi
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
            
        }
        else{
            frame=CGRectMake(98.0, 8.0, 192.0, 30.0);
        }
        [cell.fieldButton setFrame:frame];
        [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	}
    if (indexPath.section == G2EXPENSE_SECTION && [fieldName isEqualToString:RPLocalizedString(@"Type", @"")]) {
		
        //[cell.fieldButton setFrame:CGRectMake(98.0, 6.0, 182.0, 30.0)];
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
            
        }
        else{
            frame=CGRectMake(98.0, 8.0, 192.0, 30.0);
        }
        [cell.fieldButton setFrame:frame];
        if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) 
        {
            if (clientAndProjectBothPresentFromPrevious) {
                [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
            }
            else
            {
                [cell.fieldButton setTitleColor:RepliconStandardGrayColor forState:UIControlStateNormal]; 
            }
            
            
        }
        else {
            [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];
        }

        
	}
	
	
	if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:MOVE_TO_NEXT_SCREEN]) {
		[cell.fieldName setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//US4065//Juhi//DE5654 ullas
		[[cell fieldName] setText:[[cell dataObj]  objectForKey:@"fieldName"]];
		if ([[[cell dataObj]  objectForKey:@"defaultValue"] isEqualToString:@""]) {
			//TODO: ravi - We cannot change the string "Add" to localized string as there are places where we are checking for the string as "Add".This will result in sideeffects
			[[cell fieldButton] setTitle:RPLocalizedString(@"Add", @"") forState:UIControlStateNormal];
		}else {
            [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
            
			[[cell fieldButton] setTitle:[[cell dataObj]  objectForKey:@"defaultValue"] forState:UIControlStateNormal];
		}
		
		if ([[cell dataObj] objectForKey:@"fieldName"] == RPLocalizedString(@"Amount", @"")){
			[self amountFiledHandlings:cell];
		}
		
	}
	else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: NUMERIC_KEY_PAD ]){
		[cell.fieldButton setHidden:YES];
		[cell.fieldText setHidden:NO];
		[cell.amountTextField setHidden:YES];
	}
	else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: CHECK_MARK ]) {
		[[cell fieldName] setText:[[cell dataObj] objectForKey:@"fieldName"]];
		if ([[cell dataObj] objectForKey:@"fieldName"] == RPLocalizedString(@"Bill Client", @"")){
			if ([[cell.dataObj objectForKey:@"defaultValue"] isEqualToString:G2Check_OFF_Image]) {
				[cell.fieldName setTextColor:RepliconStandardGrayColor];
			}else {
				[cell.fieldName setTextColor:RepliconStandardBlackColor];
			}
		}else {
			[cell.fieldButton setUserInteractionEnabled:YES];
		}
		
		
	}
	else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: IMAGE_PICKER]|| [[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]||
			 [[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: DATE_PICKER]) {
		
		//[cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[[cell fieldName] setText:[[cell dataObj] objectForKey:@"fieldName"]];
		[[cell fieldButton] setTitle:[[cell dataObj] objectForKey:@"defaultValue"] forState:UIControlStateNormal];
		
		if ([[cell dataObj] objectForKey:@"fieldName"] == RPLocalizedString(@"Type", @"")){
            if (![[[cell dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(@"Select", @"")]) {
                [self typeFiledHandlings:cell];
            }
			
		}
		
	}	else {
		[cell.fieldButton setHidden:NO];
		[cell.fieldText setHidden:YES];
	}
    
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];//DE3566//Juhi
    // tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
	
	return cell;
}

-(void)switchButtonHandlings:(id)entryCellObj
{
	id entryCell = (G2ExpenseEntryCellView*)[tnewExpenseEntryTable cellForRowAtIndexPath:currentIndexPath];
	UISwitch *tempSwitch = [entryCell switchMark];
	if ([tempSwitch isOn]) {
		[tempSwitch setOn:NO animated:YES];
		[[entryCell dataObj] setObject:G2Check_OFF_Image forKey:@"defaultValue"];
	}else {
		[tempSwitch setOn:YES animated:YES];
		[[entryCell dataObj] setObject:G2Check_ON_Image forKey:@"defaultValue"];
	}
	[self performSelector:@selector(tableViewCellUntapped:) withObject:currentIndexPath afterDelay:0.3];
}

-(void)amountFiledHandlings:(id)amountCell
{
	NSIndexPath *typeIndex = nil;
	if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
		typeIndex = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
	}else {
		typeIndex = [NSIndexPath indexPathForRow:0 inSection:G2EXPENSE_SECTION];//Ullas-ML
	}
	if (![[[firstSectionfieldsArray objectAtIndex:typeIndex.row] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(TYPE_DEFAULT, TYPE_DEFAULT)]) {
		[(UIButton *)[amountCell fieldButton] setTitleColor:NewRepliconStandardBlueColor
									   forState:UIControlStateNormal];//US4065//Juhi
		[[amountCell fieldName] setTextColor:RepliconStandardBlackColor];
		[amountCell setUserInteractionEnabled:YES];
	}else {
		[[amountCell fieldName] setTextColor:RepliconStandardGrayColor];
		[(UIButton *)[amountCell fieldButton] setTitleColor:RepliconStandardGrayColor forState:UIControlStateNormal];
		[amountCell setUserInteractionEnabled:NO];
	}
}

-(void)typeFiledHandlings:(id)typeCell
{
	
	//NSMutableArray *lastEntryArray = [expensesModel getLastEntryAddedForSheet:expenseSheetID];
	
    //	NSIndexPath *projIndex = nil;		//fixed memory leak
	if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
		//projIndex = [NSIndexPath indexPathForRow:0 inSection:0];		//fixed memory leak
		[(UIButton *)[typeCell fieldButton] setTitleColor:NewRepliconStandardBlueColor
									 forState:UIControlStateNormal];//US4065//Juhi
		[[typeCell fieldName] setTextColor:RepliconStandardBlackColor];
		[typeCell setUserInteractionEnabled:YES];
		/*if (lastEntryArray != nil) {
		 [[typeCell fieldButton] setTitleColor:FieldButtonColor
		 forState:UIControlStateNormal];
		 [[typeCell fieldName] setTextColor:RepliconStandardBlackColor];
		 [typeCell setUserInteractionEnabled:YES];
		 }else {
		 [[typeCell fieldName] setTextColor:RepliconStandardGrayColor];
		 [[typeCell fieldButton] setTitleColor:RepliconStandardGrayColor forState:UIControlStateNormal];
		 [typeCell setUserInteractionEnabled:NO];
		 }*/
		
	}
	
}


#pragma mark HandleButtonClicks
-(void)handleButtonClicks:(NSIndexPath*)selectedButtonIndex
{
	
	if (selectedButtonIndex.row != currentIndexPath.row || selectedButtonIndex.section != currentIndexPath.section) {
		[self tableViewCellUntapped:currentIndexPath];
	}
	[self hideKeyBoard];
	//currentIndexPath = [NSIndexPath indexPathForRow: selectedButtonIndex.row inSection: selectedButtonIndex.section];
	[self setCurrentIndexPath:
	 [NSIndexPath indexPathForRow: selectedButtonIndex.row inSection: selectedButtonIndex.section]];
	G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if (cell == nil || [cell dataObj] == nil)	{
		DLog(@"Error 1: Cell cannot be null");
		return;
	}
	
	if([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER])	{
        
        
        
        if (currentIndexPath.section == 0)
        {
            NSDictionary *_rowData = [firstSectionfieldsArray objectAtIndex: currentIndexPath.row];
            NSMutableArray  *expensesArray = [_rowData objectForKey:@"dataSourceArray"];
            
            if ([expensesArray count]==0)
            {
                
                NSMutableDictionary *projectDict =  [self.firstSectionfieldsArray objectAtIndex:1];
                NSString *projectIdentity=[projectDict objectForKey:@"projectIdentity"];
                if ([[cell dataObj] objectForKey: @"fieldName"] ==   RPLocalizedString(@"Type", @"") && permissionType != PermType_NonProjectSpecific  && projectIdentity!=nil && ![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:@"null"] && ![projectIdentity isEqualToString:NULL_STRING] )
                    
                {
                    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
                        
                        [G2Util showOfflineAlert];
                        return;
                        
                    }
                    else
                    {
                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expensesTypesFinishedDownloading:)
                                                                     name:EXPENSETYPES_FINSIHED_DOWNLOADING object:nil];
                        [[G2RepliconServiceManager expensesService]downloadExpenseTypesByProjectSelectionwithId:projectIdentity];
                        return;
                    }
                    
                    
                }
            }

        }
                    
		[self dataPickerAction: cell withEvent: nil forRowIndex: currentIndexPath];
	}
	else if([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: DATE_PICKER])	{
		[self datePickerAction: cell withEvent:nil];
	}
	else if([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: MOVE_TO_NEXT_SCREEN])	{
		[self moveToNextScreen: cell withEvent:nil];
	}
	else if([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: IMAGE_PICKER])	{
		[self imagePicker: cell withEvent:nil];
	}
	else if([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: CHECK_MARK] )	{
		//[self checkMarkAction: cell withEvent:nil];
		[self switchButtonHandlings:cell];
	}
	else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: NUMERIC_KEY_PAD]) {
		
		[self numericKeyPadAction: cell withEvent:nil];
		//[self resetTableViewUsingSelectedIndex: currentIndexPath];
	}
	else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: @"button_numeric_keyPad"]) {
		
		[self numericKeyPadAction: cell withEvent:nil];
		//[self resetTableViewUsingSelectedIndex: currentIndexPath];
	}
	else {
		DLog(@"Error: Invalid field type");
	}
}

- (void) buttonPressed: (id) sender withEvent: (UIEvent *) event
{
    UITouch * touch = [[event allTouches] anyObject];
	
    CGPoint location = [touch locationInView: tnewExpenseEntryTable];
    NSIndexPath * indexPath = [tnewExpenseEntryTable indexPathForRowAtPoint: location];
	
	//[self handleButtonClicks: indexPath];
	[self tableCellTappedAtIndex:indexPath];
	
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return ROW_HEIGHT;//US4065//Juhi
	
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic may go here. Create and push another view controller.
	DLog(@"current INDEX %ld @@@ %ld ----------------- %ld -- %ld",(long)currentIndexPath.row,(long)currentIndexPath.section,(long)indexPath.row,(long)indexPath.section);
	if (indexPath.row != currentIndexPath.row || indexPath.section != currentIndexPath.section) {
		[self tableViewCellUntapped:currentIndexPath];
	}
	
	[self tableCellTappedAtIndex:indexPath];
	
}


-(void)deselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tnewExpenseEntryTable deselectRowAtIndexPath:indexPath animated:YES];
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[entryCell.fieldName setTextColor:RepliconStandardBlackColor];
	[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	[entryCell.fieldText setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
    [entryCell setBackgroundColor:iosStandaredWhiteColor];//DE3566//Juhi
}

-(void)animateCellWhichIsSelected
{   isDataPickerChosen=NO;[self resetTableViewUsingSelectedIndex:nil];//DE5011 ullas
	//[self deselectRowAtIndexPath:currentIndexPath];
	[tnewExpenseEntryTable selectRowAtIndexPath:currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	//[self performSelector:@selector(deselectRowAtIndexPath:) withObject:currentIndexPath afterDelay:0.50];//DE2949 FadeOut is slow
    //[self performSelector:@selector(deselectRowAtIndexPath:) withObject:currentIndexPath afterDelay:0.0];
    [self performSelector:@selector(deselectRowAtIndexPath:) withObject:currentIndexPath afterDelay:0.15];//DE3566//Juhi
}

#pragma mark -
#pragma mark ButtonActions
#pragma mark -

-(void)cancelAction:(id)sender{
	
	[self releaseCache];
	RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	[delegate setCurrVisibleViewController: nil];
	
	if (isEntriesAvailable)
		[self dismissViewControllerAnimated:YES completion:nil];
	else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_ENTRY_SAVED" object:nil];
	}
	
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"GoBackToSheets" object:nil];
	
}

-(NSString *)isValidEntry
{
	NSMutableString *errorMsg = nil;
	
#ifdef PHASE1_US2152
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		//[Util showOfflineAlert];
		NSString *offlineMessage = RPLocalizedString(@"Your device is offline.  Please try again when your device is online.", @"Your device is offline.  Please try again when your device is online.");
		return offlineMessage;
	}
#endif
	
	
	if(permissionType == PermType_ProjectSpecific || permissionType == PermType_Both)	{
		
		if ([[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] &&
			[[[firstSectionfieldsArray objectAtIndex:4]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")])
		{
			errorMsg = [NSMutableString stringWithString: RPLocalizedString(@"Please select expense type", @"Please select expense type")];
		}
		else if ([[[firstSectionfieldsArray objectAtIndex:4]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")]) {
			errorMsg = [NSMutableString stringWithString: RPLocalizedString(@"Please enter Amount", @"Please enter Amount")];
		}
	}
	
	if (permissionType == PermType_NonProjectSpecific){
		
		if ([[[firstSectionfieldsArray objectAtIndex:0]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] &&
			[[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")])
		{
			errorMsg = [NSMutableString stringWithString: RPLocalizedString(@"Please select expense type", @"Please select expense type")];
		}
		else if ([[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")]) {
			//[Util errorAlert:@"Please enter Amount" errorMessage:@""];
			errorMsg = [NSMutableString stringWithString: RPLocalizedString(@"Please enter Amount", @"Please enter Amount")];
		}
	}
	return errorMsg;
}

-(void)saveAction:(id)sender{
	
	[self updateFieldsWithDefaultValues];//DE6113 Ullas M L
	if (numberUdfText != nil) {
		[numberUdfText resignFirstResponder];
	}
	[pickerView1 setHidden:YES];
	[pickerViewC setHidden:YES];
	[self resetTableViewUsingSelectedIndex:nil];
	[self deselectRowAtIndexPath:currentIndexPath];
	if (![NetworkMonitor isNetworkAvailableForListener:self]) {
		[G2Util showOfflineAlert];
        [self pickerDone:nil];
		return;
	}
    
    if (permissionType==PermType_ProjectSpecific || permissionType==PermType_Both)
    {
        NSDictionary *_clientDict = [firstSectionfieldsArray objectAtIndex:0];
        NSDictionary *_projectDict = [firstSectionfieldsArray objectAtIndex:1];
        
        NSString *clientIdentity=[_clientDict objectForKey:@"clientIdentity"];
        NSString *projectIdentity=[_projectDict objectForKey:@"projectIdentity"];
        
        if (clientIdentity!=nil && ![clientIdentity isKindOfClass:[NSNull class]] && ![clientIdentity isEqualToString:@"null"] && ![clientIdentity isEqualToString:NULL_STRING])
        {
            if (projectIdentity==nil && [projectIdentity isKindOfClass:[NSNull class]] && [projectIdentity isEqualToString:NO_CLIENT_ID] && [projectIdentity isEqualToString:NULL_STRING] )
            {
                [self.mainScrollView setFrame:CGRectMake(0,0.0,self.view.frame.size.width,self.view.frame.size.height)];
                [G2Util errorAlert:@"" errorMessage:RPLocalizedString(CLIENT_VALIDATION_NO_PROJECT_SELECTED, CLIENT_VALIDATION_NO_PROJECT_SELECTED)];
                return;
            }
            else if ([projectIdentity isEqualToString:NO_CLIENT_ID] )
            {
                [self.mainScrollView setFrame:CGRectMake(0,0.0,self.view.frame.size.width,self.view.frame.size.height)];
                [G2Util errorAlert:@"" errorMessage:RPLocalizedString(CLIENT_VALIDATION_NO_PROJECT_SELECTED, CLIENT_VALIDATION_NO_PROJECT_SELECTED)];
                return;
            }
        }
        
    }
    
    
    
	@try {
		if (firstSectionfieldsArray == nil || [firstSectionfieldsArray count] <= 0) {
			DLog(@"Error: firstsectionfields is empty");
			return;
		}
		NSString *errorMsg = [self isValidEntry];
		if (errorMsg != nil) {
			[G2Util errorAlert: @"" errorMessage: errorMsg];//DE1231//Juhi
            [self pickerDone:nil];
			return;
		}
		
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
		
		NSMutableDictionary *dictionary=[NSMutableDictionary dictionary];
		
		//Add the expense Sheet ID to the request
		if (expenseSheetID!=nil)
			[dictionary setObject:expenseSheetID forKey:@"ExpenseSheetID"];
		
		
		NSMutableArray *udfsArrayEnabled = [supportDataModel getEnabledUserDefineFieldsExpensesFromDatabase];
		NSUInteger valueWithOutUdfs = 0;
		if (udfsArrayEnabled != nil && [udfsArrayEnabled count] > 0) {
			valueWithOutUdfs = [udfsArrayEnabled count];
		}
        
		if (secondSectionfieldsArray!=nil && [secondSectionfieldsArray count]>0) {
			valueWithOutUdfs = [secondSectionfieldsArray count] - valueWithOutUdfs;
			for (int i=0; i<valueWithOutUdfs; i++) {
				NSDictionary *_fieldInfo = [secondSectionfieldsArray objectAtIndex:i];
				if ([_fieldInfo objectForKey:@"defaultValue"]!=nil)
					[dictionary setObject:[_fieldInfo objectForKey:@"defaultValue"] forKey:[_fieldInfo objectForKey:@"fieldName"]];
			}
			if ([[secondSectionfieldsArray objectAtIndex:1]objectForKey:@"defaultValue"]!=nil)
				[dictionary setObject:[[secondSectionfieldsArray objectAtIndex:1]objectForKey:@"defaultValue"] forKey:@"Description"];
		}
		
		
		
		//ravi - Handle first section fields
		if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0) {
			for (int i=0; i<[firstSectionfieldsArray count]; i++) {
				NSDictionary *_fieldInfo = [firstSectionfieldsArray objectAtIndex:i];
				if ([_fieldInfo objectForKey:@"defaultValue"]!=nil)
					[dictionary setObject:[_fieldInfo objectForKey:@"defaultValue"] forKey:[_fieldInfo objectForKey:@"fieldName"]];
			}
		}
		
		NSNumber *entryNetAmount = nil;
		NSDictionary *_typeInfo = nil;
		NSDictionary *_amountInfo = nil;
		NSMutableString *_projIdentity = [NSMutableString stringWithString: @"null"];
		
		if(permissionType == PermType_ProjectSpecific || permissionType == PermType_Both)	{
			if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0){
				NSDictionary *_clientDict = [firstSectionfieldsArray objectAtIndex:0];
                NSDictionary *_projectDict = [firstSectionfieldsArray objectAtIndex:1];
                
				if ([_clientDict objectForKey:@"clientIdentity"]!=nil)
					[dictionary setObject:[_clientDict objectForKey:@"clientIdentity"] forKey:@"clientIdentity"];
				if ([_projectDict objectForKey:@"projectIdentity"]!=nil) {
					[dictionary setObject:[_projectDict objectForKey:@"projectIdentity"] forKey:@"projectIdentity"];
					[_projIdentity setString: [_projectDict objectForKey:@"projectIdentity"]];
				}
				if ([_clientDict objectForKey:@"clientName"]!=nil)
					[dictionary setObject:[_clientDict objectForKey:@"clientName"] forKey:@"clientName"];
				
				if ([_projectDict objectForKey:@"projectName"]!=nil)
					[dictionary setObject:[_projectDict objectForKey:@"projectName"] forKey:@"projectName"];
			}
			_typeInfo = [firstSectionfieldsArray objectAtIndex: 2];
			_amountInfo = [firstSectionfieldsArray objectAtIndex: 4];
		} else if (permissionType == PermType_NonProjectSpecific) {
			_typeInfo = [firstSectionfieldsArray objectAtIndex: 0];
			_amountInfo = [firstSectionfieldsArray objectAtIndex: 2];
		}
		
		//ravi add expense type and amount
		if ([_typeInfo objectForKey: @"selectedDataIdentity"] != nil) {
			[dictionary setObject: [_typeInfo objectForKey: @"selectedDataIdentity"] forKey: @"typeIdentity"];
		}
		NSString *amount = [_amountInfo objectForKey: @"defaultValue"];
		if (amount != nil) {
			entryNetAmount = [NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amount]];
		}
		if (entryNetAmount!=nil)
			[dictionary setObject:entryNetAmount forKey:@"NetAmount"];
		//ravi - End
		
		NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesToSaveWithEntryForSelectedProjectId: _projIdentity withType:[dictionary objectForKey: @"typeIdentity"]];
		
		NSString *selectedDataSource=nil;
		NSString *selectedType=nil;
		if (expenseTypeArr!=nil && [expenseTypeArr count]>0) {
			selectedDataSource = [[expenseTypeArr objectAtIndex:0]objectForKey:@"name"];
			[dictionary setObject: selectedDataSource forKey:@"typeName"];
			selectedType = [[expenseTypeArr objectAtIndex:0]objectForKey:@"type"];
		}
		if (selectedType!=nil) {
			if ([selectedType isEqualToString:@"RatedWithOutTaxes"]||[selectedType isEqualToString:@"RatedWithTaxes"]) {
				if (defaultRateAndAmountsArray!=nil && [defaultRateAndAmountsArray count]>0) {
					NSString *expenseRate =[defaultRateAndAmountsArray objectAtIndex:1];
					[dictionary setObject:[NSNumber numberWithDouble:[[defaultRateAndAmountsArray objectAtIndex:0]doubleValue]] forKey:@"NumberOfUnits"];
					if (expenseRate!=nil)
						[dictionary setObject:[NSNumber numberWithDouble:[expenseRate doubleValue]]  forKey:@"ExpenseRate"];
				}
				
				[dictionary setObject:[NSNumber numberWithInt:1] forKey:@"isRated"];
			}else {
				[dictionary setObject:[NSNumber numberWithInt:0] forKey:@"isRated"];
			}
		}
		
		
		
		
		double amountWithTaxes=0;
		if (amountValuesArray!=nil|| [amountValuesArray count]>0) {
			NSString *amount=nil;
			if ([amountValuesArray objectAtIndex:1] !=nil)
				amount = [amountValuesArray objectAtIndex:1];
			if (amount!=nil)
				entryNetAmount = [NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amount]];
			if (entryNetAmount!=nil)
				[dictionary setObject:entryNetAmount forKey:@"NetAmount"];
			
			amountWithTaxes= entryNetAmount == nil ? 0.0 : [entryNetAmount doubleValue];
			for (int j=2; j<[amountValuesArray count]-1; j++) {
				NSString *taxAmount = [amountValuesArray objectAtIndex:j];
				if (taxAmount!=nil)	{
					[dictionary setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",j-1]];
					amountWithTaxes=amountWithTaxes+[taxAmount doubleValue];
				}
			}
		}
		
		if (ratedCalculatedValuesArray!=nil|| [ratedCalculatedValuesArray count]>1) {
			for (int j=0; j<[ratedCalculatedValuesArray count]-1; j++) {//DE6113 Ullas M L
				NSString *taxAmount = [ratedCalculatedValuesArray objectAtIndex:j];
				if (taxAmount!=nil)
					[dictionary setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",j+1]];
			}
		}
		
		if (baseCurrency!=nil)
			[dictionary setObject:baseCurrency forKey:@"currencyType"];
		
		if (b64String!=nil && ![b64String isKindOfClass:[NSNull class]] ) {
			[dictionary setObject:b64String forKey:@"base64ImageString"];
			//[self releaseCache];// This should not be here
		}else {
			[dictionary setObject:@"" forKey:@"base64ImageString"];
		}
		
		NSString *currencyId=nil;
		if (permissionType == PermType_Both ||permissionType == PermType_ProjectSpecific) {
			currencyId = [[firstSectionfieldsArray objectAtIndex:3] objectForKey:@"selectedDataIdentity"];
		}
		else if (permissionType == PermType_NonProjectSpecific) {
			currencyId = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"selectedDataIdentity"];
		}
		if (currencyId!=nil)
			[dictionary setObject:currencyId forKey:@"currencyIdentity"];
		
		NSString *paymentMethodName=nil;
		NSMutableArray *paymentMethodId=nil;
		if ([dictionary objectForKey:RPLocalizedString(@"Payment Method", @"") ]!=nil) {
			paymentMethodName = [dictionary objectForKey:RPLocalizedString(@"Payment Method", @"")];
			if (![paymentMethodName isEqualToString:RPLocalizedString(@"Select", @"")]) {
				paymentMethodName = [dictionary objectForKey:RPLocalizedString(@"Payment Method", @"")];
				paymentMethodId = [expensesModel getPaymentMethodIdFromDefaultPayments:paymentMethodName];
				if (paymentMethodId!=nil && [paymentMethodId count]>0)
					[dictionary setObject:[[paymentMethodId objectAtIndex:0] objectForKey:@"identity"] forKey:@"paymentMethodId"];
			}
		}
		
		
		if ([dictionary objectForKey:RPLocalizedString(@"Bill Client", @"") ] !=nil) {
			if ([[dictionary objectForKey:RPLocalizedString(@"Bill Client", @"")] isEqualToString:G2Check_OFF_Image]) {
				[dictionary setObject:[NSNumber numberWithInt:0] forKey:@"BillClient"];
			}else if([[dictionary objectForKey:RPLocalizedString(@"Bill Client", @"")] isEqualToString:G2Check_ON_Image]){
				[dictionary setObject:[NSNumber numberWithInt:1] forKey:@"BillClient"];
			}
		}
		
		if ([dictionary objectForKey:RPLocalizedString(@"Reimburse", @"") ] !=nil) {
			if ([[dictionary objectForKey:RPLocalizedString(@"Reimburse", @"")] isEqualToString:@"G2check_off.png"]) {
				[dictionary setObject:[NSNumber numberWithInt:0] forKey:@"Reimburse"];
			}else {
				[dictionary setObject:[NSNumber numberWithInt:1] forKey:@"Reimburse"];
			}
		}
        
		
		NSMutableArray *editedUdfArray = [NSMutableArray array];
		NSUInteger z = valueWithOutUdfs ;
		for (NSDictionary * udf in udfsArrayEnabled) {
			
			NSString *dictionaryValue = [[secondSectionfieldsArray objectAtIndex:z] objectForKey:@"defaultValue"];
			if (dictionaryValue != nil  ) {
				
				NSDictionary *udfDictionary = [NSDictionary dictionaryWithObjectsAndKeys:dictionaryValue ,@"udfValue",[udf objectForKey:@"name"],@"udf_name",
											   [udf objectForKey:@"identity"],@"udf_id",
											   [udf objectForKey:@"udfType"],@"udf_type",
											   [udf objectForKey:@"required"],@"required",
											   nil];
				if (udfDictionary!=nil)
					[editedUdfArray addObject:udfDictionary];
			}
			z++;
		}
		
		[dictionary setObject:editedUdfArray forKey:@"UserDefinedFields"];
		
		
		if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
			
			
			[dictionary setObject:[NSNumber numberWithInt:1] forKey:@"isModified"];
			[dictionary setObject:@"create" forKey:@"editStatus"];
			[dictionary setObject:[NSString stringWithFormat:@"%d",(int)[NSDate timeIntervalSinceReferenceDate]] forKey:@"identity"];
			NSMutableArray *editedUdfArray = [NSMutableArray array];
			//SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
			//NSArray *udfsArray = [supportDataModel getUserDefineFieldsFromDatabase];
			
            /*	for (NSDictionary * udf in udfsArray) {
             NSString *dictionaryValue = [dictionary objectForKey:[udf objectForKey:@"name"]];
             if (dictionaryValue != nil  ) {
             NSDictionary *udfDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
             dictionaryValue ,@"udfValue",
             [udf objectForKey:@"name"],@"udf_name",
             [udf objectForKey:@"identity"],@"udf_id",
             [udf objectForKey:@"udfType"],@"udf_type",
             [udf objectForKey:@"required"],@"required",
             nil];
             [editedUdfArray addObject:udfDictionary];
             }
             }
             [dictionary setObject:editedUdfArray forKey:@"UserDefinedFields"];*/
			
			if (amountWithTaxes>0)
				[dictionary setObject:[NSNumber numberWithDouble:amountWithTaxes] forKey:@"NetAmount"];
			
			[expensesModel saveNewExpenseEntryToDataBase:dictionary];
			[expensesModel saveUdfsForExpenseEntry:editedUdfArray :[dictionary objectForKey:@"identity"] :@"Expense"];
			[expensesModel updateExpenseSheetModifyStatus:[NSNumber numberWithInt:1] :[dictionary objectForKey:@"ExpenseSheetID"]];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ExpenseEntriesNotification"
																object:nil];
			//[self dismissViewControllerAnimated:YES completion:nil];
			[self.navigationController popViewControllerAnimated: YES];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
			
		}else {
			//newApril
			[[G2RepliconServiceManager expensesService]sendRequestToAddNewExpenseWithUserEnteredData:dictionary withDelegate:self];
		}
		
		if ( pickerViewC!=nil && [pickerViewC isHidden]==NO) {
			[pickerViewC setHidden:YES];
		}
	}
	@finally {
		
	}
	
}

-(void)setTotalAmountToRatedType:(NSString*)totalAmountCalculated
{
	amountValue=totalAmountCalculated;
}
-(void)setRatedUnits:(NSString*)ratedKilometerEntry
{
	kilometersUnitsValue=ratedKilometerEntry;
}
-(void)setValuesForRatedExpenseType:(NSMutableArray *)_arrayrated{
	[self setDefaultRateAndAmountsArray:[NSMutableArray arrayWithArray:[_arrayrated objectAtIndex:0]]];
	[self setRatedCalculatedValuesArray:[NSMutableArray arrayWithArray:[_arrayrated objectAtIndex:1]]];
}
-(NSIndexPath *)getIndexPathForCellEvent:(UIEvent *) event{
	UITouch * touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView: tnewExpenseEntryTable];
	NSIndexPath * indexPath = [tnewExpenseEntryTable indexPathForRowAtPoint: location];
	return indexPath;
}
-(void)hideKeyBoard{isDataPickerChosen=YES;//DE5011 ullas
	if(numberUdfText != nil)
		[numberUdfText resignFirstResponder];
}

-(void)dataPickerAction:(G2ExpenseEntryCellView *)_cell withEvent: (UIEvent *) event forRowIndex: (NSIndexPath *) rowIndex
{
	[self hideKeyBoard];
	[datePicker setHidden:YES];
	//ravi - Over cautious
	if (_cell == nil) {
		DLog(@"Error: Cell Cannot be nil here");
		return;
	}
	
	NSDictionary *_dataObj = [_cell dataObj];
	
	if (rowIndex.section == 0) {
		NSDictionary *_rowData = [firstSectionfieldsArray objectAtIndex: rowIndex.row];
		
		if ([_dataObj objectForKey: @"fieldName"] ==   RPLocalizedString(@"Project", @"")) {
			clientsArray = [_rowData objectForKey: @"clientsArray"];
			dataSourceArray = [_rowData objectForKey: @"clientsArray"];
			projectsArray = [_rowData objectForKey: @"projectsArray"];
		} else {
			dataSourceArray = [_rowData objectForKey:@"dataSourceArray"];
		}
		[self changeSegmentControlState: rowIndex];
		[self reloadDataPicker: rowIndex];
	}	else if (rowIndex.section == 1) {
        
		dataSourceArray = [[secondSectionfieldsArray objectAtIndex: rowIndex.row]objectForKey:@"dataSourceArray"];
		[self reloadDataPicker: rowIndex];
		
		[self changeSegmentControlState: rowIndex];
		//[self resetTableViewUsingSelectedIndex: rowIndex];
	}
	[self resetTableViewUsingSelectedIndex: rowIndex];
}

-(void)changeSegmentControlState:(NSIndexPath *)indexpath{
    //DE2113
    G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath: indexpath];
	if (indexpath.section == 0) {
		if (indexpath.row==0) {
			[toolbarSegmentControl setEnabled:NO forSegmentAtIndex: NavigationType_Previous];
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Next];
		}else {
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Previous];
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Next];
		}
		
	}else if (indexpath.section==1) {
		
		if (indexpath.row == [secondSectionfieldsArray count]-1) {
			[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:NavigationType_Next];
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NavigationType_Previous];
		}else {
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NavigationType_Previous];
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NavigationType_Next];
		}
		
		if (indexpath.row == 0) {
			G2ExpenseEntryCellView *expenseEntryCellView=nil;
			expenseEntryCellView =(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:
														   [NSIndexPath indexPathForRow:[firstSectionfieldsArray count]-1 inSection:G2EXPENSE_SECTION]];
			if([expenseEntryCellView isUserInteractionEnabled]==YES)
			{
				[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NavigationType_Next];
				[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NavigationType_Previous];
				
				
			}else {
				[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NavigationType_Next];
				[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:NavigationType_Previous];
			}
			
		}
		
		//DLog(@"numberudf tag: %d==== %d", numberUdfText.tag, [secondSectionfieldsArray count]);
		if (numberUdfText.tag-1-SECONDSECTION_TAG_INDEX ==[secondSectionfieldsArray count]-1) {
			[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:NavigationType_Next];
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NavigationType_Previous];
		}
        //DE2113
		if ([[cell fieldName].text isEqualToString:RPLocalizedString(@"Payment Method", @"") ]&& indexpath.row<udfStartIndex) {
            [toolbarSegmentControl setEnabled:NO forSegmentAtIndex:NavigationType_Previous];
            [toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NavigationType_Next];
        }
	}
}


-(void)datePickerAction:(G2ExpenseEntryCellView *)cell  withEvent: (UIEvent *) event
{
	[self hideKeyBoard];
	if (event != nil) {
		//selectedIndexPath = [self getIndexPathForCellEvent: event];
	}
	
	datePicker.date = [NSDate date];
	[self reloadDatePicker: currentIndexPath];
	
#ifdef _DROP_RELEASE_1_US1730
	//ravi - Field validations will be handled from the API side for this release.
	//REF:- US1730
	
	if ([[cell dataObj] objectForKey: @"defaultMaxValue"] != nil &&
		!([[[cell dataObj] objectForKey: @"defaultMaxValue"] isKindOfClass: [NSNull class]]))
	{
		[datePicker setMaximumDate:[Util convertStringToDate1:[[cell dataObj] objectForKey: @"defaultMaxValue"]]];
	}
	if ([[cell dataObj] objectForKey: @"defaultMinValue"] != nil &&
		!([[[cell dataObj] objectForKey: @"defaultMinValue"] isKindOfClass: [NSNull class]]))
	{
		[datePicker setMinimumDate:[Util convertStringToDate1:[[cell dataObj] objectForKey: @"defaultMinValue"]]];
	}
#endif
	[self resetTableViewUsingSelectedIndex:currentIndexPath];
	[self changeSegmentControlState: currentIndexPath];
}

-(void)checkMarkAction:(id)sender withEvent: (UIEvent *) event
{
	[pickerViewC setHidden:YES];
	[pickerView1 setHidden:YES];
	[datePicker setHidden:YES];
	[self hideKeyBoard];
	if (event!=nil) {
	}
	
	G2ExpenseEntryCellView *expenseEntryCellView=nil;
	expenseEntryCellView =(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:
												   [NSIndexPath indexPathForRow:currentIndexPath.row inSection:currentIndexPath.section]];
	if ([[[expenseEntryCellView dataObj] objectForKey: @"fieldType"] isEqualToString: CHECK_MARK])	{
		if (currentIndexPath.section==1) {
			NSString *imgName = [[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"];
			
			if ([imgName isEqualToString:G2Check_ON_Image]) {
				[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]setObject:G2Check_OFF_Image forKey:@"defaultValue"];
				
			}else {
				[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]setObject:G2Check_ON_Image forKey:@"defaultValue"];
				
			}
		}
	}
	UIImage *img = [G2Util thumbnailImage:[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]];
	[expenseEntryCellView.fieldButton setImage:img forState:UIControlStateNormal];
	
	[self changeSegmentControlState: currentIndexPath];
	[self resetTableViewUsingSelectedIndex:nil];
	
}
-(void)setCheckMarkImage:(NSString *)imgName withFieldButton: (G2ExpenseEntryCellView*)entryCell{
	
	UIImage *img = [G2Util thumbnailImage:imgName];
	if ([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString: CHECK_MARK]) {
		[entryCell.fieldButton setImage:img forState:UIControlStateNormal];
	}else {
		[entryCell.fieldButton setImage:nil forState:UIControlStateNormal];
	}
	[self changeSegmentControlState:currentIndexPath];
	
}

#pragma mark keyboardNotifications

-(void)registerForKeyBoardNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
	// Register notification when the keyboard will be hide
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	
}

- (void)showToolBarWithAnimation{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    CGRect frame = pickerViewC.frame;
    frame.origin.y = self.view.frame.size.height -keyBoardHeight ;
	pickerViewC.frame= frame;
	
    [UIView commitAnimations];
}
- (void)hideToolBarWithAnimation {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    CGRect frame = pickerViewC.frame;
    frame.origin.y = self.view.frame.size.height;
    pickerViewC.frame = frame;
	
	[UIView commitAnimations];
}

-(void) keyboardWillShow:(NSNotification *)note{
}

-(void) keyboardWillHide:(NSNotification *)note
{
}


-(void)viewWillDisappear:(BOOL)animated
{
    
	[self resetTableViewUsingSelectedIndex:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


-(void)hidePickersForKeyBoard:(UITextField*)textField
{
	
	NSIndexPath *selectedIndex= nil;
	int amountRowIndex = 4;
	if (permissionType == PermType_NonProjectSpecific) {
		amountRowIndex = 2;
	}
	if (amountRowIndex == textField.tag- FIRSTSECTION_TAG_INDEX) {
		
		selectedIndex = [NSIndexPath indexPathForRow:amountRowIndex inSection:G2EXPENSE_SECTION];
	}
	else {
		selectedIndex = [NSIndexPath indexPathForRow:textField.tag-SECONDSECTION_TAG_INDEX inSection:1];
	}
	
	//if (selectedIndex != currentIndexPath) { // Since the comparision of NSIndexPath in 5.0 falis, this line has been commented
    if ([selectedIndex compare: currentIndexPath] != NSOrderedSame) {
		[self tableViewCellUntapped:currentIndexPath];
	}
	
	self.currentIndexPath=selectedIndex;
	
	[self highLightCellWhichIsSelected:currentIndexPath];
	numberUdfText=textField;
	[pickerView1 setHidden:YES];
	[pickerViewC setHidden:NO];
	[datePicker setHidden:YES];
	[pickerViewC setBackgroundColor:[UIColor clearColor]];
	[self resetTableViewUsingSelectedIndex: currentIndexPath];
	[self changeSegmentControlState: currentIndexPath];
	
}
-(void)highLightCellWhichIsSelected:(NSIndexPath*)indexTapped
{
	id cellSelected = [self getCellForIndexPath:indexTapped];
	[tnewExpenseEntryTable selectRowAtIndexPath:indexTapped animated:YES scrollPosition:UITableViewScrollPositionNone];
    [cellSelected setBackgroundColor:RepliconStandardBlueColor];//DE3566//Juhi
	[cellSelected setCellViewState:YES];
}
-(void)addValuesToNumericUdfs:(UITextField*)textFields
{
	DLog(@"currentIndexPath %@",currentIndexPath);
    //DE8239 Ullas
    NSUInteger currentRowIndex = [firstSectionfieldsArray count]-1;
	
    NSIndexPath *tempCurrentIndexPath= nil;
    tempCurrentIndexPath = [NSIndexPath indexPathForRow:currentRowIndex inSection:G2EXPENSE_SECTION];
	if (textFields.tag == (FIRSTSECTION_TAG_INDEX + currentRowIndex)) {
		
		NSMutableDictionary *infoDict =[firstSectionfieldsArray objectAtIndex: 2];
		if (permissionType != PermType_NonProjectSpecific) {
			infoDict = [firstSectionfieldsArray objectAtIndex:4];
		}
        if (![textFields.text isKindOfClass:[NSNull class] ])
        {
            if ([textFields.text length] == 0) {
                textFields.text = RPLocalizedString(@"Add", @"");
            }
        }
		
		NSString *commaRemovedString = [self replaceStringToCalculateAmount:@"," replaceWith:@"" originalString:textFields.text];
		double amountDoubleValue = [G2Util getValueFromFormattedDoubleWithDecimalPlaces:commaRemovedString];
		NSString *amountString = [G2Util formatDoubleAsStringWithDecimalPlaces:amountDoubleValue];
		[infoDict setObject:amountString forKey:@"defaultValue"];
		G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:tempCurrentIndexPath];
		[entryCell.fieldButton setTitle:amountString forState:UIControlStateNormal];
		[entryCell.fieldText setText:amountString];
		return;
	}
	
    NSString *tempValue =	[G2Util formatDecimalPlacesForNumericKeyBoard:[textFields.text doubleValue] withDecimalPlaces:deimalPlacesCount];
    if (tempValue == nil) {
        tempValue = textFields.text;
    }
    textFields.text = [G2Util removeCommasFromNsnumberFormaters:tempValue];
	numberUdfText=textFields;
    
	NSMutableDictionary *infoDict =[secondSectionfieldsArray objectAtIndex: currentIndexPath.row];
	
	[infoDict setObject:numberUdfText.text forKey:@"defaultValue"];
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:currentIndexPath];
	/*
	 if (entryCell.fieldText == nil) {
	 [[entryCell dataObj] setObject: @"" forKey: @"defaultValue"];
	 [entryCell.fieldText setText:RPLocalizedString(textFields.text,@"")];
	 }else	{
	 [[entryCell dataObj] setObject: entryCell.fieldText.text forKey: @"defaultValue"];
	 }
	 */
	[[entryCell dataObj] setObject: textFields.text forKey: @"defaultValue"];
	//Handling Leaks
	
	self.numberUdfText=entryCell.fieldText;//DE5422 Ullas M L
	//[pickerViewC setHidden:NO];//DE5422 Ullas M L
	//[self resetTableViewUsingSelectedIndex:nil];//DE5422 Ullas M L
	[datePicker setHidden:YES];
	//[self tableViewCellUntapped:currentIndexPath];//DE5422 Ullas M L
}

-(void)updateNumberOfDecimalPlaces:(NSNumber*)decimalPlaces
{
	deimalPlacesCount = [decimalPlaces intValue];
	
}

-(void)numericKeyPadAction:(G2ExpenseEntryCellView*)cell withEvent: (UIEvent *) event
{
	
	//int row=sender.tag;
	//if (numberUdfText==nil) {
	//ExpenseEntryCellView *expenseEntryCellView =(ExpenseEntryCellView *)[newExpenseEntryTable cellForRowAtIndexPath:
	//																	 [NSIndexPath indexPathForRow:row inSection:1]];
	numberUdfText=cell.fieldText;
	[cell.fieldText becomeFirstResponder];
	
	
	//}else {
	//[numberUdfText becomeFirstResponder];
	//}
	
	///NSIndexPath *selectedIndex=[NSIndexPath indexPathForRow:row inSection:1];
	//selectedIndexPath=selectedIndex;
	[pickerViewC setHidden:NO];
	[pickerView1 setHidden:YES];
	[pickerViewC setBackgroundColor:[UIColor clearColor]];
	[self changeSegmentControlState:currentIndexPath];
}

-(void)moveToNextScreen:(G2ExpenseEntryCellView *)entryCell withEvent: (UIEvent *) event{
	
    
	
	[datePicker setHidden:YES];
	[pickerView1 setHidden:YES];
	[self hideKeyBoard];
	[pickerViewC setHidden:YES];
	
	if (currentIndexPath.section == 1) {
        
		G2AddDescriptionViewController *addDescriptionViewController  = [[G2AddDescriptionViewController alloc]init];
        //US4065//Juhi
        //DE8142
        if ([entryCell.fieldName.text isEqualToString:@"Description"]&&currentIndexPath.row<udfStartIndex) {
            addDescriptionViewController.fromExpenseDescription =YES;
        }
        else
            addDescriptionViewController.fromExpenseDescription=NO;
		[addDescriptionViewController setDescTextString:[[ NSString alloc] initWithString:[[entryCell dataObj] objectForKey:@"defaultValue"]] ];
		[addDescriptionViewController setViewTitle: [[entryCell dataObj]objectForKey: @"fieldName"]];
		
		addDescriptionViewController.descControlDelegate=self;
		RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
		[delegate setCurrVisibleViewController: addDescriptionViewController];
		
		[self.navigationController pushViewController:addDescriptionViewController animated:YES];
		
	}
	else if (currentIndexPath.section == 0) {
		if([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:MOVE_TO_NEXT_SCREEN])	{
            
            
            
            
            if ([entryCell.fieldName.text isEqualToString:RPLocalizedString(CLIENT, @"")])
            {
                [self showAllClients];
            }
            else if ([entryCell.fieldName.text isEqualToString:RPLocalizedString(@"Project", @"")])
            {
                NSArray *allProjects=[self genarateProjectsListForDtaListView];
                if (allProjects==nil || [allProjects count]==0)
                {
                    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
                        
                        [G2Util showOfflineAlert];
                        return;
                        
                    }
                    else
                    {
                        NSMutableDictionary *clientDict =  [self.firstSectionfieldsArray objectAtIndex:0];
                        [[G2RepliconServiceManager expensesService] sendRequestToGetExpenseProjectsByClient:[clientDict objectForKey:@"clientIdentity"] withDelegate:[G2RepliconServiceManager expensesService]];
                        
//                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
                        
                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                        
                        G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
                        self.dataListViewCtrl=tempdataListViewCtrl;
                        

                         [self.dataListViewCtrl setTitleStr:RPLocalizedString(CHOOSE_PROJECT, CHOOSE_PROJECT)];

                        
                        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                        name:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:nil];
                        
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(expensesFinishedDownloadingProjects:)
                                                                     name:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:nil];
                    }
                    
                }
                else
                {
                    G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
                    self.dataListViewCtrl=tempdataListViewCtrl;
                    
                    [self showAllProjectswithMoreButton:TRUE];
                }
                
                [self.navigationController pushViewController:self.dataListViewCtrl animated:YES];
                [self pickerDone:nil];
                
            }
            else if ([entryCell.fieldName.text isEqualToString:@"Amount"])
            {
                
                NSString *identity;
                NSDictionary *infoDict;
                
                if(permissionType == PermType_ProjectSpecific || permissionType == PermType_Both)	{
                    identity = [[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"];
                    infoDict=[firstSectionfieldsArray objectAtIndex:2];
                }else {//if (nonProjectSpecific ==YES) {
                    identity = @"null";
                    infoDict = [firstSectionfieldsArray objectAtIndex:0];
                }
                
                int ind = [[infoDict objectForKey:@"selectedIndex"]intValue];
                NSArray *_dataSource = [infoDict objectForKey:@"dataSourceArray"];
                if (_dataSource != nil && [_dataSource count] == 0) {
                    [self changeSegmentControlState:currentIndexPath];
                    self.isDataPickerChosen=FALSE;
                    [self resetTableViewUsingSelectedIndex:nil];
                    [self deselectRowAtIndexPath:currentIndexPath];
                    [self disableExpenseFieldAtIndex:currentIndexPath];
                    return;
                }
                
                NSString *typeName = nil;
                if (_dataSource != nil && [_dataSource count] > 0) {
                    typeName = [[_dataSource objectAtIndex: ind] objectForKey: @"name"];
                }
                //NSString *typeName = [[[infoDict objectForKey:@"dataSourceArray"]objectAtIndex:ind]objectForKey:@"name"];
                
                
                NSMutableArray *expenseUnitLabelArray=[supportDataModel getExpenseUnitLabelsFromDB:identity withExpenseType:typeName];
                NSMutableArray *expenseTaxCodesLocalArray=[supportDataModel getExpenseLocalTaxcodesFromDB:identity withExpenseType:typeName];
                
                NSMutableArray *taxDetailsArray=[supportDataModel getAmountTaxCodesForSelectedProjectID:identity
                                                                                         withExpenseType:typeName];
                
                
                for (int x=0; x<[taxDetailsArray count]-1; x++) {
                    NSMutableDictionary *mutableDict=[NSMutableDictionary dictionary];
                    if (taxDetailsArray != nil && [taxDetailsArray count] > 0) {
                        [mutableDict addEntriesFromDictionary:[taxDetailsArray objectAtIndex:x]];
                    }
                    
                    NSString *formulaString=[[taxDetailsArray objectAtIndex:x] objectForKey:@"formula"];
                    if (formulaString !=nil && ![formulaString isKindOfClass:[NSNull class]]) {
                        
                        NSString *localTax=[expenseTaxCodesLocalArray objectAtIndex:x];
                        if (localTax!=nil && ![localTax isKindOfClass:[NSNull class]]) {
                            [mutableDict setObject:localTax forKey:@"formula"];
                        }
                        
                    }
                    
                    [taxDetailsArray replaceObjectAtIndex:x withObject:mutableDict];
                }
                
                if (amountviewController == nil)
                    amountviewController=[[G2AmountViewController alloc]init];
                
                [amountviewController setAmountControllerDelegate:self];
                [amountviewController setRatedExpenseArray:expenseUnitLabelArray];
                
                if (![[taxDetailsArray objectAtIndex:[taxDetailsArray count]-1] isEqualToString:Flat_WithOut_Taxes]){
                    previousWasTaxExpense = YES;
                }else {
                    previousWasTaxExpense = NO;
                }
                
                if ([[taxDetailsArray objectAtIndex:[taxDetailsArray count]-1] isEqualToString:@"FlatWithOutTaxes"] || [[taxDetailsArray objectAtIndex:[taxDetailsArray count]-1] isEqualToString:@"FlatWithTaxes"])
                {
                    
                    [amountviewController setButtonTitle:baseCurrency];
                    if ([[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")]) {
                        NSMutableArray *fieldsArray= [NSMutableArray arrayWithObjects:baseCurrency,RPLocalizedString(@"Select", @""),nil];
                        for (int i=0; i<[taxDetailsArray count]; i++) {
                            [fieldsArray addObject:@"0.00"];
                        }
                        [amountviewController setFieldValuesArray:fieldsArray];
                        
                        
                    }else {
                        //[amountviewController setDoneTapped:YES];
                        RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                        //DE4881 Ullas M L
                        if (appdelegate.isUserPressedCancel)
                        {
                            
                            NSMutableArray *tmpArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousArrayForAdd"] ;
                            
                            for (int i=1; i<[tmpArray count]; i++) {
                                [amountValuesArray replaceObjectAtIndex:i withObject:[tmpArray objectAtIndex:i]];
                            }
                            
                            appdelegate.isUserPressedCancel=NO;
                        }
                        [amountValuesArray replaceObjectAtIndex:0 withObject:baseCurrency];
                        [amountviewController setFieldValuesArray:amountValuesArray];
                        [amountviewController setCurrecncyString:baseCurrency];
                        //NSString *amountString=[self replaceStringToCalculateAmount:[amountValuesArray objectAtIndex:0] replaceWith:@"" originalString:[amountValuesArray objectAtIndex:1]];
                        NSString *amountString = [amountValuesArray objectAtIndex:1];
                        if (amountString!=nil)
                            [amountviewController setAmountValueEntered:amountString];
                    }
                }
                else {
                    //DLog(@"RATED");
                    double hourlyRate=0;
                    [amountviewController setButtonTitle:baseCurrency];
                    
                    
                    hourlyRate=[expensesModel getHourlyRateFromDBWithProjectId:identity withTypeName:typeName];
                    self.rate=hourlyRate;//US4234
                    [amountviewController setRate:hourlyRate];
                    if ([[[firstSectionfieldsArray objectAtIndex: currentIndexPath.row]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")]) {
                        NSMutableArray *ratedDefaultValuesArray=[NSMutableArray array];//]WithObjects:@"Select",nil];
                        for (int i=0; i<[taxDetailsArray count]; i++) {
                            //[ratedDefaultValuesArray addObject:@"$0.0"];
                            if (baseCurrency!=nil && ![baseCurrency isKindOfClass:[NSNull class]])
                                [ratedDefaultValuesArray addObject:@"0.00"];
                        }
                        amountviewController.totalAmountValue.text=@"0.00";
                        [amountviewController setRatedBaseCurrency:baseCurrency];
                        if (hourlyRate !=0) {
                            self.defaultRateAndAmountsArray=[NSMutableArray arrayWithObjects:RPLocalizedString(@"Select", @""),[NSString stringWithFormat:@"%0.04lf",hourlyRate],@"0.00",nil];
                        }else {
                            self.defaultRateAndAmountsArray=[NSMutableArray arrayWithObjects:RPLocalizedString(@"Select", @""),@"0.00",@"0.00",nil];
                        }
                        
                        
                        [amountviewController setDefaultValuesArray:defaultRateAndAmountsArray];
                        [amountviewController setRatedValuesArray:ratedDefaultValuesArray];
                    }else {
                        
                        RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                        
                        //US4234 Ullas M L  && DE5801 Ullas M L
                        if (isComplexAmountCalucationScenario/*||appdelegate.isUserPressedCancel==YES*/) {
                            [amountviewController setIsComplexAmountComputation:YES];
                            isComplexAmountCalucationScenario=NO;
                            appdelegate.isUserPressedCancel=NO;
                            //[ratedValuesArray addObject:[totalCalucatedAmountArray objectAtIndex:0]];
                            [amountviewController setRatedBaseCurrency:baseCurrency];
                            [amountviewController setRatedValuesArray:ratedValuesArray];
                            [amountviewController setDefaultValuesArray:rateAndAmountsArray];
                            amountviewController.totalAmountValue.text=[totalCalucatedAmountArray objectAtIndex:0];
                            UILabel *tmpLabel=[[UILabel alloc]init];
                            tmpLabel.text=[totalCalucatedAmountArray objectAtIndex:0];
                            [amountviewController setTotalAmountValue:tmpLabel];
                            
                            
                            
                        }
                        
                        else{
                            [amountviewController setIsComplexAmountComputation:YES]; //US4234 Ullas M L
                            [amountviewController setRatedBaseCurrency:baseCurrency];
                            [amountviewController setRatedValuesArray:ratedCalculatedValuesArray];
                            [amountviewController setDefaultValuesArray:defaultRateAndAmountsArray];
                            amountviewController.totalAmountValue.text=amountValue;
                            UILabel *tmpLabel=[[UILabel alloc]init];
                            tmpLabel.text=amountValue;
                            [amountviewController setTotalAmountValue:tmpLabel];
                            
                        }
                        
                    }
                }
                [amountviewController setExpenseTaxesInfoArray:(NSMutableArray*)taxDetailsArray];
                RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                [delegate setCurrVisibleViewController: amountviewController];
                [amountviewController setIsFromAddExpense:YES];//DE4881 Ullas M L
                [amountviewController setIsFromEditExpense:NO];//DE4881 Ullas M L
                [self.navigationController pushViewController:amountviewController animated:YES];
               
                amountviewController = nil;
                //Handling Leaks
               
            }
			
			
			
            
            
            
        }
	}
	[self changeSegmentControlState:currentIndexPath];
	[self resetTableViewUsingSelectedIndex:nil];
	
}
-(NSString*)replaceStringToCalculateAmount:(NSString*)currentString replaceWith:(NSString*)replString originalString:(NSString*)string
{
	
	NSMutableString *requiredString=[NSMutableString stringWithFormat:@"%@",string];
	
	if ([requiredString rangeOfString:currentString].location == NSNotFound) {
		DLog(@" CURRENCY STRING NOT FOUND IN AMOUNT");
		return string;
	} else {
        if (![requiredString isKindOfClass:[NSNull class] ])
        {
            [requiredString replaceOccurrencesOfString:currentString withString:replString options:0 range:NSMakeRange(0, [requiredString length])];
        }
		
	}
	
	return requiredString;
}


-(void)imagePicker:(id)sender withEvent: (UIEvent *) event{
	[self hideKeyBoard];
	[pickerView1 setHidden:YES];
	[pickerViewC setHidden:YES];
	[datePicker setHidden:YES];
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	
	//[self releaseCache];// it should be on delete action
	if ([[[entryCell dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(@"Yes", @"Yes")]) {
		@autoreleasepool {
			RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        //DE4865//Juhi
        //if (receiptViewController==nil) {
        G2ReceiptsViewController *tempreceiptViewController=[[G2ReceiptsViewController alloc]init];
        self.receiptViewController=tempreceiptViewController;
       
        // }
        
			
			[receiptViewController setRecieptDelegate: self];
			[receiptViewController setInNewEntry: YES];
			
			if (self.b64String != nil) {
				NSData *decodedStringInAdd = [G2Util decodeBase64WithString: b64String];
				[receiptViewController setImageOnEditing: decodedStringInAdd];
				[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				decodedStringInAdd = nil;
			}
			[delegate setCurrVisibleViewController: receiptViewController];
			[self.navigationController pushViewController:receiptViewController animated:YES];
		}
	}else {
		UIActionSheet *receiptActionSheet;
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
		{
			receiptActionSheet=[[UIActionSheet alloc]initWithTitle: nil delegate:self
												 cancelButtonTitle: RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE)
											destructiveButtonTitle: nil
												 otherButtonTitles: RPLocalizedString(TAKE_PHOTO_BTN_TITLE, TAKE_PHOTO_BTN_TITLE) , RPLocalizedString (CHOOSE_FROM_LIB_BTN_TITLE, CHOOSE_FROM_LIB_BTN_TITLE),nil];
		} else {
           receiptActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:RPLocalizedString(CHOOSE_FROM_LIB_BTN_TITLE, CHOOSE_FROM_LIB_BTN_TITLE),nil];
		}
		
		[receiptActionSheet setDelegate:self];
		[receiptActionSheet setTag: RECEIPT_TAG_INDEX];
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
            receiptActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        }
        
			
        [receiptActionSheet setBackgroundColor:[UIColor blackColor]];
		[receiptActionSheet setFrame:CGRectMake(0,203, 320, 280)];
		[receiptActionSheet showInView:self.view];
		
		
		[self changeSegmentControlState: currentIndexPath];isDataPickerChosen=NO;//DE5011 ullas
        //		[self resetTableViewUsingSelectedIndex:currentIndexPath];
        [self resetTableViewUsingSelectedIndex:nil];
		
	}
}


#pragma mark ActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
		if (buttonIndex==0) {
			UIImagePickerController *imgCameraPicker;
			imgCameraPicker = [[UIImagePickerController alloc]init];
			imgCameraPicker.delegate=self;
			imgCameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
			[self presentViewController: imgCameraPicker animated:YES completion:nil];
			imgCameraPicker.allowsEditing= NO;
			
		}
		if (buttonIndex==1) {
			UIImagePickerController *imgPicker = [[UIImagePickerController alloc]init];
			imgPicker.delegate=self;
			imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentViewController:imgPicker animated:YES completion:nil];
			
		}
		if (buttonIndex==2) {
			[self performSelector:@selector(tableViewCellUntapped:) withObject:currentIndexPath afterDelay:0.5];
		}
	}else {
		if (buttonIndex==0) {
			UIImagePickerController *imgPicker = [[UIImagePickerController alloc]init];
			imgPicker.delegate=self;
			imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentViewController:imgPicker animated:YES completion:nil];
			
		}
		if (buttonIndex== 1) {
			[self performSelector:@selector(tableViewCellUntapped:) withObject:currentIndexPath afterDelay:0.5];
		}
	}
	
}

#pragma mark UIImagePickerController

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:nil];
    //DE4865//Juhi
    //	if (receiptViewController==nil) {
    G2ReceiptsViewController *tempreceiptViewController=[[G2ReceiptsViewController alloc]init];
    self.receiptViewController=tempreceiptViewController;
    
    //    }
	[receiptViewController setRecieptDelegate: self];
	[receiptViewController setInNewEntry: YES];
	UIImage	 *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	[receiptViewController setImage:image];
    //	[self dismissViewControllerAnimated:NO completion:nil];
	
	RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	[delegate setCurrVisibleViewController: receiptViewController];
	[self.navigationController pushViewController:receiptViewController animated:YES];
	[self resetTableViewUsingSelectedIndex:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:nil];
	[self resetTableViewUsingSelectedIndex:nil];
	[self performSelector:@selector(tableViewCellUntapped:) withObject:currentIndexPath afterDelay:0.5];
}

#pragma mark -
#pragma mark Picker Delegates methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		DLog(@"Error: Cell or cell data cannot be null");
		return 1;
	}
	if ([[entryCell dataObj] objectForKey: @"fieldName"] == RPLocalizedString(@"Project", @""))
    {
        if (hasClient) {
            return 2;
        }
        else
        {
            return 1;
        }
		
	}
	
	return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		DLog(@"Error: Cell or cell data cannot be null");
		return 320;
	}
	
	if ([[entryCell dataObj] objectForKey: @"fieldName"] ==  RPLocalizedString(@"Project", @"")) {
		if (component==0)
        {
			return 150;
		}
        else {
			return 150;
		}
	}
	else {
		return 320;
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(component == 0)
    {
        if ([[entryCell dataObj] objectForKey: @"fieldName"] ==  RPLocalizedString(@"Project", @""))
        {
            if (!hasClient) {
                if ([projectsArray count]==0)
                {
                    [pickerView setUserInteractionEnabled:FALSE];
                }
                else
                {
                    [pickerView setUserInteractionEnabled:TRUE];
                }
                return [projectsArray count];
            }
        }
        if ([dataSourceArray count]==0)
        {
            [pickerView setUserInteractionEnabled:FALSE];
        }
        else
        {
            [pickerView setUserInteractionEnabled:TRUE];
        }
		return [dataSourceArray count];
    }
	else if(component == 1)
    {
        if ([projectsArray count]==0)
        {
            [pickerView setUserInteractionEnabled:FALSE];
        }
        else
        {
            [pickerView setUserInteractionEnabled:TRUE];
        }
		return [projectsArray count];
    }
    
    [pickerView setUserInteractionEnabled:FALSE];
    
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	
	if(component == 0) {
		NSString *rowTitle = nil;
        
		if (currentIndexPath.section == G2EXPENSE_SECTION &&
			[[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Project", @"")] )
            
		{
            if (hasClient) {
				rowTitle = [[dataSourceArray objectAtIndex:row] objectForKey:@"name"] ;
			} else {
				rowTitle = [[projectsArray objectAtIndex:row] objectForKey:@"name"] ;
			}
		} else {
			rowTitle = [[dataSourceArray objectAtIndex:row] objectForKey:@"name"] ;
		}
        
		
        
        
        if (currentIndexPath.section == G2EXPENSE_SECTION &&
            [[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Currency", @"")] ) {
            return [[dataSourceArray objectAtIndex:row] objectForKey:@"symbol"];
        }
        return rowTitle;
	}
	else if(component == 1)
		return [[projectsArray objectAtIndex:row] objectForKey:@"name"] ;
	
	return nil;
    
	
}

-(BOOL)checkAvailabilityOfTypeForSelectedProject:(NSString*)_projectId
{
	typeAvailableForProject = NO;
	NSMutableDictionary *infoDict1 = [firstSectionfieldsArray objectAtIndex:2];
	
	
	NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:_projectId];
	
	[[firstSectionfieldsArray objectAtIndex:2] setObject:expenseTypeArr forKey:@"dataSourceArray"];
	
	if (currentIndexPath.section == 0) {
		NSDictionary *_rowData = [firstSectionfieldsArray objectAtIndex: currentIndexPath.row];
		G2ExpenseEntryCellView *entryCellCP = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:currentIndexPath.row inSection:currentIndexPath.section]];
		if ([[entryCellCP dataObj] objectForKey: @"fieldName"] ==  RPLocalizedString(@"Project", @"")) {
			clientsArray = [_rowData objectForKey: @"clientsArray"];
			dataSourceArray = [_rowData objectForKey: @"clientsArray"];
			//projectsArray = [_rowData objectForKey: @"projectsArray"];
		} else {
			dataSourceArray = [_rowData objectForKey:@"dataSourceArray"];
		}
		
		NSString *selectedType = [NSString stringWithFormat:@"%@",[infoDict1 objectForKey:@"defaultValue"]];
        // selectedType = [infoDict1 objectForKey:@"defaultValue"];
		if (selectedType !=nil && ![selectedType isKindOfClass:[NSNull class]]) {
			if ([selectedType isEqualToString:RPLocalizedString(@"Select", @"")]) {
				typeAvailableForProject = YES;
			}
			if ( expenseTypeArr!=nil && [expenseTypeArr count]>0) {
				NSUInteger i, count = [expenseTypeArr count];
				for (i = 0; i < count; i++) {
					NSDictionary * expenseTypeDict = [expenseTypeArr objectAtIndex:i];
					if([[expenseTypeDict objectForKey:@"name"] isEqualToString:selectedType]) {
						NSString	*selectedTypeDefault = [expenseTypeDict objectForKey:@"name"];
						NSString	*selectedDataIdentity = [expenseTypeDict objectForKey:@"identity"];
						NSNumber *selectedTypeIndex = [NSNumber numberWithUnsignedInteger:i];
						[[firstSectionfieldsArray objectAtIndex:2] setObject:selectedTypeDefault forKey:@"defaultValue"];
						[[firstSectionfieldsArray objectAtIndex:2] setObject:selectedTypeIndex forKey:@"selectedIndex"];
						[[firstSectionfieldsArray objectAtIndex:2] setObject:selectedTypeDefault forKey:@"selectedDataSource"];
						[[firstSectionfieldsArray objectAtIndex:2] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
						typeAvailableForProject = YES;
					}
				}
			}
			
		}
		
       
		
		return typeAvailableForProject;
	}
	return 0;
}

//DE2705//Juhi
//-(void)reloadCellAtIndex:(NSIndexPath*)indexPath
-(void)reloadCellAtIndex:(NSIndexPath*)indexPath andRow:(NSInteger)row
{
    
	G2ExpenseEntryCellView	*expenseEntryCellView = (G2ExpenseEntryCellView *) [self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[expenseEntryCellView setUserInteractionEnabled:YES];
	[expenseEntryCellView.switchMark setUserInteractionEnabled:YES];
    //DE2705//Juhi
    //	[[expenseEntryCellView dataObj] setObject:G2Check_ON_Image forKey:@"defaultValue"];
    //	[expenseEntryCellView.switchMark setOn:YES];
   
    if ([[[projectsArray objectAtIndex:row]objectForKey:@"billingStatus"] isEqualToString:@"AllowBoth"]||[[[projectsArray objectAtIndex:row]objectForKey:@"billingStatus"] isEqualToString:@"AllowBillable"]) {
        [expenseEntryCellView.switchMark setOn:YES];
        [[expenseEntryCellView dataObj] setObject:G2Check_ON_Image forKey:@"defaultValue"];
    }
    else{
        [[expenseEntryCellView dataObj] setObject:G2Check_OFF_Image forKey:@"defaultValue"];
        [expenseEntryCellView.switchMark setOn:NO];
    }
	expenseEntryCellView.fieldName.textColor=RepliconStandardBlackColor;
}

-(void)DisableCellAtIndexForCheckmark:(NSIndexPath*)indexPath
{
	G2ExpenseEntryCellView	*expenseEntryCellView = (G2ExpenseEntryCellView *) [self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[expenseEntryCellView.switchMark setOn:NO];
	[expenseEntryCellView setUserInteractionEnabled:NO];
	[expenseEntryCellView.switchMark setUserInteractionEnabled:NO];
	[[expenseEntryCellView dataObj] setObject:G2Check_OFF_Image forKey:@"defaultValue"];
	expenseEntryCellView.fieldName.textColor=RepliconStandardGrayColor;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
	
    
	@try {
		//Added the below condiito to avoid crash when Empty picker is shown. Need to fix this.
		if ([pickerView numberOfRowsInComponent: component] ==0) {
			return;
		}
		
		G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
		if(entryCell == nil || [entryCell dataObj] == nil)
		{
			DLog(@"Error: Cell or cell data cannot be null");
			return;
		}
		
		if(component == 0  )
        {
            //DE8142
			
            
            [[entryCell dataObj] setObject:[NSNumber numberWithInteger: row] forKey:@"selectedIndex"];
            
            NSString *_selectedName =[[dataSourceArray objectAtIndex:row]objectForKey:@"name"];
            
            //DE8142
            if ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Currency", @"")]&& currentIndexPath.section==G2EXPENSE_SECTION) {
                _selectedName = [[dataSourceArray objectAtIndex:row]objectForKey:@"symbol"];
                //baseCurrency = _selectedName;
                [self setBaseCurrency:_selectedName];
            }
            
            //TODO: ravi - This condition should be based on field type and not on field name
            if (![[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Amount", @"")]) {
                //[[entryCell dataObj] setObject:_selectedName forKey:@"defaultValue"];DE2991
                NSString *selectedDataIdentity = [[dataSourceArray objectAtIndex:row]objectForKey:@"identity"];
                [[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
                
                [self enableExpenseFieldAtIndex: currentIndexPath];
                if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]){//DE2991
                    [[entryCell dataObj] setObject:_selectedName forKey:@"defaultValue"];
                    [self updateFieldAtIndex: currentIndexPath WithSelectedValues:_selectedName];
                }
            }
            //DE8142
            if ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Amount", @"")]&& currentIndexPath.section==1) {
                NSString *selectedDataIdentity = [[dataSourceArray objectAtIndex:row]objectForKey:@"identity"];
                [[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
                
                [self enableExpenseFieldAtIndex: currentIndexPath];
                if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]){//DE2991
                    [[entryCell dataObj] setObject:_selectedName forKey:@"defaultValue"];
                    [self updateFieldAtIndex: currentIndexPath WithSelectedValues:_selectedName];
                }
            }
            
            //DE8142
            if ([[entryCell dataObj] objectForKey:@"fieldName"] ==  RPLocalizedString(@"Type", @"") && currentIndexPath.section==G2EXPENSE_SECTION ) {
                NSString *taxModeOfExpenseType = nil;
                [self updateFieldAtIndex:currentIndexPath WithSelectedValues:[[entryCell dataObj] objectForKey: @"defaultValue"]];
                NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow: (currentIndexPath.row+2) inSection: currentIndexPath.section];
                G2ExpenseEntryCellView *amountEntryCell =
                (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: amountIndexPath];
                if (permissionType != PermType_NonProjectSpecific ) {
                    G2ExpenseEntryCellView *previousEntryCell = nil;
                    NSIndexPath *previousIndexPath = nil;
                    if (currentIndexPath.row>0) {
                        previousIndexPath = [NSIndexPath indexPathForRow: (currentIndexPath.row-1) inSection: currentIndexPath.section];
                        previousEntryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: previousIndexPath];
                    }else {
                        previousIndexPath = [NSIndexPath indexPathForRow: (currentIndexPath.row) inSection: currentIndexPath.section];
                        previousEntryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: previousIndexPath];
                    }
                    
                    taxModeOfExpenseType = [supportDataModel getExpenseModeOfTypeForTaxesFromDB:[[previousEntryCell dataObj] objectForKey:@"projectIdentity"] withType:[[entryCell dataObj] objectForKey: @"defaultValue"] andColumnName:@"type"];
                    
                    
                    //updated by vijay for amount.
                    //[self changeAmountRowFieldType :taxModeOfExpenseType];
                    if (taxModeOfExpenseType == nil || ![taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes] ) {
                        if (isComplexAmountCalucationScenario) {
                            if (totalCalucatedAmount!=nil) {
                                [[amountEntryCell dataObj] setObject:totalCalucatedAmount forKey: @"defaultValue"];//US4234 ullas
                            }
                            
                        }
                        
                    }
                    if (previousWasTaxExpense == YES) {
                        if (isComplexAmountCalucationScenario) {
                            if (totalCalucatedAmount!=nil) {
                                [[amountEntryCell dataObj] setObject:totalCalucatedAmount forKey: @"defaultValue"];//US4234 ullas
                            }
                        }
                        
                    }
                }else {
                    taxExpenseChnged = YES;
                    taxModeOfExpenseType = [[dataSourceArray objectAtIndex:row]
                                            objectForKey:@"type"];
                    //[[amountEntryCell dataObj] setObject:@"Add" forKey: @"defaultValue"];
                }
                
                BOOL disableCurrencyField = NO;
                if ([taxModeOfExpenseType isEqualToString:Rated_With_Taxes] ||
                    [taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]) {
                    disableCurrencyField = YES;
                    //update currency to base currency for rated type.
                    [self updateCurrencyFieldToBasecurrency];
                }
                [self changeCurrencyFieldEnableStatus:disableCurrencyField];
                [self changeAmountRowFieldType:taxModeOfExpenseType];
                [self enableExpenseFieldAtIndex: amountIndexPath];
                [self updateDependentFields:[amountEntryCell indexPath] WithSelectedValues:[[amountEntryCell dataObj] objectForKey: @"defaultValue"]];
                amountValue=@"";//which is used for every Type change....
            }
			
            selectedRowForClients=row;
		}
       
	}
	@finally {
		
		
	}
	
}

- (void)didSelectRowFromDataList:(NSInteger)row inComponent:(NSInteger)componentIndex{
	
    
	@try {
		
		
		NSMutableDictionary *projectDict =  [[self firstSectionfieldsArray] objectAtIndex:1];
        NSMutableDictionary *clientDict =  [[self firstSectionfieldsArray] objectAtIndex:0];
        G2ExpenseEntryCellView *expenseClientEntryCellView =(G2ExpenseEntryCellView *)[[self tnewExpenseEntryTable] cellForRowAtIndexPath:
                                                                                   [NSIndexPath indexPathForRow:0 inSection:0]];
        G2ExpenseEntryCellView *expenseProjectEntryCellView =(G2ExpenseEntryCellView *)[[self tnewExpenseEntryTable] cellForRowAtIndexPath:
                                                                                    [NSIndexPath indexPathForRow:1 inSection:0]];
		
        //DE8142
        if ([[expenseProjectEntryCellView dataObj] objectForKey:@"fieldName"] == RPLocalizedString(@"Project", @"") && currentIndexPath.section==G2EXPENSE_SECTION) {
            
            
            NSString *clientIdentity =[clientDict objectForKey:@"clientIdentity"];
            NSString *_selectedClientName=[clientDict objectForKey:@"clientName"];
            
            NSString *_selectedProjectName=[projectDict objectForKey:@"projectName"];
            
            [[expenseClientEntryCellView dataObj] setObject:clientIdentity forKey:@"clientIdentity"];
            [[expenseProjectEntryCellView dataObj] setObject:[projectDict objectForKey:@"projectIdentity"] forKey:@"projectIdentity"];
            
            [[expenseClientEntryCellView dataObj] setObject: [NSNumber numberWithInteger: row] forKey:@"selectedClientIndex"];
            [[expenseProjectEntryCellView dataObj] setObject: [NSNumber numberWithInt:0] forKey:@"selectedProjectIndex"];
            [[expenseClientEntryCellView dataObj] setObject: _selectedClientName forKey:@"clientName"];
            [[expenseProjectEntryCellView dataObj] setObject: _selectedProjectName forKey:@"projectName"];
            [[expenseProjectEntryCellView dataObj] setObject: projectsArray forKey:@"projectsArray"];
            [[expenseClientEntryCellView dataObj] setObject: [clientDict objectForKey:@"clientsArr"] forKey:@"clientsArray"];
            
            NSString *existedTypeName = [[NSString alloc] initWithFormat:@"%@",[[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"defaultValue"]];
            
            NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:[projectDict objectForKey:@"projectIdentity"]];
            
            if ([expenseTypeArr count]>0)
            {
                [[firstSectionfieldsArray objectAtIndex:2] setObject:expenseTypeArr forKey:@"dataSourceArray"];
            }
            
            
            //DE7578 Ullas M L
            
            NSMutableDictionary *infoDict1 = [firstSectionfieldsArray objectAtIndex:2];
            NSString *defaultExpenseType=nil;
            if ([[infoDict1 objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] && [(NSMutableArray *)[infoDict1 objectForKey:@"dataSourceArray"]count]>0)
            {
                defaultExpenseType=[[[infoDict1 objectForKey:@"dataSourceArray"] objectAtIndex:0] objectForKey:@"name"];
                
            }
            
            
            if ( expenseTypeArr!=nil && [expenseTypeArr count]>0)
            {
                NSUInteger i, count = [expenseTypeArr count];
                for (i = 0; i < count; i++)
                {
                    
                    NSDictionary * expenseTypeDict = [expenseTypeArr objectAtIndex:i];
                    if([[expenseTypeDict objectForKey:@"name"] isEqualToString:defaultExpenseType])
                    {
                        NSString	*selectedDataIdentity = [expenseTypeDict objectForKey:@"identity"];
                        [[firstSectionfieldsArray objectAtIndex:2] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
                    }
                    
                    
                }
            }
            
            NSMutableDictionary *infoDict2 = [firstSectionfieldsArray objectAtIndex:4];
            
            
            
            
            if([_selectedProjectName isEqualToString:RPLocalizedString(NONE_STRING, @"")])
            {
                [[expenseProjectEntryCellView dataObj] setObject:[NSString stringWithFormat:@"%@",_selectedProjectName] forKey:@"defaultValue"];
                [self updateFieldAtIndex: currentIndexPath WithSelectedValues: [[expenseProjectEntryCellView dataObj] objectForKey: @"defaultValue"]];
                
            }else {
                [[expenseProjectEntryCellView dataObj] setObject:[NSString stringWithFormat:@"%@",_selectedProjectName] forKey:@"defaultValue"];
                [self updateFieldAtIndex:currentIndexPath WithSelectedValues:[[expenseProjectEntryCellView dataObj]objectForKey:@"defaultValue"]];
            }
            
            if (![[infoDict1 objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")]) {
                BOOL validExpenseType = [self checkAvailabilityOfTypeForSelectedProject:[projectDict objectForKey:@"projectIdentity"]];
                if (validExpenseType == NO) {
                    [infoDict1 setObject:[NSNumber numberWithInt: 0] forKey:@"selectedIndex"];
                    id amountCell = [self getCellForIndexPath:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
                    [self updateFieldAtIndex: [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues: RPLocalizedString(@"Add", @"")];
                    [amountCell grayedOutRequiredCell];//DE6130//Juhi
                    //[Util errorAlert:nil errorMessage:ExpenseType_UnAvailable];
                    //return;
                }
                
                NSString *taxModeOfExpenseType = [supportDataModel getExpenseModeOfTypeForTaxesFromDB:[projectDict objectForKey:@"projectIdentity"] withType:[infoDict1 objectForKey: @"defaultValue"] andColumnName:@"type"];
                //if (taxModeOfExpenseType == nil || (![taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes] && validExpenseType == NO)) {
                if (taxModeOfExpenseType == nil || validExpenseType == NO) {
                    [infoDict2 setObject:RPLocalizedString(@"Add", @"") forKey: @"defaultValue"];
                }
                if (previousWasTaxExpense == YES&& validExpenseType == NO) {
                    [infoDict2 setObject:RPLocalizedString(@"Add", @"") forKey: @"defaultValue"];
                }
                BOOL disableCurrencyField = NO;
                if ([taxModeOfExpenseType isEqualToString:Rated_With_Taxes] ||
                    [taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]) {
                    disableCurrencyField = YES;
                    //update currency to base currency for rated type.
                    [self updateCurrencyFieldToBasecurrency];
                }
                [self changeCurrencyFieldEnableStatus:disableCurrencyField];
                
                NSString *typeNameValid = [infoDict1 objectForKey:@"defaultValue"];
                
                if (![existedTypeName isEqualToString:typeNameValid]){
                    [self changeAmountRowFieldType:taxModeOfExpenseType];
                    taxExpenseChnged = YES;
                }else {
                    taxExpenseChnged = NO;
                }
                
                [self updateDependentFields:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION] WithSelectedValues:[infoDict1 objectForKey:@"defaultValue"]];
                [self updateDependentFields:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues:[infoDict2 objectForKey:@"defaultValue"]];
            }
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow: (currentIndexPath.row+1) inSection: currentIndexPath.section];
            self.fromReloaOfDataView=NO;
            [self enableExpenseFieldAtIndex: nextIndexPath];
            NSIndexPath *billClientIndex = [NSIndexPath indexPathForRow:2 inSection:1];
            if ([_selectedClientName isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
                
                if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
                {
                    
                    if ([[self getBillClientInfo] intValue] == 1){
                        [self DisableCellAtIndexForCheckmark:billClientIndex];
                    }
                }
            }else {
                if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
                    if ([[self getBillClientInfo] intValue] == 1){
                        //DE2705//Juhi
                        //							[self reloadCellAtIndex:billClientIndex];
                        [self reloadCellAtIndex:billClientIndex andRow:0];
                    }
            }
            
            
           
            
            
            
            [self didSelectionRowFromDataListSecond:row];
            
        }
        
        selectedRowForClients=row;
		
        
    }
	@finally {
		
		
	}
	
}

//HANDLING OF PROJECTS WITH NO CLIENTS
-(void)didSelectionRowFromDataListSecond:(NSInteger)row
{
    
    NSMutableDictionary *projecttDict =  [[self firstSectionfieldsArray] objectAtIndex:1];
    NSMutableDictionary *clientDict =  [[self firstSectionfieldsArray] objectAtIndex:0];
    G2ExpenseEntryCellView *expenseClientEntryCellView =(G2ExpenseEntryCellView *)[[self tnewExpenseEntryTable] cellForRowAtIndexPath:
                                                                               [NSIndexPath indexPathForRow:0 inSection:0]];
    G2ExpenseEntryCellView *expenseProjectEntryCellView =(G2ExpenseEntryCellView *)[[self tnewExpenseEntryTable] cellForRowAtIndexPath:
                                                                                [NSIndexPath indexPathForRow:1 inSection:0]];
    
    NSString *_selectedProjectName=[projecttDict objectForKey:@"projectName"];
    [[expenseProjectEntryCellView dataObj] setObject: _selectedProjectName forKey:@"projectName"];
    
    if ([[expenseClientEntryCellView dataObj] objectForKey: @"clientName"] == nil || [[[expenseClientEntryCellView dataObj] objectForKey: @"clientName"]  isEqualToString: RPLocalizedString(NONE_STRING, @"")]) {
        [[expenseClientEntryCellView dataObj] setObject: [clientDict objectForKey:@"clientName"] forKey: @"clientName"];
    }
    NSString *_selectedClientName = [[expenseClientEntryCellView dataObj] objectForKey: @"clientName"];
    
    [[expenseProjectEntryCellView dataObj] setObject:[projecttDict objectForKey:@"selectedProjectIndex"] forKey:@"selectedProjectIndex"];
    [[expenseProjectEntryCellView dataObj] setObject:[projecttDict objectForKey:@"projectIdentity"] forKey:@"projectIdentity"];
    
    NSString *existedTypeName = [[NSString alloc] initWithFormat:@"%@",[[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"defaultValue"]];
    
    NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:[projecttDict objectForKey:@"projectIdentity"]];
    [[firstSectionfieldsArray objectAtIndex:2] setObject:expenseTypeArr forKey:@"dataSourceArray"];
    
    if([_selectedProjectName isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        [[expenseProjectEntryCellView dataObj] setObject:[NSString stringWithFormat:@"%@",_selectedProjectName] forKey:@"defaultValue"];
        [self updateFieldAtIndex: currentIndexPath WithSelectedValues: [[expenseProjectEntryCellView dataObj] objectForKey: @"defaultValue"]];
        
    }else {
        [[expenseProjectEntryCellView dataObj] setObject: [NSString stringWithFormat: @"%@",
                                                           [[expenseProjectEntryCellView dataObj] objectForKey:@"projectName"]] forKey:@"defaultValue"];
        
        [self updateFieldAtIndex: currentIndexPath WithSelectedValues: [[expenseProjectEntryCellView dataObj] objectForKey: @"defaultValue"]];
    }
    
    NSMutableDictionary *infoDict1 = [firstSectionfieldsArray objectAtIndex:2];
    NSMutableDictionary *infoDict2 = [firstSectionfieldsArray objectAtIndex:4];
    BOOL validExpenseType = [self checkAvailabilityOfTypeForSelectedProject:[projecttDict objectForKey:@"projectIdentity"]];
    
    if (![[infoDict1 objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")]) {
        if (validExpenseType == NO) {
            [infoDict1 setObject:[NSNumber numberWithInt: 0] forKey:@"selectedIndex"];
            id amountCell = [self getCellForIndexPath:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
            [self updateFieldAtIndex: [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues: RPLocalizedString(@"Add", @"")];
            [amountCell grayedOutRequiredCell];//DE6130//Juhi
            //[Util errorAlert:nil errorMessage:ExpenseType_UnAvailable];
            //return;
        }
        //DE7314
        if (validExpenseType)
        {    NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
            if (permissionType == PermType_NonProjectSpecific) {
                amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
            }
            [self enableExpenseFieldAtIndex: amountIndexPath];
        }
        
        NSString *taxModeOfExpenseType = [supportDataModel getExpenseModeOfTypeForTaxesFromDB:[projecttDict objectForKey:@"projectIdentity"] withType:[infoDict1 objectForKey: @"defaultValue"] andColumnName:@"type"];
        //if (taxModeOfExpenseType == nil || ![taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes] && validExpenseType == NO) {
        if (taxModeOfExpenseType == nil || validExpenseType == NO) {
            [infoDict2 setObject:RPLocalizedString(@"Add", @"") forKey: @"defaultValue"];
        }
        if (previousWasTaxExpense == YES && validExpenseType == NO) {
            [infoDict2 setObject:RPLocalizedString(@"Add", @"") forKey: @"defaultValue"];
        }
        BOOL disableCurrencyField = NO;
        if ([taxModeOfExpenseType isEqualToString:Rated_With_Taxes] ||
            [taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]) {
            disableCurrencyField = YES;
            //update currency to base currency for rated type.
            [self updateCurrencyFieldToBasecurrency];
        }
        NSString *typeNameValid = [infoDict1 objectForKey:@"defaultValue"];
        [self changeCurrencyFieldEnableStatus:disableCurrencyField];
        if (![existedTypeName isEqualToString:typeNameValid]){
            [self changeAmountRowFieldType:taxModeOfExpenseType];
            taxExpenseChnged = YES;
        }else {
            taxExpenseChnged = NO;
        }
        
        [self updateDependentFields:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION] WithSelectedValues:[infoDict1 objectForKey:@"defaultValue"]];
        [self updateDependentFields:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues:[infoDict2 objectForKey:@"defaultValue"]];
    }
    //DE6922 Ullas M L
    if ([[infoDict1 objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] && [(NSMutableArray *)[infoDict1 objectForKey:@"dataSourceArray"] count]>0)
    {
        
        NSString *defaultTaxExpenseTypeName=[[[infoDict1 objectForKey:@"dataSourceArray"] objectAtIndex:0] objectForKey:@"name"];
        
        
        NSString *taxModeOfExpenseType = [supportDataModel getExpenseModeOfTypeForTaxesFromDB:[projecttDict objectForKey:@"projectIdentity"] withType:defaultTaxExpenseTypeName andColumnName:@"type"];
        
        
        
        NSString *projectdId = nil;
        if (firstSectionfieldsArray != nil && [firstSectionfieldsArray count] >0) {
            if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific) {
                projectdId = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"projectIdentity"];
                
            }else {
                projectdId = @"null";
            }
            
        }
        
        NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:projectdId];//DE6922//Juhi
        
        if ( expenseTypeArr!=nil && [expenseTypeArr count]>0) {
            NSUInteger i, count = [expenseTypeArr count];
            for (i = 0; i < count; i++) {
                NSDictionary * expenseTypeDict = [expenseTypeArr objectAtIndex:i];
                if([[expenseTypeDict objectForKey:@"name"] isEqualToString:defaultTaxExpenseTypeName]) {
                    //DE6922//Juhi
                    NSString	*selectedDataIdentity = [expenseTypeDict objectForKey:@"identity"];
                    NSNumber *selectedTypeIndex = [NSNumber numberWithUnsignedInteger:i];
                    [[firstSectionfieldsArray objectAtIndex:2] setObject:selectedTypeIndex forKey:@"selectedIndex"];
                    [[firstSectionfieldsArray objectAtIndex:2] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
                    
                }
            }
        }
        
        
        
        if (taxModeOfExpenseType == nil || validExpenseType == NO) {
            [infoDict2 setObject:RPLocalizedString(@"Add", @"") forKey: @"defaultValue"];
        }
        if (previousWasTaxExpense == YES && validExpenseType == NO) {
            [infoDict2 setObject:RPLocalizedString(@"Add", @"") forKey: @"defaultValue"];
        }
        BOOL disableCurrencyField = NO;
        if ([taxModeOfExpenseType isEqualToString:Rated_With_Taxes] ||
            [taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]) {
            disableCurrencyField = YES;
            [self updateCurrencyFieldToBasecurrency];
        }
        NSString *typeNameValid = [infoDict1 objectForKey:@"defaultValue"];
        [self changeCurrencyFieldEnableStatus:disableCurrencyField];
        
        
        
        if (![existedTypeName isEqualToString:typeNameValid] && [existedTypeName isEqualToString:RPLocalizedString(@"Select", @"")]){
            [self changeAmountRowFieldType:taxModeOfExpenseType];
            taxExpenseChnged = YES;
        }else {
            
            taxExpenseChnged = NO;
        }
        
        //DE6922//Juhi
        if (![[infoDict2 objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(@"Add", @"")]) {
            [self updateDependentFields:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues:[infoDict2 objectForKey:@"defaultValue"]];
            NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
            [self enableExpenseFieldAtIndex: nextIndexPath];
        }
        
        
        
    }
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow: (currentIndexPath.row+1) inSection: currentIndexPath.section];
    [self enableExpenseFieldAtIndex: nextIndexPath];
    
    NSIndexPath *billClientIndex = [NSIndexPath indexPathForRow:2 inSection:1];
    if ([_selectedClientName isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
        if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
        {
            
            if ([[self getBillClientInfo] intValue] == 1){
                [self DisableCellAtIndexForCheckmark:billClientIndex];
            }
        }
    }else {
        if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
            if ([[self getBillClientInfo] intValue] == 1){
                
                //DE2705//Juhi
                //							[self reloadCellAtIndex:billClientIndex];
                [self reloadCellAtIndex:billClientIndex andRow:row];
            }
    }

    
    
    
    
}

-(void)configurePicker{
	UIPickerView *temppickerView1 = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerView1=temppickerView1;
    
	CGSize pickerSize = [pickerView1 sizeThatFits:CGSizeZero];
	[pickerView1 setFrame: CGRectMake(0.0,
									  45.0 ,
									  pickerSize.width,
									  pickerSize.height)];
	
	pickerView1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	pickerView1.delegate = self;
    pickerView1.dataSource = self;
	pickerView1.showsSelectionIndicator = YES;
	pickerView1.hidden = YES;
	
	if (datePicker == nil) {
		UIDatePicker *tempdatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0,
                                                                                      45.0 ,
                                                                                      pickerSize.width,
                                                                                      pickerSize.height)];
        self.datePicker=tempdatePicker;
       
	}
	datePicker.datePickerMode = UIDatePickerModeDate;
	datePicker.hidden = YES;
	datePicker.date = [NSDate date];
	
	
	UISegmentedControl *temptoolbarSegmentControl = [[UISegmentedControl alloc] initWithItems:
                                                     [NSArray arrayWithObjects:RPLocalizedString( @"Previous",@""),RPLocalizedString(@"Next",@""),nil]];
    self.toolbarSegmentControl=temptoolbarSegmentControl;
   
	
	[toolbarSegmentControl setFrame:CGRectMake(10.0,
											   8.0,
											   140.0,
											   31.0)];
//	[toolbarSegmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:0];
	[toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:1];
	[toolbarSegmentControl addTarget:self
							  action:@selector(segmentClick:)
					forControlEvents:UIControlEventValueChanged];
	[toolbarSegmentControl setMomentary:YES];
		
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				target:self
																				action:@selector(pickerDone:)];
	
	
	UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				 target:nil
																				 action:nil];
	
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
   
	G2CustomPickerView *temppickerViewC = [[G2CustomPickerView alloc] initWithFrame:CGRectMake(0.0,
                                                                                           screenRect.size.height-320,
                                                                                           pickerSize.width,
                                                                                           pickerSize.height + 45.0)];
    
    
    self.pickerViewC=temppickerViewC;
   
	//[pickerViewC setBackgroundColor:[UIColor blueColor]];
	[pickerViewC setBackgroundColor:[UIColor clearColor]];
	NSArray *toolArray = [NSArray arrayWithObjects:
						  spaceButton,
						  doneButton,
						  nil];
	
	//Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        doneButton.tintColor=RepliconStandardWhiteColor;
        [toolbarSegmentControl setTintColor:RepliconStandardWhiteColor];
        
    }
	else{
        [toolbarSegmentControl setTintColor:[UIColor clearColor]];
        
    }

	[[pickerViewC toolbar] setItems:toolArray];
	
	[pickerViewC setHidden:YES];
	[pickerViewC addSubview:pickerView1];
	[pickerViewC addSubview:toolbarSegmentControl];
	
	[self.view addSubview:pickerViewC];
	
}

-(void)updateFieldsWithDefaultValues
{
	
	if(numberUdfText != nil)
		[numberUdfText resignFirstResponder];
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		DLog(@"Error: Cell or cell data cannot be null");
		return;
	}
	//[entryCell setCellViewState: NO];
    //DE8142
	if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString: RPLocalizedString(@"Project", @"")]&& currentIndexPath.section==G2EXPENSE_SECTION) {
		if ([[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] ||
			[[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(NONE_STRING, @"")])
		{
			[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
			
			NSString *temp = @"";
			temp = [NSString stringWithFormat: @"%@",
					[[projectsArray objectAtIndex: 0]objectForKey:@"name"]];
			
			
			if (![temp isEqualToString:@""] &&![temp isKindOfClass:[NSNull class]] && ![temp isEqualToString:@"(null)"]) {
				[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
				[[entryCell dataObj] setObject:temp forKey:@"defaultValue"];
			}
		}
		
		if (![self checkAvailabilityOfTypeForSelectedProject:[[entryCell dataObj]objectForKey:@"projectIdentity"]]) {
			[self tableViewCellUntapped:currentIndexPath];
			NSIndexPath *amountIndex = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
			id amountCell = [self getCellForIndexPath:amountIndex];
			[self updateFieldAtIndex:amountIndex WithSelectedValues:RPLocalizedString(@"Add", @"")];
			[amountCell grayedOutRequiredCell];
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(ExpenseType_UnAvailable,"")];
            [self pickerDone:nil];
			return;
		}
        
		
		
		if (dataSourceArray!=nil && [dataSourceArray count]>0)
        {
            if ([[dataSourceArray objectAtIndex:currentIndexPath.row]objectForKey:@"name"]!=nil
				&& [[[dataSourceArray objectAtIndex:currentIndexPath.row]
					 objectForKey:@"name"] isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
				{
					
					if ([[self getBillClientInfo] intValue] == 1){
					}
				}
			}else {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
                {
                    if ([[self getBillClientInfo] intValue] == 1){
					}
                }
                
			}
        }
        
		
		
		
	}
	else if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]){
		if(currentIndexPath.section == 0 && [[[entryCell dataObj]objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")]){
			if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific){
				G2ExpenseEntryCellView *entryCellCP = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:1 inSection:currentIndexPath.section]];
				if (![self checkAvailabilityOfTypeForSelectedProject:[[entryCellCP dataObj]objectForKey:@"projectIdentity"]]) {
					[[entryCell dataObj]  setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
					//	if (previousWasTaxExpense == YES) {
					[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row+1] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
					[self updateFieldAtIndex: [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues: RPLocalizedString(@"Add", @"")];
					
				}
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
			}else {
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
			}
			
		}
		
		NSNumber *selectedRowIndex = [[entryCell dataObj] objectForKey: @"selectedIndex"];
		NSString *temp = @"";
		//added below condition to check if picker data is empty and handle gracefully.
		//TODO: Need to fix.
		if (dataSourceArray != nil && [dataSourceArray count] > 0) {
			temp = [[dataSourceArray objectAtIndex: [selectedRowIndex intValue]]objectForKey:@"name"];
            //DE8142
			if ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Currency", @"")]&& currentIndexPath.section==G2EXPENSE_SECTION) {
				temp = [[dataSourceArray objectAtIndex: [selectedRowIndex intValue]]objectForKey:@"symbol"];
				[self setBaseCurrency:temp];
			}
			if ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")] &&[selectedRowIndex intValue] == 0) {
				//get ExpenseType mode for firstexpense and change the type of amount  field.
				NSMutableArray *expenseTypeArr = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
				if ([expenseTypeArr count] > 0) {
					NSString *firstExpenseTypeMode = [[expenseTypeArr objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"type"];
					[self changeAmountRowFieldType:firstExpenseTypeMode];
					
					BOOL disableCurrencyField = NO;
					if ([firstExpenseTypeMode isEqualToString:Rated_With_Taxes] ||
						[firstExpenseTypeMode isEqualToString:Rated_WithOut_Taxes]) {
						disableCurrencyField = YES;
						//update currency to base currency for rated type.
						[self updateCurrencyFieldToBasecurrency];
					}
					[self changeCurrencyFieldEnableStatus:disableCurrencyField];
				}
			}
			[[entryCell dataObj] setObject: temp forKey: @"defaultValue"];
			NSString *selectedDataIdentity = [[dataSourceArray objectAtIndex:[selectedRowIndex intValue]]objectForKey:@"identity"];
			[[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
		}
		if (![temp isEqualToString:@""])
			[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
	}
	[self tableViewCellUntapped:currentIndexPath];
	
}
- (void)pickerDone:(UIBarButtonItem *)button{
	isDataPickerChosen=NO;//DE5011 ullas
    
    if (button)
    {
        [self updateFieldsWithDefaultValues];
    }
	
	
	[pickerViewC setHidden:YES];
	
	[self resetTableViewUsingSelectedIndex:nil];
}

-(void)moveTableToTop:(int)y
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	if (y<[secondSectionfieldsArray count]/2) {
		//[newExpenseEntryTable setFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height)];
		[tnewExpenseEntryTable setFrame:CGRectMake(0, y*(-80), self.view.frame.size.width, self.view.frame.size.height)];
	}else {
		//[newExpenseEntryTable setFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height)];
		[tnewExpenseEntryTable setFrame:CGRectMake(0, y*(-40), self.view.frame.size.width, self.view.frame.size.height)];
		
	}
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark Picker Utility methods


- (void)segmentClick:(UISegmentedControl *)segmentControl{
	
	if (segmentControl.selectedSegmentIndex == 0) {
		[self pickerPrevious:segmentControl];
		
		[toolbarSegmentControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
	}
	if (segmentControl.selectedSegmentIndex == 1) {
		[self pickerNext:segmentControl];
		[toolbarSegmentControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
	}
	
}

- (void)pickerPrevious:(id )button{
	
	if(numberUdfText != nil)
		[numberUdfText resignFirstResponder];
	
	
	
	//DLog(@"index Pathhhhh %@",currentIndexPath);
	//[self moveTableToTop:currentIndexPath.row];
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		//DLog(@"Previous=>Error: Cell or cell data cannot be null");
		return;
	}
	//[entryCell setCellViewState: NO];
    //DE8142
	if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString: RPLocalizedString(@"Project", @"")]&& currentIndexPath.section==G2EXPENSE_SECTION) {
		if ([[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] ||
			[[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(NONE_STRING, @"")])
		{
			[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
			
			NSString *temp = @"";
			temp = [NSString stringWithFormat: @"%@",
					[[projectsArray objectAtIndex: 0]objectForKey:@"name"]];
			
			
			if (![temp isEqualToString:@"" ] &&![temp isKindOfClass:[NSNull class]] && ![temp isEqualToString:@"(null)"]) {
				[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
				[[entryCell dataObj] setObject:temp forKey:@"defaultValue"];
			}
		}
	}
	else if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]){
		
		if(currentIndexPath.section == 0 && [[[entryCell dataObj]objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")]){
			if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific){
				G2ExpenseEntryCellView *entryCellCP = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:1 inSection:currentIndexPath.section]];
				if (![self checkAvailabilityOfTypeForSelectedProject:[[entryCellCP dataObj]objectForKey:@"projectIdentity"]]) {
					[[entryCell dataObj]  setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
					//	if (previousWasTaxExpense == YES) {
					[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row+2] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
					[self updateFieldAtIndex: [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues: RPLocalizedString(@"Add", @"")];
					
				}
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
			}else {
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
			}
			
		}
		
		NSNumber *selectedRowIndex = [[entryCell dataObj] objectForKey: @"selectedIndex"];
		NSString *temp = @"";
		//added below condition to check if picker data is empty and handle gracefully.
		//TODO: Need to fix.
		if (dataSourceArray != nil && [dataSourceArray count] > 0) {
			temp = [[dataSourceArray objectAtIndex: [selectedRowIndex intValue]]objectForKey:@"name"];
            //DE8142
			if ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Currency", @"")] && currentIndexPath.section==0) {
				temp = [[dataSourceArray objectAtIndex: [selectedRowIndex intValue]]objectForKey:@"symbol"];
				[self setBaseCurrency:temp];
			}
			//DE8142
			if (([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")] && currentIndexPath.section==0 )&&[selectedRowIndex intValue] == 0) {
				//get ExpenseType mode for firstexpense and change the type of amount  field.
				NSMutableArray *expenseTypeArr = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
				if ([expenseTypeArr count] > 0) {
					NSString *firstExpenseTypeMode = [[expenseTypeArr objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"type"];
					[self changeAmountRowFieldType:firstExpenseTypeMode];
					BOOL disableCurrencyField = NO;
					if ([firstExpenseTypeMode isEqualToString:Rated_With_Taxes] ||
						[firstExpenseTypeMode isEqualToString:Rated_WithOut_Taxes]) {
						disableCurrencyField = YES;
						//update currency to basecurrency for rated type
						[self updateCurrencyFieldToBasecurrency];
					}
					[self changeCurrencyFieldEnableStatus:disableCurrencyField];
				}
			}
			
			[[entryCell dataObj] setObject: temp forKey: @"defaultValue"];
			NSString *selectedDataIdentity = [[dataSourceArray objectAtIndex:[selectedRowIndex intValue]]objectForKey:@"identity"];
			[[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
		}
		if (![temp isEqualToString:@""])
			[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
	}
	
	DLog(@"CURRENT INDEX PATH %@",currentIndexPath);
	[self tableViewCellUntapped:currentIndexPath];
	/*
	 if (currentInd==nil) {
	 currentIndexPath = [NSIndexPath indexPathForRow:(currentIndexPath.row-1) inSection: currentIndexPath.section];
	 
	 }
	 */
	NSIndexPath *previousIndexPath = [self getPreviousEnabledFieldFromCurrentIndex:currentIndexPath];
	if (previousIndexPath != nil) {
		self.currentIndexPath = previousIndexPath;
		//[self handleButtonClicks: currentIndexPath];
		[self tableCellTappedAtIndex:currentIndexPath];
	}
	else {
		//[self changeSegmentControlState:currentIndexPath];
		[pickerViewC setHidden:YES];isDataPickerChosen=NO;//DE5011 ullas
		[self resetTableViewUsingSelectedIndex:nil];
	}
	
	
	//[self handleButtonClicks: currentIndexPath];
}



-(void)resetTableViewUsingSelectedIndex:(NSIndexPath*)selectedIndex
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.0];
	if (selectedIndex!=nil) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
		if (selectedIndex.section == 0) {
             //JUHI
            
            
			[self.mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                     screenRect.size.height-320)];
            
            float height=0.0;
            height=height+([firstSectionfieldsArray count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT);
            height=height+100.0;
            
            
            self.mainScrollView.contentSize=CGSizeMake(self.view.frame.size.width,height);
            
            if (selectedIndex.row==0) {
                [self.mainScrollView setContentOffset:CGPointMake(0.0,selectedIndex.row*ROW_HEIGHT) animated:YES];
            }
            else
            {
                [self.mainScrollView setContentOffset:CGPointMake(0.0,(selectedIndex.row*ROW_HEIGHT)-ROW_HEIGHT) animated:YES];
            }
            
            
            
	    }
        else if(selectedIndex.section == 1)
        {
            //JUHI
            [self.mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                     screenRect.size.height-320)];
            
            
            float height=0.0;
            height=height+([firstSectionfieldsArray count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT);
            
            
            height=height+100.0;
            
            
            
            
            
            self.mainScrollView.contentSize=CGSizeMake(self.view.frame.size.width,height);
            
            [self.mainScrollView setContentOffset:CGPointMake(0.0,(([firstSectionfieldsArray count]*ROW_HEIGHT)+(selectedIndex.row*ROW_HEIGHT))) animated:YES];
        }
        
        
        
        
		
		
	}else if (selectedIndex==nil) {
        //DE5011 ullas
        if (!isDataPickerChosen) {
            [self.mainScrollView setFrame:CGRectMake(0,0.0,self.view.frame.size.width,self.view.frame.size.height)];
            isDataPickerChosen=NO;
        }
		
        
        CGRect rect=self.tnewExpenseEntryTable.frame;
        rect.origin.y=5.0;
        self.tnewExpenseEntryTable.frame=rect;
        CGSize size=self.mainScrollView.contentSize;
        //int totalHeight=0;
        int scrollHeight=0;
        //countAddExpenseUDF=countAddExpenseUDF-1;
        //        if (countAddExpenseUDF==0)
        //        {
        //           // countAddExpenseUDF=1;
        //            totalHeight=80;
        //            if ([secondSectionfieldsArray count]<=5)
        //            {
        //                scrollHeight=40;
        //            }
        //            else
        //                scrollHeight=85;
        //
        //        }
        //        else{
        //            totalHeight= (countAddExpenseUDF*48.0)+55;
        //            if (countAddExpenseUDF>=4)
        //            {
        //                scrollHeight=5+(75-(15*countAddExpenseUDF));
        //            }
        //            else{
        //                if (countAddExpenseUDF<=3)
        //                {
        //                    scrollHeight=75-(10*countAddExpenseUDF);
        //                }
        //
        //            }
        //
        //        }
        //        if (permissionType==PermType_NonProjectSpecific) {
        //            if (countAddExpenseUDF>=4)
        //            {
        //                scrollHeight=80-scrollHeight;
        //            }
        //            if (countAddExpenseUDF <=3)
        //            {
        //                if (countAddExpenseUDF==0) {
        //
        //                    if ([secondSectionfieldsArray count]<=5)
        //                    {
        //                        scrollHeight=40;
        //                    }
        //                    else
        //                        scrollHeight=90;
        //                }
        //
        //                scrollHeight =85-scrollHeight;
        //            }
        //
        //             size.height=  self.view.frame.size.height+((countAddExpenseUDF+1)*60.0)-scrollHeight;
        //        }
        //        else
        scrollHeight =([firstSectionfieldsArray count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT)+35.0+40.0+30.0+20.0;
        size.height=scrollHeight;
        self.mainScrollView.contentSize=size;
	}
	[UIView commitAnimations];
	
	//	newExpenseEntryTable.frame = frame;
}
- (void)scrollTableView:(UITableView *)tableView toIndexPath:(NSIndexPath *)indexPath withBottomPadding:(CGFloat)bottomPadding
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	if (indexPath.row<[secondSectionfieldsArray count]-3) {
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+3 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	}else {
		[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row  inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	}
	
	[UIView commitAnimations];
}



#pragma mark TableViewSelectionStyles
-(void)tableCellTappedAtIndex:(NSIndexPath*)indexPath
{
	
	[tnewExpenseEntryTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	
	G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:RepliconStandardBlueColor];//DE3566//Juhi
	
	if (cell.fieldName !=nil) {
		[cell.fieldName setTextColor:iosStandaredWhiteColor];
	}
	if (cell.fieldButton !=nil) {
		[cell.fieldButton setTitleColor:iosStandaredWhiteColor forState:UIControlStateNormal];
	}
	if (cell.fieldText !=nil) {
		[cell.fieldText setTextColor:iosStandaredWhiteColor];
	}
	
	
	[self handleButtonClicks: indexPath];
}

-(void)tableViewCellUntapped:(NSIndexPath*)indexPath
{
	[tnewExpenseEntryTable deselectRowAtIndexPath:indexPath animated:NO];
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[entryCell.fieldName setTextColor:RepliconStandardBlackColor];
	[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	[entryCell.fieldText setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
	[entryCell setBackgroundColor:iosStandaredWhiteColor];//DE3566//Juhi
	//[entryCell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	//[self handleButtonClicks: indexPath];
	
}

-(G2ExpenseEntryCellView*)getCellForIndexPath:(NSIndexPath*)indexPath
{
	G2ExpenseEntryCellView *cellAtIndex = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: indexPath];
	return cellAtIndex;
}

- (void)pickerNext:(id )button{
	//	[self moveTableToTop:currentIndexPath.row+1];
	//[self scrollTableView:newExpenseEntryTable toIndexPath:currentIndexPath withBottomPadding:40.0];
	if(numberUdfText != nil)
		[numberUdfText resignFirstResponder];
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		DLog(@"Error: Cell or cell data cannot be null");
		return;
	}
	//[entryCell setCellViewState: NO];
    //DE8142
	if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString: RPLocalizedString(@"Project", @"")]&&currentIndexPath.section==G2EXPENSE_SECTION) {
		if ([[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] ||
			[[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(NONE_STRING, @"")])
		{
			[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
			
			NSString *temp = @"";
			temp = [NSString stringWithFormat: @"%@",
					[[projectsArray objectAtIndex: 0]objectForKey:@"name"]];
			
			
			if (![temp isEqualToString:@""] &&![temp isKindOfClass:[NSNull class]] && ![temp isEqualToString:@"(null)"]) {
				[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
				[[entryCell dataObj] setObject:temp forKey:@"defaultValue"];
			}
			
			NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:[[projectsArray objectAtIndex:0]objectForKey:@"identity"]];
			[[firstSectionfieldsArray objectAtIndex:2] setObject:expenseTypeArr forKey:@"dataSourceArray"];
			
		}
		
		
		NSIndexPath *billClientIndex =  [NSIndexPath indexPathForRow:2 inSection:1];
		if (dataSourceArray!=nil && [dataSourceArray count]>0)
        {
            if ([[entryCell dataObj]objectForKey:@"clientName"]!=nil && [[[entryCell dataObj]
																		  objectForKey:@"clientName"] isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
				{
					
					if ([[self getBillClientInfo] intValue] == 1){
						[self DisableCellAtIndexForCheckmark:billClientIndex];
					}
				}
			}else {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
                {
                    if ([[self getBillClientInfo] intValue] == 1){
						//DE2705//Juhi
                        //							[self reloadCellAtIndex:billClientIndex];
                        [self reloadCellAtIndex:billClientIndex andRow:0];
					}
                }
                
			}
            
        }
        
		
		
	}
	else if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]){
		if(currentIndexPath.section == 0 && [[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")]){
			if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific){
				G2ExpenseEntryCellView *entryCellCP = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:(currentIndexPath.row)-1 inSection:currentIndexPath.section]];
				
				if (![self checkAvailabilityOfTypeForSelectedProject:[[entryCellCP dataObj]objectForKey:@"projectIdentity"]]) {
					[G2Util errorAlert:nil errorMessage:RPLocalizedString(ExpenseType_UnAvailable,"")];
                    [self pickerDone:nil];
					return;
				}
				
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
			}else {
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
			}
		}
		
		
		
		NSNumber *selectedRowIndex = [[entryCell dataObj] objectForKey: @"selectedIndex"];
		DLog(@"=======================->>%d : %ld", [selectedRowIndex intValue], (long)[[entryCell indexPath]row]);
		
		NSString *temp = @"";
		//added below condition to check if picker data is empty and handle gracefully.
		//TODO: Need to fix.
		if (dataSourceArray != nil && [dataSourceArray count] > 0) {
			
			temp = [[dataSourceArray objectAtIndex: [selectedRowIndex intValue]]objectForKey:@"name"];
            //DE8142
			if ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Currency", @"")] && currentIndexPath.section==0) {
                
                //DE6734-issue existed only when selected project did not have saved type.Hence added check point
                if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific){
                    G2ExpenseEntryCellView *entryCellCP = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:(currentIndexPath.row)-2 inSection:currentIndexPath.section]];
                    if ([self checkAvailabilityOfTypeForSelectedProject:[[entryCellCP dataObj]objectForKey:@"projectIdentity"]]==NO) {
                        [self updateAmountWhenTypeUnAvailable:YES];
                        return;
                    }
                }
                
				temp = [[dataSourceArray objectAtIndex: [selectedRowIndex intValue]]objectForKey:@"symbol"];
				[self setBaseCurrency:temp];
			}
			//DE8142
			if ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")] &&[selectedRowIndex intValue] == 0 && currentIndexPath.section==G2EXPENSE_SECTION) {
				//get ExpenseType mode for firstexpense and change the type of amount  field.
				NSMutableArray *expenseTypeArr = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
				if ([expenseTypeArr count] > 0) {
					NSString *firstExpenseTypeMode = [[expenseTypeArr objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"type"];
					[self changeAmountRowFieldType:firstExpenseTypeMode];
					BOOL disableCurrencyField = NO;
					if ([firstExpenseTypeMode isEqualToString:Rated_With_Taxes] ||
						[firstExpenseTypeMode isEqualToString:Rated_WithOut_Taxes]) {
						disableCurrencyField = YES;
						//update currency to base currency for rated type.
						//[self updateCurrencyFieldToBasecurrency];
					}
					[self changeCurrencyFieldEnableStatus:disableCurrencyField];
				}
			}
			
			
			[[entryCell dataObj] setObject: temp forKey: @"defaultValue"];
			NSString *selectedDataIdentity = [[dataSourceArray objectAtIndex:[selectedRowIndex intValue]]objectForKey:@"identity"];
			[[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
		}
		if (![temp isEqualToString:@""])
			[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
	}
	
	[self tableViewCellUntapped:currentIndexPath];
	/*
	 if (currentIndexPath.section == EXPENSE_SECTION && (currentIndexPath.row  == [firstSectionfieldsArray count] -1)) {
	 if ([[entryCell dataObj] objectForKey:@"fieldType"]== NUMERIC_KEY_PAD) {
	 currentIndexPath = [NSIndexPath indexPathForRow:0 inSection: currentIndexPath.section+1];
	 [self resetTableViewUsingSelectedIndex:currentIndexPath];
	 }
	 else {
	 currentIndexPath = [NSIndexPath indexPathForRow:(currentIndexPath.row+1) inSection: currentIndexPath.section];
	 }
	 
	 }
	 else {
	 currentIndexPath = [NSIndexPath indexPathForRow:(currentIndexPath.row+1) inSection: currentIndexPath.section];
	 }
	 */
	
	NSIndexPath *amountIndex = [NSIndexPath indexPathForRow:(currentIndexPath.row+1) inSection:currentIndexPath.section];
	id cellObj = [self getCellForIndexPath:amountIndex];
    //DE8142
	if ([[[cellObj dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Amount", @"")] && amountIndex.section==0) {
		if ([[[cellObj dataObj] objectForKey:@"fieldValue"] isEqualToString:RPLocalizedString(@"Add", @"")] || ![cellObj isUserInteractionEnabled] ) {
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(@"Please select expense type.", @"")];
            [self pickerDone:nil];
			return;
		}
	}
	
	
	NSIndexPath *nextIndexPath = [self getNextEnabledFieldFromCurrentIndex:currentIndexPath];
	if (nextIndexPath != nil) {
		[self setCurrentIndexPath:nextIndexPath];
		//[self handleButtonClicks: currentIndexPath];
		[self tableCellTappedAtIndex:currentIndexPath];
	}
	else {
		[pickerViewC setHidden:YES];
		[self resetTableViewUsingSelectedIndex:nil];
		//[self changeSegmentControlState:currentIndexPath];
	}
	
}

-(void)reloadDataPicker:(NSIndexPath *)indexPath{
	
	
	boolIsProjSelForFirstTime=YES;//DE4850 ullas
	[pickerViewC setHidden:NO];
	[pickerView1 setHidden:NO];
	[datePicker setHidden:YES];
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: indexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		DLog(@"Error: Cell or cell data cannot be null");
		return;
	}
	
	//if (pickerView1.tag==2000) {
    //DE8142
	if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString:RPLocalizedString(@"Project", @"")]&& indexPath.section==G2EXPENSE_SECTION) {
		NSNumber *num1= [[firstSectionfieldsArray objectAtIndex:indexPath.row]objectForKey:@"selectedClientIndex"];
		NSNumber *num2=  [[firstSectionfieldsArray objectAtIndex:indexPath.row]objectForKey:@"selectedProjectIndex"];
        tmpSelectedClientIndex=[[[firstSectionfieldsArray objectAtIndex:indexPath.row]objectForKey:@"selectedClientIndex"] intValue];//DE4850 ullas
		[pickerView1 reloadAllComponents];
	    [pickerView1 selectRow:[num1 intValue] inComponent:0 animated:YES];
	    if (hasClient) {
			[pickerView1 selectRow:[num2 intValue] inComponent:1 animated:YES];
		}
	}
    else {
		if (indexPath.section==0) {
			[self updatePaymentMethodOnCell:entryCell];
			[pickerView1 reloadAllComponents];
			[pickerView1 selectRow:[[[firstSectionfieldsArray objectAtIndex:indexPath.row]objectForKey:@"selectedIndex"]intValue] inComponent:0 animated:YES];
		}else{
			[self updatePaymentMethodOnCell:entryCell];
			[pickerView1 reloadAllComponents];
			[pickerView1 selectRow:[[[secondSectionfieldsArray objectAtIndex:indexPath.row]objectForKey:@"selectedIndex"]intValue] inComponent:0 animated:YES];
		}
	}
}


-(void)updatePaymentMethodOnCell:(G2ExpenseEntryCellView*)entryCell
{
    //DE8142
	if (entryCell!=nil && [[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Payment Method", @"")] && currentIndexPath.row<udfStartIndex) {
		NSMutableArray *paymentsArray = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
		NSString *paymentFirst = nil;
		paymentFirst = [[entryCell dataObj] objectForKey:@"defaultValue"];
		if (paymentsArray !=nil && [paymentsArray count] >0) {
			if (paymentFirst == nil || [paymentFirst isKindOfClass:[NSNull class]] || [paymentFirst isEqualToString: RPLocalizedString(@"Select", @"")]) {
				paymentFirst = [[paymentsArray objectAtIndex:0] objectForKey:@"name"];
			}
			
		}
		[entryCell.fieldButton setTitle:paymentFirst forState:UIControlStateNormal];
		[[entryCell dataObj] setObject:paymentFirst forKey:@"defaultValue"];
	}
    //DE8142
    else if (entryCell!=nil && [[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")]&& currentIndexPath.section==G2EXPENSE_SECTION) {
		NSMutableArray *typesArray = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
        NSNumber *selectedRowIndex = [[entryCell dataObj] objectForKey: @"selectedIndex"]; //Fix for DE2982//Juhi
		NSString *typeDefault = [[entryCell dataObj] objectForKey: @"defaultValue"];
		taxExpenseChnged = NO;
		
		if (typesArray !=nil && [typesArray count] >0) {
			if (typeDefault == nil || [typeDefault isKindOfClass:[NSNull class]] || [typeDefault isEqualToString: RPLocalizedString(@"Select", @"")]) {
				typeDefault = [[typesArray objectAtIndex:0] objectForKey:@"name"];
                //Fix for DE2982//Juhi
                NSString *firstExpenseTypeMode = [[typesArray objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"type"];
                [self changeAmountRowFieldType:firstExpenseTypeMode];
                //DE4911//Juhi
                if (permissionType == PermType_NonProjectSpecific) {
                    [self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
                }
                else
                    [self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
                //DE4911//Juhi
                BOOL disableCurrencyField = NO;
                if ([firstExpenseTypeMode isEqualToString:Rated_With_Taxes] ||
                    [firstExpenseTypeMode isEqualToString:Rated_WithOut_Taxes]) {
                    disableCurrencyField = YES;
                    //update currency to base currency for rated type.
                    [self updateCurrencyFieldToBasecurrency];//DE8328 Ullas M L
                }
                [self changeCurrencyFieldEnableStatus:disableCurrencyField];
			}
		}
        else
        {
            typeDefault=RPLocalizedString(@"Select", @"");
        }
        
        
		[entryCell.fieldButton setTitle:typeDefault forState:UIControlStateNormal];
		[[entryCell dataObj] setObject:typeDefault forKey:@"defaultValue"];
        
        
        
	}else if (entryCell!=nil && [[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString:DATA_PICKER]) {
		NSMutableArray *objectsArray = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
		NSString *valueDefault = [[entryCell dataObj] objectForKey: @"defaultValue"];
		
		if (objectsArray !=nil && [objectsArray count] >0) {
			if (valueDefault == nil || [valueDefault isKindOfClass:[NSNull class]] || [valueDefault isEqualToString: RPLocalizedString(@"Select", @"")]) {
				valueDefault = [[objectsArray objectAtIndex:0] objectForKey:@"name"];
			}
		}
		[entryCell.fieldButton setTitle:valueDefault forState:UIControlStateNormal];
		[[entryCell dataObj] setObject:valueDefault forKey:@"defaultValue"];
	}
	
}

-(void)reloadDatePicker:(NSIndexPath *)indexPath{
	
	
	[pickerViewC setHidden:NO];
	[datePicker setHidden:NO];
	[pickerView1 setHidden:YES];
	[pickerViewC addSubview:datePicker];
	if (indexPath.section==1) {
		if ([datePicker tag]==DEFAULT_DATE_PICKER_TAG) {
			datePicker.date = [G2Util convertStringToDate1:[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]];
			[self showDatePicker];
		}else {
			
			if(![[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(@"Select", @"")]) {
				datePicker.date = [G2Util convertStringToDate1:[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]];
			}else {
				datePicker.date = [NSDate date];
                
                //DE4001//Juhi
                NSString *dateToStringValue = [G2Util convertPickerDateToString:datePicker.date];
                G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: indexPath];
                [[entryCell dataObj] setObject:dateToStringValue forKey:@"defaultValue"];
                [entryCell.fieldButton setTitle:dateToStringValue forState:UIControlStateNormal];
 			}
			
			[self showDatePicker];
			
			
		}
	}
}
-(void)showDatePicker
{
	[datePicker addTarget:self  action:@selector(updateDateField:)
		 forControlEvents:UIControlEventValueChanged];
}
-(void)updateDateField:(id)sender{
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		DLog(@"Error: Cell or cell data cannot be null");
		return;
	}
	
	NSString *dateToStringValue = [G2Util convertPickerDateToString:datePicker.date];
	if (dateToStringValue!=nil) {
        if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString:DATE_PICKER]) {//DE2991
            [[entryCell dataObj] setObject:dateToStringValue forKey:@"defaultValue"];
            [self updateFieldAtIndex: currentIndexPath WithSelectedValues:dateToStringValue];
        }
	}
}

-(void)setDeletedFlags {
	[self releaseCache];
	[self setDescription: RPLocalizedString(@"Add", @"")];
}

-(void)setDescription:(NSString *)_description{
	//DE8430 Ullas M L
	if (currentIndexPath.section == 1) {//Updates receipt photo value
        defaultDescription = [[secondSectionfieldsArray objectAtIndex:currentIndexPath.row] objectForKey:@"defaultValue"];
        if(defaultDescription == _description){
            return;
        }
        defaultDescription=_description;
		[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row] setObject:defaultDescription forKey:@"defaultValue"];
		
		[self updateFieldAtIndex:currentIndexPath WithSelectedValues:[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]];
	}else if (currentIndexPath.section == 0) {//updates amount value
        defaultDescription = [[firstSectionfieldsArray objectAtIndex:currentIndexPath.row] objectForKey:@"defaultValue"];
        if(defaultDescription == _description){
            return;
        }
        defaultDescription=_description;
		[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row] setObject:defaultDescription forKey:@"defaultValue"];
		[self updateFieldAtIndex:currentIndexPath WithSelectedValues:[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]];
	}
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
}


-(void)tableViewMoveToTop:(NSIndexPath*)selectedIndex
{
	
	UIButton *buttonField = [(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:selectedIndex] fieldButton];
	
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	CGRect frame = tnewExpenseEntryTable.frame;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.3f];
	if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
		frame.size.height -= (selectedIndex.row)*80 ;
	else
		frame.size.height -= (selectedIndex.row)*80;
	
	//    // Apply new size of table view
	self.tnewExpenseEntryTable.frame = frame;
	//
	//    // Scroll the table view to see the TextField just above the keyboard
	if (buttonField)
	{
		CGRect buttonRect = [self.tnewExpenseEntryTable convertRect:buttonField.bounds fromView:buttonField];
		[self.tnewExpenseEntryTable scrollRectToVisible:buttonRect animated:NO];
	}
	
	[UIView commitAnimations];
	
	
	
}
#pragma mark -
#pragma mark ServerProtocolMethods
#pragma mark -

-(void)handleExpenseEntrySaveResponse:(id) response {
	
	//insert
	[tnewEntryDelegate performSelector:@selector(newEntryIsAddedToSheet)];
	
	
	[expensesModel insertExpenseSheetsInToDataBase:response];
	[expensesModel insertExpenseEntriesInToDataBase:response];
	[expensesModel insertUdfsforEntryIntoDatabase:response];
	[[NSUserDefaults standardUserDefaults]setObject:[expensesModel getExpenseSheetsFromDataBase] forKey:@"expenseSheetsArray"];
	[[NSUserDefaults standardUserDefaults]setObject:[expensesModel getExpenseEntriesFromDatabase] forKey:@"expenseEntriesArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ExpenseEntriesNotification"
														object:nil];
	
	[self releaseCache];
	
	if (isEntriesAvailable) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_ENTRY_SAVED" object:nil];
	}
	
    
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
}
- (void) serverDidRespondWithResponse:(id) response {
	
	if (response!=nil) {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if ([status isEqualToString:@"OK"]) {
			
			if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == SaveNewExpenseEntry_28) {
				
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]>0) {
					[[G2RepliconServiceManager expensesService]sendRequestToGetExpenseById:[[responseArray objectAtIndex:0]objectForKey:@"Identity"] withDelegate:self];
				}
			}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == ExpenseById_ServiceID_12) {
				
				NSArray *expenseByIDArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (expenseByIDArray!=nil && [expenseByIDArray count]!=0) {
					[self handleExpenseEntrySaveResponse:expenseByIDArray];
				}
			}
		}else {
			NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
            //			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
            [self pickerDone:nil];
		}
	}
	
}
- (void) serverDidFailWithError:(NSError *) error {
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		[G2Util showConnectionError];
		return;
	}
    [self showErrorAlert:error];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
}

-(void)showErrorAlert:(NSError *) error
{
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED]) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                                      delegate:self cancelButtonTitle:RPLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [confirmAlertView setDelegate:self];
            [confirmAlertView setTag:SAML_SESSION_TIMEOUT_TAG];
            [confirmAlertView show];
            
        }
        else
        {
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)];
            
        }
        
        [self pickerDone:nil];
    }
    else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
        [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(G2PASSWORD_EXPIRED, G2PASSWORD_EXPIRED) ];
        [self pickerDone:nil];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    else
    {
        [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
        [self pickerDone:nil];
    }
}


-(void) networkActivated {
	//do nothing
}



#pragma mark AmountValues

-(void)updateCurrencyFieldToBasecurrency {
	
	NSIndexPath *currencyIndexPath = [NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION];
	if (permissionType ==PermType_NonProjectSpecific) {
		currencyIndexPath = [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION];
	}
	
	//SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
	//NSMutableArray *baseCurrencyArray =[supportDataModel getBaseCurrencyFromDatabase];
	
	
	NSString *projectdId = nil;
	NSString *typeIdentity = nil;
	if (firstSectionfieldsArray != nil && [firstSectionfieldsArray count] >0) {
		if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific) {
			projectdId = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"projectIdentity"];
			typeIdentity = [[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"selectedDataIdentity"];
		}else {
			projectdId = @"null";
			typeIdentity = [[firstSectionfieldsArray objectAtIndex:0] objectForKey:@"selectedDataIdentity"];
		}
		
	}
	
	NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesToSaveWithEntryForSelectedProjectId: projectdId withType:typeIdentity];
	
	
	if (expenseTypeArr != nil && [expenseTypeArr count] > 0) {
		
        
        [self setBaseCurrency:[[expenseTypeArr objectAtIndex:0] objectForKey:@"ratedCurrency"]];
        
		G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:currencyIndexPath];
		NSMutableArray *dataArray = [[cell dataObj] objectForKey:@"dataSourceArray"];
		int selectedIndex = [G2Util getObjectIndex:dataArray withKey:@"symbol" forValue:baseCurrency];
		[[cell dataObj] setObject:[NSNumber numberWithInt:selectedIndex] forKey:@"selectedIndex"];
		[[cell dataObj] setObject:[[expenseTypeArr objectAtIndex:0] objectForKey:@"ratedCurrencyId"] forKey:@"selectedDataIdentity"];
		[[cell dataObj] setObject:[[expenseTypeArr objectAtIndex:0] objectForKey:@"ratedCurrency"] forKey:@"selectedDataSource"];
		[[cell dataObj] setObject:baseCurrency forKey:@"defaultValue"];
		/*[[cell dataObj] setObject:[[baseCurrencyArray objectAtIndex:0]
		 objectForKey:@"identity"] forKey:@"selectedDataIdentity"];
		 [[cell dataObj] setObject:[[baseCurrencyArray objectAtIndex:0]
		 objectForKey:@"symbol"] forKey:@"selectedDataSource"];*/
		[self updateFieldAtIndex:currencyIndexPath WithSelectedValues:[NSString stringWithFormat:@"%@",self.baseCurrency]];
	}
	
	
}

-(void)changeCurrencyFieldEnableStatus:(BOOL)disableCurrencyField {
	NSIndexPath *currencyIndexPath = [NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION];
	if (permissionType ==PermType_NonProjectSpecific) {
		currencyIndexPath = [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION];
	}
	
	if (disableCurrencyField) {
		[self disableExpenseFieldAtIndex:currencyIndexPath];
	}
	else {
		[self enableExpenseFieldAtIndex:currencyIndexPath];
	}
	
}

//US4234 Ullas M L
-(void)updateTypeSelectionLogic:(NSString *)expenseTypeMode
{
    
    
    NSString *taxModeOfExpenseType=expenseTypeMode;
    //DLog(@"%@ ---->%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"previousTaxType"],taxModeOfExpenseType);
    NSString *previousTaxModeOfExpenseType=[[NSUserDefaults standardUserDefaults]objectForKey:@"previousTaxType"];
    
    [[NSUserDefaults standardUserDefaults]setObject:taxModeOfExpenseType forKey:@"previousTaxType"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //DE7030 Ullas M L
    if (previousTaxModeOfExpenseType==nil && taxModeOfExpenseType!=nil) {
        NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
        if (permissionType == PermType_NonProjectSpecific) {
            amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
        }
        
        G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:amountIndexPath];
        NSString *fieldType = nil;
        if ([expenseTypeMode isEqualToString:Flat_WithOut_Taxes] ) {
            fieldType = NUMERIC_KEY_PAD;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            [cell setDecimalPlaces:2];
            [cell addTextFieldsForTextUdfsAtIndexRow:(amountIndexPath.row+FIRSTSECTION_TAG_INDEX)];
            [cell.fieldText setHidden:NO];
            if (previousWasTaxExpense) {
                [cell.fieldText setText:RPLocalizedString(@"Add", @"")];
                previousWasTaxExpense = NO;
            }
            else {
                [cell.fieldText setText:[[cell dataObj]objectForKey:@"defaultValue"]];
            }
            [cell.fieldButton setHidden:YES];
            
            amountValuesArray = nil;
            ratedCalculatedValuesArray = nil;
        }
        else {
            fieldType = MOVE_TO_NEXT_SCREEN;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            if (cell.fieldText != nil) {
                [cell.fieldText setHidden:YES];
                
            }
            [cell.fieldButton setHidden:NO];
            if (taxExpenseChnged) {
                [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"") forState:UIControlStateNormal];
                [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
            }
        }
        
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
        
    }
    
    if ([previousTaxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]&&[taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]) {
        
        isComplexAmountCalucationScenario=NO;
        NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
        if (permissionType == PermType_NonProjectSpecific) {
            amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
        }
        
        G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:amountIndexPath];
        NSString *fieldType = nil;
        if ([expenseTypeMode isEqualToString:Flat_WithOut_Taxes] ) {
            fieldType = NUMERIC_KEY_PAD;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            [cell setDecimalPlaces:2];
            [cell addTextFieldsForTextUdfsAtIndexRow:(amountIndexPath.row+FIRSTSECTION_TAG_INDEX)];
            [cell.fieldText setHidden:NO];
            [cell.fieldText setText:cell.fieldButton.titleLabel.text];//retaining the previous amount
            [cell.fieldButton setHidden:YES];
            amountValuesArray = nil;
            ratedCalculatedValuesArray = nil;
        }
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
        
    }
    if ((([previousTaxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]||[previousTaxModeOfExpenseType isEqualToString:Flat_With_Taxes])&&([taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]||[taxModeOfExpenseType isEqualToString:Rated_With_Taxes]))||(([taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]||[taxModeOfExpenseType isEqualToString:Flat_With_Taxes])&&([previousTaxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]||[previousTaxModeOfExpenseType isEqualToString:Rated_With_Taxes]))) {
        
        //DLog(@"Scenario 1 Success.Clear the amount");
        
        isComplexAmountCalucationScenario=NO;
        NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
        if (permissionType == PermType_NonProjectSpecific) {
            amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
        }
        
        G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:amountIndexPath];
        NSString *fieldType = nil;
        if ([expenseTypeMode isEqualToString:Flat_WithOut_Taxes] ) {
            fieldType = NUMERIC_KEY_PAD;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            [cell setDecimalPlaces:2];
            [cell addTextFieldsForTextUdfsAtIndexRow:(amountIndexPath.row+FIRSTSECTION_TAG_INDEX)];
            [cell.fieldText setHidden:NO];
            [cell.fieldText setText:RPLocalizedString(@"Add", @"Add") ];//clearing the previous amount and making it add
            [[cell dataObj]setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"];//DE6986 Ullas M L
            [cell.fieldButton setHidden:YES];
            
            amountValuesArray = nil;
            ratedCalculatedValuesArray = nil;
        }
        else
        {
            fieldType = MOVE_TO_NEXT_SCREEN;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            if (cell.fieldText != nil) {
                [cell.fieldText setHidden:YES];
                
            }
            [cell.fieldButton setHidden:NO];
            [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"Add") forState:UIControlStateNormal];
            [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"];
            amountValuesArray = nil;//DE6113 Ullas M L
            ratedCalculatedValuesArray=nil;//DE6113 Ullas M L
        }
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
    }
    
    if ([previousTaxModeOfExpenseType isEqualToString:Flat_With_Taxes]&&[taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]) {
        //DLog(@"Scenario 2 Success.Retain the amount");
        isComplexAmountCalucationScenario=NO;
        
        NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
        if (permissionType == PermType_NonProjectSpecific) {
            amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
        }
        
        G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:amountIndexPath];
        
        NSString *fieldType = nil;
        if ([expenseTypeMode isEqualToString:Flat_WithOut_Taxes] ) {
            fieldType = NUMERIC_KEY_PAD;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            [cell setDecimalPlaces:2];
            [cell addTextFieldsForTextUdfsAtIndexRow:(amountIndexPath.row+FIRSTSECTION_TAG_INDEX)];
            [cell.fieldText setHidden:NO];
            NSString *amountString=[NSString stringWithFormat:@"%@", cell.fieldButton.titleLabel.text];
            if (amountString==nil)
            {
                [cell.fieldText setText:RPLocalizedString(@"Add", @"Add")];
            }
            else
            {
                [cell.fieldText setText:cell.fieldButton.titleLabel.text];//Retaining the amount
            }
            [cell.fieldButton setHidden:YES];
            
            amountValuesArray = nil;
            ratedCalculatedValuesArray = nil;
        }
        else
        {
            fieldType = MOVE_TO_NEXT_SCREEN;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            if (cell.fieldText != nil) {
                [cell.fieldText setHidden:YES];
                
            }
            [cell.fieldButton setHidden:NO];
            [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"Add") forState:UIControlStateNormal];
            [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"];
            
            
        }
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
        
    }
    if (([previousTaxModeOfExpenseType isEqualToString:Flat_With_Taxes]&&[taxModeOfExpenseType isEqualToString:Flat_With_Taxes])||([previousTaxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]&&[taxModeOfExpenseType isEqualToString:Flat_With_Taxes])) {
        //DLog(@"Scenario 3 Success.Complex computation keep it ADD");
        isComplexAmountCalucationScenario=NO;
        NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
        if (permissionType == PermType_NonProjectSpecific) {
            amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
        }
        
        G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:amountIndexPath];
        
        
        NSString *fieldType = nil;
        if ([expenseTypeMode isEqualToString:Flat_WithOut_Taxes] ) {
            fieldType = NUMERIC_KEY_PAD;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            [cell setDecimalPlaces:2];
            [cell addTextFieldsForTextUdfsAtIndexRow:(amountIndexPath.row+FIRSTSECTION_TAG_INDEX)];
            [cell.fieldText setHidden:NO];
            [cell.fieldText setText:[[cell dataObj]objectForKey:@"defaultValue"]];//retaining the default value of amount
            [cell.fieldButton setHidden:YES];
            
            amountValuesArray = nil;
            ratedCalculatedValuesArray = nil;
        }
        else
        {
            fieldType = MOVE_TO_NEXT_SCREEN;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            if (cell.fieldText != nil) {
                [cell.fieldText setHidden:YES];
                
            }
            [cell.fieldButton setHidden:NO];
            [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"Add") forState:UIControlStateNormal];
            [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"];
            
            
            
        }
        
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
        
    }
    
    if (([previousTaxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]&&[taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes])||([previousTaxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]&&[taxModeOfExpenseType isEqualToString:Rated_With_Taxes])||([previousTaxModeOfExpenseType isEqualToString:Rated_With_Taxes]&&[taxModeOfExpenseType isEqualToString:Rated_With_Taxes])||([previousTaxModeOfExpenseType isEqualToString:Rated_With_Taxes]&&[taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes])) {
        
        
        NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
        if (permissionType == PermType_NonProjectSpecific) {
            amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
        }
        
        G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:amountIndexPath];
        //DLog(@"Scenario 4 Success. computation");
        NSString *str=[defaultRateAndAmountsArray objectAtIndex:0];
        
        
        if (![cell.fieldButton.titleLabel.text isEqualToString:RPLocalizedString(@"Add", @"Add")])
        {
            isComplexAmountCalucationScenario=YES;
            if (str!=nil && ![[[cell dataObj]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"Add")])
            {
                [self updateRatedExpenseData:[defaultRateAndAmountsArray objectAtIndex:0]];
            }
            
            
        }
        
    }
    
    
}
-(void)changeAmountRowFieldType :(NSString *)expenseTypeMode{
	[self updateTypeSelectionLogic:expenseTypeMode];
	/*NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
     if (permissionType == PermType_NonProjectSpecific) {
     amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
     }
     
     ExpenseEntryCellView *cell = (ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:amountIndexPath];
     NSString *fieldType = nil;
     if ([expenseTypeMode isEqualToString:Flat_WithOut_Taxes] ) {
     fieldType = NUMERIC_KEY_PAD;
     [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
     [cell setDecimalPlaces:2];
     [cell addTextFieldsForTextUdfsAtIndexRow:(amountIndexPath.row+FIRSTSECTION_TAG_INDEX)];
     [cell.fieldText setHidden:NO];
     if (previousWasTaxExpense) {
     [cell.fieldText setText:RPLocalizedString(@"Add", @"")];
     previousWasTaxExpense = NO;
     }
     else {
     [cell.fieldText setText:[[cell dataObj]objectForKey:@"defaultValue"]];
     }
     [cell.fieldButton setHidden:YES];
     
     amountValuesArray = nil;
     ratedCalculatedValuesArray = nil;
     }
     else {
     fieldType = MOVE_TO_NEXT_SCREEN;
     [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
     if (cell.fieldText != nil) {
     [cell.fieldText setHidden:YES];
     
     }
     [cell.fieldButton setHidden:NO];
     if (taxExpenseChnged) {
     [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"") forState:UIControlStateNormal];
     [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
     }
     }
     
     [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
     [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];*/
	
}

-(void)setAmountArrayBaseCurrency:(NSMutableArray*)_amountArray{
	[self setAmountValuesArray:_amountArray];
	[self setBaseCurrency:[_amountArray objectAtIndex:0]];
	
	NSIndexPath *currencyIndexPath = [NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION];
	if(permissionType == PermType_NonProjectSpecific) {
		currencyIndexPath = [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION];
	}
	
	G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:currencyIndexPath];
    //DE4062//Juhi
    //	if ([cell indexPath] != currencyIndexPath) {
    //		return;
    //	}
	if (baseCurrency == nil) {
		self.baseCurrency = @"";
	}
	[[cell dataObj] setObject:baseCurrency forKey:@"defaultValue"];
	[cell.fieldButton setTitle:baseCurrency forState:UIControlStateNormal];
	
}
-(void)setCurrencyId:(NSString *)_identity selectedIndex:(NSNumber *)_selectedRowIndex {
	[self setCurrencyIdentity:_identity];
	NSMutableDictionary *infoDict = [firstSectionfieldsArray objectAtIndex:1];
	if(permissionType != PermType_NonProjectSpecific) {
		infoDict = [firstSectionfieldsArray objectAtIndex:3];
	}
	[infoDict setObject:_identity forKey:@"selectedDataIdentity"];
	[infoDict setObject:baseCurrency forKey:@"selectedDataSource"];
	[infoDict setObject:_selectedRowIndex forKey:@"selectedIndex"];
}

-(void)setAmountArrayToNil
{
	amountValuesArray=nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	/*RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
     if (delegate != nil)	{
     [delegate expenseEntryMemoryWarning];
     }*/
	//[self.navigationController popViewControllerAnimated: YES];
	DLog(@"Add IN DID RECIEVE didReceiveMemoryWarning: %@", [self view].superview);
	[self releaseCache];
}


//US4234 Ullas M L
-(void)updateRatedExpenseData:(NSString *)kilometerString
{
    NSString *identity;
    NSDictionary *infoDict;
    
    if(permissionType == PermType_ProjectSpecific || permissionType == PermType_Both)	{
        identity = [[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"];
        infoDict=[firstSectionfieldsArray objectAtIndex:2];
    }else {//if (nonProjectSpecific ==YES) {
        identity = @"null";
        infoDict = [firstSectionfieldsArray objectAtIndex:0];
    }
    
    int ind = [[infoDict objectForKey:@"selectedIndex"]intValue];
    NSArray *_dataSource = [infoDict objectForKey:@"dataSourceArray"];
    
    
    NSString *typeName = nil;
    if (_dataSource != nil && [_dataSource count] > 0) {
        typeName = [[_dataSource objectAtIndex: ind] objectForKey: @"name"];
    }
    NSMutableArray *tmpRatedValuesArray=[[NSMutableArray alloc]init];
    self.ratedValuesArray=tmpRatedValuesArray;
   
    
    NSMutableArray *tmpRateAndAmountsArray=[[NSMutableArray alloc]init];
    self.rateAndAmountsArray=tmpRateAndAmountsArray;
    
    
	NSString *kilometerUnitValue=kilometerString;
	double kilometersInDouuble=[G2Util getValueFromFormattedDoubleWithDecimalPlaces:kilometerUnitValue];
    double hourlyRate=0;
    hourlyRate=[expensesModel getHourlyRateFromDBWithProjectId:identity withTypeName:typeName];
    self.rate=hourlyRate;
    //DE7062
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
    NSDecimalNumber *netTmpAmount=[[NSDecimalNumber alloc] initWithDouble:kilometersInDouuble*rate];
    NSDecimalNumber *roundedNetAmount= [netTmpAmount decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    NSString *formattedRateString = [[NSString alloc] initWithFormat:@"%0.04lf",rate];
    NSString *formattedNetAmountString = [G2Util formatDoubleAsStringWithDecimalPlaces:[roundedNetAmount doubleValue]];
	
	
    NSMutableArray *tmpArray=[[NSMutableArray alloc]initWithObjects:kilometerUnitValue,formattedRateString,formattedNetAmountString, nil];
    [rateAndAmountsArray addObjectsFromArray:tmpArray];
	
	double totalTax=0;
	NSNumber *taxAmount;
    NSDecimalNumber *roundedTotalTaxAmount=[[NSDecimalNumber alloc] initWithDouble:0];
    
    NSMutableArray *expenseTaxesInfoArray=[G2Util getTaxesInfoArray:identity :typeName];
    for (int i=0; i<[expenseTaxesInfoArray count]-1; i++) {
		NSString *taxFormula=[[expenseTaxesInfoArray objectAtIndex:i] objectForKey:@"formula"];
        taxFormula=[taxFormula lowercaseString];
		
        NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
        NSDecimalNumber *doubleDecimal;
        NSDecimalNumber *roundedTaxAmount;
        if ([taxFormula rangeOfString:@"$net"].location!=NSNotFound)
        {   //DE7062
            taxFormula=[taxFormula stringByReplacingOccurrencesOfString:@"$net"withString:[NSString stringWithFormat:@"%f", [roundedNetAmount doubleValue]]];
            NSPredicate *pred = [NSPredicate predicateWithFormat:[taxFormula stringByAppendingString:@" == 42"]];
            NSExpression *exp = [(NSComparisonPredicate *)pred leftExpression];
            taxAmount = [exp expressionValueWithObject:nil context:nil];
            doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[taxAmount doubleValue]];
            roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
        }
        else
        {
			taxAmount=[NSNumber numberWithDouble:[taxFormula doubleValue]];
            doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[taxAmount doubleValue]];
            roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
            
		}
		NSString *taxes=[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]];
        
		[ratedValuesArray addObject:taxes];
		totalTax=totalTax +[roundedTaxAmount doubleValue];
        NSDecimalNumber *totalTaxDecimal=[[NSDecimalNumber alloc] initWithDouble:totalTax];
        roundedTotalTaxAmount=[totalTaxDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
		
	}
	
	//DE7062
    NSDecimalNumberHandler *roundingBehavior1 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE]; 
    netTmpAmount=[netTmpAmount decimalNumberByRoundingAccordingToBehavior:roundingBehavior1];  
	NSDecimalNumber *totalAmount=(NSDecimalNumber *)[G2Util getTotalAmount:netTmpAmount taxAmount:roundedTotalTaxAmount];
	NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow: (currentIndexPath.row+2) inSection: currentIndexPath.section];
    G2ExpenseEntryCellView *amountEntryCell =
    (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: amountIndexPath];
    [[amountEntryCell dataObj] setObject:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[totalAmount doubleValue]]] forKey: @"defaultValue"];//
    totalCalucatedAmount=[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[totalAmount doubleValue]]];
    
    NSMutableArray *tmpTotalCalucatedAmountArray=[[NSMutableArray alloc]init];
    self.totalCalucatedAmountArray=tmpTotalCalucatedAmountArray;
   
    if (totalCalucatedAmount!=nil) {
        [totalCalucatedAmountArray addObject:totalCalucatedAmount];
    }
    self.ratedCalculatedValuesArray=ratedValuesArray;//Defect
    self.defaultRateAndAmountsArray=rateAndAmountsArray;//Defect
    [self.ratedCalculatedValuesArray addObject:totalCalucatedAmount];
    
}



/*- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
 {
 if (buttonIndex == 0&&alertView.tag == Image_Alert_tag_Add) {
 [receiptViewController.receiptImageView setImage:nil];
 [self.navigationController popViewControllerAnimated:YES];
 
 }
 }*/

-(void) releaseCache
{
	if (b64String != nil && ![b64String isKindOfClass: [NSNull class]]) {
		
		b64String = nil;
	}
}
-(void)updateAmountWhenTypeUnAvailable:(BOOL)showAlert
{
	NSIndexPath *amountIndex = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
    //Fix for DE3952//Juhi
    if (permissionType == PermType_NonProjectSpecific) {
		amountIndex = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
	}
	id amountCell = [self getCellForIndexPath:amountIndex];
	[self updateFieldAtIndex:amountIndex WithSelectedValues:RPLocalizedString(@"Add", @"")];
	[amountCell grayedOutRequiredCell];
	if (showAlert)
    {
        [G2Util errorAlert:nil errorMessage:RPLocalizedString(ExpenseType_UnAvailable,"")];
        [self pickerDone:nil];
    }
    
}

-(void)showAllClients
{
    G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
    self.dataListViewCtrl=tempdataListViewCtrl;
    
    //  [self.projectAndClientsListViewCtrl setListOfItems:tasksForProjects];
    if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0)
    {
        NSMutableArray *clientsArr=[[firstSectionfieldsArray objectAtIndex:0] objectForKey:@"clientsArr"];
        
        
        [self.dataListViewCtrl.mainTableView reloadData];
        
        NSMutableDictionary *clientDict =  [self.firstSectionfieldsArray objectAtIndex:0];
        [self.dataListViewCtrl setSelectedRowIdentity: [clientDict objectForKey:@"clientIdentity"] ];
        [self.dataListViewCtrl setParentDelegate:self];
        [self.dataListViewCtrl setTitleStr:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)];
        [self.dataListViewCtrl setListOfItems:clientsArr];
        [self.navigationController pushViewController:self.dataListViewCtrl animated:YES];
        [self pickerDone:nil];
    }
    
    
}

-(void)showAllProjectswithMoreButton:(BOOL)isShowMoreButton
{
    
    //  [self.projectAndClientsListViewCtrl setListOfItems:tasksForProjects];
    if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0)
    {
        
        [self genarateProjectsListForDtaListView];
        
        
        if ([projectsArray count]==0)
        {
            [G2Util errorAlert:@"" errorMessage:RPLocalizedString(NO_PROJECT_MSG, NO_PROJECT_MSG)];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay)];//Juhi
            return;
        }
        
        
               
        NSMutableDictionary *projectDict =  [self.firstSectionfieldsArray objectAtIndex:1];
        [self.dataListViewCtrl setSelectedRowIdentity: [projectDict objectForKey:@"projectIdentity"] ];
        [self.dataListViewCtrl setParentDelegate:self];
         [self.dataListViewCtrl setTitleStr:RPLocalizedString(CHOOSE_PROJECT, CHOOSE_PROJECT)];
        NSMutableDictionary *clientDict =  [self.firstSectionfieldsArray objectAtIndex:0];
        NSMutableArray *recentProjectsArray=[expensesModel getRecentExpenseProjectsForSelectedClientID: [clientDict objectForKey:@"clientIdentity"]];
        if([recentProjectsArray count]>0)
        {
            [self.dataListViewCtrl setRecentProjectsArr:recentProjectsArray];
        }
        else
        {
            [self.dataListViewCtrl setRecentProjectsArr:nil];
        }
        [self.dataListViewCtrl setListOfItems:projectsArray];
        [self.dataListViewCtrl setAllProjectsArr:projectsArray];
        self.dataListViewCtrl.isShowMoreButton=isShowMoreButton;
        
        if (isShowMoreButton)
        {
            [self.dataListViewCtrl.mainTableView setTableFooterView:self.dataListViewCtrl.footerView];
        }
        
        [self.dataListViewCtrl.mainTableView reloadData];
        
        
    }
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay)];
}

-(NSMutableArray *)genarateProjectsListForDtaListView
{
    if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0)
    {
        NSMutableDictionary *clientDict =  [self.firstSectionfieldsArray objectAtIndex:0];
        projectsArray=[expensesModel getExpenseProjectsForSelectedClientID: [clientDict objectForKey:@"clientIdentity"]];
        return projectsArray;
    }
    
    return nil;
}

-(void)expensesFinishedDownloadingProjects: (id)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:PROJECTSBYCLIENTS_FINSIHED_DOWNLOADING object:nil];
    
    id isNotMoreProjectsAvailable = ((NSNotification *)notificationObject).object;
    
    if ([isNotMoreProjectsAvailable boolValue])
    {
        [self showAllProjectswithMoreButton:FALSE];
    }
    else
    {
        [self showAllProjectswithMoreButton:TRUE];
    }
}

-(void)expensesTypesFinishedDownloading: (id)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:EXPENSETYPES_FINSIHED_DOWNLOADING object:nil];
    
    
    NSIndexPath *typeIndex = nil;
	if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
		typeIndex = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
	}else {
		typeIndex = [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION];
	}
    self.fromReloaOfDataView=YES;
    [self updateTypePickerOn_Client_ProjectChange];
       
    [self dataPickerAction: (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath: typeIndex] withEvent: nil forRowIndex: currentIndexPath];
    
    
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
}

-(void)updateTypePickerOn_Client_ProjectChange
{
    NSIndexPath *typeIndex = nil;
	if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
		typeIndex = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
	}else {
		typeIndex = [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION];
	}
    NSMutableDictionary *_rowData = [firstSectionfieldsArray objectAtIndex: typeIndex.row];
    
    NSString *projectIdentity=@"null";
    if (permissionType==PermType_ProjectSpecific || permissionType==PermType_Both )
    {
        NSMutableDictionary *projectDict =  [self.firstSectionfieldsArray objectAtIndex:1];
        projectIdentity=[projectDict objectForKey:@"projectIdentity"];
    }
    //Ullas-ML
    
    NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId: projectIdentity];
    
    
    NSString *selectedDataSource =nil;
    NSString *selectedDataIdentity =nil;
    
    if (expenseTypeArr!=nil && [expenseTypeArr count]>0) {
        selectedDataSource = [[expenseTypeArr objectAtIndex:0]objectForKey:@"name"];
        selectedDataIdentity = [[expenseTypeArr objectAtIndex:0]objectForKey:@"identity"];
        [_rowData setObject:selectedDataSource forKey:@"selectedDataSource"];
        [_rowData setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
        [_rowData setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
        [_rowData setObject:expenseTypeArr forKey:@"dataSourceArray"];
        [firstSectionfieldsArray replaceObjectAtIndex:typeIndex.row withObject:_rowData];
    }
    //TODO: what if selectedDataSource / selectDataIdentity are null? Currently, writing error to log
        
    
    if (projectIdentity==nil ||[projectIdentity isKindOfClass:[NSNull class]]||[projectIdentity isEqualToString:@"null"]) {
        
        if (permissionType==PermType_Both) 
        {
            [self enableExpenseFieldAtIndex:typeIndex];
        }
        else {
            [self disableExpenseFieldAtIndex:typeIndex];
        }
        
        
    }
    else {
        
        [self enableExpenseFieldAtIndex:typeIndex];
        
    }
    
    if (permissionType == PermType_Both) 
    {
        G2ExpenseEntryCellView *expenseEntryCellView=nil;
        expenseEntryCellView =(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:
                                                       [NSIndexPath indexPathForRow:0 inSection:G2EXPENSE_SECTION]];
        NSString *clientName=expenseEntryCellView.fieldButton.titleLabel.text;
        if ([clientName isEqualToString:RPLocalizedString(NONE_STRING, @"")]) 
        {
            if (projectIdentity==nil ||[projectIdentity isKindOfClass:[NSNull class]]||[projectIdentity isEqualToString:@"null"]) {
                self.fromReloaOfDataView=NO;
                [self enableExpenseFieldAtIndex:typeIndex];
                
            }
        }
        
        
    }

    BOOL disableCurrencyField = YES;
    [self changeCurrencyFieldEnableStatus:disableCurrencyField];
    
    NSIndexPath *amountIndex = nil;
	if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
		amountIndex = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
	} 
    [self disableExpenseFieldAtIndex:amountIndex];
    NSString *taxModeOfExpenseType=nil;
    
    if (selectedDataSource!=nil) {
        G2SupportDataModel *supportDataMdl = [[G2SupportDataModel alloc] init];
        taxModeOfExpenseType = [supportDataMdl getExpenseModeOfTypeForTaxesFromDB:projectIdentity withType:selectedDataSource andColumnName:@"type"];
        
        
        if ([taxModeOfExpenseType isEqualToString:Rated_With_Taxes] ||
            [taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]) {
            BOOL disableCurrencyField = NO;
            disableCurrencyField = YES;
            [self changeCurrencyFieldEnableStatus:disableCurrencyField];
    
        }

    }
    
    [self updateFieldAtIndex:typeIndex WithSelectedValues:RPLocalizedString(@"Select", @"")];
    [self updateFieldAtIndex:amountIndex WithSelectedValues:RPLocalizedString(@"Add", @"")];
    [[firstSectionfieldsArray objectAtIndex:2] setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];    
    [[firstSectionfieldsArray objectAtIndex:4] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
    if (selectedDataSource == nil || selectedDataIdentity == nil) {
#ifdef DEV_DEBUG
        DLog(@"Error: Either selectedDatasource or selectedDataIdentity is nil");
#endif
    }

}

- (void)viewDidUnload {
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.pickerViewC=nil;
    self.toolbarSegmentControl=nil;
    self.tnewExpenseEntryTable=nil;
    self.datePicker=nil;
    self.pickerView1=nil;
}




@end
