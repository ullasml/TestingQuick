//
//  EditExpenseEntryViewController.m
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2EditExpenseEntryViewController.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"
#import "G2ReceiptsViewController.h"


@interface G2EditExpenseEntryViewController()
//-(NSDictionary *) createUDFInfoDictionary;
-(NSMutableArray *) createUDFInfoDictionary:(NSMutableArray*)secondSectionArr;
@end

@implementation G2EditExpenseEntryViewController
@synthesize ratedValuesArray;
@synthesize rateAndAmountsArray;
@synthesize tnewExpenseEntryTable;
@synthesize amountValue;
@synthesize canNotEdit;
@synthesize baseCurrency;
@synthesize kilometersUnitsValue;
@synthesize amountValuesArray;
@synthesize defaultRateAndAmountsArray;
@synthesize defaultDescription;
@synthesize numberUdfText;
@synthesize expenseSheetStatus;
@synthesize imageDeletePressed;
@synthesize currentIndexPath;
@synthesize b64String;
@synthesize taxCodesAndFormulasArray;
@synthesize expenseSheetID;
@synthesize topToolbarLabel;
@synthesize currencyIdentity;
@synthesize netAmount;
@synthesize selectedIndexPath;
@synthesize ratedCalculatedValuesArray;
@synthesize editExpenseEntryDict;
@synthesize expenseEntryDetailsDict;
@synthesize base64Encoded;
@synthesize clientsArr;
@synthesize base64Decoded;
@synthesize deletButton;
@synthesize editControllerDelegate;
@synthesize expenseUnitLable;
@synthesize  expenseTypeWithTaxCodesArr;
@synthesize  currenciesArray;
@synthesize  udfsArray;
@synthesize  firstSectionfieldsArray;
@synthesize  secondSectionfieldsArray;
@synthesize saveButton;
@synthesize  pickerViewC;
@synthesize  datePicker;
@synthesize pickerView1;
@synthesize toolbarSegmentControl;
@synthesize footerView;
@synthesize  checkImageView;
@synthesize dataSourceArray;
@synthesize selectedDataIdentityStr;
@synthesize  amountviewController;
@synthesize  fieldsArray;
@synthesize  expenseUnitLabelArray;
@synthesize addDescriptionViewController;
@synthesize receiptViewController;
@synthesize mainScrollView;
@synthesize hasClient;
//static NSString *CellIdentifier = @"CellIdentifer";
@synthesize isPickerDoneClicked;
@synthesize rate;
@synthesize totalCalucatedAmountArray;
@synthesize isComplexAmountCalucationScenario;
@synthesize projectChanged;
@synthesize dataListViewCtrl;
@synthesize fromReloaOfDataView;
#define DEFAULT_DATE_PICKER_TAG 5000
#define FIRSTSECTION_TAG_INDEX 6000
#define SECONDSECTION_TAG_INDEX 6050
#define SAVE_TAG_INDEX 200
#define RECEIPT_TAG_INDEX 300
#define Image_Alert_tag 100
#define Image_Alert_Unsupported 5000
#define ROW_HEIGHT 44.0

static BOOL typeChanged =NO;
#define taxesCount 5
static int max_supported_decimals_Rate = 4;

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

- (id) init
{
    
    
	self = [super init];
	if (self != nil) {

		
	}
    
	return self;
}



-(void)checkClientWithName
{
	NSIndexPath *billClientIndex = [NSIndexPath indexPathForRow:2 inSection:1];
	if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0) {
		if ([[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"fieldName"] ==  RPLocalizedString(@"Project", @"")) {
			if ([[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"clientName"]!=nil &&[[[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"clientName"] isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
				{
					if ([[self getBillClientInfo] intValue] == 1){
						[self DisableCellAtIndexForCheckmark:billClientIndex];
					}
				}
				
			}else {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific){
					if ([[self getBillClientInfo] intValue] == 1){
						[self reloadCellAtIndex:billClientIndex];
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
		
		
		[expenseEntryCellView.fieldButton setTitle:RPLocalizedString(@"Select",@"") forState:UIControlStateNormal];
		
		[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
		[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
		
		
	}else if (permissionType == PermType_Both) {
		
		expenseEntryCellView =(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:
													   [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION]];
		[expenseEntryCellView.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[expenseEntryCellView.fieldButton setTitle:RPLocalizedString(NONE_STRING, @"") forState:UIControlStateNormal];
		self.fromReloaOfDataView=NO;
		[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
		[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
		
		
	} else if (permissionType == PermType_NonProjectSpecific){
		
		G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
		self.expenseTypeWithTaxCodesArr = [expensesModel getExpenseTypesWithTaxCodesFromDatabase];	
		
		[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:0 inSection:G2EXPENSE_SECTION]];
		[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
		
	}
	
}

-(NSNumber *)getBillClientInfo{
	
	BOOL isBillClient = FALSE;
	BOOL isUseBillingInformation = FALSE;
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	isBillClient=[supportDataModel getBillingInfoFromSystemPreferences:@"BillClient"];
	isUseBillingInformation=[supportDataModel getBillingInfoFromSystemPreferences:@"UseBillingInformation"];
	
	if(isBillClient && isUseBillingInformation)	{
		
		return [NSNumber numberWithInt: 1];
	}
	
	
	return [NSNumber numberWithInt: 0];
}

-(NSNumber*)getReimburseInfo{
	
	BOOL isReimburse=FALSE;
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];	
	isReimburse=[supportDataModel getBillingInfoFromSystemPreferences:@"Reimburse"];
	
	if (isReimburse) {
		
		return [NSNumber numberWithInt:1];
	}
	
	return [NSNumber numberWithInt:0];
}
-(void)updateFieldAtIndex:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue{
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[entryCell.fieldButton setTitle:selectedValue forState:UIControlStateNormal];
	//[entryCell.fieldButton setTitleColor:iosStandaredWhiteColor forState:UIControlStateNormal];//DE5235 Ullas M L
	//[entryCell.fieldName setTextColor:iosStandaredWhiteColor];//DE5235 Ullas M L
	
	if (entryCell.fieldText != nil) {
		//[entryCell.fieldText setTextColor:iosStandaredWhiteColor];//DE5235 Ullas M L
		[[entryCell fieldText] setText:selectedValue];
	}
}

-(void)updateDependentFields:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue{
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[entryCell.fieldButton setTitle:selectedValue forState:UIControlStateNormal];
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

	if (expenseEntryCellView.fieldText != nil) {
		[expenseEntryCellView.fieldText setUserInteractionEnabled:YES];
		expenseEntryCellView.fieldText.textColor = NewRepliconStandardBlueColor;//US4065//Juhi
	}
}

-(void)disableExpenseFieldAtIndex:(NSIndexPath *)indexPath{
	G2ExpenseEntryCellView	*expenseEntryCellView = (G2ExpenseEntryCellView *) [self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	expenseEntryCellView.fieldName.textColor=[UIColor grayColor];
	[expenseEntryCellView setUserInteractionEnabled:NO];
	[expenseEntryCellView.fieldButton setEnabled:NO];
	[expenseEntryCellView.fieldButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
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
	NSIndexPath *currentInd;
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
			if ([cell isUserInteractionEnabled] ) { //&& ![[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:CHECK_MARK]
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
			if ([cell isUserInteractionEnabled] ) { //&& ![[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:CHECK_MARK]
				if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:CHECK_MARK]) {
					return nil;
				}
				return previousIndexPath;
			}
		}
	}
	
	return nil;
}

-(NSMutableArray *)setfirstSectionFields{
	
	
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
	NSMutableDictionary *dict1;
	NSMutableDictionary *dict2;
	NSNumber *selectedCurrencyIndex = nil;
	NSString *selectedExpenseTypeCode = nil;
	NSNumber *selectedCurrencyIdentity = nil;
	
	G2ExpensesModel *expensesModel =[[G2ExpensesModel alloc] init];
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	
	NSDictionary *selectedExpenseEntry = [[NSUserDefaults standardUserDefaults] objectForKey: @"SELECTED_EXPENSE_ENTRY"];
	NSString *currencyType = [selectedExpenseEntry objectForKey:@"currencyType"];
	
	NSString *netAmountValue=[selectedExpenseEntry objectForKey:@"netAmount"];
	
	self.baseCurrency=[selectedExpenseEntry objectForKey:@"currencyType"];
	self.currenciesArray = [supportDataModel getSystemCurrenciesFromDatabase];
	
	int selectedIndex = [G2Util getObjectIndex:currenciesArray withKey:@"symbol" forValue:baseCurrency];
	selectedIndex = selectedIndex == -1 ? 0 : selectedIndex;
	
	if (currenciesArray != nil && [currenciesArray count] >0) {
		if (selectedIndex != -1) {
			selectedCurrencyIdentity = [[currenciesArray objectAtIndex:selectedIndex] objectForKey:@"identity"];
		}
		
		
		if (currencyIdentity == nil ) {
			self.currencyIdentity = [[currenciesArray objectAtIndex:selectedIndex] objectForKey:@"identity"];
		}
	}
	
	
	if (selectedIndex != -1) {
		selectedCurrencyIndex = [NSNumber numberWithInt:selectedIndex];
	}
	else {
		selectedCurrencyIndex = [NSNumber numberWithInt:0];
	}
	
	dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(@"Currency", @"")  ,@"fieldName",
			 DATA_PICKER,@"fieldType",
			 baseCurrency,@"defaultValue",
			 selectedCurrencyIndex,@"selectedIndex",
			 baseCurrency,@"selectedDataSource",
			 nil];
	if (currenciesArray != nil && [currenciesArray count] > 0) {
		[dict2 setObject:currenciesArray forKey:@"dataSourceArray"];
	}
	if (selectedCurrencyIdentity != nil) {
		[dict2 setObject:selectedCurrencyIdentity forKey:@"selectedDataIdentity"];
	}
	
	if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific) {
		
		NSString *projectIdentity =[selectedExpenseEntry objectForKey:@"projectIdentity"];
        if (projectIdentity!=nil && [projectIdentity isEqualToString:@""])
        {
                projectIdentity=@"null";
        }
		
		//NSArray *projIdsArray = [[expensesModel getExpenseProjectIdentitiesFromDatabase] retain];
		
		/*if ([self isProjectAvailableToUser]) {
         
         }else {
         if (projIdsArray != nil && [projIdsArray count] > 0)
         projectIdentity = [[projIdsArray objectAtIndex:0] objectForKey:@"identity"];
         }*/
        
		
		//self.clientsArr=[expensesModel getExpenseClientsFromDatabase];
          self.clientsArr=[expensesModel getAllClientsforDownloadedExpenseEntries];
        if ([clientsArr count]==0) {
            hasClient=FALSE;
        }
        else if ([clientsArr count]==1) {
            if([[[clientsArr objectAtIndex:0] objectForKey:@"name"]  isEqualToString:RPLocalizedString(NONE_STRING, @"") ])
            {
                hasClient=FALSE;
            }
        }
        
		NSString *clientIdentity =[selectedExpenseEntry objectForKey:@"clientIdentity"];
		if (clientIdentity!=nil && [clientIdentity isEqualToString:@""]) {
			clientIdentity=@"null";
             [self disableExpenseFieldAtIndex: [NSIndexPath indexPathForRow:1 inSection:0]];
		}		
		
		NSString *clientName =[selectedExpenseEntry objectForKey:@"clientName"];
		NSString *projectName =[selectedExpenseEntry objectForKey:@"projectName"];
		
		if ( projectIdentity!=nil && [projectIdentity isEqualToString:@""]) {
			//DE8583
            if (permissionType == PermType_Both) {
                projectIdentity = @"null";
            }

		}
		if ( projectName!=nil && [projectName isEqualToString:@""]) {
			projectName = RPLocalizedString(NONE_STRING, @"");
		}
		if (clientName!=nil && [clientName isEqualToString:@""]) {
			clientName = RPLocalizedString(NONE_STRING, @"");
             [self disableExpenseFieldAtIndex: [NSIndexPath indexPathForRow:1 inSection:0]];
		}
        
        
		NSMutableArray *projectsArr =nil;
		if (clientIdentity!=nil)	{
			projectsArr =[expensesModel getExpenseProjectsForSelectedClientID:clientIdentity];
		}
		
        
        
        
        
        
        
//        NSMutableDictionary *clientDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                           RPLocalizedString(CLIENT, @""),@"fieldName",
//                                           clientsArr,@"clientsArr",
//                                           MOVE_TO_NEXT_SCREEN, @"fieldType",
//                                           clientName,     @"clientName",
//                                           clientIdentity, @"clientIdentity",
//                                           [NSNumber numberWithInt:selectedClientIndex],@"selectedClientIndex",
//                                           RPLocalizedString(@"Select", @""), @"defaultValue", nil];
//        if (clientIdentity!=nil && ![clientIdentity isKindOfClass:[NSNull class]])
//        {
//            [clientDict setObject:clientName forKey: @"defaultValue"];
//        }
        
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
        [clientDict setObject: [NSNumber numberWithInteger:selectedClientIndex] forKey: @"selectedClientIndex"];
        
        
        
        [firstSectionfieldsArray addObject:clientDict];

//        NSMutableDictionary *projectDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                            RPLocalizedString(@"Project", @""),@"fieldName",
//                                            projectsArr,@"projectsArray",
//                                            MOVE_TO_NEXT_SCREEN, @"fieldType",
//                                            projectName,     @"projectName",
//                                            projectIdentity, @"projectIdentity",
//                                            [NSNumber numberWithInt:selectedClientIndex],@"selectedProjectIndex",
//                                            RPLocalizedString(@"Select", @""), @"defaultValue", nil];

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
        if (projectIdentity!=nil && ![projectIdentity isKindOfClass:[NSNull class]])
        {
            [projectDict setObject:projectIdentity forKey: @"projectIdentity"];
        }
        if (projectIdentity!=nil && ![projectIdentity isKindOfClass:[NSNull class]])
        {
            [projectDict setObject:projectName forKey: @"defaultValue"];
        }
        else
        {
            [projectDict setObject: RPLocalizedString(@"Select", @"") forKey: @"defaultValue"];
        }
        [projectDict setObject: [NSNumber numberWithInteger:selectedProjectIndex] forKey: @"selectedProjectIndex"];
        
        [firstSectionfieldsArray addObject:projectDict];
		
//		dict0 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//				 RPLocalizedString(@"Project", @""),@"fieldName",
//				 DATA_PICKER,@"fieldType",
//				 clientProjectName,@"defaultValue",
//				 projectIdentity,@"projectIdentity",
//				 clientIdentity,@"clientIdentity",
//				 projectName,@"projectName",
//				 clientName,@"clientName",
//				 [NSNumber numberWithInt:projectIndex],@"selectedProjectIndex",
//				 [NSNumber numberWithInt:clientIndex],@"selectedClientIndex",
//				 clientsArr,@"clientsArray",
//				 projectsArr,@"projectsArray",
//				 nil];
		
		
		NSMutableArray *expenseTypeArr=nil;
		if (projectIdentity!=nil)
			expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:projectIdentity];
		
		NSString *selectedDataSource =nil;
		NSString *selectedDataIdentity =nil;
		NSString *entryExpenseType = [selectedExpenseEntry objectForKey:@"expenseTypeName"];
		
		NSNumber *selectedTypeIndex = [NSNumber numberWithInt:0];
		
		if ( expenseTypeArr!=nil && [expenseTypeArr count]>0) {
			NSUInteger i, count = [expenseTypeArr count];
			for (i = 0; i < count; i++) {
				NSDictionary * expenseType = [expenseTypeArr objectAtIndex:i];
				if([[expenseType objectForKey:@"name"] isEqualToString:entryExpenseType]) {
					selectedDataSource = [expenseType objectForKey:@"name"];
					//ravi - This value is overwritten by expenseTypeIdentity below
					//selectedDataIdentity = [expenseType objectForKey:@"identity"];
					selectedTypeIndex = [NSNumber numberWithInteger:i];
					selectedExpenseTypeCode = [expenseType objectForKey:@"type"]; 
				}
			}
			
		}
		selectedDataIdentity=[selectedExpenseEntry objectForKey:@"expenseTypeIdentity"];
		
		dict1	= [NSMutableDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(@"Type", @""),@"fieldName",
				   DATA_PICKER,@"fieldType",
				   entryExpenseType,@"defaultValue",
				   selectedTypeIndex,@"selectedIndex",
				   selectedDataIdentity, @"selectedDataIdentity",
				   expenseTypeArr,@"dataSourceArray",
				   selectedDataSource,@"selectedDataSource",
				   nil];
		
//		[firstSectionfieldsArray addObject:dict0];
		[firstSectionfieldsArray addObject:dict1];
		
	}
    else if (permissionType == PermType_NonProjectSpecific){
		
		NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:@"null"];
		NSString *selectedDataSource = nil;
		NSString *selectedDataIdentity=nil;
		NSString *expenseTypeName = [selectedExpenseEntry objectForKey:@"expenseTypeName"];
		NSNumber *selectedTypeIndex = [NSNumber numberWithInt:0];
		if (expenseTypeArr !=nil && [expenseTypeArr count]>0){ 
			NSUInteger i, count = [expenseTypeArr count];
			for (i = 0; i < count; i++) {
				NSDictionary * expenseType = [expenseTypeArr objectAtIndex:i];
				if([[expenseType objectForKey:@"name"] isEqualToString:expenseTypeName]) {
					selectedDataSource = [expenseType objectForKey:@"name"];
					//ravi - This value is overwritten by expenseTypeIdentity below
					//selectedDataIdentity = [expenseType objectForKey:@"identity"];
					selectedTypeIndex = [NSNumber numberWithInteger:i];
					selectedExpenseTypeCode = [expenseType objectForKey:@"type"]; 
				}
			}
		}
		
		selectedDataIdentity=[selectedExpenseEntry objectForKey:@"expenseTypeIdentity"];
		
		dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(@"Type", @""),@"fieldName",
				 DATA_PICKER,@"fieldType",
				 expenseTypeName,@"defaultValue",
				 selectedTypeIndex,@"selectedIndex",
				 selectedDataIdentity,@"selectedDataIdentity",
				 expenseTypeArr,@"dataSourceArray",
				 selectedDataSource,@"selectedDataSource",
				 nil];
		
		[firstSectionfieldsArray addObject:dict1];
	}
	
	if (selectedExpenseTypeCode == nil) {
		selectedExpenseTypeCode = [selectedExpenseEntry objectForKey:@"type"];
	}
	
	NSString *amountFieldType = MOVE_TO_NEXT_SCREEN;
	if ([selectedExpenseTypeCode isEqualToString:Flat_WithOut_Taxes]) {
		amountFieldType = NUMERIC_KEY_PAD;
		previousWasTaxExpense = NO;
	}
	else if ([selectedExpenseTypeCode isEqualToString:Rated_With_Taxes] ||
			 [selectedExpenseTypeCode isEqualToString:Rated_WithOut_Taxes]) {
		[self changeCurrencyFieldEnableStatus:YES];
	}
	else {
		previousWasTaxExpense = YES;
	}
	
	
	NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  RPLocalizedString(@"Amount", @""),@"fieldName",
								  amountFieldType,@"fieldType", nil];
	//	  amount,@"defaultValue", nil];
	NSString *amount=nil;
	if (currencyType!=nil && netAmountValue !=nil) {
		amount = [G2Util formatDoubleAsStringWithDecimalPlaces: [netAmountValue doubleValue]];
		//amount = [NSString stringWithFormat:@"%@ %@", currencyType, formattedTotalReimbursementString];
	}
	if (amount!=nil) {
		[dict3 setObject:amount forKey:@"defaultValue"];
	}
	
	[firstSectionfieldsArray addObject:dict2];
	[firstSectionfieldsArray addObject:dict3];
    
    //    //Fix for DE3362//Juhi
    //	NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
    //    [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
    //DE4801//Juhi
    NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
	if (permissionType == PermType_NonProjectSpecific) {
		amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
	}
    
	[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
	
   
	return firstSectionfieldsArray;
}

-(NSMutableArray *)setSecondSectionFields{
	//Fix for DE3597//juhi
    int index=0;
	//NSMutableArray *secondSectionArray = [NSMutableArray array];
	if (secondSectionfieldsArray == nil) {
		NSMutableArray *tempsecondSectionfieldsArray = [[NSMutableArray alloc] init];
        self.secondSectionfieldsArray=tempsecondSectionfieldsArray;
       
	}
    else
    {
        [self.secondSectionfieldsArray removeAllObjects];
    }
    
	NSDictionary *selectedExpenseEntry = [[NSUserDefaults standardUserDefaults] objectForKey: @"SELECTED_EXPENSE_ENTRY"];
	NSMutableArray *_paymentMethodsArray;
	
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	
	_paymentMethodsArray = [supportDataModel getPaymentMethodsAllFromDatabase];
	
	NSString *entryDate=nil;
    //DE7129
	entryDate =[selectedExpenseEntry objectForKey:@"entryDate"];// [Util getDeviceRegionalDateString:[selectedExpenseEntry objectForKey:@"entryDate"]];
	
	NSMutableDictionary *dict0 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  RPLocalizedString(@"Date", @""),@"fieldName",
								  DATE_PICKER,@"fieldType", nil];
	if (entryDate !=nil) 
		[dict0 setObject:entryDate forKey:@"defaultValue"];
    //Fix for DE3597//juhi
	[secondSectionfieldsArray insertObject: dict0 atIndex: index++];
	NSString *description= [selectedExpenseEntry objectForKey:@"description"];
	NSMutableDictionary *dict1 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								  RPLocalizedString(@"Description",@""),@"fieldName",
								  MOVE_TO_NEXT_SCREEN,@"fieldType", nil];
	
	if (description !=nil) 
		[dict1 setObject:[selectedExpenseEntry objectForKey:@"description"] forKey:@"defaultValue"];
	//Fix for DE3597//juhi
	[secondSectionfieldsArray insertObject: dict1 atIndex: index++];
	BOOL hasExpenseReceipt = !([[selectedExpenseEntry objectForKey:@"expenseReceipt"] isEqualToString:@"No"] || 
							   [[selectedExpenseEntry objectForKey:@"expenseReceipt"] isEqualToString:@""]);
	NSMutableDictionary *dict2 ;
	BOOL billClient = NO;
	billClient = [[selectedExpenseEntry objectForKey:@"billClient"] boolValue];
	dict2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
             RPLocalizedString(@"Bill Client", @""),@"fieldName",
			 CHECK_MARK,@"fieldType",
			 billClient?G2Check_ON_Image:G2Check_OFF_Image,@"defaultValue",
			 nil];
	
	if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
		
		if ([[self getBillClientInfo]intValue]==1){
            //Fix for DE3597//juhi
			[secondSectionfieldsArray insertObject:dict2 atIndex:index++];
		}
    }
    
    NSMutableDictionary *dict3 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  RPLocalizedString(@"Receipt Photo", @""),@"fieldName",
								  IMAGE_PICKER,@"fieldType",
								  (hasExpenseReceipt ? RPLocalizedString(@"Yes", @"Yes")  :RPLocalizedString(@"Add", @"") ),@"defaultValue", nil];
	//Fix for DE3597//juhi
	[secondSectionfieldsArray insertObject: dict3 atIndex: index++];
	//Reimburesement info
	BOOL canReimburse = [[selectedExpenseEntry objectForKey:@"requestReimbursement"] boolValue];
	NSString *reimbursementImage = canReimburse?G2Check_ON_Image : G2Check_OFF_Image;
	NSMutableDictionary *dict4 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  RPLocalizedString(@"Reimburse", @""),@"fieldName",
								  CHECK_MARK,@"fieldType",
								  reimbursementImage,@"defaultValue",
								  nil];
    //Fix for DE3597//juhi
	if ([[self getReimburseInfo] intValue]==1) {
        [secondSectionfieldsArray insertObject:dict4 atIndex:index++];
        
    }
	int selectedPaymentIndex = 0;
	NSString *paymentMethod = [selectedExpenseEntry objectForKey:@"paymentMethodName"];
	NSMutableDictionary *dict5=nil;
	if (paymentMethod == nil || [paymentMethod isEqualToString:@""]
		|| [paymentMethod isKindOfClass:[NSNull class]]) {
		paymentMethod = RPLocalizedString(@"Select", @"");
	}
	if (_paymentMethodsArray == nil) {
	} else if (_paymentMethodsArray != nil && [_paymentMethodsArray count]>0)	{
		
		if (_paymentMethodsArray !=nil && [_paymentMethodsArray count]>0){ 
			NSUInteger  count = [_paymentMethodsArray count];
            int i;
			for (i = 0; i < count; i++) {
				NSDictionary *paymentMethodsDict= [_paymentMethodsArray objectAtIndex:i];
				if([[paymentMethodsDict objectForKey:@"name"] isEqualToString:paymentMethod]) {
					selectedPaymentIndex = i;
				}
			}
		}
		dict5 = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				 RPLocalizedString(@"Payment Method", @""),@"fieldName",
				 DATA_PICKER,@"fieldType",
				 paymentMethod,@"defaultValue", 
				 _paymentMethodsArray,@"dataSourceArray",
				 [[_paymentMethodsArray objectAtIndex:0]objectForKey:@"name"],@"selectedDataSource",
				 [[_paymentMethodsArray objectAtIndex:0]objectForKey:@"identity"],@"selectedDataIdentity",
				 [NSNumber numberWithInt:selectedPaymentIndex],@"selectedIndex",nil];
		
		
	}
	
	//Fix for DE3597//juhi
	//[secondSectionfieldsArray addObject:dict0];
	//[secondSectionfieldsArray addObject:dict1];
	//[secondSectionfieldsArray addObject:dict3];
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
	
	
	
	udfStartIndex=[secondSectionfieldsArray count];//DE8142
	
	
	NSMutableArray *udfInfoArray = [self createUDFInfoDictionary:secondSectionfieldsArray];
	if (udfInfoArray != nil || [udfInfoArray count] > 0) {
		//[secondSectionArray insertObject: udfInfoDictionary atIndex: [secondSectionArray count]];
	}
	self.secondSectionfieldsArray = udfInfoArray;
	
	
	return secondSectionfieldsArray;
}


-(NSMutableArray *) createUDFInfoDictionary:(NSMutableArray*)secondSectionArr
{
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	
	self.udfsArray = [supportDataModel getUserDefineFieldsExpensesFromDatabase];
	NSString *entryId=	[[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"] objectForKey:@"identity"];
	NSMutableDictionary *selectedUdfs=[expensesModel getSelectedUdfsForEntry:entryId andType:@"Expense"];
	if (udfsArray!=nil && [udfsArray count]> 0) {
		for (int i=0; i<[udfsArray count]; i++) {
			
			if ([supportDataModel checkExpensePermissionWithPermissionName:[[udfsArray objectAtIndex:i] objectForKey:@"name"]]==YES) {
				NSDictionary *udfDict = [udfsArray objectAtIndex:i];
				NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
				[dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
				[dictInfo setObject:[udfDict objectForKey:@"identity"] forKey:@"identity"];
				
				
				
				NSString *selectedValue=[[selectedUdfs objectForKey:[udfDict objectForKey:@"identity"]] objectForKey:@"udfValue" ];
				
				if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Numeric"]) {
					[dictInfo setObject:NUMERIC_KEY_PAD forKey:@"fieldType"];
					
					if ([udfDict objectForKey:@"numericDecimalPlaces"]!=nil && !([[udfDict objectForKey:@"numericDecimalPlaces"] isKindOfClass:[NSNull class]])) 
						[dictInfo setObject:[udfDict objectForKey:@"numericDecimalPlaces"] forKey:@"defaultDecimalValue"];
					
					
					if ([udfDict objectForKey:@"numericMinValue"]!=nil && !([[udfDict objectForKey:@"numericMinValue"] isKindOfClass:[NSNull class]])) {
						[dictInfo setObject:[udfDict objectForKey:@"numericMinValue"] forKey:@"defaultMinValue"];
					}
					if ([udfDict objectForKey:@"numericMaxValue"]!=nil && !([[udfDict objectForKey:@"numericMaxValue"] isKindOfClass:[NSNull class]])) {
						[dictInfo setObject:[udfDict objectForKey:@"numericMaxValue"] forKey:@"defaultMaxValue"];
					}
					
					if (selectedValue!=nil  && !([selectedValue isKindOfClass:[NSNull class]])) {
						int decimals = [[dictInfo objectForKey:@"defaultDecimalValue"] intValue];
						NSString *tempValues =	[G2Util formatDecimalPlacesForNumericKeyBoard:[selectedValue doubleValue] withDecimalPlaces:decimals];
						tempValues = [G2Util removeCommasFromNsnumberFormaters:tempValues];
						if (tempValues == nil) {
							
						}else {
							selectedValue = tempValues;
						}
						
						[dictInfo setObject:selectedValue forKey:@"defaultValue"];
					}else {
						[dictInfo setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
						//if ([udfDict objectForKey:@"numericDefaultValue"]!=nil && !([[udfDict objectForKey:@"numericDefaultValue"] isKindOfClass:[NSNull class]])) {
                        //							[dictInfo setObject:[udfDict objectForKey:@"numericDefaultValue"] forKey:@"defaultValue"];
                        //						}else {
                        //							[dictInfo setObject:@"Select" forKey:@"defaultValue"];	
                        //						}
						
						
					}
				}else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Text"]){
					[dictInfo setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
					
					if (selectedValue!=nil && ![selectedValue isKindOfClass:[NSNull class]]) {
						[dictInfo setObject:selectedValue forKey:@"defaultValue"];
					}else {
						[dictInfo setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
						/*if ([[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@"null"]) {
                         [dictInfo setObject:@"" forKey:@"defaultValue"];
                         }else {
                         if ([udfDict objectForKey:@"textDefaultValue"]!=nil) {
                         [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                         }else {
                         [dictInfo setObject:@"Select" forKey:@"defaultValue"];
                         
                         }
                         }*/
						if ([udfDict objectForKey:@"textMaxValue"]!=nil && !([[udfDict objectForKey:@"textMaxValue"] isKindOfClass:[NSNull class]])) 
							[dictInfo setObject:[udfDict objectForKey:@"textMaxValue"] forKey:@"defaultMaxValue"];
					}
					
				}else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Date"]){
					[dictInfo setObject: DATE_PICKER forKey: @"fieldType"];
					
					if ([udfDict objectForKey:@"dateMaxValue"]!=nil && !([[udfDict objectForKey:@"dateMaxValue"] isKindOfClass:[NSNull class]])){ 		
						[dictInfo setObject:[udfDict objectForKey:@"dateMaxValue"] forKey:@"defaultMaxValue"];
					}
					if ([udfDict objectForKey:@"dateMinValue"]!=nil && !([[udfDict objectForKey:@"dateMinValue"] isKindOfClass:[NSNull class]])){ 
						[dictInfo setObject:[udfDict objectForKey:@"dateMinValue"] forKey:@"defaultMinValue"];
					}
					//Fix For DE4000//Juhi
                    //					if (selectedValue!=nil && ![selectedValue isKindOfClass:[NSNull class]] && ![selectedValue isEqualToString:@"<null>"])
                    if (selectedValue!=nil && ![selectedValue isKindOfClass:[NSNull class]] && ![selectedValue isEqualToString:@"null"])
                    {
						[dictInfo setObject:[G2Util getDeviceRegionalDateString:selectedValue] forKey:@"defaultValue"];
					}else {
						[dictInfo setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
						/*if ([udfDict objectForKey:@"isDateDefaultValueToday"]!=nil && !([[udfDict objectForKey:@"isDateDefaultValueToday"] isKindOfClass:[NSNull class]])){ 
                         if ([[udfDict objectForKey:@"isDateDefaultValueToday"]intValue]==1) {
                         [dictInfo setObject:[Util convertPickerDateToString:[NSDate date]] forKey:@"defaultValue"];
                         }else{
                         if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]])){ 
                         [dictInfo setObject:[udfDict objectForKey:@"dateDefaultValue"] forKey:@"defaultValue"];
                         }else {
                         [dictInfo setObject:@"Select" forKey:@"defaultValue"];
                         }
                         }
                         }else {
                         if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]])){ 
                         [dictInfo setObject:[udfDict objectForKey:@"dateDefaultValue"] forKey:@"defaultValue"];
                         }else {
                         [dictInfo setObject:@"Select" forKey:@"defaultValue"];
                         }
                         }*/
					}
				}else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"DropDown"]){
					[dictInfo setObject:DATA_PICKER forKey:@"fieldType"];
					NSMutableArray *dataSource= [supportDataModel getDropDownOptionsForUDFIdentity:[udfDict objectForKey:@"identity"]];
					
					if (dataSource!=nil && ![dataSource isKindOfClass:[NSNull class]]) {
						for (int i=0; i<[dataSource count]; i++) {
							NSMutableDictionary *dict =[NSMutableDictionary dictionary];
							if ([[dataSource objectAtIndex:i] objectForKey:@"value"]!=nil) 
								[dict setObject:[[dataSource objectAtIndex:i] objectForKey:@"value"] forKey:@"name"];
							if ([[dataSource objectAtIndex:i] objectForKey:@"defaultOption"]!=nil) {
								if ([[[dataSource objectAtIndex:i] objectForKey:@"defaultOption"]intValue] == 1) {
                                    //	[dictInfo setObject:[[dataSource objectAtIndex:i] objectForKey:@"value"] forKey:@"defaultValue"];
								}
								//[dict setObject:[[dataSource objectAtIndex:i] objectForKey:@"defaultOption"] forKey:@"defaultValue"];
							}
							if ([[dataSource objectAtIndex:i] objectForKey:@"identity"]!=nil) 
								[dict setObject:[[dataSource objectAtIndex:i] objectForKey:@"identity"] forKey:@"identity"];
							[dataSource replaceObjectAtIndex:i withObject:dict];
							
							if (selectedValue == nil || [selectedValue isKindOfClass:[NSNull class]]) {
								if ([dictInfo objectForKey:@"defaultValue"] == nil)
									[dictInfo setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
								
							}else {
								[dictInfo setObject:selectedValue forKey:@"defaultValue"];
							}
						}
						
						[dictInfo setObject:dataSource forKey:@"dataSourceArray"];
						[dictInfo setObject:[[dataSource objectAtIndex:0]objectForKey:@"name"] forKey:@"selectedDataSource"];
						
					}else {
						[dictInfo setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
					}
					
				}
                countEditExpenseUDF++;
				[secondSectionArr insertObject:dictInfo atIndex:[secondSectionArr count]];
				//return dictInfo;
			}
			
		}
		
		return secondSectionArr;
		
	}
	
	return secondSectionArr;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    countEditExpenseUDF=0;
    previousWasTaxExpense = NO;
    typeAvailableForProject = YES;
    permissionType = [G2PermissionsModel getProjectPermissionType]; 
    imageDeletePressed=NO;
    typeChanged = NO;
    //Input providing Dicitonary
    if (editExpenseEntryDict == nil) {
        NSMutableDictionary *tempeditExpenseEntryDict=[[NSMutableDictionary alloc]init];
        self.editExpenseEntryDict = tempeditExpenseEntryDict ;
        
    }
    
    //Saving details dictionary after editing the entry
    if (expenseEntryDetailsDict == nil) {
        NSMutableDictionary *tempexpenseEntryDetailsDict=[[NSMutableDictionary alloc]init];
        self.expenseEntryDetailsDict = tempexpenseEntryDetailsDict;
        
    }
    
    memoryWarnCount = 0;
    hasClient=TRUE;
    [self setfirstSectionFields];
    [self setSecondSectionFields];
    //------------------------------------ US4234 Ullas M L------------------------------------------
    NSString *projectdId = nil;
    NSString *typeName = nil;
    if (firstSectionfieldsArray != nil && [firstSectionfieldsArray count] >0) {
        if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific) {
            projectdId = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"projectIdentity"];
            typeName = [[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"defaultValue"];
        }else {
            projectdId = @"null";
            typeName = [[firstSectionfieldsArray objectAtIndex:0] objectForKey:@"defaultValue"];
        }
        
    }
    G2SupportDataModel *supportDataMdl = [[G2SupportDataModel alloc] init];
    NSString *taxModeOfExpenseType = [supportDataMdl getExpenseModeOfTypeForTaxesFromDB:projectdId withType:typeName andColumnName:@"type"];
    
    
    [[NSUserDefaults standardUserDefaults]setObject:taxModeOfExpenseType forKey:@"previousTaxType"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //--------------------------------------------------------------------------------------------
    totalFieldsCount = [firstSectionfieldsArray count]+[secondSectionfieldsArray count];
    
    int heightforNorEdit=100;
    int scrollHeight=0;
    
    if(permissionType==PermType_ProjectSpecific || permissionType==PermType_Both)
    {
        //scrollHeight=scrollHeight+ROW_HEIGHT;
        heightforNorEdit=heightforNorEdit+ROW_HEIGHT;
    }
    
    //DE7757
    if (canNotEdit)
    {
        scrollHeight =([firstSectionfieldsArray count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT)+35.0+48.0+ROW_HEIGHT+ROW_HEIGHT;
    }
    else {
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
            scrollHeight =([firstSectionfieldsArray count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT)+35.0+40.0+20.0+ROW_HEIGHT+115;
        }
        else{
            scrollHeight =([firstSectionfieldsArray count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT)+35.0+40.0+20.0+ROW_HEIGHT+90;
        }
        
    }
    UITableView *tempeditExpenseEntryTable=[[UITableView alloc]initWithFrame:CGRectMake(0,5, self.view.frame.size.width, self.view.frame.size.height+(countEditExpenseUDF*ROW_HEIGHT)+ROW_HEIGHT+heightforNorEdit) style:UITableViewStyleGrouped];//US4065//Juhi
    self.tnewExpenseEntryTable=tempeditExpenseEntryTable;
   
    
    [tnewExpenseEntryTable setDelegate:self];
    [tnewExpenseEntryTable setDataSource:self];
    //[editExpenseEntryTable setBackgroundColor:[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0]];
    [self.tnewExpenseEntryTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];//DE5655 Ullas M L
    [tnewExpenseEntryTable setBackgroundColor:G2RepliconStandardBackgroundColor];
    tnewExpenseEntryTable.backgroundView=nil;
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    //        if (countEditExpenseUDF<=3)
    //        {
    //            scrollView.contentSize= CGSizeMake(self.view.frame.size.width,scrollHeight);
    //        }
    //        else
    scrollView.contentSize= CGSizeMake(self.view.frame.size.width,scrollHeight);
    
    
    [scrollView addSubview:tnewExpenseEntryTable];
    
    self.mainScrollView=scrollView;
    [self.view addSubview:self.mainScrollView];
    
   
    
    [self.tnewExpenseEntryTable setScrollEnabled:FALSE];
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
    
    
    
    
    
    UIBarButtonItem *tempsaveButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(G2SAVE_BTN_TITLE, G2SAVE_BTN_TITLE)
                                                                       style:UIBarButtonItemStylePlain 
                                                                      target:self 
                                                                      action:@selector(saveAction:)];
    self.saveButton=tempsaveButton;
    
    [self.navigationItem setRightBarButtonItem:saveButton animated:NO];
    [saveButton setTag:SAVE_TAG_INDEX];
    
    
    
    UIView *footerNewExpenses = [UIView new];
    [footerNewExpenses setFrame:CGRectMake(0.0,
                                           50,
                                           tnewExpenseEntryTable.frame.size.width,
                                           200.0)];
    [footerNewExpenses setBackgroundColor:[UIColor clearColor]];
    [tnewExpenseEntryTable setTableFooterView:footerNewExpenses];
    
    [self configurePicker];
    
    [self handlePermissions];
    
    //Handling Leaks
    
    
    imgDownloaded=NO;
    projectAvailToUser = YES;
    
    

}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		return 35;   // return 55.0;
	}else {
		return 30;   //return 35;
	}
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		UILabel	*expenseLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.15,
																		 4.0,   //0.0,
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
		[expenseLabel setText:RPLocalizedString(@"Expense",@"")];
		
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
        //[expenseHeader addSubview:descExpHeaderLabel];
		
		
		return expenseHeader;
	} else if (section ==1) {
		UILabel	*otherLabel= [[UILabel alloc] initWithFrame:CGRectMake(10,//38.0,   //40.0,
																	   0.0,
																	   250.0,
                                                                       30.0)];//US4065//Juhi
		//UIImage *img1 = [Util thumbnailImage:DetailsInfoHeaderImage];
        //		UIImageView	*otherImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0,
        //																				3.5,   //0.0,
        //																				img1.size.width,
        //																				img1.size.height)];
		//[otherImage setImage:img1];
		[otherLabel setBackgroundColor:[UIColor clearColor]];
		[otherLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];//US4065//Juhi
		[otherLabel setTextColor:RepliconStandardBlackColor];
		[otherLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
		[otherLabel setText:RPLocalizedString(@"Detail",@"")];
		
		
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
	

	if (section == EDIT_EXPENSE_EXPENSE1) {
		return [firstSectionfieldsArray count];
	}
	if (section == EDIT_EXPENSE_DETAILS1) {
		return [secondSectionfieldsArray count];
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[G2ExpenseEntryCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	// Configure the cell...
	cell.expenseEntryCellDelegate=self;
	
	
	if ( indexPath.row <[firstSectionfieldsArray count]&& indexPath.section == EDIT_EXPENSE_EXPENSE1) {
		NSInteger tagIndex = FIRSTSECTION_TAG_INDEX+indexPath.row;
		
		//[cell addFieldAtIndex:indexPath.row atSection:indexPath.section];
		[cell addFieldAtIndex:indexPath withTagIndex: tagIndex withObj: [firstSectionfieldsArray objectAtIndex:indexPath.row]];
		[cell.fieldButton addTarget:self action:@selector(buttonPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
		[cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	}
	if ( indexPath.row <[secondSectionfieldsArray count] && indexPath.section== EDIT_EXPENSE_DETAILS1) {
		NSInteger tagIndex = SECONDSECTION_TAG_INDEX+indexPath.row;
		//[cell addFieldAtIndex:indexPath.row atSection:indexPath.section];
		[cell addFieldAtIndex:indexPath withTagIndex: tagIndex withObj: [secondSectionfieldsArray objectAtIndex:indexPath.row]];
		[cell.fieldButton addTarget:self action:@selector(buttonPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
	}	
	
	
	/*if ([expenseSheetStatus isEqualToString:@"Not Submitted"] || [expenseSheetStatus isEqualToString:@"Rejected"]) {
     [cell setUserInteractionEnabled:YES];
     [saveButton setEnabled:YES];
     [footerView setHidden:NO];
     }else {
     if([[cell dataObj] objectForKey:@"fieldType"]==IMAGE_PICKER && ! [[[cell dataObj] objectForKey:@"defaultValue"] isEqualToString:@"Add"] ){
     [cell setUserInteractionEnabled:YES];
     [saveButton setEnabled:NO];
     [footerView setHidden:YES];
     }else {
     [cell setUserInteractionEnabled:NO];
     [saveButton setEnabled:NO];
     [footerView setHidden:YES];
     }
     
     }*/
	
	//Vijay : change frame for Project & Type to increase readability - DE2801.
	//Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    CGRect frame;

	NSString *fieldName = [[cell dataObj] objectForKey:@"fieldName"];
	if (indexPath.section == G2EXPENSE_SECTION && ([fieldName isEqualToString:ClientProject] || 
                                                 [fieldName isEqualToString:RPLocalizedString(@"Type", @"")] ||
                                                 [fieldName isEqualToString:RPLocalizedString(CLIENT, @"")])) {
		
        //[cell.fieldButton setFrame:CGRectMake(98.0, 6.0, 182.0, 30.0)];
        //Fix for ios7//JUHI
        if (version>=7.0)
        {
            frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
            
        }
        else{
            frame=CGRectMake(98.0, 8.0, 192.0, 30.0);
        }
		[cell.fieldButton setFrame:frame];//US4065//Juhi
	}
	
	
	if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: MOVE_TO_NEXT_SCREEN]) {
		[[cell fieldName] setText:[[cell dataObj]  objectForKey:@"fieldName"]];
		if ([[[cell dataObj]  objectForKey:@"defaultValue"] isEqualToString:@""]) {
			[[cell fieldButton] setTitle:RPLocalizedString(@"Add", @"Add")  forState:UIControlStateNormal];
			[cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		}else {
			if (indexPath.section == 0 && [[[cell dataObj]  objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Amount", @"")]) {
				//NSString *amountWithCommas = [Util formatDoubleAsStringWithDecimalPlaces:[[[cell dataObj]objectForKey:@"defaultValue"]doubleValue]];
				[cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
				[[cell fieldButton] setTitle:[[cell dataObj]  objectForKey:@"defaultValue"] forState:UIControlStateNormal];
			}else {
				[cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
				[[cell fieldButton] setTitle:[[cell dataObj]  objectForKey:@"defaultValue"] forState:UIControlStateNormal];
                if ([fieldName isEqualToString:ClientProject]) 
                {
                    if (permissionType == PermType_ProjectSpecific) 
                    {
                        if ([[[cell dataObj]  objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(NONE_STRING, @"")]) 
                        {
                            [[cell fieldButton] setTitle:RPLocalizedString(SelectString, @"") forState:UIControlStateNormal];
                        }
                    }
                    else if (permissionType == PermType_Both) 
                    {
                        if ([[[cell dataObj]  objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(SelectString, @"")]) 
                        {
                            [[cell fieldButton] setTitle:RPLocalizedString(NONE_STRING, @"") forState:UIControlStateNormal];
                        }
                        
                    }

                }
                                
			}
			
			
		}
	}
	else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: CHECK_MARK]) {
		if ([[cell dataObj] objectForKey:@"fieldName"] == RPLocalizedString(@"Bill Client", @"")){
			if ([[cell.dataObj objectForKey:@"defaultValue"] isEqualToString:G2Check_OFF_Image]) {
				[cell.fieldName setTextColor:RepliconStandardGrayColor];
				if ([self billClientShouldDisble]) {
					[cell.switchMark setUserInteractionEnabled:NO];
					[cell setUserInteractionEnabled:NO];
				}else {
					[cell.switchMark setUserInteractionEnabled:YES];
					[cell setUserInteractionEnabled:YES];
				}
				
			}else {
				[cell.fieldName setTextColor:RepliconStandardBlackColor];
			}
		}else {
			[cell.fieldButton setUserInteractionEnabled:YES];
		}
		
	}
	else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: IMAGE_PICKER]|| [[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER] ||
			 [[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: DATE_PICKER]) {
		[[cell fieldName] setText:[[cell dataObj] objectForKey:@"fieldName"]];
		[[cell fieldButton] setTitle:[[cell dataObj] objectForKey:@"defaultValue"] forState:UIControlStateNormal];
		[cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		
		if ([[cell dataObj] objectForKey:@"fieldName"] == RPLocalizedString(@"Currency", @"")){
			if ([self currencyFieldHandlings]) 
			{
				[cell grayedOutRequiredCell];
			}else {
				[cell enableRequiredCell];
			}
            
		}
		
        
	}else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: NUMERIC_KEY_PAD]){
		[cell.fieldButton setHidden:YES];
		[cell.fieldText setHidden:NO];
	}	else {
		[cell.fieldButton setHidden:NO];
		[cell.fieldText setHidden:YES];
	}
	
	//DE3566//Juhi
    //	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	if (canNotEdit) 
		[self disableAllFieldsForWaitingSheets:cell];
	
    
    
	
	return cell;
	
}

-(void)disableAllFieldsForWaitingSheets:(G2ExpenseEntryCellView*)cellObj
{
	if([[[cellObj dataObj] objectForKey:@"fieldType"] isEqualToString: IMAGE_PICKER]&& ! [[[cellObj dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(@"Add", @"")] ){
		[cellObj setUserInteractionEnabled:YES];
		[saveButton setEnabled:NO];
		[footerView setHidden:YES];
		[cellObj enableRequiredCell];
	}else {
		[cellObj setUserInteractionEnabled:NO];
		[saveButton setEnabled:NO];
		[footerView setHidden:YES];
		[cellObj grayedOutRequiredCell];
	}
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
}

-(BOOL)billClientShouldDisble
{
	if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0) {
		if ([[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"fieldName"] ==  RPLocalizedString(@"Project", @"")) {
			if ([[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"clientName"]!=nil &&
				[[[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"clientName"] isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
				return YES;
			}else {
				return NO;
			}
			
		}
	}
	return NO;
}
-(void)disableSwitchWhenNoClient
{
	NSIndexPath *billClientIndex = [NSIndexPath indexPathForRow:2 inSection:1];
	G2ExpenseEntryCellView * billClientCell = (G2ExpenseEntryCellView*)[tnewExpenseEntryTable cellForRowAtIndexPath:billClientIndex];
	if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0) {
		if ([[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"fieldName"] ==  RPLocalizedString(@"Project", @"")) {
			if ([[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"clientName"]!=nil &&
				[[[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"clientName"] isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
				[[billClientCell switchMark] setEnabled:NO];
				[[billClientCell switchMark]setUserInteractionEnabled:NO];
				[[billClientCell switchMark] setOn:NO];
				[[billClientCell fieldName] setTextColor:RepliconStandardGrayColor];
			}else {
				[[billClientCell switchMark] setEnabled:YES];
				[[billClientCell switchMark]setUserInteractionEnabled:YES];
				[[billClientCell switchMark] setOn:YES];
				[[billClientCell fieldName] setTextColor:RepliconStandardBlackColor];
			}
			
		}
	}
}

-(BOOL)currencyFieldHandlings
{
	//NSString *projectdId = nil;
	NSString *typeName = nil;
	if (firstSectionfieldsArray != nil && [firstSectionfieldsArray count] >0) {
		if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific) {
			//projectdId = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"projectIdentity"];
			typeName = [[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"defaultValue"];
		}else {
			//projectdId = @"null";
			typeName = [[firstSectionfieldsArray objectAtIndex:0] objectForKey:@"defaultValue"];
		}
		
	}
	
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
    NSString *taxModeOfExpenseType = [supportDataModel getExpenseModeOfTypeForTaxesFromDBwithType:typeName andColumnName:@"type"];
	
    //DE7593 Ullas M L
	if (taxModeOfExpenseType != nil && ([taxModeOfExpenseType isEqualToString:Rated_With_Taxes] || 
                                        [taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]) ){
		
		return YES;
	}
	return NO;
       
}


-(void)switchButtonHandlings:(id)entryCellObj{
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

#pragma mark HandleButtonClicks

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
}


-(void)handleButtonClicks:(NSIndexPath*)selectedButtonIndex{
	[self hideKeyBoard];
	
	if (selectedButtonIndex.row != currentIndexPath.row || selectedButtonIndex.section != currentIndexPath.section) {
		[self tableViewCellUntapped:currentIndexPath];
	}
	
	self.currentIndexPath = [NSIndexPath indexPathForRow: selectedButtonIndex.row inSection: selectedButtonIndex.section];
    
    
	G2ExpenseEntryCellView *cell=nil;	
	cell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath: selectedButtonIndex];
	
	if (cell == nil || [cell dataObj] == nil)	{
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
		[self dataPickerAction: cell withEvent: nil];
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
	else if([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: CHECK_MARK])	{
		[self switchButtonHandlings:cell];
	} 
	else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString: NUMERIC_KEY_PAD]) {
		[self numericKeyPadAction: cell withEvent:nil];
	}
	else {
		DLog(@"Error: Invalid field type");
	}
}

- (void) buttonPressed: (id) sender withEvent: (UIEvent *) event{
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView: tnewExpenseEntryTable];
    NSIndexPath * indexPath = [tnewExpenseEntryTable indexPathForRowAtPoint: location];
	
	[self tableCellTappedAtIndex:indexPath];
	
}

-(void)hideKeyBoard{
	if(numberUdfText != nil)
		[numberUdfText resignFirstResponder];
	[self resetTableViewUsingSelectedIndex:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	return ROW_HEIGHT;//US4065//Juhi
	
}										

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Navigation logic may go here. Create and push another view controller.
	
	if (indexPath.row != currentIndexPath.row || indexPath.section != currentIndexPath.section) {
		[self tableViewCellUntapped:currentIndexPath];
	}
	//[self performActionWithRowSelection: indexPath];
	[self tableCellTappedAtIndex:indexPath];
}

#pragma mark DeselectSelectedCells
-(void)deselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[entryCell.fieldName setTextColor:RepliconStandardBlackColor];
	[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	[entryCell.fieldText setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
    [entryCell setBackgroundColor:iosStandaredWhiteColor];//DE3566//Juhi
	
	[tnewExpenseEntryTable deselectRowAtIndexPath:indexPath animated:YES];	
}

-(void)animateCellWhichIsSelected
{   isPickerDoneClicked=YES;[self resetTableViewUsingSelectedIndex:nil];//DE5011 ullas
	[[[UIApplication sharedApplication] delegate]performSelector:@selector(stopProgression)];
	
	[tnewExpenseEntryTable selectRowAtIndexPath:currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	
	//[self performSelector:@selector(deselectRowAtIndexPath:) withObject:currentIndexPath afterDelay:0.50];//DE2949 FadeOut is slow
	//[self performSelector:@selector(deselectRowAtIndexPath:) withObject:currentIndexPath afterDelay:0.0];
    [self performSelector:@selector(deselectRowAtIndexPath:) withObject:currentIndexPath afterDelay:0.15];//DE3566//Juhi
}

#pragma mark -
#pragma mark ButtonActions
#pragma mark -

-(void)cancelAction:(id)sender{
	if(base64Decoded !=nil)
	{
		base64Decoded=nil;
	}
	[self dismissViewControllerAnimated:YES completion:nil];
	RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	[delegate setCurrVisibleViewController: nil];
	[self.navigationController popViewControllerAnimated:YES];
	[editControllerDelegate performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.5];
}

-(void)saveAction:(id)sender{ 
	
	
	if (numberUdfText != nil) {
		[numberUdfText resignFirstResponder];
	}
	[pickerView1 setHidden:YES];
	[pickerViewC setHidden:YES];
    //DE8313
    isPickerDoneClicked=YES;
    [self resetTableViewUsingSelectedIndex:nil];
	[self deselectRowAtIndexPath:currentIndexPath];
   
	
	
#ifdef PHASE1_US2152
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		[G2Util showOfflineAlert];
        [self pickerDone:nil];
		return;
	}
#endif
    
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

	


    
	
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	
	@try {
        /*NSArray *baseCurrencyArray =[[supportDataModel getBaseCurrencyFromDatabase] retain];	
         if (baseCurrencyArray!=nil && [baseCurrencyArray count]>0) 
         currencyIdentity = [[baseCurrencyArray objectAtIndex:0] objectForKey:@"identity"];*/
		NSMutableArray *udfsArrayEnabled = [supportDataModel getEnabledUserDefineFieldsExpensesFromDatabase];
		NSUInteger valueWithOutUdfs = 0;
		if (udfsArrayEnabled != nil && [udfsArrayEnabled count] > 0) {
			valueWithOutUdfs = [udfsArrayEnabled count];
		}
        NSMutableDictionary *dictionary=[NSMutableDictionary dictionary];
        if (secondSectionfieldsArray!=nil && [secondSectionfieldsArray count] >0) {
            valueWithOutUdfs = [secondSectionfieldsArray count] - [udfsArrayEnabled count];
            for (int i=0; i<valueWithOutUdfs; i++) {
                [dictionary setObject:[[secondSectionfieldsArray objectAtIndex:i]objectForKey:@"defaultValue"] forKey:[[secondSectionfieldsArray objectAtIndex:i]objectForKey:@"fieldName"]];
            }
        }
		
        
        
        //Get PaymentMethod Id 
        NSString *paymentMethodName=nil;
        if([dictionary objectForKey:@"Payment Method"] !=nil)
            paymentMethodName = [dictionary objectForKey:@"Payment Method"];
        if (paymentMethodName!=nil) {
            if ( [paymentMethodName isEqualToString:RPLocalizedString(@"Select", @"")]) {
                //	[Util errorAlert:@"Please select a Payment Method" errorMessage:@""];
                //	return;
            }else {
                NSMutableArray *paymentMethodId = [expensesModel getExpensePaymentMethodId:paymentMethodName];
                if (paymentMethodId!=nil && [paymentMethodId count]>0) {
                    [dictionary setObject:[[paymentMethodId objectAtIndex:0] objectForKey:@"identity"] forKey:@"paymentMethodId"];
                }
                
            }
        }
        
        if ([dictionary objectForKey:RPLocalizedString(@"Bill Client", @"") ] !=nil) {
            if ([[dictionary objectForKey:RPLocalizedString(@"Bill Client", @"")] isEqualToString:@"G2check_off.png"]) {
                [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"BillClient"];
            }else  if([[dictionary objectForKey:RPLocalizedString(@"Bill Client", @"")] isEqualToString:G2Check_ON_Image]) {
                [dictionary setObject:[NSNumber numberWithInt:1] forKey:@"BillClient"];
            }
        }
        else if (permissionType == PermType_NonProjectSpecific) {
            [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"BillClient"];
        }
        
        if ([dictionary objectForKey:RPLocalizedString(@"Reimburse", @"")] !=nil) {
            if ([[dictionary objectForKey:RPLocalizedString(@"Reimburse", @"")] isEqualToString:@"G2check_off.png"]) {
                [dictionary setObject:[NSNumber numberWithInt:0] forKey:@"Reimburse"];
            }else {
                [dictionary setObject:[NSNumber numberWithInt:1] forKey:@"Reimburse"];
            }
        }
        
        if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0) {
            for (int i=0; i<[firstSectionfieldsArray count]; i++) {
                [dictionary setObject:[[firstSectionfieldsArray objectAtIndex:i]objectForKey:@"defaultValue"]
                               forKey:[[firstSectionfieldsArray objectAtIndex:i]objectForKey:@"fieldName"]];
            }
        }
        ///DE6966 Ullas M L--------------------------------------------------------------------------
        
        if (typeChanged) 
        {
            NSDictionary *infoDict;
            NSString *identity;
            if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
                identity = [[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"];
                infoDict = [firstSectionfieldsArray objectAtIndex:2];
            }else {
                identity = @"null";
                infoDict = [firstSectionfieldsArray objectAtIndex:0];
            }
            
            int ind = [[infoDict objectForKey:@"selectedIndex"]intValue];
            
            NSMutableArray *typesArray=[infoDict objectForKey:@"dataSourceArray"];
            NSString *typeName=nil;
            if (typesArray!=nil && [typesArray count]>0) 
                typeName = [[typesArray objectAtIndex:ind]objectForKey:@"name"];
            
            if (identity!=nil && typeName !=nil) 
            {
                self.expenseUnitLabelArray=[supportDataModel  getExpenseUnitLabelsFromDB:identity withExpenseType:typeName];
                if (!typeChanged)
                    self.expenseUnitLabelArray = [NSMutableArray arrayWithObjects:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"] objectForKey:@"expenseUnitLable"],nil];
                [self setExpenseUnitLable:[self.expenseUnitLabelArray objectAtIndex:0]];
                
            }

        }
        //-------------------------------------------------------------------------------------
        if(baseCurrency!=nil)
            [dictionary setObject:baseCurrency forKey:@"currencyType"];
		
		if (expenseUnitLable != nil) {
			[dictionary setObject:expenseUnitLable forKey:@"expenseUnitLable"];
		}
        
        NSNumber *entryNetAmount = nil;
        NSMutableArray *expenseTypeArr = nil;
        //NSString *expenseTypeName = @"";
        NSString *amount= @"";
        
        double totalAmountDb = 0;
        if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
            if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0) {
                if ([[firstSectionfieldsArray objectAtIndex:4]objectForKey:@"defaultValue"]!=nil) {
                    if ([[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] &&
                        [[[firstSectionfieldsArray objectAtIndex:4]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")]) {
                        //					[Util errorAlert:@"Please select expense type" errorMessage:@""];
                        [G2Util errorAlert:@"" errorMessage:RPLocalizedString(@"Please select expense type", @"Please select expense type")];//DE1231//Juhi
                        [self pickerDone:nil];
                        return;
                    }
                    else if ([[[firstSectionfieldsArray objectAtIndex:4]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")]) {
                        //					[Util errorAlert:@"Please enter Amount" errorMessage:@""];
                        [G2Util errorAlert:@"" errorMessage:RPLocalizedString(@"Please enter Amount",@"Please enter Amount")];//DE1231//Juhi
                        [self pickerDone:nil];
                        return;
                    }
                }
                /*if (typeChanged) {
                 if (![self checkAvailabilityOfTypeForSelectedProject:[[firstSectionfieldsArray objectAtIndex:0]objectForKey:@"projectIdentity"]]) {
                 [self tableViewCellUntapped:currentIndexPath];
                 [Util errorAlert:nil errorMessage:ExpenseType_UnAvailable];
                 return;
                 }
                 }*/
                if ([[firstSectionfieldsArray objectAtIndex:0]objectForKey:@"clientIdentity"]!=nil) {
                    [dictionary setObject:[[firstSectionfieldsArray objectAtIndex:0]objectForKey:@"clientIdentity"] forKey:@"clientIdentity"];
                    [dictionary setObject:[[firstSectionfieldsArray objectAtIndex:0]objectForKey:@"clientName"] forKey:@"clientName"];
                }
                
                if ([[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"]!=nil) {
                    [dictionary setObject:[[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"] forKey:@"projectIdentity"];
                    [dictionary setObject:[[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectName"] forKey:@"projectName"];
                }
                
                if ([[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"selectedDataIdentity"]!=nil)
                    [dictionary setObject:[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"selectedDataIdentity"] forKey:@"expenseTypeIdentity"];
                
                if ([[firstSectionfieldsArray objectAtIndex:4]objectForKey:@"defaultValue"]!=nil) {
                    if ([[[firstSectionfieldsArray objectAtIndex:4] objectForKey:@"fieldType"] isEqualToString: NUMERIC_KEY_PAD]) {
                        amount = [[firstSectionfieldsArray objectAtIndex:4]objectForKey:@"defaultValue"];
                    }
                    else {
                        amount =[[firstSectionfieldsArray objectAtIndex:4]objectForKey:@"defaultValue"];
                    }
                    if (amount!=nil) 
                        entryNetAmount = [NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amount]];
                }
            }
            
        }
        else if (permissionType == PermType_NonProjectSpecific){
            if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0) {
                if ([[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"]!=nil) {
                    
                    if ([[[firstSectionfieldsArray objectAtIndex:0]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] &&
                        [[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")]) {
                        //					[Util errorAlert:@"Please select expense type" errorMessage:@""];
                        [G2Util errorAlert:@"" errorMessage:RPLocalizedString(@"Please select expense type", @"Please select expense type")];//DE1231//Juhi
                        [self pickerDone:nil];
                        return;
                    }
                    else if ([[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"") ]) {
                        //					[Util errorAlert:@"Please enter Amount" errorMessage:@""];
                        [G2Util errorAlert:@"" errorMessage:RPLocalizedString(@"Please enter Amount",@"Please enter Amount")];//DE1231//Juhi
                        [self pickerDone:nil];
                        return;
                    }
                    
                    if ([[[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"fieldType"] isEqualToString: NUMERIC_KEY_PAD]) {
                        amount = [[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"];
                    }
                    else {
                        amount =[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"];
                    }
                    if (amount!=nil) 
                        entryNetAmount = [NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amount]];
                }
                
                if ([[firstSectionfieldsArray objectAtIndex:0]objectForKey:@"selectedDataIdentity"]!=nil)
                    [dictionary setObject:[[firstSectionfieldsArray objectAtIndex:0]objectForKey:@"selectedDataIdentity"] forKey:@"expenseTypeIdentity"];
            }
        }
        
        
        if (baseCurrency != nil) {
            
            NSString *currencyId = [supportDataModel getSystemCurrencyIdFromDBUsingCurrencySymbol:baseCurrency];
            [dictionary setObject:currencyId forKey:@"currencyIdentity"];
        }
        
        if (entryNetAmount!=nil) 
            [dictionary setObject:entryNetAmount forKey:@"NetAmount"];
        if (entryNetAmount != nil) {
            totalAmountDb = [entryNetAmount doubleValue];
        }
        if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0) {
            if([[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"] !=nil){
                if ([[[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"] isEqualToString:@"null"]) {
                    expenseTypeArr =[expensesModel getExpenseTypesToSaveWithEntryForSelectedProjectId:@"null" withType:[dictionary objectForKey:@"expenseTypeIdentity"]];
                }else {
                    expenseTypeArr =[expensesModel getExpenseTypesToSaveWithEntryForSelectedProjectId:[[firstSectionfieldsArray objectAtIndex:1]
                                                                                                       objectForKey:@"projectIdentity"] withType:[dictionary objectForKey:@"expenseTypeIdentity"]];
                }
            }
        }
        
        if ( permissionType == PermType_NonProjectSpecific) {
            if ([dictionary objectForKey:@"expenseTypeIdentity"]!=nil)
                expenseTypeArr =[expensesModel getExpenseTypesToSaveWithEntryForSelectedProjectId:@"null" withType:[dictionary objectForKey:@"expenseTypeIdentity"]];
        }
        
        double amountWithTaxes=0;
        
        if (expenseTypeArr !=nil && [expenseTypeArr count]>0) {
            NSString *selectedDataSource = [[expenseTypeArr objectAtIndex:0]objectForKey:@"name"];
            [dictionary setObject:selectedDataSource forKey:@"typeName"];
        }
        
        [dictionary setObject:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"]
                               objectForKey:@"expense_sheet_identity"] forKey:@"ExpenseSheetID"];
        
        
        [dictionary setObject:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"] 
                               objectForKey:@"identity"] forKey:@"identity"];	
        
        double hourlyRate=0;
        /*hourlyRate=[expensesModel getRateForEntryWhereEntryId:[[[NSUserDefaults standardUserDefaults] 
         objectForKey:@"SELECTED_EXPENSE_ENTRY"]objectForKey:@"identity"]];*/
        if (typeChanged==YES) {
            if ( permissionType == PermType_NonProjectSpecific) {
                [dictionary setObject:@"null" forKey:@"projectIdentity"];
            }
            hourlyRate=[expensesModel getHourlyRateFromDBWithProjectId:[dictionary objectForKey:@"projectIdentity"] withTypeName:[dictionary objectForKey:@"typeName"]];
        }else {
            hourlyRate=[expensesModel getRateForEntryWhereEntryId:[[[NSUserDefaults standardUserDefaults] 
                                                                    objectForKey:@"SELECTED_EXPENSE_ENTRY"]objectForKey:@"identity"]];	
        }
        //DE6811 Ullas M L
        if (projectChanged==YES) {
            if ( permissionType == PermType_NonProjectSpecific) {
                [dictionary setObject:@"null" forKey:@"projectIdentity"];
            }
            hourlyRate=[expensesModel getHourlyRateFromDBWithProjectId:[dictionary objectForKey:@"projectIdentity"] withTypeName:[dictionary objectForKey:@"typeName"]];
        }else {
            hourlyRate=[expensesModel getRateForEntryWhereEntryId:[[[NSUserDefaults standardUserDefaults] 
                                                                    objectForKey:@"SELECTED_EXPENSE_ENTRY"]objectForKey:@"identity"]];	
        }

        NSString *rateWithDecimals = [G2Util formatDecimalPlacesForNumericKeyBoard:hourlyRate withDecimalPlaces:max_supported_decimals_Rate];
        [dictionary setObject:[NSNumber numberWithDouble:[rateWithDecimals doubleValue]] forKey:@"ExpenseRate"];
        NSString *selectedType = nil;
        if (expenseTypeArr !=nil && [expenseTypeArr count]>0) {
            //Copy
            selectedType = [[expenseTypeArr objectAtIndex:0]objectForKey:@"type"];
        }else {
            selectedType = [[[NSUserDefaults standardUserDefaults] 
                             objectForKey:@"SELECTED_EXPENSE_ENTRY"]objectForKey:@"type"];
        }
        
		if (selectedType !=nil) {
			if ([selectedType isEqualToString:@"RatedWithOutTaxes"]||[selectedType isEqualToString:@"RatedWithTaxes"]) {
				if (defaultRateAndAmountsArray != nil && [defaultRateAndAmountsArray count] >0) {
					[dictionary setObject:[NSNumber  numberWithDouble:[[defaultRateAndAmountsArray objectAtIndex:0]doubleValue]] forKey:@"NumberOfUnits"];
				}else {
					NSNumber *noOfUnits = [[[NSUserDefaults standardUserDefaults] 
											objectForKey:@"SELECTED_EXPENSE_ENTRY"]objectForKey:@"noOfUnits"];
					if (noOfUnits != nil) {
						[dictionary setObject:noOfUnits forKey:@"NumberOfUnits"];
					}
				}
                
				
				[dictionary setObject:[NSNumber numberWithInt:1] forKey:@"isRated"];
				[dictionary setObject:entryNetAmount forKey:@"Rate"];
			}else {
				[dictionary setObject:[NSNumber numberWithInt:0] forKey:@"isRated"];
			}
            
            
            
            if (amountValuesArray!=nil && [amountValuesArray count]>0) {
                
                NSString *amount=nil;
                if ([amountValuesArray objectAtIndex:1] !=nil) 
                    amount = [amountValuesArray objectAtIndex:1];
                if (amount!=nil) 
                    entryNetAmount = [NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amount]];
                if (entryNetAmount!=nil) 
                    [dictionary setObject:entryNetAmount forKey:@"NetAmount"];
                
                amountWithTaxes=[entryNetAmount doubleValue];
                NSNumber *taxValueNumber=nil;
                for (int j=2; j<[amountValuesArray count]-1; j++) {
                    NSString *taxAmount=nil;
                    taxAmount = [amountValuesArray objectAtIndex:j];
                    if (taxAmount!=nil)
                        taxValueNumber = [NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:taxAmount]];
                    if (taxAmount!=nil){
                        [dictionary setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",j-1]];
                    }
                    amountWithTaxes = amountWithTaxes+[taxValueNumber doubleValue];
                    totalAmountDb = amountWithTaxes;
                }//DE6811 Ullas M L
            }else if ((amountValuesArray == nil || [amountValuesArray count] == 0) && !typeChanged) {
                for (int f =0; f<5; f++) {
                    
                    NSString *taxCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
                                         objectForKey:[NSString stringWithFormat:@"taxCode%d",f+1]];
                    if (taxCode !=nil ) {
                        [dictionary setObject:taxCode forKey:[NSString stringWithFormat:@"taxCode%d",f+1]];
                    }
                    
                    NSString *taxAmountString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
                                                 objectForKey:[NSString stringWithFormat:@"taxAmount%d",f+1]];
                    if (taxAmountString != nil ) {
                        [dictionary setObject:taxAmountString forKey:[NSString stringWithFormat:@"taxAmount%d",f+1]];
                    }
                    
                    entryNetAmount = [NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amount]];
                    amountWithTaxes = [entryNetAmount doubleValue] - [taxAmountString doubleValue];
                    amount = [NSString stringWithFormat:@"%lf",amountWithTaxes];
                    [dictionary setObject:[NSNumber numberWithDouble:amountWithTaxes] forKey:@"NetAmount"];
                    
                    
                    NSString *formulaString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
                                               objectForKey:[NSString stringWithFormat:@"formula%d",f+1]];
                    
                    if ( formulaString !=nil ) {
                        [dictionary setObject:formulaString forKey:[NSString stringWithFormat:@"formula%d",f+1]];
                    }		
                }
            }
            
            [self setTaxCodesArray];//DE6113 Ullas M L
            //DE7411 Ullas M L
            //DE8404 Ullas M L
           
            
            if (isComplexAmountCalucationScenario) {
                
                if (ratedValuesArray!=nil|| [ratedValuesArray count]>1) {//DE6113 Ullas M L
                    
                    for (int j=0; j<[ratedValuesArray count]; j++) {
                        //NSString *taxAmount=[self replaceStringToCalculateAmount:baseCurrency replaceWith:@"" originalString:[ratedCalculatedValuesArray objectAtIndex:j]];
                        NSString *taxAmount = [ratedValuesArray objectAtIndex:j];
                        if (taxAmount!=nil)
                            [dictionary setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",j+1]];
                        
                    }
                    
                }

            }
            else {
                if (ratedCalculatedValuesArray!=nil|| [ratedCalculatedValuesArray count]>1) {//DE6113 Ullas M L
                    
                    for (int j=0; j<[ratedCalculatedValuesArray count]; j++) {
                        //NSString *taxAmount=[self replaceStringToCalculateAmount:baseCurrency replaceWith:@"" originalString:[ratedCalculatedValuesArray objectAtIndex:j]];
                        NSString *taxAmount = [ratedCalculatedValuesArray objectAtIndex:j];
                        if (taxAmount!=nil)
                            [dictionary setObject:taxAmount forKey:[NSString stringWithFormat:@"taxAmount%d",j+1]];
                        
                    }
                    
                }
            }
            
            
            
        }else {
            //This situation will arise when type removed from List of ExpenseTypes...
			for (int f =0; f<5; f++) {
				NSString *taxCode = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
									 objectForKey:[NSString stringWithFormat:@"taxCode%d",f+1]];
				if (taxCode !=nil ) {
					[dictionary setObject:taxCode forKey:[NSString stringWithFormat:@"taxCode%d",f+1]];
				}
				
				NSString *taxAmountString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
											 objectForKey:[NSString stringWithFormat:@"taxAmount%d",f+1]];
				if (taxAmountString != nil ) {
					[dictionary setObject:taxAmountString forKey:[NSString stringWithFormat:@"taxAmount%d",f+1]];
				}
				
				entryNetAmount = [NSNumber numberWithDouble:[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amount]];
				amountWithTaxes = [entryNetAmount doubleValue] - [taxAmountString doubleValue];
				amount = [NSString stringWithFormat:@"%lf",amountWithTaxes];
				[dictionary setObject:[NSNumber numberWithDouble:amountWithTaxes] forKey:@"NetAmount"];
				
				
				NSString *formulaString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
										   objectForKey:[NSString stringWithFormat:@"formula%d",f+1]];
				
				if ( formulaString !=nil ) {
					[dictionary setObject:formulaString forKey:[NSString stringWithFormat:@"formula%d",f+1]];
				}		
			}
        }
        
        
        if (taxCodesAndFormulasArray!=nil && [taxCodesAndFormulasArray count]>0) {
            for (int j=0; j<[taxCodesAndFormulasArray count]-1; j++) {
                NSString *taxCodes=[[taxCodesAndFormulasArray objectAtIndex:j] objectForKey:@"identity"];
                if (taxCodes!=nil){
                    [dictionary setObject:taxCodes forKey:[NSString stringWithFormat:@"taxCode%d",j+1]];
                }else {
                    if (typeChanged)
                        [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"taxCode%d",j+1]];
                }
                
                NSString *formula=[[taxCodesAndFormulasArray objectAtIndex:j] objectForKey:@"formula"];
                if (formula!=nil){
                    [dictionary setObject:formula forKey:[NSString stringWithFormat:@"formula%d",j+1]];
                }else {
                    if (typeChanged)
                        [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"formula%d",j+1]];
                }
            }
            
            
        }else {
            if (typeChanged){
                for (int f =0; f<5; f++) {
                    [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"taxCode%d",f+1]];
                    [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"taxAmount%d",f+1]];
                    [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"formula%d",f+1]];
                }
            }
        }
        
        
        
        for (int x = 1  ;  x < (taxesCount+1) ; x++) {
            
            //NSString *taxAmountString = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
            //										 objectForKey:[NSString stringWithFormat:@"taxAmount%d",x]];
            
            if ([dictionary objectForKey:[NSString stringWithFormat:@"taxCode%d",x]] != nil && ![[dictionary objectForKey:[NSString stringWithFormat:@"taxCode%d",x]] isEqualToString:@""]) {
                
            }else {
                [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"taxCode%d",x]];
                [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"taxAmount%d",x]];
                [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"formula%d",x]];
            }
        }
        
        
        /*if (typeChanged){
         for (int f =0; f<5; f++) {
         
         if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
         objectForKey:[NSString stringWithFormat:@"taxCode%d",f+1]] !=nil && [dictionary objectForKey:[NSString stringWithFormat:@"taxCode%d",f+1]] == nil ) {
         [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"taxCode%d",f+1]];
         }
         if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
         objectForKey:[NSString stringWithFormat:@"taxAmount%d",f+1]] !=nil && [dictionary objectForKey:[NSString stringWithFormat:@"taxAmount%d",f+1]] == nil ) {
         [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"taxAmount%d",f+1]];
         }
         
         if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]
         objectForKey:[NSString stringWithFormat:@"formula%d",f+1]] !=nil && [dictionary objectForKey:[NSString stringWithFormat:@"taxAmount%d",f+1]] == nil ) {
         [dictionary setObject:@"" forKey:[NSString stringWithFormat:@"formula%d",f+1]];
         }		
         }
         }*/
        
        if (b64String!=nil && imageDeletePressed==NO) {
            [dictionary setObject:b64String forKey:@"Base64ImageString"];
        }else if(b64String == nil && imageDeletePressed==YES){
            //new implementation to delete image in server 
            
        }else if (b64String!=nil && imageDeletePressed==YES){
            [dictionary setObject:@"replace" forKey:@"imageFlag"];
            [dictionary setObject:b64String forKey:@"Base64ImageString"];
        }else if(b64String==nil && base64Decoded!=nil) {
            [dictionary setObject:@"" forKey:@"Base64ImageString"];
        }else if(b64String==nil && base64Decoded==nil) {
            NSString *recieptFlag=[dictionary objectForKey:RPLocalizedString(@"Receipt Photo", @"") ];
            if (recieptFlag!=nil &&[recieptFlag isEqualToString:RPLocalizedString(@"Yes", @"")]) {
                [dictionary setObject:@"" forKey:@"Base64ImageString"];
            }
        }else {
            [dictionary setObject:@"" forKey:@"Base64ImageString"];
        }
        
		NSString *allocationId = @"";
		NSMutableArray *clientArray=[expensesModel getClientsForBucketProjects:[dictionary objectForKey:@"projectIdentity"]];
		if (clientArray!=nil && [clientArray count]>=1) {
			allocationId=[[clientArray objectAtIndex:0] objectForKey:@"allocationMethodId"];
		}else {
			allocationId =  [[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"]
                             objectForKey:@"allocationMethodId"];
		}
		
		[dictionary setObject:allocationId forKey:@"allocationMethodId"];
        
        [dictionary setObject:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"]
                               objectForKey:@"identity"] forKey:@"identity"];
        
        NSMutableArray *editedUdfArray = [NSMutableArray array];
		NSUInteger z = valueWithOutUdfs;
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
        if (editedUdfArray!=nil) 
            [dictionary setObject:editedUdfArray forKey:@"UserDefinedFields"];
        
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
            //Save the expense entry to DB
            
            [dictionary setObject:[NSNumber numberWithInt:1] forKey:@"isModified"];
            if(![[[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"]objectForKey:@"editStatus"] isEqualToString:@"create"]) {
                [dictionary setObject:@"edit" forKey:@"editStatus"];
            }else {
                [dictionary setObject:@"create" forKey:@"editStatus"];
            }
            
            if (amountWithTaxes>0 && amountValuesArray != nil){ 
                [dictionary setObject:[NSNumber numberWithDouble:amountWithTaxes] forKey:@"NetAmount"];
            }else {
                [dictionary setObject:[NSNumber numberWithDouble:totalAmountDb] forKey:@"NetAmount"];
            }
            
            [expensesModel updateExpenseById:dictionary];
            [expensesModel updateExpenseSheetModifyStatus:[NSNumber numberWithInt:1] : [dictionary objectForKey:@"ExpenseSheetID"]];
            NSArray *arr = [expensesModel getExpenseEntriesFromDatabase];
            [[NSUserDefaults standardUserDefaults]setObject:arr forKey:@"expenseEntryArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ExpenseEntriesNotification"
                                                                object:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
            //[editControllerDelegate performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.5];
        }else {
            
            [[G2RepliconServiceManager expensesService]sendRequestToEditEntryForSheet:[NSMutableArray arrayWithObject:dictionary]
                                                                            sheetId:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"]objectForKey:@"expense_sheet_identity"]
                                                                           delegate:self];
            
            if (amountWithTaxes>0 && amountValuesArray != nil) {
                [dictionary setObject:[NSNumber numberWithDouble:amountWithTaxes] forKey:@"NetAmount"];
            }else {
                [dictionary setObject:[NSNumber numberWithDouble:totalAmountDb] forKey:@"NetAmount"];
            }
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
            
        }
        
        self.expenseEntryDetailsDict = dictionary;
	}
	@finally {
		
	}
}


-(void)setTotalAmountToRatedType:(NSString*)totalAmountCalculated
{
	amountValue=totalAmountCalculated;
}

-(void)checkAllValues{
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

-(void)dataPickerAction:(G2ExpenseEntryCellView*)_cell withEvent: (UIEvent *) event

{   
	//[self hideKeyBoard];
	[datePicker setHidden:YES];
	//ravi - Over cautious
	if (_cell == nil) {
		return;
	}
	
	NSDictionary *_dataObj = [_cell dataObj];
	
	if (currentIndexPath.section == 0) {
		
		if ([_dataObj objectForKey: @"fieldName"] ==  RPLocalizedString(@"Project", @"")) {
			clientsArray = [[firstSectionfieldsArray objectAtIndex: currentIndexPath.row]objectForKey:@"clientsArray"];
			self.dataSourceArray = [[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"clientsArray"];
			projectsArray = [[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"projectsArray"];	
		} else {
			self.dataSourceArray = [[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"dataSourceArray"];
		}
		[self changeSegmentControlState:currentIndexPath];
		
		[self reloadDataPicker: currentIndexPath];
	}	else if (currentIndexPath.section == 1) {
		self.dataSourceArray = [[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"dataSourceArray"];
		pickerView1.tag = 0;
		[self reloadDataPicker:currentIndexPath];
		
		[self changeSegmentControlState:currentIndexPath];
	}
	[self resetTableViewUsingSelectedIndex:currentIndexPath];
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
			[toolbarSegmentControl setEnabled:NO forSegmentAtIndex: NavigationType_Next];
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Previous];
		}else {
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Previous];
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Next];
		}
		
		
		if (indexpath.row == 0) {
			G2ExpenseEntryCellView *expenseEntryCellView=nil;	
			expenseEntryCellView =(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:
														   [NSIndexPath indexPathForRow:[firstSectionfieldsArray count]-1 inSection:G2EXPENSE_SECTION]];
			if([expenseEntryCellView isUserInteractionEnabled]==YES)
			{
				[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Next];
				[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Previous];
				
				
			}else {
				[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Next];
				[toolbarSegmentControl setEnabled:NO forSegmentAtIndex: NavigationType_Previous];
			}
		}
		if (numberUdfText.tag-1-SECONDSECTION_TAG_INDEX ==[secondSectionfieldsArray count]-1) {
			[toolbarSegmentControl setEnabled:NO forSegmentAtIndex: NavigationType_Next];
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex: NavigationType_Previous];
		}
        //DE2113
		if ([[cell fieldName].text isEqualToString:RPLocalizedString(@"Payment Method", @"") ]&& indexpath.row<udfStartIndex) {
            [toolbarSegmentControl setEnabled:NO forSegmentAtIndex:NavigationType_Previous];
            [toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NavigationType_Next];
        }
	}
}




-(void)datePickerAction:(G2ExpenseEntryCellView*)cell withEvent: (UIEvent *) event
{
	[self hideKeyBoard];
	if (event != nil) {
		//selectedIndexPath = [self getIndexPathForCellEvent: event];
	}
	
	datePicker.date = [NSDate date];
	[self reloadDatePicker: currentIndexPath];
	[self changeSegmentControlState: currentIndexPath];
	
#ifdef _DROP_RELEASE_1_US1730
	//ravi - Field validations will be handled from the API side for this release. 
	//REF:- US1730
	if ([[cell dataObj] objectForKey: @"defaultMaxValue"] != nil &&
		!([[[cell dataObj] objectForKey: @"defaultMaxValue"] isKindOfClass:[NSNull class]]))
	{
		[datePicker setMaximumDate:[Util convertStringToDate1:[[cell dataObj] objectForKey: @"defaultMaxValue"]]];
	}
	if ([[cell dataObj] objectForKey: @"defaultMinValue"] != nil &&
		!([[[cell dataObj] objectForKey: @"defaultMinValue"] isKindOfClass:[NSNull class]])) 
	{	
		[datePicker setMinimumDate:[Util convertStringToDate1:[[cell dataObj] objectForKey: @"defaultMinValue"]]];
	}
#endif
	
	[self resetTableViewUsingSelectedIndex:currentIndexPath];
}


-(void)checkMarkAction:(G2ExpenseEntryCellView*)sender withEvent: (UIEvent *) event {
	[pickerViewC setHidden:YES];
	[pickerView1 setHidden:YES];
	[datePicker setHidden:YES];
	[self hideKeyBoard];
	
	G2ExpenseEntryCellView *expenseEntryCellView=nil;	
	expenseEntryCellView =(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath:
												   [NSIndexPath indexPathForRow:currentIndexPath.row inSection:currentIndexPath.section]];
	
	if ([[[expenseEntryCellView dataObj] objectForKey:@"fieldType"] isEqualToString: CHECK_MARK])	{
		if (currentIndexPath.section==1) {
			NSString *imgName = [[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"];
			
			if ([imgName isEqualToString:G2Check_ON_Image]) {
				[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]setObject:G2Check_OFF_Image forKey:@"defaultValue"];
				
			}else {
				[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]setObject:G2Check_ON_Image forKey:@"defaultValue"];
				
			}
			
			UIImage *img = [G2Util thumbnailImage:[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]];
			[sender.fieldButton setImage:img forState:UIControlStateNormal];
		}
		
	}
	
	[self changeSegmentControlState: currentIndexPath];
	[self resetTableViewUsingSelectedIndex:nil];
	
}
-(void)setCheckMarkImage:(NSString *)imgName withFieldButton: (G2ExpenseEntryCellView*)entryCell{
	UIImage *img = [G2Util thumbnailImage:imgName];
	if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: CHECK_MARK]) {
		[entryCell.fieldButton setImage:img forState:UIControlStateNormal];
	}else { 
		[entryCell.fieldButton setImage:nil forState:UIControlStateNormal];
	}
	
	[self changeSegmentControlState:currentIndexPath];
}

-(void)moveToNextScreen:(G2ExpenseEntryCellView*)entryCell withEvent: (UIEvent *) event{
	
	
	
	[datePicker setHidden:YES];
	[pickerView1 setHidden:YES];
	[self hideKeyBoard];
	[pickerViewC setHidden:YES];
	
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *expDictFromDB = [standardUserDefaults objectForKey: @"SELECTED_EXPENSE_ENTRY"];
	
	if (currentIndexPath.section == 1) {
		G2AddDescriptionViewController *tempaddDescriptionViewController  = [[G2AddDescriptionViewController alloc]init];
        self.addDescriptionViewController=tempaddDescriptionViewController;
       
        //US4065//Juhi
        //DE8142
        if ([entryCell.fieldName.text isEqualToString:@"Description"] && currentIndexPath.row<udfStartIndex) {
            addDescriptionViewController.fromExpenseDescription =YES;
        }
        else
            addDescriptionViewController.fromExpenseDescription=NO;
		[addDescriptionViewController setDescTextString:[[entryCell dataObj] objectForKey:@"defaultValue"]];
		//[addDescriptionViewController setTitle:[[entryCell dataObj]objectForKey:@"fieldName"]];
		[addDescriptionViewController setViewTitle: [[entryCell dataObj]objectForKey:@"fieldName"]];
		addDescriptionViewController.descControlDelegate=self;
		
		RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
		[delegate setCurrVisibleViewController: self.addDescriptionViewController];
		
		[self.navigationController pushViewController:addDescriptionViewController animated:YES];
        
	}
    else if (currentIndexPath.section == 0) {
		if([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:MOVE_TO_NEXT_SCREEN])
        {
            
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
                NSDictionary *infoDict;
                NSString *identity;
                if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
                    identity = [[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"];
                    infoDict = [firstSectionfieldsArray objectAtIndex:2];
                }else {
                    identity = @"null";
                    infoDict = [firstSectionfieldsArray objectAtIndex:0];
                }
                
                
                int ind = [[infoDict objectForKey:@"selectedIndex"]intValue];
                NSString *selectedDataIdentity=[infoDict objectForKey:@"selectedDataIdentity"];
                NSMutableArray *typesArray=[infoDict objectForKey:@"dataSourceArray"];
                
                if (typesArray != nil && [typesArray count] == 0 && selectedDataIdentity==nil) {
                    [self changeSegmentControlState:currentIndexPath];
                    self.isPickerDoneClicked=TRUE;
                    [self resetTableViewUsingSelectedIndex:nil];
                    [self deselectRowAtIndexPath:currentIndexPath];
                    [self disableExpenseFieldAtIndex:currentIndexPath];
                    [self pickerDone:nil];//DE8583
                    return;
                }
                
                NSString *typeName=nil;
                if (typesArray!=nil && [typesArray count]>0)
                    typeName = [[typesArray objectAtIndex:ind]objectForKey:@"name"];
                
                NSMutableArray *taxDetailsArray=nil;
                NSMutableArray *expenseTaxCodesLocalArray=nil;
                G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
                if (typeChanged==NO && self.projectChanged==NO ){//DE6811 Ullas M L
                    id _selExpEntryId = [expDictFromDB objectForKey: @"identity"];
                    typeName = [expDictFromDB objectForKey:@"expenseTypeName"];
                    if (identity!=nil && typeName !=nil) {
                        taxDetailsArray = [supportDataModel getTaxCodesForSavedEntry:identity withExpenseType:typeName andId:_selExpEntryId];
                    }
                    expenseTaxCodesLocalArray = [supportDataModel getExpenseLocalTaxcodesForEntryFromDB: _selExpEntryId];
                    
                }else {
                    if (identity!=nil && typeName !=nil)
                        taxDetailsArray=[supportDataModel getAmountTaxCodesForSelectedProjectID:identity
                                                                                withExpenseType:typeName];
                    expenseTaxCodesLocalArray=[supportDataModel getExpenseLocalTaxcodesFromDB:identity
                                                                              withExpenseType:typeName];
                    
                }
                
                if (taxDetailsArray!=nil && [taxDetailsArray count]>0) {
                    for (int x=0; x<[taxDetailsArray count] -1; x++) {
                        id _taxDetail = [taxDetailsArray objectAtIndex: x];
                        NSMutableDictionary *mutableDict=[NSMutableDictionary dictionary];
                        //DE8583
                        if ([_taxDetail isKindOfClass:[NSDictionary class]]) {
                            [mutableDict addEntriesFromDictionary: _taxDetail];
                        }
                        
                        NSString *formulaString=[_taxDetail objectForKey:@"formula"];
                        if (formulaString !=nil && ![formulaString isKindOfClass:[NSNull class]]) {
                            NSString *localTax=[expenseTaxCodesLocalArray objectAtIndex:x];
                            if (localTax!=nil && ![localTax isKindOfClass:[NSNull class]]) {
                                [mutableDict setObject:localTax forKey:@"formula"];
                            }
                        }
                        [taxDetailsArray replaceObjectAtIndex:x withObject:mutableDict];
                    }
                    
                    [self setTaxCodesAndFormulasArray:taxDetailsArray];
                }
                
                //			NSString *taxType = nil;
                //			if ([taxDetailsArray objectAtIndex:[taxDetailsArray count]-1] != nil && [[taxDetailsArray objectAtIndex:[taxDetailsArray count]-1] isKindOfClass:[NSString class]]) {
                //				taxType = [taxDetailsArray objectAtIndex:[taxDetailsArray count]-1];
                //			}
                
                
                G2AmountViewController	*tempamountviewController=[[G2AmountViewController alloc]init];
                self.amountviewController=tempamountviewController;
               
                
                
                
                
                if (identity!=nil && typeName !=nil)
                {
                    self.expenseUnitLabelArray=[supportDataModel  getExpenseUnitLabelsFromDB:identity withExpenseType:typeName];
                    if (!typeChanged && !self.projectChanged)//DE6811 Ullas M L
                        self.expenseUnitLabelArray = [NSMutableArray arrayWithObjects:[expDictFromDB objectForKey:@"expenseUnitLable"],nil];
                    [self setExpenseUnitLable:[self.expenseUnitLabelArray objectAtIndex:0]];
                    [amountviewController setRatedExpenseArray:self.expenseUnitLabelArray];
                }
                
                [amountviewController setAmountControllerDelegate:self];
                
                if (taxDetailsArray!=nil && [taxDetailsArray count]>0) {
                    if (![[taxDetailsArray objectAtIndex:[taxDetailsArray count]-1] isEqualToString:Flat_WithOut_Taxes]){
                        previousWasTaxExpense = YES;
                    }else {
                        previousWasTaxExpense = NO;
                    }
                    if ([[taxDetailsArray objectAtIndex:[taxDetailsArray count]-1] isEqualToString:@"FlatWithOutTaxes"] ||
                        [[taxDetailsArray objectAtIndex:[taxDetailsArray count]-1] isEqualToString:@"FlatWithTaxes"])
                    {
                        if ([[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")]) {
                            //NSMutableArray *fieldsArray=[NSMutableArray arrayWithObjects:baseCurrency,@"Select",nil];
                            NSMutableArray *tempfieldsArray=[[NSMutableArray alloc]init];
                            self.fieldsArray=tempfieldsArray;
                           
                            [fieldsArray addObject:baseCurrency];
                            [fieldsArray addObject:RPLocalizedString(@"Select", @"")];
                            for (int i=0; i<[taxDetailsArray count]; i++) {
                                [fieldsArray addObject:@"0.00"];
                                
                            }
                            //[amountviewController setDoneTapped:NO];
                            [amountviewController setFieldValuesArray:fieldsArray];
                            
                        }else if (amountValuesArray != nil){
                            RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                            //DE4881 Ullas M L
                            if (appdelegate.isUserPressedCancel)
                            {
                                
                                NSMutableArray *tmpArray=[[NSUserDefaults standardUserDefaults] objectForKey:@"PreviousArrayForEdit"] ;
                                
                                for (int i=1; i<[tmpArray count]; i++) {
                                    [amountValuesArray replaceObjectAtIndex:i withObject:[tmpArray objectAtIndex:i]];
                                }
                                
                                
                                appdelegate.isUserPressedCancel=NO;
                            }
                            [amountValuesArray replaceObjectAtIndex:0 withObject:baseCurrency];
                            [amountviewController setFieldValuesArray:amountValuesArray];
                            [amountviewController setCurrecncyString:baseCurrency];
                            [amountviewController setButtonTitle:baseCurrency];
                            NSString *amountString=[amountValuesArray objectAtIndex:1];
                            if (amountString!=nil)
                                [amountviewController setAmountValueEntered:amountString];
                        }else {
                            //[amountviewController setDoneTapped:NO];
                            
                            NSString *amount = [NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:
                                                                                 [[expDictFromDB objectForKey:@"netAmount"] doubleValue]]];
                            NSMutableArray *tempamountValuesArray =[[NSMutableArray alloc]init];
                            [tempamountValuesArray addObject:baseCurrency];
                            [tempamountValuesArray addObject:amount];
                            self.amountValuesArray = tempamountValuesArray;
                           
                            NSString *totalAmount=nil;
                            double total=0;
                            total=[[expDictFromDB objectForKey:@"netAmount"] doubleValue];
                            for (int i=0; i<[taxDetailsArray count]-1; i++) {
                                if ([expDictFromDB objectForKey:[NSString stringWithFormat:@"taxAmount%d",i+1]] != nil) {
                                    double taxAmount = [[expDictFromDB objectForKey:[NSString stringWithFormat:@"taxAmount%d",i+1]] doubleValue];
                                    [amountValuesArray addObject:[G2Util formatDoubleAsStringWithDecimalPlaces:taxAmount]];
                                    
                                    total =total-taxAmount;
                                    totalAmount=[G2Util formatDoubleAsStringWithDecimalPlaces:total];
                                }
                            }
                            
                            
                            if (totalAmount!=nil) {
                                
                                if ([totalAmount isEqualToString:@"-0.00"]) //DE5047 Ullas M L
                                {
                                    totalAmount=@"0.00";
                                }
                                
                                [amountValuesArray replaceObjectAtIndex:1 withObject:totalAmount];
                                [amountValuesArray addObject:amount];
                                
                            }
                            
                            
                            [amountviewController setFieldValuesArray:amountValuesArray];
                            [amountviewController setCurrecncyString:baseCurrency];
                            [amountviewController setButtonTitle:baseCurrency];
                            NSString *amountString= [amountValuesArray objectAtIndex:1];
                            if (amountString!=nil)
                                [amountviewController setAmountValueEntered:amountString];
                        }
                    }else {
                        double hourlyRate=0;
                        G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
                        if (typeChanged==YES||self.projectChanged==YES) {//DE6811 Ullas M L
                            hourlyRate=[expensesModel getHourlyRateFromDBWithProjectId:identity withTypeName:typeName];
                        }else {
                            hourlyRate=[expensesModel getRateForEntryWhereEntryId:[expDictFromDB objectForKey:@"identity"]];
                        }
                        
                                               
                        [amountviewController setRate:hourlyRate];
                        
                        NSString *totalAmountRated=nil;
                        double totalRated=0;
                        if ([[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"")]) {
                            NSMutableArray *ratedDefaultValuesArray=[[NSMutableArray alloc]init];//]WithObjects:@"Select",nil];
                            for (int i=0; i<[taxDetailsArray count]; i++) {
                                [ratedDefaultValuesArray addObject:@"0.00"];
                            }
                            amountviewController.totalAmountValue.text=@"0.00";
                            [amountviewController setRatedBaseCurrency:baseCurrency];
                            if (hourlyRate !=0) {
                                self.defaultRateAndAmountsArray=[NSMutableArray arrayWithObjects:RPLocalizedString(@"Select", @""),[NSString stringWithFormat:@"%0.04lf",hourlyRate],@"0.00",nil];
                            } else {
                                self.defaultRateAndAmountsArray=[NSMutableArray arrayWithObjects:RPLocalizedString(@"Select", @""),@"0.00",@"0.00",nil];
                            }
                            [amountviewController setDefaultValuesArray:defaultRateAndAmountsArray];
                            [amountviewController setRatedValuesArray:ratedDefaultValuesArray];
                            
                            
                            
                        } else if (ratedCalculatedValuesArray != nil && defaultRateAndAmountsArray != nil) {
                            //RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                            if (isComplexAmountCalucationScenario/*||appdelegate.isUserPressedCancel==YES*/) {
                                //isComplexAmountCalucationScenario=NO;
                                //appdelegate.isUserPressedCancel=NO;
                                [ratedValuesArray addObject:[totalCalucatedAmountArray objectAtIndex:0]];
                                [amountviewController setRatedBaseCurrency:baseCurrency];
                                [amountviewController setRatedValuesArray:ratedValuesArray];
                                [amountviewController setDefaultValuesArray:rateAndAmountsArray];
                                amountviewController.totalAmountValue.text=[totalCalucatedAmountArray objectAtIndex:0];
                                UILabel *tmpLabel=[[UILabel alloc]init];
                                tmpLabel.text=[totalCalucatedAmountArray objectAtIndex:0];
                                [amountviewController setTotalAmountValue:tmpLabel];
                               
                                
                            }
                            else{
                                [amountviewController setRatedBaseCurrency:baseCurrency];
                                [amountviewController setRatedValuesArray:ratedCalculatedValuesArray];
                                [amountviewController setDefaultValuesArray:defaultRateAndAmountsArray];
                                amountviewController.totalAmountValue.text=amountValue;
                                UILabel *tmpLabel=[[UILabel alloc]init];
                                tmpLabel.text=amountValue;
                                [amountviewController setTotalAmountValue:tmpLabel];
                               
                            }
                            
                        } else {
                            //RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                            
                            if (isComplexAmountCalucationScenario/*||appdelegate.isUserPressedCancel==YES*/) {
                                
                                //isComplexAmountCalucationScenario=NO;
                                //appdelegate.isUserPressedCancel=NO;
                                [ratedValuesArray addObject:[totalCalucatedAmountArray objectAtIndex:0]];
                                [amountviewController setRatedBaseCurrency:baseCurrency];
                                [amountviewController setRatedValuesArray:ratedValuesArray];
                                [amountviewController setDefaultValuesArray:rateAndAmountsArray];
                                amountviewController.totalAmountValue.text=[totalCalucatedAmountArray objectAtIndex:0];
                                UILabel *tmpLabel=[[UILabel alloc]init];
                                tmpLabel.text=[totalCalucatedAmountArray objectAtIndex:0];
                                [amountviewController setTotalAmountValue:tmpLabel];
                                
                                
                            }
                            else
                            {
                                totalRated = [[expDictFromDB objectForKey:@"netAmount"] doubleValue];
                                //						double noOfUnits=0;
                                NSString *selectedcurrencyType = [expDictFromDB objectForKey:@"currencyType"];
                                totalAmountRated=[G2Util formatDoubleAsStringWithDecimalPlaces:totalRated];
                                NSMutableArray *ratedDefaultValuesArray=[[NSMutableArray alloc]init];//]WithObjects:@"Select",nil];
                                for (int i=0; i<[taxDetailsArray count]; i++) {
                                    if ([expDictFromDB objectForKey:[NSString stringWithFormat:@"taxAmount%d",i+1]] != nil) {
                                        double taxAmount = [[expDictFromDB objectForKey:[NSString stringWithFormat:@"taxAmount%d",i+1]] doubleValue];
                                        [ratedDefaultValuesArray addObject:[G2Util formatDoubleAsStringWithDecimalPlaces:taxAmount]];
                                        totalRated =totalRated-taxAmount;
                                        
                                        
                                    }else {
                                        [ratedDefaultValuesArray addObject:@"0.00"];
                                    }
                                }
                                
                                //						noOfUnits=totalRated/hourlyRate;
                                [ratedDefaultValuesArray replaceObjectAtIndex:[ratedDefaultValuesArray count]-1 withObject:totalAmountRated];//DE5853 Ullas M L
                                [amountviewController setRatedBaseCurrency:selectedcurrencyType];
                                [amountviewController setRatedValuesArray:ratedDefaultValuesArray];
                                
                                
                               
                                
                                
                                amountValue = [G2Util formatDoubleAsStringWithDecimalPlaces:totalRated];
                                
                                self.defaultRateAndAmountsArray=[NSMutableArray arrayWithObjects:
                                                                 [NSString stringWithFormat:@"%0.02lf",[[expDictFromDB objectForKey:@"noOfUnits"]doubleValue]],
                                                                 [NSString stringWithFormat:@"%0.04lf",hourlyRate],
                                                                 amountValue,
                                                                 nil];
                                [amountviewController setDefaultValuesArray:defaultRateAndAmountsArray];
                                
                                amountviewController.totalAmountValue.text=totalAmountRated;//problem here
                                UILabel *tmpLbl=[[UILabel alloc]init];
                                tmpLbl.text=totalAmountRated;
                                [amountviewController setTotalAmountValue:tmpLbl];
                               
                            }
                        }
                    
                    }
                }
                
                [amountviewController setInEditState:YES];
                
                [amountviewController setExpenseTaxesInfoArray:(NSMutableArray*)taxDetailsArray];
                
                RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                [delegate setCurrVisibleViewController: amountviewController];
                [amountviewController setIsFromEditExpense:YES];//DE4881 Ullas M L
                [amountviewController setIsFromAddExpense:NO];//DE4881 Ullas M L
                [self.navigationController pushViewController:self.amountviewController animated:YES];
                
            
                
                
            

            }
            
        }
	}
	[self changeSegmentControlState:currentIndexPath];	
	[self resetTableViewUsingSelectedIndex:nil];
	//self.projectChanged=NO;//DE6811 Ullas M L
	
}

-(NSString*)replaceStringToCalculateAmount:(NSString*)currentString replaceWith:(NSString*)replString originalString:(NSString*)string
{
	
	NSMutableString *requiredString=[NSMutableString stringWithFormat:@"%@",string];
	
	if ([requiredString rangeOfString:currentString].location == NSNotFound) {
		return string;
	} else {
        if (![requiredString isKindOfClass:[NSNull class] ]) 
        {
            [requiredString replaceOccurrencesOfString:currentString withString:replString options:0 range:NSMakeRange(0,[requiredString length])];
        }
		
	}
	
	return requiredString;
}

-(void)setRatedUnits:(NSString*)ratedKilometerEntry
{
	self.kilometersUnitsValue=ratedKilometerEntry;
}

-(void)reloadCellAtIndex:(NSIndexPath*)indexPath
{
	//UIImage *img = [Util thumbnailImage:G2Check_ON_Image];
	G2ExpenseEntryCellView	*expenseEntryCellView = (G2ExpenseEntryCellView *) [self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[expenseEntryCellView setUserInteractionEnabled:YES];
	[expenseEntryCellView.switchMark setUserInteractionEnabled:YES];
	[[expenseEntryCellView dataObj] setObject:G2Check_ON_Image forKey:@"defaultValue"];
	[expenseEntryCellView.switchMark setOn:YES];
	expenseEntryCellView.fieldName.textColor=RepliconStandardBlackColor;
}

-(void)DisableCellAtIndexForCheckmark:(NSIndexPath*)indexPath
{
	G2ExpenseEntryCellView	*expenseEntryCellView = (G2ExpenseEntryCellView *) [self.tnewExpenseEntryTable cellForRowAtIndexPath:indexPath];
	[expenseEntryCellView setUserInteractionEnabled:NO];
	[expenseEntryCellView.switchMark setOn:NO];
	[expenseEntryCellView.switchMark setUserInteractionEnabled:NO];
	[[expenseEntryCellView dataObj] setObject:G2Check_OFF_Image forKey:@"defaultValue"];
	expenseEntryCellView.fieldName.textColor=RepliconStandardGrayColor;
}

-(void)imagePicker:(id)sender withEvent: (UIEvent *) event{
	[pickerView1 setHidden:YES];
	[pickerViewC setHidden:YES];
	[datePicker setHidden:YES];	
	[self hideKeyBoard];
	memoryWarnCount = 0;
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	
	//[self  tableViewMoveToTop:selectedIndexPath];
	if ([[[entryCell dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(@"Yes", @"Yes")]) {
		if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
			[self deselectRowAtIndexPath:currentIndexPath];
			[G2Util errorAlert:ErrorTitle errorMessage:RPLocalizedString(@"This receipt cannot be viewed while offline", @"This receipt cannot be viewed while offline")];
            [self pickerDone:nil];
			return;
		}else {
			[self getReceiptImage];
		}
		
	}else {
		
		UIActionSheet *receiptActionSheet;
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
		{
			receiptActionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self 
												 cancelButtonTitle: RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE)
											destructiveButtonTitle:nil
												 otherButtonTitles:RPLocalizedString(TAKE_PHOTO_BTN_TITLE, TAKE_PHOTO_BTN_TITLE),RPLocalizedString(CHOOSE_FROM_LIB_BTN_TITLE, CHOOSE_FROM_LIB_BTN_TITLE),nil];
		}
		else 
		{
			receiptActionSheet=[[UIActionSheet alloc]initWithTitle: nil delegate:self 
												 cancelButtonTitle: RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE)
											destructiveButtonTitle: nil
												 otherButtonTitles: RPLocalizedString(CHOOSE_FROM_LIB_BTN_TITLE, CHOOSE_FROM_LIB_BTN_TITLE),nil];
		}
		
		[receiptActionSheet setDelegate:self];
		[receiptActionSheet setTag:RECEIPT_TAG_INDEX];
		[receiptActionSheet setBackgroundColor:[UIColor blackColor]];
		[receiptActionSheet setFrame:CGRectMake(0,203, 320, 280)];
		[receiptActionSheet showFromTabBar:self.tabBarController.tabBar];
		
		
		[self changeSegmentControlState:currentIndexPath];isPickerDoneClicked=YES;//DE5011 ullas
		//[self resetTableViewUsingSelectedIndex:currentIndexPath];
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
		if (buttonIndex==1) {
			[self performSelector:@selector(tableViewCellUntapped:) withObject:currentIndexPath afterDelay:0.5];
		}
	}
}


#pragma mark UIImagePickerController

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
	[picker dismissViewControllerAnimated:NO completion:nil];
    //DE4865//Juhi
    //    if (receiptViewController==nil) {
    G2ReceiptsViewController *tempreceiptViewController=[[G2ReceiptsViewController alloc]init];
    self.receiptViewController=tempreceiptViewController;
   
    //    }
	
  	[receiptViewController setInNewEntry: YES];
  	[receiptViewController setRecieptDelegate: self];
  	[receiptViewController setSheetStatus: expenseSheetStatus];
	[receiptViewController.receiptImageView setFrame:self.view.frame];
	UIImage	 *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	[receiptViewController setImage:image];
  	[self dismissViewControllerAnimated:NO completion:nil];
  	
  	RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
  	[delegate setCurrVisibleViewController: receiptViewController];
	
	[self.navigationController pushViewController:receiptViewController animated:YES];
	
	[self resetTableViewUsingSelectedIndex:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[self dismissViewControllerAnimated:YES completion:nil];
	[self performSelector:@selector(tableViewCellUntapped:) withObject:currentIndexPath afterDelay:0.5];
	[self resetTableViewUsingSelectedIndex:nil];
}

#pragma mark -
#pragma mark Picker Delegates methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		return 1;
	}
	if ([[entryCell dataObj] objectForKey: @"fieldName"] ==  RPLocalizedString(@"Project", @"")) {
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
		return 320;
	}
	
	if ([[entryCell dataObj] objectForKey: @"fieldName"] ==  RPLocalizedString(@"Project", @"")) {
		if (component==0) {
			return 150;
		}else {
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

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
//	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	
	@try {
        //Added the below condiito to avoid crash when Empty picker is shown. Need to fix this.
        if ([pickerView numberOfRowsInComponent:component] ==0) {
            return;
        }
        
        G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
        if(entryCell == nil || [entryCell dataObj] == nil)
        {
            return;
        }
        
        if(component == 0)	{
            //DE8142
            
            
//                NSString *_selectedProjectName=[[entryCell dataObj]objectForKey:@"projectName"];
//                NSString *_previousProjectName=[[entryCell dataObj]objectForKey:@"defaultValue"];
//                if (![_selectedProjectName isEqualToString:_previousProjectName]) {
//                    self.projectChanged=YES;//DE6811 Ullas M L
//                }
                
                [[entryCell dataObj] setObject:[NSNumber numberWithInteger: row] forKey:@"selectedIndex"];
                NSString *_selectedName =[[dataSourceArray objectAtIndex:row]objectForKey:@"name"];
                //DE8142
                if ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Currency", @"")] && currentIndexPath.section==0) {
                    _selectedName = [[dataSourceArray objectAtIndex:row]objectForKey:@"symbol"];
                    [self setBaseCurrency:_selectedName];
                }
                //TODO: ravi - This condition should be based on field type and not on field name
                if (![[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Amount", @"Amount")]) {
                    //ravi - DE2711: View/edit expense entry (basic implementation): While Editing a Taxed expense, when we change the currency selection with a quick swipe,
                    //the app crashes
                    //[[entryCell dataObj] setObject:_selectedName forKey:@"defaultValue"];DE2991
                    NSString *selectedDataIdentity = [[dataSourceArray objectAtIndex:row]objectForKey:@"identity"];
                    [[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
                    if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]){//DE2991
                        [[entryCell dataObj] setObject:_selectedName forKey:@"defaultValue"];
                        [self updateFieldAtIndex: currentIndexPath  WithSelectedValues:[[entryCell dataObj] objectForKey: @"defaultValue"]];
                    }
                }
                //DE8142
                if ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Amount", @"Amount")] && currentIndexPath.section==1)
                {
                    NSString *selectedDataIdentity = [[dataSourceArray objectAtIndex:row]objectForKey:@"identity"];
                    [[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
                    if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]){//DE2991
                        [[entryCell dataObj] setObject:_selectedName forKey:@"defaultValue"];
                        [self updateFieldAtIndex: currentIndexPath  WithSelectedValues:[[entryCell dataObj] objectForKey: @"defaultValue"]];
                    }
                    
                }
                
                
                //DE8142
                if ([[entryCell dataObj] objectForKey:@"fieldName"] == RPLocalizedString(@"Type",@"") && currentIndexPath.section==0) {
                    NSString *taxModeOfExpenseType = nil;
                    [self updateFieldAtIndex:currentIndexPath WithSelectedValues:[[entryCell dataObj] objectForKey: @"defaultValue"]];
                    NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow: (currentIndexPath.row+2) inSection: currentIndexPath.section];
                    G2ExpenseEntryCellView *amountEntryCell =
                    (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: amountIndexPath];
                    typeChanged =YES;
                    self.projectChanged=YES;
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
                        if (taxModeOfExpenseType == nil || (![taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]) ) {
                            [[amountEntryCell dataObj] setObject:RPLocalizedString(@"Add", @"") forKey: @"defaultValue"];
                        }
                        
                        if (previousWasTaxExpense == YES) {
                            [[amountEntryCell dataObj] setObject:RPLocalizedString(@"Add", @"") forKey: @"defaultValue"];
                        }
                    }else {
                        taxModeOfExpenseType = [[dataSourceArray objectAtIndex:row] objectForKey:@"type"];
                    }
                    
                    //updated by vijay for amount.
                    BOOL disableCurrencyField = NO;
                    if ([taxModeOfExpenseType isEqualToString:Rated_With_Taxes] ||
                        [taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]) {
                        disableCurrencyField = YES;
                        //update currency to basecurrency for rated type
                        [self updateCurrencyFieldToBasecurrency];
                    }
                    [self changeCurrencyFieldEnableStatus:disableCurrencyField];
                    [self changeAmountRowFieldType :taxModeOfExpenseType];
                    [self enableExpenseFieldAtIndex: amountIndexPath];
                    [self updateDependentFields:[amountEntryCell indexPath] WithSelectedValues:[[amountEntryCell dataObj] objectForKey: @"defaultValue"]];
                    amountValue=@"";//which is used for every Type change....
                }
            
            selectedRowForClients=row;
            //[self tableViewCellUntapped:currentIndexPath];//DE4824 Ullas M l-reverted Fix & fixed DE5235
        }
        
	}
	@finally {
		
	}
	
}

- (void)didSelectRowFromDataList:(NSInteger)row inComponent:(NSInteger)componentIndex{
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	
	@try {
        NSMutableDictionary *projectDict =  [[self firstSectionfieldsArray] objectAtIndex:1];
        NSMutableDictionary *clientDict =  [[self firstSectionfieldsArray] objectAtIndex:0];
        G2ExpenseEntryCellView *expenseClientEntryCellView =(G2ExpenseEntryCellView *)[[self tnewExpenseEntryTable] cellForRowAtIndexPath:
                                                                                   [NSIndexPath indexPathForRow:0 inSection:0]];
        G2ExpenseEntryCellView *expenseProjectEntryCellView =(G2ExpenseEntryCellView *)[[self tnewExpenseEntryTable] cellForRowAtIndexPath:
                                                                                    [NSIndexPath indexPathForRow:1 inSection:0]];
       
            //DE8142
            if ([[expenseProjectEntryCellView dataObj] objectForKey:@"fieldName"] ==  RPLocalizedString(@"Project", @"") && currentIndexPath.section==0) 
            {
                 
                
                
                    NSString *clientIdentity =[clientDict objectForKey:@"clientIdentity"];
//                    NSString *_previousClientName=[[expenseClientEntryCellView dataObj]objectForKey:@"clientName"];//DE6811 Ullas
                    NSString *_selectedClientName=[clientDict objectForKey:@"clientName"];
                    
                    NSString *_selectedProjectName=[projectDict objectForKey:@"projectName"];
//                    NSString *_previousProjectName=[[expenseProjectEntryCellView dataObj]objectForKey:@"defaultValue"];
                    [[expenseClientEntryCellView dataObj] setObject:clientIdentity forKey:@"clientIdentity"];
                    [[expenseProjectEntryCellView dataObj] setObject:[projectDict objectForKey:@"projectIdentity"] forKey:@"projectIdentity"];
                    
                    [[expenseClientEntryCellView dataObj] setObject: [NSNumber numberWithInteger: row] forKey:@"selectedClientIndex"];
                    [[expenseProjectEntryCellView dataObj] setObject: [NSNumber numberWithInt:0] forKey:@"selectedProjectIndex"];
                    [[expenseClientEntryCellView dataObj] setObject: _selectedClientName forKey:@"clientName"];
                    [[expenseProjectEntryCellView dataObj] setObject: _selectedProjectName forKey:@"projectName"];
                    [[expenseProjectEntryCellView dataObj] setObject: projectsArray forKey:@"projectsArray"];
                    [[expenseClientEntryCellView dataObj] setObject: [clientDict objectForKey:@"clientsArr"] forKey:@"clientsArray"];
                    
                    
//                    if (![_previousProjectName isEqualToString:_selectedProjectName]) {
//                        self.projectChanged=YES;//DE6811 Ullas M L
//                    }
//                    if (![_previousClientName isEqualToString:_selectedClientName]&&[_previousProjectName isEqualToString:_selectedProjectName]) {
//                        self.projectChanged=YES;//DE6811 Ullas M L
//                    }

                    
                    NSString *existedTypeName = [[NSString alloc] initWithFormat:@"%@",[[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"defaultValue"]];
                    
                    NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:[projectDict objectForKey:@"projectIdentity"]];
                
                if ([expenseTypeArr count]>0)
                {
                    [[firstSectionfieldsArray objectAtIndex:2] setObject:expenseTypeArr forKey:@"dataSourceArray"];
                }
                    
                    NSMutableDictionary *infoDict1 = [firstSectionfieldsArray objectAtIndex:2];
                    NSMutableDictionary *infoDict2 = [firstSectionfieldsArray objectAtIndex:4];
                   
                    
                    if([_selectedProjectName isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                    {
                        [[expenseProjectEntryCellView dataObj] setObject:[NSString stringWithFormat:@"%@",_selectedProjectName] forKey:@"defaultValue"];
                        [self updateFieldAtIndex: currentIndexPath WithSelectedValues: [[expenseProjectEntryCellView dataObj] objectForKey: @"defaultValue"]];
                        
                    }else {
                        [[expenseProjectEntryCellView dataObj] setObject:[NSString stringWithFormat:@"%@",_selectedProjectName] forKey:@"defaultValue"];
                        [self updateFieldAtIndex:currentIndexPath WithSelectedValues:[[expenseProjectEntryCellView dataObj]objectForKey:@"defaultValue"]];
                    }
                    
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
                                [self reloadCellAtIndex:billClientIndex];
                            }
                    }
                    
                    BOOL validExpenseType = YES;
                    if (![[infoDict1 objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")]) {
                        //[infoDict1 setObject:@"Select" forKey:@"defaultValue"];
                        
                        validExpenseType = [self checkAvailabilityOfTypeForSelectedProject:[projectDict objectForKey:@"projectIdentity"]];
                        if (validExpenseType == NO) {
                            [infoDict1 setObject:[NSNumber numberWithInt: 0] forKey:@"selectedIndex"];
                            [self updateAmountWhenTypeUnAvailable:NO];
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
                            //update currency to basecurrency for rated type
                            [self updateCurrencyFieldToBasecurrency];
                        }
                        
                        NSString *typeNameValid = [infoDict1 objectForKey:@"defaultValue"];
                        [self changeCurrencyFieldEnableStatus:disableCurrencyField];
                        if (![existedTypeName isEqualToString:typeNameValid]){
                            [self changeAmountRowFieldType:taxModeOfExpenseType];
                        }else {
                            //typeChanged = NO; DE6811 Ullas M L
                        }
                        
                        [self updateDependentFields:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION] WithSelectedValues:[infoDict1 objectForKey:@"defaultValue"]];
                        if (validExpenseType)
                            [self updateDependentFields:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues:[infoDict2 objectForKey:@"defaultValue"]];
                    }
                    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow: (currentIndexPath.row+1) inSection: currentIndexPath.section];
                    self.fromReloaOfDataView=NO;
                    if (validExpenseType)
                        [self enableExpenseFieldAtIndex: nextIndexPath];
                    //used to select first project in componrnt 1 always
                    
                
                                
                 [self didSelectionRowFromDataListSecond:row];
            } 
            
            selectedRowForClients=row;
            //[self tableViewCellUntapped:currentIndexPath];//DE4824 Ullas M l-reverted Fix & fixed DE5235
        
        
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
	
    //ravi - this is a rare case. This may happen if the user spins the project before the the projects are refreshed when the client is changed.
    if ([projecttDict objectForKey:@"projectsArray"] == nil || [(NSMutableArray *)[projecttDict objectForKey:@"projectsArray"] count]<=row) {
        return;
    }
    NSString *_selectedProjectName=[projecttDict objectForKey:@"projectName"];
    [[expenseProjectEntryCellView dataObj] setObject: _selectedProjectName forKey:@"projectName"];			
    
    if ([[expenseClientEntryCellView dataObj] objectForKey: @"clientName"] == nil || [[[expenseClientEntryCellView dataObj] objectForKey: @"clientName"]  isEqualToString: RPLocalizedString(NONE_STRING, @"")]) {
        [[expenseClientEntryCellView dataObj] setObject:  [clientDict objectForKey:@"clientName"] forKey: @"clientName"];
    }
    
    [[expenseProjectEntryCellView dataObj] setObject:[projecttDict objectForKey:@"selectedProjectIndex"] forKey:@"selectedProjectIndex"];
    [[expenseProjectEntryCellView dataObj] setObject:[projecttDict objectForKey:@"projectIdentity"] forKey:@"projectIdentity"];
    
    NSString *existedTypeName = [[NSString alloc] initWithFormat:@"%@",[[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"defaultValue"]];
    G2ExpensesModel *expensesMdl = [[G2ExpensesModel alloc] init];
    NSMutableArray *expenseTypeArr = [expensesMdl getExpenseTypesWithTaxCodesForSelectedProjectId:[projecttDict objectForKey:@"projectIdentity"]];
   
    [[firstSectionfieldsArray objectAtIndex:2] setObject:expenseTypeArr forKey:@"dataSourceArray"];
    
    NSMutableDictionary *infoDict1 = [firstSectionfieldsArray objectAtIndex:2];
    NSMutableDictionary *infoDict2 = [firstSectionfieldsArray objectAtIndex:4];
    BOOL validExpenseType = [self checkAvailabilityOfTypeForSelectedProject:[projecttDict objectForKey:@"projectIdentity"]];
    
    if (![[infoDict1 objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")]) {
        if (validExpenseType == NO) {
            [infoDict1 setObject:[NSNumber numberWithInt: 0] forKey:@"selectedIndex"];
            [self updateAmountWhenTypeUnAvailable:NO];
            //[Util errorAlert:nil errorMessage:ExpenseType_UnAvailable];
            //return;
        }  
        G2SupportDataModel *supportDataMdl = [[G2SupportDataModel alloc] init];
        NSString *taxModeOfExpenseType = [supportDataMdl getExpenseModeOfTypeForTaxesFromDB:[projecttDict objectForKey:@"projectIdentity"] withType:[infoDict1 objectForKey: @"defaultValue"] andColumnName:@"type"];
       
        //if (taxModeOfExpenseType == nil ||( ![taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes] && validExpenseType == NO)) {
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
            //update currency to basecurrency for rated type
            [self updateCurrencyFieldToBasecurrency];
        }
        NSString *typeNameValid = [infoDict1 objectForKey:@"defaultValue"];
        
        
        [self changeCurrencyFieldEnableStatus:disableCurrencyField];
        if (![existedTypeName isEqualToString:typeNameValid]){
            [self changeAmountRowFieldType:taxModeOfExpenseType];
        }else {
            typeChanged = NO;
        }
        [self updateDependentFields:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION] WithSelectedValues:[infoDict1 objectForKey:@"defaultValue"]];
        [self updateDependentFields:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues:[infoDict2 objectForKey:@"defaultValue"]];
    }
    
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow: (currentIndexPath.row+1) inSection: currentIndexPath.section];
    [self enableExpenseFieldAtIndex: nextIndexPath];
    
    //DE6811 Ullas M L
    if (validExpenseType) {
        NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:2 inSection: currentIndexPath.section];
        if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
        {
            amountIndexPath = [NSIndexPath indexPathForRow:3 inSection: currentIndexPath.section];   
        }
        [self enableExpenseFieldAtIndex: amountIndexPath];
    }
    
    
    if([_selectedProjectName isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        [[expenseProjectEntryCellView dataObj] setObject:[NSString stringWithFormat:@"%@",_selectedProjectName] forKey:@"defaultValue"];
        [self updateFieldAtIndex: currentIndexPath WithSelectedValues: [[expenseProjectEntryCellView dataObj] objectForKey: @"defaultValue"]];
        
    }else {
        [[expenseProjectEntryCellView dataObj] setObject: [NSString stringWithFormat: @"%@", 
                                         [[expenseProjectEntryCellView dataObj] objectForKey:@"projectName"]] forKey:@"defaultValue"];
        
        [self updateFieldAtIndex: currentIndexPath WithSelectedValues: [[expenseProjectEntryCellView dataObj] objectForKey: @"defaultValue"]];
    }
	

	
    
    
    
    
}

-(void)getReceiptImage{
	RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    //DE4865//Juhi
    //    if (receiptViewController==nil) {
    G2ReceiptsViewController *tempreceiptViewController=[[G2ReceiptsViewController alloc]init];
    self.receiptViewController=tempreceiptViewController;
  
    //    }
	
	[receiptViewController setSheetStatus: expenseSheetStatus];
	//[receiptViewController setIsPictureFromCamera: FALSE];
	if (canNotEdit) {
		[receiptViewController setCanNotDelete:YES];
	}else {
		[receiptViewController setCanNotDelete:NO];
	}
	
	[receiptViewController setB64String: b64String];
	[receiptViewController setInNewEntry: NO];
	[receiptViewController setRecieptDelegate: self];
	[delegate setCurrVisibleViewController: receiptViewController];
	[self.navigationController pushViewController: receiptViewController animated:YES];
	
}

-(void)alertForImageDownloadTimeOut
{
	[memoryExceedAlert show];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"IMAGE_DOWNLOAD_TIMEOUT" object:nil];
	if(base64Decoded !=nil)
	{
		base64Decoded=nil;
	}
	if(b64String !=nil)
	{
		b64String=nil;
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
	
	UIDatePicker *tempdatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0,
                                                                                  45.0 ,
                                                                                  pickerSize.width,
                                                                                  pickerSize.height)];
    self.datePicker=tempdatePicker;
   
	
	datePicker.datePickerMode = UIDatePickerModeDate;
	datePicker.hidden = YES;
	datePicker.date = [NSDate date];
	
	UISegmentedControl *temptoolbarSegmentControl = [[UISegmentedControl alloc] initWithItems:
                                                     [NSArray arrayWithObjects:RPLocalizedString(@"Previous", @"") ,RPLocalizedString(@"Next", @"") ,nil]];
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
                                                                                           pickerSize.height +45.0)];
    self.pickerViewC=temppickerViewC;
   
    
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

- (void)pickerDone:(UIBarButtonItem *)button{
	isPickerDoneClicked=YES;//DE5011 ullas
    
    if (button) 
    {
        [self updateFieldsWithDefaultValues];
    }
	
	
	[pickerViewC setHidden:YES];
	if (numberUdfText!=nil) {
		[numberUdfText resignFirstResponder];
	}
	[self resetTableViewUsingSelectedIndex:nil];
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
    //DE8142
	if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString: RPLocalizedString(@"Project", @"")] && currentIndexPath.section==0) {
		if ([[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] || 
			[[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(NONE_STRING, @"")]) 
		{
			[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
			
			NSString *temp = @"";
			temp = [NSString stringWithFormat: @"%@",
                    [[projectsArray objectAtIndex: 0]objectForKey:@"name"]];
			
			
			if (![temp isEqualToString: @""] &&![temp isKindOfClass:[NSNull class]] && ![temp isEqualToString:@"(null)"]) {
				[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
				[[entryCell dataObj] setObject:temp forKey:@"defaultValue"];
			}
		}
		
		if (![self checkAvailabilityOfTypeForSelectedProject:[[entryCell dataObj]objectForKey:@"projectIdentity"]]) {
			[self tableViewCellUntapped:currentIndexPath];
			[self updateAmountWhenTypeUnAvailable:YES];
			return;
		}else {
			NSIndexPath *amountIndex = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
			id amountCell = [self getCellForIndexPath:amountIndex];
			[amountCell enableRequiredCell];
		}
		
		//NSIndexPath *billClientIndex = [NSIndexPath indexPathForRow:2 inSection:1];
		
		if (dataSourceArray!=nil && [dataSourceArray count]>0)
        {
            if ([[dataSourceArray objectAtIndex:currentIndexPath.row]objectForKey:@"name"]!=nil && [[[dataSourceArray objectAtIndex:currentIndexPath.row]
																									 objectForKey:@"name"] isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
				{
					
					if ([[self getBillClientInfo] intValue] == 1){
						//[self DisableCellAtIndexForCheckmark:billClientIndex];
					}
				}
			}else {
				if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific)
					if ([[self getBillClientInfo] intValue] == 1){
						//[self reloadCellAtIndex:billClientIndex];
					}
			}

        }
    }
	else if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]){
		if(currentIndexPath.section == 0 && [[[entryCell dataObj]objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")]){
			if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific){
				
				G2ExpenseEntryCellView *entryCellCP = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:(currentIndexPath.row)-1 inSection:currentIndexPath.section]];
				if (![self checkAvailabilityOfTypeForSelectedProject:[[entryCellCP dataObj]objectForKey:@"projectIdentity"]]) {
					[[entryCell dataObj]  setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
					//	if (previousWasTaxExpense == YES ) {
					[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row+1] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
					//DE8583
                    if (![[[entryCellCP dataObj]objectForKey:@"projectIdentity"]isEqualToString:@""]) {
                        [self updateFieldAtIndex: [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues: RPLocalizedString(@"Add", @"")];
                    }
					//	}
					typeChanged = YES;
					
				}
				
				//DE8583
				if (![[[entryCellCP dataObj]objectForKey:@"projectIdentity"]isEqualToString:@""])
                    [self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
			}
            else {
                //DE3952
                //                ExpenseEntryCellView *entryCellCP = (ExpenseEntryCellView *)[self.editExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:(currentIndexPath.row)-1 inSection:currentIndexPath.section]];
                //                if (![self checkAvailabilityOfTypeForSelectedProject:[[entryCellCP dataObj]objectForKey:@"projectIdentity"]]) {
                //					[[entryCell dataObj]  setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
                //					//	if (previousWasTaxExpense == YES ) {
                //					[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row+1] setObject:@"Add" forKey:@"defaultValue"];
                //					[self updateFieldAtIndex: [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION] WithSelectedValues: @"Add"];
                //					//	}
                //					typeChanged = YES;
                //				}
                //               //De4433//Juhi
                if (![self checkAvailabilityOfTypeForNonProject]) {
					//[Util errorAlert:nil errorMessage:ExpenseType_UnAvailable];
					[[entryCell dataObj]  setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
					[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row+1] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
                    [self updateFieldAtIndex: [NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION] WithSelectedValues: RPLocalizedString(@"Add", @"")];
                    typeChanged = YES;
				}
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION]];
			}
		}
		
		//DE8820 //DE8217 Ullas M L
		NSNumber *selectedRowIndex=nil;
        if ([[secondSectionfieldsArray objectAtIndex: currentIndexPath.row] objectForKey: @"dataSourceArray"]!=nil) 
        {
            selectedRowIndex = [NSNumber numberWithInt:[G2Util getObjectIndex: 
                                                        [[secondSectionfieldsArray objectAtIndex: currentIndexPath.row] objectForKey: @"dataSourceArray"] 
                                                                    withKey: @"name" 
                                                                   forValue: [[secondSectionfieldsArray objectAtIndex: currentIndexPath.row] objectForKey: @"defaultValue"]]];
        }
        else {
            
            selectedRowIndex = [[entryCell dataObj] objectForKey: @"selectedIndex"];
        }

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
						//update currency to basecurrency for rated type
						[self updateCurrencyFieldToBasecurrency];
					}
					[self changeCurrencyFieldEnableStatus:disableCurrencyField];
				}
			}
			
			[[entryCell dataObj] setObject: temp forKey: @"defaultValue"];
			NSString *selectedDataIdentity = nil;
			selectedDataIdentity = [[dataSourceArray objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"identity"];
			[[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
		}
		
		if (![temp isEqualToString:@""])
			[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
	}
	
	[self tableViewCellUntapped:currentIndexPath];
}


-(void)moveTableToTop:(int)y
{
	[tnewExpenseEntryTable setFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height)];
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
    
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		return;
	}
	//[entryCell setCellViewState: NO];
    //DE8142
	if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString: RPLocalizedString(@"Project", @"")] && currentIndexPath.section==0) {
		if ([[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] || 
			[[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(NONE_STRING, @"")]) 
		{
			[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
			
			NSString *temp = @"";
			temp = [NSString stringWithFormat: @"%@",
					[[projectsArray objectAtIndex: 0]objectForKey:@"name"]];
			
			
			if ( ![temp isEqualToString: @"" ] &&![temp isKindOfClass:[NSNull class]] && ![temp isEqualToString:@"(null)"]) {
				[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
				[[entryCell dataObj] setObject:temp forKey:@"defaultValue"];
			}
		}
	}
	else if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString: DATA_PICKER]){
		//DE8142
		if(currentIndexPath.section == 0 && ([[[entryCell dataObj]objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")] && currentIndexPath.section==0)){
			if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific){
				G2ExpenseEntryCellView *entryCellCP = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:1 inSection:currentIndexPath.section]];
				if (![self checkAvailabilityOfTypeForSelectedProject:[[entryCellCP dataObj]objectForKey:@"projectIdentity"]]) {
					[[entryCell dataObj]  setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
					//	if (previousWasTaxExpense == YES) {
					[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row+2] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
					[self updateFieldAtIndex: [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION] WithSelectedValues: RPLocalizedString(@"Add", @"")];
					
				}
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
			}
            else {
                //DE3952
                //                ExpenseEntryCellView *entryCellCP = (ExpenseEntryCellView *)[self.editExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:(currentIndexPath.row)-1 inSection:currentIndexPath.section]];
                //                if (![self checkAvailabilityOfTypeForSelectedProject:[[entryCellCP dataObj]objectForKey:@"projectIdentity"]]) {
                //					[[entryCell dataObj]  setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
                //					//	if (previousWasTaxExpense == YES) {
                //					[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row+2] setObject:@"Add" forKey:@"defaultValue"];
                //					[self updateFieldAtIndex: [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION] WithSelectedValues: @"Add"];
                //				}
                //De4433//Juhi
                if (![self checkAvailabilityOfTypeForNonProject]) {
					[[entryCell dataObj]  setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
					//	if (previousWasTaxExpense == YES) {
					[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row+1] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
					[self updateFieldAtIndex: [NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION] WithSelectedValues: RPLocalizedString(@"Add", @"")];
				}
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION]];
			}
			
		}
		
		//DE8217 Ullas
        NSNumber *selectedRowIndex=nil;
        if ([[secondSectionfieldsArray objectAtIndex: currentIndexPath.row] objectForKey: @"dataSourceArray"]!=nil) 
        {
            selectedRowIndex = [NSNumber numberWithInt:[G2Util getObjectIndex: 
                                                        [[secondSectionfieldsArray objectAtIndex: currentIndexPath.row] objectForKey: @"dataSourceArray"] 
                                                                    withKey: @"name" 
                                                                   forValue: [[secondSectionfieldsArray objectAtIndex: currentIndexPath.row] objectForKey: @"defaultValue"]]];
        }
        else {
            
            selectedRowIndex = [[entryCell dataObj] objectForKey: @"selectedIndex"];
        }

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
			if (([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")]&&currentIndexPath.section==0)&&[selectedRowIndex intValue] == 0) {
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
			NSString *selectedDataIdentity = nil;
			selectedDataIdentity = [[dataSourceArray objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"identity"];
			[[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
		}
		if (![temp isEqualToString:@""])
			[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
		
	}
	
	[self tableViewCellUntapped:currentIndexPath];
	if([entryCell fieldText] != nil)
		[[entryCell fieldText] resignFirstResponder];
	
    
	NSIndexPath *previousIndexPath = [self getPreviousEnabledFieldFromCurrentIndex:self.currentIndexPath];
	if (previousIndexPath != nil) {
		self.currentIndexPath = previousIndexPath;
		//[self performActionWithRowSelection: currentIndexPath];
		[self tableCellTappedAtIndex:currentIndexPath];
		//[self handleButtonClicks: currentIndexPath]; 
	}
	else {
		//[self changeSegmentControlState:currentIndexPath];
		[pickerViewC setHidden:YES];isPickerDoneClicked=YES;//DE5011 ullas
		[self resetTableViewUsingSelectedIndex:nil];
	}
}


-(G2ExpenseEntryCellView*)getCellForIndexPath:(NSIndexPath*)indexPath
{
	G2ExpenseEntryCellView *cellAtIndex = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: indexPath]; 
	return cellAtIndex;
}

-(BOOL)checkAvailabilityOfTypeForSelectedProject:(NSString*)_projectId
{
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	typeAvailableForProject = NO;
	NSMutableDictionary *infoDict1 = [firstSectionfieldsArray objectAtIndex:2];
	NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:_projectId];
	[[firstSectionfieldsArray objectAtIndex:2] setObject:expenseTypeArr forKey:@"dataSourceArray"];
	
	if (currentIndexPath.section == 0) {
		NSDictionary *_rowData = [firstSectionfieldsArray objectAtIndex: currentIndexPath.row];
		G2ExpenseEntryCellView *entryCellCP = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:currentIndexPath.row inSection:currentIndexPath.section]];
		if ([[entryCellCP dataObj] objectForKey: @"fieldName"] ==  RPLocalizedString(@"Project", @"")) {			
			clientsArray = [_rowData objectForKey: @"clientsArray"];
			self.dataSourceArray = [_rowData objectForKey: @"clientsArray"];
			//projectsArray = [_rowData objectForKey: @"projectsArray"];
		} else {
			self.dataSourceArray = [_rowData objectForKey:@"dataSourceArray"];
			//dataSourceArray = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"dataSourceArray"];
		}
		
		NSString *selectedType= [[NSString alloc] initWithFormat:@"%@",[infoDict1 objectForKey:@"defaultValue"]];
        // [infoDict1 objectForKey:@"defaultValue"]];
		
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
						NSNumber *selectedTypeIndex = [NSNumber numberWithInteger:i];
						[[firstSectionfieldsArray objectAtIndex:2] setObject:selectedTypeDefault forKey:@"defaultValue"];
						[[firstSectionfieldsArray objectAtIndex:2] setObject:selectedTypeIndex forKey:@"selectedIndex"];
						[[firstSectionfieldsArray objectAtIndex:2] setObject:selectedTypeDefault forKey:@"selectedDataSource"];
						[[firstSectionfieldsArray objectAtIndex:2] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
						typeAvailableForProject = YES;
					}
				}
			}
			
			
			
		}
        //fixed memory leak
		
		if (typeAvailableForProject == YES) {
			return YES;
		}else {
			//[Util errorAlert:nil errorMessage:ExpenseType_UnAvailable];
			return NO;
		}
	}else {
		return YES;
	}
    
	
	return 0;
}
//DE4433//Juhi
-(BOOL)checkAvailabilityOfTypeForNonProject
{
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	typeAvailableForProject = NO;
	NSMutableDictionary *infoDict1 = [firstSectionfieldsArray objectAtIndex:0];
	NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForNonProject];
	[[firstSectionfieldsArray objectAtIndex:0] setObject:expenseTypeArr forKey:@"dataSourceArray"];
	
	if (currentIndexPath.section == 0) {
		NSDictionary *_rowData = [firstSectionfieldsArray objectAtIndex: currentIndexPath.row];
		G2ExpenseEntryCellView *entryCellCP = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:currentIndexPath.row inSection:currentIndexPath.section]];
		if ([[entryCellCP dataObj] objectForKey: @"fieldName"] ==  RPLocalizedString(@"Project", @"")) {
			clientsArray = [_rowData objectForKey: @"clientsArray"];
			self.dataSourceArray = [_rowData objectForKey: @"clientsArray"];
			projectsArray = [_rowData objectForKey: @"projectsArray"];
		} else {
			self.dataSourceArray = [_rowData objectForKey:@"dataSourceArray"];
			//dataSourceArray = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"dataSourceArray"];
		}
		
		NSString *selectedType= [[NSString alloc] initWithFormat:@"%@",[infoDict1 objectForKey:@"defaultValue"]];
        // [infoDict1 objectForKey:@"defaultValue"]];
		
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
						[[firstSectionfieldsArray objectAtIndex:0] setObject:selectedTypeDefault forKey:@"defaultValue"];
						[[firstSectionfieldsArray objectAtIndex:0] setObject:selectedTypeIndex forKey:@"selectedIndex"];
						[[firstSectionfieldsArray objectAtIndex:0] setObject:selectedTypeDefault forKey:@"selectedDataSource"];
						[[firstSectionfieldsArray objectAtIndex:0] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
						typeAvailableForProject = YES;
					}
				}
			}
        }
        //fixed memory leak
		
		if (typeAvailableForProject == YES) {
			return YES;
		}else {
			//[Util errorAlert:nil errorMessage:ExpenseType_UnAvailable];
			return NO;
		}
	}else {
		return YES;
	}
    
	
	return 0;
}


- (void)pickerNext:(id )button{
	
	if(numberUdfText != nil)
		[numberUdfText resignFirstResponder];
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	
	//dataSourceArray = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		return;
	}
	//[entryCell setCellViewState: NO];
    //DE8142
	if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString: RPLocalizedString(@"Project", @"")] && currentIndexPath.section==0) {
		if ([[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(@"Select", @"")] || 
			[[[entryCell dataObj] objectForKey: @"defaultValue"]isEqualToString:RPLocalizedString(NONE_STRING, @"")]) 
		{
			[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION]];
			NSString *temp = @"";
			temp = [NSString stringWithFormat: @"%@",
                    [[projectsArray objectAtIndex: 0]objectForKey:@"name"]];
			if ([temp isEqualToString:@"None"]) {
				//temp=@"None";
			}
			
			if (![temp isEqualToString: @""] &&![temp isKindOfClass:[NSNull class]] && ![temp isEqualToString:@"(null)"]) {
				[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
				[[entryCell dataObj] setObject:temp forKey:@"defaultValue"];
			}
			
			/*ExpensesModel *expensesModel=[[ExpensesModel alloc]init];
             NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:[[projectsArray objectAtIndex:0]objectForKey:@"identity"]];
             [[firstSectionfieldsArray objectAtIndex:1] setObject:expenseTypeArr forKey:@"dataSourceArray"];
             */
		}
		
		NSIndexPath *billClientIndex = [NSIndexPath indexPathForRow:2 inSection:1];
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
						[self reloadCellAtIndex:billClientIndex];
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
					//[Util errorAlert:nil errorMessage:ExpenseType_UnAvailable];
					//DE8583
                    if ([[[entryCellCP dataObj]objectForKey:@"projectIdentity"] isEqualToString:@""])
                    {
                        [self changeSegmentControlState:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
                        [self resetTableViewUsingSelectedIndex:nil];
                        
                        [self deselectRowAtIndexPath:currentIndexPath];
                        [self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
                        [self pickerDone:nil];
                    }
                    else {
                        [self updateAmountWhenTypeUnAvailable:YES];
                    }
					
					return;
				}
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
			}
            else {
                //DE3952//Juhi
                //                ExpenseEntryCellView *entryCellCP = (ExpenseEntryCellView *)[self.editExpenseEntryTable cellForRowAtIndexPath: [NSIndexPath indexPathForRow:(currentIndexPath.row)-1 inSection:currentIndexPath.section]];
                //De4433//Juhi
                if (![self checkAvailabilityOfTypeForNonProject]) {
					//[Util errorAlert:nil errorMessage:ExpenseType_UnAvailable];
					[self updateAmountWhenTypeUnAvailable:YES];
					return;
				}
                
				[self enableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION]];
			}
		}
		
		//DE8217 Ullas
        NSNumber *selectedRowIndex=nil;
        if ([[secondSectionfieldsArray objectAtIndex: currentIndexPath.row] objectForKey: @"dataSourceArray"]!=nil) 
        {
            selectedRowIndex = [NSNumber numberWithInt:[G2Util getObjectIndex: 
                                                        [[secondSectionfieldsArray objectAtIndex: currentIndexPath.row] objectForKey: @"dataSourceArray"] 
                                                                    withKey: @"name" 
                                                                   forValue: [[secondSectionfieldsArray objectAtIndex: currentIndexPath.row] objectForKey: @"defaultValue"]]];
        }
        else {
            
             selectedRowIndex = [[entryCell dataObj] objectForKey: @"selectedIndex"];
        }
		
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
			if (([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")] && currentIndexPath.section==0) &&[selectedRowIndex intValue] == 0) {
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
            
			self.selectedDataIdentityStr  =[[dataSourceArray objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"identity"];
			[[entryCell dataObj] setObject:self.selectedDataIdentityStr forKey:@"selectedDataIdentity"];
            //[selectedDataIdentityStr retain];
		}
		
		if (![temp isEqualToString:@""]) {
			[self updateFieldAtIndex: currentIndexPath WithSelectedValues: temp];
		}
	}
	
	[self tableViewCellUntapped:currentIndexPath];
	NSIndexPath *nextIndexPath = [self getNextEnabledFieldFromCurrentIndex:currentIndexPath];
	if (nextIndexPath != nil) {
		[self setCurrentIndexPath:nextIndexPath];
		[self tableCellTappedAtIndex:currentIndexPath];
	}
	else {
		[pickerViewC setHidden:YES];
		[self resetTableViewUsingSelectedIndex:nil];
	}
	
}					 

-(void)reloadDataPicker:(NSIndexPath *)indexPath{
    
    boolIsProjSelForFirstTime=YES;//DE4850 ullas
	
	[pickerViewC setHidden:NO];
	[pickerView1 setHidden:NO];
	[datePicker setHidden:YES];
	
	[pickerViewC setHidden:NO];
	[pickerView1 setHidden:NO];
	[datePicker setHidden:YES];
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath: currentIndexPath];
	if(entryCell == nil || [entryCell dataObj] == nil)
	{
		return;
	}
	
	//if (pickerView1.tag==2000) {
    //DE8142
	if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString: RPLocalizedString(@"Project", @"")] && currentIndexPath.section==0) {
		
		if (![self isProjectAvailableToUser] && projectAvailToUser){
			[self  updatePickerWhenProjectNoLongerAvailForUser];
			projectAvailToUser = NO;
		}
		//ravi While editing an entry in the client/project data picker the previously selected value is not highlighted in the data picker.
		//This will fix the issue
		int selClientIndex = [G2Util getObjectIndex: 
							  [[firstSectionfieldsArray objectAtIndex: indexPath.row] objectForKey: @"clientsArray"] 
										  withKey: @"name" 
										 forValue: [[firstSectionfieldsArray objectAtIndex: indexPath.row] objectForKey: @"clientName"]];
		
		int selProjIndex = [G2Util getObjectIndex: 
							[[firstSectionfieldsArray objectAtIndex: indexPath.row] objectForKey: @"projectsArray"] 
										withKey: @"name" 
									   forValue: [[firstSectionfieldsArray objectAtIndex: indexPath.row] objectForKey: @"projectName"]];
		tmpSelectedClientIndex=selClientIndex;//DE4850 ullas
		
		
		[pickerView1 reloadAllComponents];
	    
        if (hasClient) {
            [pickerView1 selectRow: selClientIndex inComponent:0 animated: NO];
			[pickerView1 selectRow: selProjIndex inComponent:1 animated: NO];
		}
        else
        {
            if(selProjIndex > -1)
                
                 [pickerView1 selectRow: selProjIndex inComponent:0 animated: NO];
        }
	    
		
		
	}
    else {
		//ravi - when clicked on a row with dropdown data the picker is not populated with the selected value. This issue is resolved in the below code changes.
		int selIndex = 0;
         if (indexPath.section==0) {
			if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString: RPLocalizedString(@"Type", @"")]) {
				if (![self isProjectAvailableToUser] && projectAvailToUser)
				{
					projectAvailToUser = NO;
					//[self updatePickerWhenProjectNoLongerAvailForUser];
				}
                            
			selIndex = [[[firstSectionfieldsArray objectAtIndex:indexPath.row] objectForKey:@"selectedIndex"] intValue];	
                    
                    NSNumber *selectedRowIndex = [NSNumber numberWithInt:selIndex];
                    NSString *tempExpenseName = @"";
                    if (dataSourceArray != nil && [dataSourceArray count] > 0) 
                    {
                        tempExpenseName = [[dataSourceArray objectAtIndex: [selectedRowIndex intValue]]objectForKey:@"name"];
                        if ([selectedRowIndex intValue] == 0) 
                        {
                            //get ExpenseType mode for firstexpense and change the type of amount  field.
                            NSMutableArray *expenseTypeArr = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
                            if ([expenseTypeArr count] > 0) 
                            {
                                NSString *firstExpenseTypeMode = [[expenseTypeArr objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"type"];
                                [self changeAmountRowFieldType:firstExpenseTypeMode];
                                BOOL disableCurrencyField = NO;
                                if ([firstExpenseTypeMode isEqualToString:Rated_With_Taxes] || 
                                    [firstExpenseTypeMode isEqualToString:Rated_WithOut_Taxes]) {
                                    disableCurrencyField = YES;
                                    [self updateCurrencyFieldToBasecurrency];
                                }
                                [self changeCurrencyFieldEnableStatus:disableCurrencyField];
                            }
                        }
                        
                        [[entryCell dataObj] setObject: tempExpenseName forKey: @"defaultValue"];
                        NSString *selectedDataIdentity = nil;
                        selectedDataIdentity = [[dataSourceArray objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"identity"];
                        [[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
                    }
                    
                    if (![tempExpenseName isEqualToString:@""])
                        [self updateFieldAtIndex: currentIndexPath WithSelectedValues: tempExpenseName];
                    
                    /******* Enable amount Field ******/
                    NSIndexPath *amountIndex = nil;
                    if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
                        amountIndex = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
                    } 
                    else {
                        amountIndex = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
                    }
                    [self enableExpenseFieldAtIndex:amountIndex];
                
            }
             else if ([[[entryCell dataObj] objectForKey: @"fieldName"] isEqualToString: RPLocalizedString(@"Currency", @"")]) {
                
                 
                 selIndex = [[[firstSectionfieldsArray objectAtIndex:indexPath.row] objectForKey:@"selectedIndex"] intValue];
                 
                 NSNumber *selectedRowIndex = [NSNumber numberWithInt:selIndex];
                 NSString *tempCurrencySymbol = @"";
                 if (dataSourceArray != nil && [dataSourceArray count] > 0)
                 {
                     tempCurrencySymbol = [[dataSourceArray objectAtIndex: [selectedRowIndex intValue]]objectForKey:@"symbol"];
                  
                     
                     [[entryCell dataObj] setObject: tempCurrencySymbol forKey: @"defaultValue"];
                     NSString *selectedDataIdentity = nil;
                     selectedDataIdentity = [[dataSourceArray objectAtIndex:[selectedRowIndex intValue]] objectForKey:@"identity"];
                     [[entryCell dataObj] setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
                 }
                 
                 if (![tempCurrencySymbol isEqualToString:@""])
                     [self updateFieldAtIndex: currentIndexPath WithSelectedValues: tempCurrencySymbol];
                 
                 
             }

        }
         else{
			
            [self updatePaymentMethodOnCell:entryCell];
			selIndex = [G2Util getObjectIndex: 
						[[secondSectionfieldsArray objectAtIndex: indexPath.row] objectForKey: @"dataSourceArray"] 
									withKey: @"name" 
								   forValue: [[secondSectionfieldsArray objectAtIndex: indexPath.row] objectForKey: @"defaultValue"]];
			
		}
		
		[pickerView1 reloadAllComponents];
        if(selIndex > -1)//DE2991
            [pickerView1 selectRow: selIndex inComponent:0 animated: NO];
		
		
	}
}

-(BOOL)isProjectAvailableToUser
{
	if (permissionType == PermType_NonProjectSpecific) {
		return YES;
	}
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	@try {
		NSDictionary *previouslySavedData = nil;
		previouslySavedData = [[NSUserDefaults standardUserDefaults] objectForKey: @"SELECTED_EXPENSE_ENTRY"];
		id cellObj = [self getCellForIndexPath:currentIndexPath];
		if ([[cellObj dataObj] objectForKey:@"fieldName"] == RPLocalizedString(@"Type", @"")) {
			if (firstSectionfieldsArray != nil && [firstSectionfieldsArray count] > 0) {
				previouslySavedData = [firstSectionfieldsArray objectAtIndex:1];
			}
		}
		NSString *projectIdentity =[previouslySavedData objectForKey:@"projectIdentity"];
		NSArray *projIdsArray = [expensesModel getExpenseProjectIdentitiesFromDatabase];
		NSMutableArray *idsArray = [NSMutableArray array];
		if ([projIdsArray count]!=0) {
			for (int i =0 ; i < [projIdsArray count] ; i++) {
				[idsArray addObject:[[projIdsArray objectAtIndex:i] objectForKey:@"identity"]];
			}
		}
		
		if (idsArray != nil && [idsArray count] >0 ) {
			if ([idsArray containsObject:projectIdentity]) {
				return YES;
			}else {
				
			}
		}
	}
	@finally {
		
	}
	return NO;
}

-(void)updatePickerWhenProjectNoLongerAvailForUser
{
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	NSDictionary *previouslySavedData = [[NSUserDefaults standardUserDefaults] objectForKey: @"SELECTED_EXPENSE_ENTRY"];
	NSString *projectIdentity =[previouslySavedData objectForKey:@"projectIdentity"];
	NSString *projName = nil;
	NSString *clientName = nil;
	NSString *clientIdentity = nil;
	//NSArray *projIdsArray = [expensesModel getExpenseProjectIdentitiesFromDatabase];
	
	NSArray *clientTempArray = [expensesModel getExpenseClientsFromDatabase];
	if (clientTempArray != nil && [clientTempArray count] > 0) {
		clientName = [[clientTempArray objectAtIndex:0] objectForKey:@"name"];
		clientIdentity = [[clientTempArray objectAtIndex:0] objectForKey:@"identity"];
		[[firstSectionfieldsArray objectAtIndex:1] setObject:clientName forKey:@"clientName"];
		[[firstSectionfieldsArray objectAtIndex:1] setObject:clientIdentity forKey:@"clientIdentity"];
		[[firstSectionfieldsArray objectAtIndex:1] setObject:clientTempArray forKey:@"clientsArray"];
	}
	
	NSArray *projTempArray = [expensesModel getExpenseProjectsForSelectedClientID:clientIdentity] ;
	
	if ([self isProjectAvailableToUser]) {
		
	}else {
		if (projTempArray != nil && [projTempArray count] > 0) {
			projName = [[projTempArray objectAtIndex:0] objectForKey:@"name"] ;
			projectIdentity = [[projTempArray objectAtIndex:0] objectForKey:@"identity"] ;
			
			[[firstSectionfieldsArray objectAtIndex:1] setObject:projName forKey:@"defaultValue"];
			[[firstSectionfieldsArray objectAtIndex:1] setObject:projName forKey:@"projectName"];
			[[firstSectionfieldsArray objectAtIndex:1] setObject:projectIdentity forKey:@"projectIdentity"];
			[[firstSectionfieldsArray objectAtIndex:1] setObject:projTempArray forKey:@"projectsArray"];
		}
        //DE8583
        else {
            NSIndexPath *amountIndex = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
            if (permissionType == PermType_NonProjectSpecific) {
                amountIndex = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
            }
            [self disableExpenseFieldAtIndex:amountIndex];
        }
    }
	
	BOOL typeAvail = [self checkAvailabilityOfTypeForSelectedProject:projectIdentity];
	if (!typeAvail) {
		NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId:projectIdentity];
		if (expenseTypeArr != nil && [expenseTypeArr count] > 0) {
			NSString *typeTempVal = [[expenseTypeArr objectAtIndex:0] objectForKey:@"name"];
			[[firstSectionfieldsArray objectAtIndex:2] setObject:typeTempVal forKey:@"defaultValue"];
			
		}
	}
	
	NSString *projTempId = @"null";
	NSString *typeTemp = nil;
	if (firstSectionfieldsArray != nil && [firstSectionfieldsArray count] > 0 && [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"projectIdentity"] != nil )
		projTempId = [[firstSectionfieldsArray objectAtIndex:1] objectForKey:@"projectIdentity"];
    typeTemp = [[firstSectionfieldsArray objectAtIndex:2] objectForKey:@"defaultValue"];
    NSString *taxModeOfExpenseType = [supportDataModel getExpenseModeOfTypeForTaxesFromDB:projTempId withType:typeTemp andColumnName:@"type"];
    if (taxModeOfExpenseType != nil && !typeAvail ) {
        previousWasTaxExpense = YES;
        typeChanged = YES;
        [self changeAmountRowFieldType:taxModeOfExpenseType];
    }
	
	id cellObj = [self getCellForIndexPath:currentIndexPath];
	
	if ([[[cellObj dataObj]objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Project", @"")] || [[[cellObj dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")]) {
		if ([[cellObj dataObj] objectForKey:@"fieldName"] == RPLocalizedString(@"Project", @"")) {
			//[[cellObj fieldButton] setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
			[(UIButton *)[cellObj fieldButton] setTitle:[[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"defaultValue"] forState:UIControlStateNormal];
			id cellObjNext = [self getCellForIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row+1 inSection:currentIndexPath.section]];
			//[[cellObjNext fieldButton] setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
			[(UIButton *)[cellObjNext fieldButton] setTitle:[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"] forState:UIControlStateNormal];
		}else {
            //DE7397
			//[[cellObj fieldButton] setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
			[(UIButton *)[cellObj fieldButton] setTitle:[[firstSectionfieldsArray objectAtIndex:2]objectForKey:@"defaultValue"] forState:UIControlStateNormal];
			id cellObjPre = [self getCellForIndexPath:[NSIndexPath indexPathForRow:currentIndexPath.row-1 inSection:currentIndexPath.section]];
			//[[cellObjPre fieldButton] setTitle:[[firstSectionfieldsArray objectAtIndex:0]objectForKey:@"projectName"] forState:UIControlStateNormal];
			[(UIButton *)[cellObjPre fieldButton] setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
			[(UIButton *)[cellObjPre fieldButton] setTitle:[[cellObjPre dataObj]objectForKey:@"projectName"] forState:UIControlStateNormal];
		}
        
	}
	[self checkClientWithName];
	
	
}

-(void)updatePaymentMethodOnCell:(G2ExpenseEntryCellView*)entryCell
{
    //DE8142
	if (entryCell!=nil && ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Payment Method", @"")]&& currentIndexPath.row<udfStartIndex) ) {
		NSMutableArray *paymentsArray = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
		NSString *paymentFirst = nil;
		if (paymentsArray !=nil && [paymentsArray count] >0 && [[[entryCell dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(@"Select", @"")] ) {
			if (paymentFirst == nil || [paymentFirst isKindOfClass: [NSNull class]] || [paymentFirst isEqualToString: RPLocalizedString(@"Select", @"")]) {
				paymentFirst = [[paymentsArray objectAtIndex:0] objectForKey:@"name"];
				//[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
				[entryCell.fieldButton setTitle:paymentFirst forState:UIControlStateNormal];
				[[entryCell dataObj] setObject:paymentFirst forKey:@"defaultValue"];
			}else {
				
			}
			
			
		}
		
	}
    //DE8142
    else if (entryCell!=nil && ([[[entryCell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(@"Type", @"")] && currentIndexPath.section==0)) {
		NSMutableArray *typesArray = [[entryCell dataObj] objectForKey:@"dataSourceArray"];
		NSString *typeDefault = [[entryCell dataObj] objectForKey: @"defaultValue"];
		
		if (typesArray !=nil && [typesArray count] >0) {
			if (typeDefault == nil || [typeDefault isKindOfClass:[NSNull class]] || [typeDefault isEqualToString: RPLocalizedString(@"Select", @"")]) {
				typeDefault = [[typesArray objectAtIndex:0] objectForKey:@"name"];
			}
		}
        else
        {
            typeDefault=RPLocalizedString(@"Select", @"");
        }
		[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
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
        //[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
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
                //[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal ];//US4065//Juhi
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
		return;
	}
	
	
	NSString *dateToStringValue = [G2Util convertPickerDateToString:datePicker.date];
	if (dateToStringValue!=nil) {
        if ([[[entryCell dataObj] objectForKey:@"fieldType"] isEqualToString:DATE_PICKER]) {//DE2991
            [[entryCell dataObj] setObject:dateToStringValue forKey:@"defaultValue"];
            [self updateFieldAtIndex: currentIndexPath WithSelectedValues:dateToStringValue];
        }
	}
    //[self tableViewCellUntapped:currentIndexPath];//DE4824 Ullas M l-reverted Fix & fixed DE5235
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


-(void)setDeletedFlags
{
	imageDeletePressed=YES;
	if (b64String != nil && ![b64String isKindOfClass: [NSNull class]] ) {
		
		b64String = nil;
	}
	[self setDescription: RPLocalizedString(@"Add", @"")];
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

#pragma mark - numeric keypad handlers

-(void)hidePickersForKeyBoard:(UITextField*)textField{
	NSIndexPath *selectedIndex = nil;
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
	self.numberUdfText=textField;
	[pickerView1 setHidden:YES];
	[pickerViewC setHidden:NO];
	[datePicker setHidden:YES];
	[pickerViewC setBackgroundColor:[UIColor clearColor]];
	[self resetTableViewUsingSelectedIndex: currentIndexPath];
	[self changeSegmentControlState: currentIndexPath];
}
-(void)highLightCellWhichIsSelected:(NSIndexPath*)indexTapped{
	id cellSelected = [self getCellForIndexPath:indexTapped];
	[cellSelected setBackgroundColor:RepliconStandardBlueColor];//DE3566//Juhi
	[tnewExpenseEntryTable selectRowAtIndexPath:indexTapped animated:YES scrollPosition:UITableViewScrollPositionNone];
	[cellSelected setCellViewState:YES];
}

-(void)updateNumberOfDecimalPlaces:(NSNumber*)decimalPlaces
{
	deimalPlacesCount=[decimalPlaces intValue];
	
}
-(BOOL)validAmount{
    NSString *identity= [[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"];
    if ((permissionType == PermType_ProjectSpecific && [identity isEqualToString:@""])&& currentIndexPath.section==0)
    {
        [self changeSegmentControlState:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
        [self resetTableViewUsingSelectedIndex:nil];
        //[pickerView1 setHidden:YES];
        [self hideKeyBoard];
        [self deselectRowAtIndexPath:currentIndexPath];
        [self disableExpenseFieldAtIndex:[NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION]];
        [self pickerDone:nil];
        return NO;
    }

    return YES;
    
}
-(void)addValuesToNumericUdfs:(UITextField*)textFields
{
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
		DLog(@"amount double value %lf",amountDoubleValue);
		NSString *amountString = [G2Util formatDoubleAsStringWithDecimalPlaces:amountDoubleValue];
		[infoDict setObject:amountString forKey:@"defaultValue"];
		G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:tempCurrentIndexPath];
		[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[entryCell.fieldButton setTitle:amountString forState:UIControlStateNormal];
		[entryCell.fieldText setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
		[entryCell.fieldText setText:amountString];
		return;
	}
	
    //textFields.text=[Util formatDecimalPlacesForNumericKeyBoard:[textFields.text doubleValue] withDecimalPlaces:deimalPlacesCount];
    NSString *tempValue =	[G2Util formatDecimalPlacesForNumericKeyBoard:[textFields.text doubleValue] withDecimalPlaces:deimalPlacesCount];
    if (tempValue == nil) {
        tempValue = textFields.text;
    }
    textFields.text = [G2Util removeCommasFromNsnumberFormaters:tempValue];
	
	self.numberUdfText=textFields;
	NSMutableDictionary *infoDict =[secondSectionfieldsArray objectAtIndex: currentIndexPath.row];
	
	[infoDict setObject:numberUdfText.text forKey:@"defaultValue"];
	
	G2ExpenseEntryCellView *entryCell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:currentIndexPath];
	if (entryCell.fieldText == nil) {
		[[entryCell dataObj] setObject: @"" forKey: @"defaultValue"];
		[entryCell.fieldText setText:RPLocalizedString(textFields.text,@"")];
	}else	{
		[[entryCell dataObj] setObject: entryCell.fieldText.text forKey: @"defaultValue"];
	}	
	
	self.numberUdfText=entryCell.fieldText;//DE5422 Ullas M L
    [self resetTableViewUsingSelectedIndex:nil];
	[datePicker setHidden:YES];
	//[self tableViewCellUntapped:currentIndexPath];//DE5422 Ullas M L
}

-(void)numericKeyPadAction:(G2ExpenseEntryCellView*)cell withEvent: (UIEvent *) event 
{
	self.numberUdfText=cell.fieldText;
	[cell.fieldText becomeFirstResponder];
    
	[numberUdfText becomeFirstResponder];
    NSString *identity= [[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"];
    if ((permissionType == PermType_ProjectSpecific && [identity isEqualToString:@""])&& currentIndexPath.section==0)
    {
        [self hideKeyBoard];
        [pickerViewC setHidden:YES];
       
    }
	else {
        [pickerViewC setHidden:NO];
        
        
    }
    [pickerView1 setHidden:YES];
	[pickerViewC setBackgroundColor:[UIColor clearColor]];
    [self changeSegmentControlState:currentIndexPath];
}


-(void)resetTableViewUsingSelectedIndex:(NSIndexPath*)selectedIndex
{
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.0];
	if (selectedIndex!=nil) {
        //JUHI
        CGRect screenRect = [[UIScreen mainScreen] bounds];
		if (selectedIndex.section == 0) {
            //JUHI
			[self.mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                     screenRect.size.height-320)];
            
            float height=0.0;
            height=height+([firstSectionfieldsArray count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT);
            height=height+180.0;
            
            
            
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
            
            
            height=height+180.0;
            
            
            
            
            
            self.mainScrollView.contentSize=CGSizeMake(self.view.frame.size.width,height);
            
            [self.mainScrollView setContentOffset:CGPointMake(0.0,(([firstSectionfieldsArray count]*ROW_HEIGHT)+(selectedIndex.row*ROW_HEIGHT))) animated:YES];
        }
        
        
        
        
		
		
	}else if (selectedIndex==nil) {
        
		//DE5011 ullas
        if (isPickerDoneClicked) {
            isPickerDoneClicked=NO;
            [self.mainScrollView setFrame:CGRectMake(0,0.0,self.view.frame.size.width,self.view.frame.size.height)];
        }
        CGRect rect=self.tnewExpenseEntryTable.frame;
        rect.origin.y=5.0;
        self.tnewExpenseEntryTable.frame=rect;
        CGSize size=self.mainScrollView.contentSize;
        //US4065//Juhi
        
        //        if (!canNotEdit) {
        //            
        //            if (permissionType==PermType_NonProjectSpecific) {
        //                
        //                if (countEditExpenseUDF==0) {
        //                    if ([secondSectionfieldsArray count]<5)
        //                    {
        //                        scrollHeight=15;
        //                    }
        //                    //countEditExpenseUDF=1;
        //                    else
        //                        scrollHeight=60;
        //                }
        //                
        //                else{
        //                    if (countEditExpenseUDF>=4)
        //                    {
        //                        int i=4;
        //                        
        //                        scrollHeight=(scrollHeight=50+(20*(i-(countEditExpenseUDF-4)))+15)-85;
        //                        DLog(@"scrollHeight %i",scrollHeight);
        //                    }
        //                    else{
        //                        if (countEditExpenseUDF<=3)
        //                        {
        //                            int i=8;
        //                            scrollHeight=(15*(i-(countEditExpenseUDF-1))+10)-90;
        //                            DLog(@"scrollHeight %i",scrollHeight);
        //                        }
        //                        
        //                    }                
        //                }
        //                
        //            }
        //            
        //            else
        //            {
        //                if (countEditExpenseUDF==0)
        //                {
        //                    if ([secondSectionfieldsArray count]<=5)
        //                    {
        //                        scrollHeight=105;
        //                    }
        //                    //countEditExpenseUDF=1;
        //                    else
        //                        scrollHeight=145;
        //                    
        //                }
        //                else{
        //                    if (countEditExpenseUDF>=4)
        //                    {
        //                        int i=4;
        //                        
        //                        scrollHeight=50+(20*(i-(countEditExpenseUDF-4)))+15;
        //                    }
        //                    else{
        //                        if (countEditExpenseUDF<=3)
        //                        {
        //                            int i=8;
        //                            scrollHeight=15*(i-(countEditExpenseUDF-1))+10;
        //                        }
        //                        
        //                    }                
        //                }
        //            }
        //            
        //            
        //            
        //        }       
        //
        //            if (countEditExpenseUDF<=3)
        //            {
        //                size.height= self.view.frame.size.height+((countEditExpenseUDF+1)*60.0)+scrollHeight;
        //            }
        //            else
        size.height=([firstSectionfieldsArray count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT)+35.0+20.0+20.0+20.0+90;
        
        
        
        self.mainScrollView.contentSize=size;
	}	
	[UIView commitAnimations];
}


#pragma mark Response Handle Methods
#pragma mark -
-(void)handleExpenseEntrySaveResponse:(id) response {
	//insert
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	
	[expensesModel insertExpenseSheetsInToDataBase:response];
	[expensesModel insertExpenseEntriesInToDataBase:response];
	[[NSUserDefaults standardUserDefaults]setObject:[expensesModel getExpenseSheetsFromDataBase] forKey:@"expenseSheetsArray"];
	[[NSUserDefaults standardUserDefaults]setObject:[expensesModel getExpenseEntriesFromDatabase] forKey:@"expenseEntriesArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ExpenseEntriesNotification"
														object:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
	//[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	if(base64Decoded !=nil )
	{
		
		base64Decoded=nil;
	}

}



-(void)handleEditedExpenseEntryResponse:(id)response{
#ifdef DEV_DEBUG
	//DLog(@"expenseEntryDetailsDict ===>%@<===\n",expenseEntryDetailsDict);
	DLog(@"REsponse ===>%@<===\n", response);
#endif
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	
	NSDictionary *sheetProperties = [[response objectAtIndex: 0] objectForKey: @"Properties"];
	
	if (sheetProperties != nil && [sheetProperties count] > 0) {
		[expenseEntryDetailsDict setObject:[sheetProperties objectForKey: @"TotalReimbursement"] forKey: @"TotalReimbursement"];
	}
	
    if([expenseEntryDetailsDict objectForKey:@"projectIdentity"]!=nil)
    {
        G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
        [myDB updateColumnFromTable:@"isExpensesRecent" fromTable:@"projects" withString:[NSString stringWithFormat:@"1 where expensesAllowed = 1 and identity='%@'",[expenseEntryDetailsDict objectForKey:@"projectIdentity"]] inDatabase:@""];
    }

    
	[expensesModel updateExpenseById:expenseEntryDetailsDict];
    
        
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    //DE7044
    [standardUserDefaults setObject:[expensesModel getExpenseSheetsFromDataBase] forKey:@"expenseSheetsArray"];
    
	[standardUserDefaults setObject:[expensesModel getExpenseEntriesFromDatabase] forKey:@"expenseEntryArray"];
    [standardUserDefaults synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"ExpenseEntriesNotification"
														object:nil];
	//[self.navigationController popViewControllerAnimated:YES];//DE3395//JUHI
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    //DE3395//Juhi
    [self.navigationController popViewControllerAnimated:YES];
    [editControllerDelegate performSelector:@selector(highlightTheCellWhichWasSelected) withObject:nil afterDelay:0.0];
    [editControllerDelegate performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.3];
	
}


-(void)handleDeleteExpenseEntryResponse:(id)response{
	//TODO Delete the Entry From DB
	
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];	
	[expensesModel deleteExpenseEntryFromDatabase:[[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"]objectForKey:@"identity"]];
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:[expensesModel getExpenseEntriesFromDatabase] forKey:@"expenseEntryArray"];
    [standardUserDefaults synchronize];
	NSString *sheetIdentity = [[standardUserDefaults objectForKey:@"SELECTED_EXPENSE_ENTRY"] objectForKey:@"expense_sheet_identity"];
	[[G2RepliconServiceManager expensesService] sendRequestTogetExpenseSheetInfo:sheetIdentity :self];
	
	
}

-(void)handleExpenseSheetInfoResponse:(id)response {
	
	NSDictionary *sheetDict = [response objectAtIndex:0];
	if (sheetDict != nil && ![sheetDict isKindOfClass:[NSNull class]]) {
		NSString *sheetIdentity = [sheetDict objectForKey:@"Identity"];
		NSString *totalReimbursement=[[sheetDict objectForKey:@"Properties"] objectForKey:@"TotalReimbursement"];
		G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
		[expensesModel updateExpenseSheetTotalReimbursementAmount:totalReimbursement sheetId:sheetIdentity];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ExpenseEntriesNotification"
															object:nil];
		[self.navigationController popViewControllerAnimated:YES];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		
	}
}

#pragma mark -
#pragma mark ServerProtocolMethods
#pragma mark -
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
					//[self handleExpenseEntrySaveResponse:expenseByIDArray];
					[self handleExpenseSheetInfoResponse:expenseByIDArray];
				}
				
			}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == ExpenseReceiptImage_Service_Id_35){
				imgDownloaded=YES;	
				//NSArray *expenseReceiptArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
			}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == EditExpenseEntries_Service_Id){
                
				NSArray *editExpenseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (editExpenseArray!=nil && [editExpenseArray count]!=0) {
					[self handleEditedExpenseEntryResponse:editExpenseArray];
				}//
			}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == DeleteExpenseEntry_ServiceID_25){
				NSArray *deleteExpenseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (deleteExpenseArray!=nil && [deleteExpenseArray count]!=0) {
					[self handleDeleteExpenseEntryResponse:deleteExpenseArray];
				}//
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
		[G2Util showOfflineAlert];
        [self pickerDone:nil];
		return;
	}
	
    [self showErrorAlert:error];
    return;
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
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED) ];
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


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
-(NSData*)getBase64DecodedString:(NSString*)base64EncodedString{
	
	NSData *decodedString  = [G2Util decodeBase64WithString:base64EncodedString];
	return decodedString;
}
#pragma mark AmountValues

-(void)updateCurrencyFieldToBasecurrency {
	
	NSIndexPath *currencyIndexPath = [NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION];
	if (permissionType ==PermType_NonProjectSpecific) {
		currencyIndexPath = [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION];
	}
	
	//SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];	
	//NSMutableArray *baseCurrencyArray =[supportDataModel getBaseCurrencyFromDatabase];
	
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
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
		[self updateFieldAtIndex:currencyIndexPath WithSelectedValues:[NSString stringWithFormat:@"%@",baseCurrency]];
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

-(void)changeAmountRowFieldType :(NSString *)expenseTypeMode{
	
    [self updateTypeSelectionLogic:expenseTypeMode];
	/*NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
	if (permissionType == PermType_NonProjectSpecific) {
		amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
	}
	
	ExpenseEntryCellView *cell = (ExpenseEntryCellView *)[self.editExpenseEntryTable cellForRowAtIndexPath:amountIndexPath];
	NSString *fieldType = nil;
	if ([expenseTypeMode isEqualToString:Flat_WithOut_Taxes] ) {
		fieldType = NUMERIC_KEY_PAD;
		[[cell dataObj] setObject:fieldType forKey:@"fieldType"];
		[cell setDecimalPlaces:2];
 		[cell addTextFieldsForTextUdfsAtIndexRow:(amountIndexPath.row+FIRSTSECTION_TAG_INDEX)];
		[cell.fieldText setHidden:NO];
		if (previousWasTaxExpense)  //&& typeChanged .... 
		{
			[cell.fieldText setText:RPLocalizedString(@"Add", @"")];
			[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"]; 
			previousWasTaxExpense = NO;
		}
		else {
			[cell.fieldText setText:[[cell dataObj]objectForKey:@"defaultValue"]];
		}
		[cell.fieldButton setHidden:YES];
		
		//amountValuesArray = nil;
        [self.amountValuesArray removeAllObjects];
		ratedCalculatedValuesArray = nil;
	}
	else {
		fieldType = MOVE_TO_NEXT_SCREEN;
		[[cell dataObj] setObject:fieldType forKey:@"fieldType"];
		if (cell.fieldText != nil) {
			[cell.fieldText setHidden:YES];
		}
		[cell.fieldButton setHidden:NO];
		[cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[cell.fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5805//Juhi
		[cell.fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
		if (typeChanged){
            [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
            [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"") forState:UIControlStateNormal];
            [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"]; 
            //amountValuesArray = nil;
            [self.amountValuesArray removeAllObjects];
            ratedCalculatedValuesArray = nil;
		}
	}
	
	[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
	[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];*/
	
}


-(void)setAmountArrayBaseCurrency:(NSMutableArray*)_amountArray{
	[self setAmountValuesArray:[NSMutableArray arrayWithArray:_amountArray]];
	[self setBaseCurrency:[amountValuesArray objectAtIndex:0]];
	
	NSIndexPath *currencyIndexPath = [NSIndexPath indexPathForRow:3 inSection:G2EXPENSE_SECTION];
	if(permissionType == PermType_NonProjectSpecific) {
		currencyIndexPath = [NSIndexPath indexPathForRow:1 inSection:G2EXPENSE_SECTION];
	}
	
	G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:currencyIndexPath];
	[[cell dataObj] setObject:baseCurrency forKey:@"defaultValue"];
	[cell.fieldButton setTitle:baseCurrency forState:UIControlStateNormal];
	[cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	
}
-(void)setAmountArrayToNil
{
	[amountValuesArray removeAllObjects];
    
    //	amountValuesArray=nil;
}
- (void)viewWillDisappear:(BOOL)animated
{
	[editControllerDelegate performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.5];
}
-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
    //    if(isNotFromNextScreen)
    //    {
    //        [self setfirstSectionFields];
    //        [self setSecondSectionFields];
    //    }
    NSDictionary *dict=(NSDictionary *)[[NSUserDefaults standardUserDefaults] 
                                        objectForKey:@"SELECTED_EXPENSE_ENTRY"];
	self.kilometersUnitsValue = [NSString stringWithFormat:@"%@", [dict objectForKey:@"noOfUnits"]] ;
	[self createFooterView];
	[self  addTitleToNavigation];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (permissionType == PermType_ProjectSpecific  && !canNotEdit)
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

-(void)addTitleToNavigation
{
	DLog(@"Expense Sheet status: %@", expenseSheetStatus);
	if( ![expenseSheetStatus isKindOfClass:[NSNull class]] &&( [expenseSheetStatus isEqualToString:@"Not Submitted"] || [expenseSheetStatus isEqualToString:@"Rejected"]))
	{
		[G2ViewUtil setToolbarLabel:self withText: RPLocalizedString(EditExpense, EditExpense)];
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(CANCEL_BTN_TITLE, @"Cancel")
																		 style:UIBarButtonItemStylePlain 
																		target:self 
																		action:@selector(cancelAction:)];
		[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
		
        
	} else {
		[G2ViewUtil setToolbarLabel:self withText: RPLocalizedString(EntryExpense, EntryExpense)];
    }
	if (canNotEdit) 
    {
 	}
}
//US4065//Juhi
-(void)backButtonAction:(id)sender{
	//DLog(@"backButtonAction ::AddNewTimeEntryViewController");
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)createFooterView{
	
	float footerHeight = 150;
	if (canNotEdit) {
		footerHeight = 50;
	}
	
	UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                      0.0,
                                                                      self.tnewExpenseEntryTable.frame.size.width,
                                                                      footerHeight)];
    self.footerView=tempfooterView;
   
    
	[footerView setBackgroundColor:[UIColor clearColor]];
	[footerView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[self.tnewExpenseEntryTable setTableFooterView:footerView];
	
	if (canNotEdit) {
		
	} else	{
		self.deletButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
		UIImage *img = [G2Util thumbnailImage:DeleteExpenseButton];
		UIImage *imgSel = [G2Util thumbnailImage:DeleteExpenseButtonSelected];
		[deletButton setBackgroundImage:img forState:UIControlStateNormal];
		[deletButton setBackgroundImage:imgSel forState:UIControlStateHighlighted];
		
		[deletButton setTitle:RPLocalizedString(DELETE,@"Delete") forState:UIControlStateNormal];
		[deletButton setFrame:CGRectMake(40.0, 15.0, img.size.width, img.size.height)];//US4065//JUHI
        deletButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
		[deletButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
		deletButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		[footerView addSubview:deletButton];
	}	
}

-(void)setRecieptCellEnbled
{
	NSIndexPath *receiptIndex = nil;
	if (permissionType == PermType_Both || permissionType == PermType_ProjectSpecific) {
		if ([[self getBillClientInfo] intValue] == 1) {
			receiptIndex = [NSIndexPath indexPathForRow:3 inSection:1];
		}else {
			receiptIndex = [NSIndexPath indexPathForRow:2 inSection:1];
		}
	}else {
		receiptIndex = [NSIndexPath indexPathForRow:2 inSection:1];
	}
	
	id receiptCell = (G2ExpenseEntryCellView*)[tnewExpenseEntryTable cellForRowAtIndexPath:receiptIndex];
	if([[[receiptCell dataObj] objectForKey:@"fieldType"] isEqualToString: IMAGE_PICKER]&& ! [[[receiptCell dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(@"Add", @"")] ){
		[receiptCell setUserInteractionEnabled:YES];
		[saveButton setEnabled:NO];
		[footerView setHidden:YES];
	}else {
		[receiptCell setUserInteractionEnabled:NO];
		[saveButton setEnabled:NO];
		[footerView setHidden:YES];
	}
}

-(void)deleteAction:(id)sender{
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
#ifdef PHASE1_US2152
        [G2Util showOfflineAlert];
        [self pickerDone:nil];
        return;
#endif
	}
	
	NSString * message = @"Permanently Delete expense?";
	[self confirmAlert:RPLocalizedString(@"Delete", @"Delete") confirmMessage:RPLocalizedString(message, message)];
}

-(void)setCurrencyId:(NSString *)_identity selectedIndex:(NSNumber *)_selectedRowIndex{
	//[self setCurrencyIdentity:[NSString stringWithString:_identity]];
	[self setCurrencyIdentity:_identity];
	
	int index = 1;
	/*NSMutableDictionary *infoDict = [firstSectionfieldsArray objectAtIndex:1];*/
	if(permissionType != PermType_NonProjectSpecific) {
		index = 3;
	}
	[[firstSectionfieldsArray objectAtIndex:index] setObject:_selectedRowIndex forKey:@"selectedIndex"];
	[[firstSectionfieldsArray objectAtIndex:index] setObject:baseCurrency forKey:@"selectedDataSource"];
	[[firstSectionfieldsArray objectAtIndex:index] setObject:_identity forKey:@"selectedDataIdentity"];
	//[infoDict setObject:_identity forKey:@"selectedDataIdentity"];
    //	[infoDict setObject:baseCurrency forKey:@"selectedDataSource"];
    //	[infoDict setObject:_selectedRowIndex forKey:@"selectedIndex"];
    //	[infoDict setObject:currenciesArray forKey:@"dataSourceArray"];
}

#pragma mark IMAGE_MEMORY_WARNIG
-(void)showUnsupportedAlertMessage
{
	NSString *_msg = RPLocalizedString(@"This receipt is in a format not supported by the image viewer \n \n Please log in to Replicon to view the receipt", "");//US4337//Juhi
	UIAlertView * unsupportedImageAlert=[[UIAlertView alloc] initWithTitle:nil 
                                                                   message:RPLocalizedString(_msg, _msg) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
	[unsupportedImageAlert setTag:Image_Alert_Unsupported];
	[unsupportedImageAlert show];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.	
    [super didReceiveMemoryWarning];
}



#pragma mark -
#pragma mark UIAlertView

-(void) confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message {
	
	
	UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:message
															  delegate:self cancelButtonTitle:RPLocalizedString(CANCEL_BTN_TITLE, @"Cancel")otherButtonTitles:_buttonTitle,nil];
	[confirmAlertView setDelegate:self];
	[confirmAlertView setTag:0];
	
	if ([_buttonTitle isEqualToString: RPLocalizedString(DELETE,@"Delete")]) {
		[confirmAlertView setTag:1];
	}
	
	[confirmAlertView show];
	
	
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
	
	else if (buttonIndex ==1&&alertView.tag==1) {	
		
		NSDictionary *selectedExpEntry = [[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"];
		if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
            G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
			[expensesModel deleteExpenseEntryInOffline:[selectedExpEntry objectForKey:@"identity"]
											   sheetId:[selectedExpEntry objectForKey:@"expense_sheet_identity"]];
			
			NSArray *arr = [expensesModel getExpenseEntriesFromDatabase];
			[[NSUserDefaults standardUserDefaults]setObject:arr forKey:@"expenseEntryArray"];
            [[NSUserDefaults standardUserDefaults] synchronize];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ExpenseEntriesNotification"
																object:nil];
			[self.navigationController popViewControllerAnimated:YES];
           
			
		}else {
			NSMutableArray *entryDetailsArr = [[NSMutableArray alloc] init];
		    [entryDetailsArr addObject:[NSDictionary dictionaryWithObject:[selectedExpEntry objectForKey:@"identity"]forKey:@"identity"]];
			[[G2RepliconServiceManager expensesService]sendRequestToDeleteExpenseEntriesForSheet: entryDetailsArr 
																					   sheetId: [selectedExpEntry objectForKey:@"expense_sheet_identity"]
																					  delegate: self];
			
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:DeletingMessage];
           
		}
        
	}
	
	
}

- (void)alertViewCancel:(UIAlertView *)alertView{
	
}


#pragma mark network protocol

-(void) networkActivated {
	//do nothing
}

-(void)alertViewNotToShow
{	
	canNotEdit = NO;
}

-(void)handleScreenBlank
{
    
    //    ListOfExpenseEntriesViewController *expenseEntriesCtrl=nil;
    //    for (int i=0; i<[self.navigationController.viewControllers count]; i++) 
    //    {
    //
    //        if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[ListOfExpenseEntriesViewController   class] ])
    //        {
    //
    //            expenseEntriesCtrl=[self.navigationController.viewControllers objectAtIndex:i];
    //            break;
    //        }
    //    }
    if (editControllerDelegate) {
        
        [self.navigationController popToViewController:editControllerDelegate animated:FALSE];
    }
    //DE5255
    
}

-(void)updateTypeSelectionLogic:(NSString *)expenseTypeMode
{
    NSString *taxModeOfExpenseType=expenseTypeMode;
    //DLog(@"%@ ---->%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"previousTaxType"],taxModeOfExpenseType);
    NSString *previousTaxModeOfExpenseType=[[NSUserDefaults standardUserDefaults]objectForKey:@"previousTaxType"];
    
    [[NSUserDefaults standardUserDefaults]setObject:taxModeOfExpenseType forKey:@"previousTaxType"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //DE7397
    if (previousTaxModeOfExpenseType ==nil && taxModeOfExpenseType!=nil)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"scenario1" forKey:@"PreviousSelectedScenario"];
        [[NSUserDefaults standardUserDefaults]synchronize];
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
            //[cell.fieldText setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            //DE7005 Ullas M L
            if (!expenseTypesDownloaded){
            [cell.fieldText setText:RPLocalizedString(@"Add", @"Add")];
            [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"]; 
            }
            if (self.projectChanged) {
                [cell.fieldText setText:RPLocalizedString(@"Add", @"Add")];
                [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"];
            }
            [cell.fieldButton setHidden:YES];
            [self.amountValuesArray removeAllObjects];
            ratedCalculatedValuesArray = nil;
        }
        else {
            fieldType = MOVE_TO_NEXT_SCREEN;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            if (cell.fieldText != nil) {
                [cell.fieldText setHidden:YES];
            }
            [cell.fieldButton setHidden:NO];
            [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
            [cell.fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
            [cell.fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            if (typeChanged){
                [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
                [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"Add") forState:UIControlStateNormal];
                [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"]; 
                //amountValuesArray = nil;
                [self.amountValuesArray removeAllObjects];
                ratedCalculatedValuesArray = nil;
            }
        }
        
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
        [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
        
    }

    
    
    if ((([previousTaxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]||[previousTaxModeOfExpenseType isEqualToString:Flat_With_Taxes])&&([taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]||[taxModeOfExpenseType isEqualToString:Rated_With_Taxes]))||(([taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]||[taxModeOfExpenseType isEqualToString:Flat_With_Taxes])&&([previousTaxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]||[previousTaxModeOfExpenseType isEqualToString:Rated_With_Taxes]))) {
        
        //DLog(@"Scenario 1 Success.Clear the previous amount and keep ADD");
        [[NSUserDefaults standardUserDefaults] setObject:@"scenario1" forKey:@"PreviousSelectedScenario"];
        [[NSUserDefaults standardUserDefaults]synchronize];
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
         //[cell.fieldText setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
             //DE7005 Ullas M L
         [cell.fieldText setText:RPLocalizedString(@"Add", @"Add")];
         [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"]; 
         [cell.fieldButton setHidden:YES];
         [self.amountValuesArray removeAllObjects];
         ratedCalculatedValuesArray = nil;
         }
         else {
         fieldType = MOVE_TO_NEXT_SCREEN;
         [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
         if (cell.fieldText != nil) {
         [cell.fieldText setHidden:YES];
         }
         [cell.fieldButton setHidden:NO];
         [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
         [cell.fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
         [cell.fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
         if (typeChanged){
		 [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
         [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"Add") forState:UIControlStateNormal];
         [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"]; 
         //amountValuesArray = nil;
         [self.amountValuesArray removeAllObjects];
         ratedCalculatedValuesArray = nil;
         }
         }
         
         //[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
         //[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
        
    }
    
    if ([previousTaxModeOfExpenseType isEqualToString:Flat_With_Taxes]&&[taxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]) {
        //DLog(@"Scenario 2 Success.Retain the amount");
        [[NSUserDefaults standardUserDefaults] setObject:@"scenario2" forKey:@"PreviousSelectedScenario"];
        [[NSUserDefaults standardUserDefaults]synchronize];
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
           // [cell.fieldText setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];//DE7005 Ullas M L
            if (amountString==nil) 
            {
                [cell.fieldText setText:RPLocalizedString(@"Add", @"Add")];
            }  
            else
            {
                [cell.fieldText setText:cell.fieldButton.titleLabel.text];//Retaining the amount
            }
            [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:cell.fieldText.text forKey:@"defaultValue"]; //DE6221 Ullas
            [cell.fieldButton setHidden:YES];
            
            [self.amountValuesArray removeAllObjects];
            ratedCalculatedValuesArray = nil;
            
            if (previousWasTaxExpense)  //&& typeChanged .... 
            {
               
                previousWasTaxExpense = NO;
            }
        }
        else {
            fieldType = MOVE_TO_NEXT_SCREEN;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            if (cell.fieldText != nil) {
                [cell.fieldText setHidden:YES];
            }
            [cell.fieldButton setHidden:NO];
            [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
            [cell.fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE7005 Ullas M L
            [cell.fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            //if (typeChanged){
                [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
                [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"Add") forState:UIControlStateNormal];
                [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"]; 
                //amountValuesArray = nil;
                [self.amountValuesArray removeAllObjects];
                ratedCalculatedValuesArray = nil;
            //}
        }
        
        //[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
        //[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
        
        
    }
    if (([previousTaxModeOfExpenseType isEqualToString:Flat_With_Taxes]&&[taxModeOfExpenseType isEqualToString:Flat_With_Taxes])||([previousTaxModeOfExpenseType isEqualToString:Flat_WithOut_Taxes]&&[taxModeOfExpenseType isEqualToString:Flat_With_Taxes])) {
        //DLog(@"Scenario 3 Success.Complex computation keep it ADD");
        [[NSUserDefaults standardUserDefaults] setObject:@"scenario3" forKey:@"PreviousSelectedScenario"];
        [[NSUserDefaults standardUserDefaults]synchronize];
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
            //[cell.fieldText setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            //DE7005 Ullas M L
            if (previousWasTaxExpense)  //&& typeChanged .... 
            {
                [cell.fieldText setText:RPLocalizedString(@"Add", @"Add")];
                [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"]; 
                previousWasTaxExpense = NO;
            }
            else {
                [cell.fieldText setText:[[cell dataObj]objectForKey:@"defaultValue"]];
                [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[[cell dataObj]objectForKey:@"defaultValue"] forKey:@"defaultValue"]; 
            }
            [cell.fieldButton setHidden:YES];
            
            [self.amountValuesArray removeAllObjects];
            ratedCalculatedValuesArray = nil;
        }
        else {
            fieldType = MOVE_TO_NEXT_SCREEN;
            [[cell dataObj] setObject:fieldType forKey:@"fieldType"];
            if (cell.fieldText != nil) {
                [cell.fieldText setHidden:YES];
            }
            [cell.fieldButton setHidden:NO];
            [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
            [cell.fieldButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
            [cell.fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            if (typeChanged){
                [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
                [cell.fieldButton setTitle:RPLocalizedString(@"Add", @"Add") forState:UIControlStateNormal];
                [[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:RPLocalizedString(@"Add", @"Add") forKey:@"defaultValue"]; 
                //amountValuesArray = nil;
                [self.amountValuesArray removeAllObjects];
                ratedCalculatedValuesArray = nil;
            }
        }
        
        //[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:fieldType forKey:@"fieldType"];
        //[[firstSectionfieldsArray objectAtIndex:amountIndexPath.row] setObject:[NSNumber numberWithInt:2] forKey:@"defaultDecimalValue"];
        
        
    }
    
    if (([previousTaxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]&&[taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes])||([previousTaxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes]&&[taxModeOfExpenseType isEqualToString:Rated_With_Taxes])||([previousTaxModeOfExpenseType isEqualToString:Rated_With_Taxes]&&[taxModeOfExpenseType isEqualToString:Rated_With_Taxes])||([previousTaxModeOfExpenseType isEqualToString:Rated_With_Taxes]&&[taxModeOfExpenseType isEqualToString:Rated_WithOut_Taxes])) {
        
        
        NSIndexPath *amountIndexPath = [NSIndexPath indexPathForRow:4 inSection:G2EXPENSE_SECTION];
        if (permissionType == PermType_NonProjectSpecific) {
            amountIndexPath = [NSIndexPath indexPathForRow:2 inSection:G2EXPENSE_SECTION];
        }

        G2ExpenseEntryCellView *cell = (G2ExpenseEntryCellView *)[self.tnewExpenseEntryTable cellForRowAtIndexPath:amountIndexPath];
        //DLog(@"Scenario 4 Success. computation");
        [[NSUserDefaults standardUserDefaults] setObject:@"scenario4" forKey:@"PreviousSelectedScenario"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        if (![cell.fieldButton.titleLabel.text isEqualToString:RPLocalizedString(@"Add", @"Add")]) {
            
            NSString *str1=[[NSUserDefaults standardUserDefaults] objectForKey: @"PreviousSelectedScenario"];
            
            if ([str1 isEqualToString:@"scenario4"]) 
            {
                
                NSString *str=[defaultRateAndAmountsArray objectAtIndex:0];
                if (str==nil) 
                {
                    isComplexAmountCalucationScenario=YES;
                    NSString *amount=nil;
                    amount =[self getAmountEnteredForDefaultExpenseEntry ];
                    [self updateRatedExpenseData:amount];
                    
                    
                }
                else
                {
                    isComplexAmountCalucationScenario=YES;
                    NSString *amount=nil;
                    if (str!=nil && [[[cell dataObj]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(@"Add", @"Add")]) 
                    {
                        amount = [defaultRateAndAmountsArray objectAtIndex:0];
                        
                    }
                    else
                    {    
                        if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both)
                            amount =[self getAmountEnteredForDefaultExpenseEntry ];   
                        else 
                            amount = [defaultRateAndAmountsArray objectAtIndex:0];
                    }
                    
                    if (amount!=nil) 
                    {
                        [self updateRatedExpenseData:amount];
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    
}

//US3234 Ullas M L 
-(void)updateRatedExpenseData:(NSString *)kilometerString
{
    NSString *identity;
    NSDictionary *infoDict;
    
    if(permissionType == PermType_ProjectSpecific || permissionType == PermType_Both)	{			
        identity = [[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"];
        infoDict=[firstSectionfieldsArray objectAtIndex:2];
    }
    else {
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
    
    
    G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
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
    //DE8583
    if ([expenseTaxesInfoArray count]>0)
    {
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
    }

	//DE7062
    NSDecimalNumberHandler *roundingBehavior1 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE]; 
    netTmpAmount=[netTmpAmount decimalNumberByRoundingAccordingToBehavior:roundingBehavior1];  
	NSDecimalNumber *totalAmount=(NSDecimalNumber *)[G2Util getTotalAmount:netTmpAmount taxAmount:roundedTotalTaxAmount];
	//DLog(@"SUCCESS Amount Calucalated :%@",[NSString stringWithFormat:@"%@",[Util formatDoubleAsStringWithDecimalPlaces:[totalAmount doubleValue]]]);
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

    
}



//US3234 Ullas M L
-(NSString *)getAmountEnteredForDefaultExpenseEntry
{
    
    NSDictionary *infoDict;
    NSString *identity;
    if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
        identity = [[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"];
        infoDict = [firstSectionfieldsArray objectAtIndex:2];
    }else {
        identity = @"null";
        infoDict = [firstSectionfieldsArray objectAtIndex:0];
    }
    
    NSMutableArray *typesArray=[infoDict objectForKey:@"dataSourceArray"];
    int ind = [[infoDict objectForKey:@"selectedIndex"]intValue];
    NSString *typeName=nil;
    if (typesArray!=nil && [typesArray count]>0) 
        typeName = [[typesArray objectAtIndex:ind]objectForKey:@"name"];
    
    NSMutableArray *taxDetailsArray=nil;
    
    
   
    G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
    taxDetailsArray=[supportDataModel getAmountTaxCodesForSelectedProjectID:identity 
                                                            withExpenseType:typeName];
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *expDictFromDB = [standardUserDefaults objectForKey: @"SELECTED_EXPENSE_ENTRY"];
    //NSString *totalAmountRated=nil;
    double totalRated=0;
    totalRated = [[expDictFromDB objectForKey:@"netAmount"] doubleValue];
   
    
    //totalAmountRated=[Util formatDoubleAsStringWithDecimalPlaces:totalRated];
    NSMutableArray *ratedDefaultValuesArray=[[NSMutableArray alloc]init];//]WithObjects:@"Select",nil];
    for (int i=0; i<[taxDetailsArray count]; i++) {
        if ([expDictFromDB objectForKey:[NSString stringWithFormat:@"taxAmount%d",i+1]] != nil) {
            double taxAmount = [[expDictFromDB objectForKey:[NSString stringWithFormat:@"taxAmount%d",i+1]] doubleValue];
            [ratedDefaultValuesArray addObject:[G2Util formatDoubleAsStringWithDecimalPlaces:taxAmount]];
            totalRated =totalRated-taxAmount;
            
            
        }else {
            [ratedDefaultValuesArray addObject:@"0.00"];
        }
    }
    
   
    
    //DLog(@"Success :%@",[NSString stringWithFormat:@"%0.02lf",[[expDictFromDB objectForKey:@"noOfUnits"]doubleValue]]);
    amountValue = [G2Util formatDoubleAsStringWithDecimalPlaces:totalRated];
    return [NSString stringWithFormat:@"%0.02lf",[[expDictFromDB objectForKey:@"noOfUnits"]doubleValue]];
    
}

-(void )setTaxCodesArray
{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *expDictFromDB = [standardUserDefaults objectForKey: @"SELECTED_EXPENSE_ENTRY"];
    
    
    NSDictionary *infoDict;
    NSString *identity;
    if (permissionType == PermType_ProjectSpecific || permissionType == PermType_Both) {
        identity = [[firstSectionfieldsArray objectAtIndex:1]objectForKey:@"projectIdentity"];
        infoDict = [firstSectionfieldsArray objectAtIndex:2];
    }else {
        identity = @"null";
        infoDict = [firstSectionfieldsArray objectAtIndex:0];
    }
    
    
    int ind = [[infoDict objectForKey:@"selectedIndex"]intValue];
    NSMutableArray *typesArray=[infoDict objectForKey:@"dataSourceArray"];
    
    
    NSString *typeName=nil;
    if (typesArray!=nil && [typesArray count]>0) 
        typeName = [[typesArray objectAtIndex:ind]objectForKey:@"name"];
    
    NSMutableArray *taxDetailsArray=nil;
    NSMutableArray *expenseTaxCodesLocalArray=nil;
    G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
    if (typeChanged==NO && projectChanged==NO){//DE6811 Ullas M L
        id _selExpEntryId = [expDictFromDB objectForKey: @"identity"];
        typeName = [expDictFromDB objectForKey:@"expenseTypeName"];
        if (identity!=nil && typeName !=nil) {
            taxDetailsArray = [supportDataModel getTaxCodesForSavedEntry:identity withExpenseType:typeName andId:_selExpEntryId];
        }				
        expenseTaxCodesLocalArray = [supportDataModel getExpenseLocalTaxcodesForEntryFromDB: _selExpEntryId];
        
    }else {
        if (identity!=nil && typeName !=nil) 
            taxDetailsArray=[supportDataModel getAmountTaxCodesForSelectedProjectID:identity 
                                                                    withExpenseType:typeName];
        expenseTaxCodesLocalArray=[supportDataModel getExpenseLocalTaxcodesFromDB:identity 
                                                                  withExpenseType:typeName];
        
    }
    
    if (taxDetailsArray!=nil && [taxDetailsArray count]>0) {
        for (int x=0; x<[taxDetailsArray count] -1; x++) {
            id _taxDetail = [taxDetailsArray objectAtIndex: x];
            NSMutableDictionary *mutableDict=[NSMutableDictionary dictionary];
            [mutableDict addEntriesFromDictionary: _taxDetail];
            
            NSString *formulaString=[_taxDetail objectForKey:@"formula"];
            if (formulaString !=nil && ![formulaString isKindOfClass:[NSNull class]]) {
                NSString *localTax=[expenseTaxCodesLocalArray objectAtIndex:x];
                if (localTax!=nil && ![localTax isKindOfClass:[NSNull class]]) {
                    [mutableDict setObject:localTax forKey:@"formula"];
                }
            }
            [taxDetailsArray replaceObjectAtIndex:x withObject:mutableDict];
        }
        
        [self setTaxCodesAndFormulasArray:taxDetailsArray];
        
    }
    

    
}


-(void)showAllClients
{
    G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
    self.dataListViewCtrl=tempdataListViewCtrl;
   
    //  [self.projectAndClientsListViewCtrl setListOfItems:tasksForProjects];
    if (firstSectionfieldsArray!=nil && [firstSectionfieldsArray count]>0)
    {
        NSMutableArray *clientsArrayList=[[firstSectionfieldsArray objectAtIndex:0] objectForKey:@"clientsArr"];
        
        
        [self.dataListViewCtrl.mainTableView reloadData];
        
        NSMutableDictionary *clientDict =  [self.firstSectionfieldsArray objectAtIndex:0];
        [self.dataListViewCtrl setSelectedRowIdentity: [clientDict objectForKey:@"clientIdentity"] ];
        [self.dataListViewCtrl setParentDelegate:self];
        [self.dataListViewCtrl setTitleStr:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)];
        [self.dataListViewCtrl setListOfItems:clientsArrayList];
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
         G2ExpensesModel *expensesModel=[[G2ExpensesModel alloc]init];
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
        G2ExpensesModel *expensesModel=[[G2ExpensesModel alloc]init];
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

    
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
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
    expenseTypesDownloaded=YES;
    self.fromReloaOfDataView=YES;
    [self updateTypeAfterDownloadingExpenseTypes];
    
    [self dataPickerAction:(G2ExpenseEntryCellView *)[tnewExpenseEntryTable cellForRowAtIndexPath: typeIndex] withEvent:nil];
    

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
    
    G2ExpensesModel *expensesModel=[[G2ExpensesModel alloc]init];
    NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId: projectIdentity];
    
    NSString *selectedDataSource =nil;
    NSString *selectedDataIdentity =nil;
    if (expenseTypeArr!=nil && [expenseTypeArr count]>0) 
    {
        NSDictionary * expenseType = [expenseTypeArr objectAtIndex:0];
        selectedDataSource = [expenseType objectForKey:@"name"];
        selectedDataIdentity=[expenseType objectForKey:@"expenseTypeIdentity"];
        [_rowData setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
        [_rowData setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
        [_rowData setObject:selectedDataSource forKey:@"selectedDataSource"];
        [_rowData setObject:selectedDataSource forKey:@"defaultValue"];
        [_rowData setObject:expenseTypeArr forKey:@"dataSourceArray"];
    }
    [firstSectionfieldsArray replaceObjectAtIndex:typeIndex.row withObject:_rowData];
    
    
    if (projectIdentity==nil ||[projectIdentity isKindOfClass:[NSNull class]]||[projectIdentity isEqualToString:@"null"]) 
    {
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
    self.projectChanged=YES;
    [self updateFieldAtIndex:typeIndex WithSelectedValues:RPLocalizedString(@"Select", @"")];
    [[firstSectionfieldsArray objectAtIndex:2] setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];    
    [[firstSectionfieldsArray objectAtIndex:4] setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
        [self updateFieldAtIndex:amountIndex WithSelectedValues:RPLocalizedString(@"Add", @"")];
    
    
    //TODO: what if selectedDataSource / selectDataIdentity are null? Currently, writing error to log
    
    if (selectedDataSource == nil || selectedDataIdentity == nil) {
#ifdef DEV_DEBUG
        DLog(@"Error: Either selectedDatasource or selectedDataIdentity is nil");
#endif
    }

}
-(void)updateTypeAfterDownloadingExpenseTypes
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
    G2ExpensesModel *expensesModel=[[G2ExpensesModel alloc]init];
    
    NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId: projectIdentity];
    
    
    
    NSString *selectedDataSource =nil;
    NSString *selectedDataIdentity =nil;
    if (self.projectChanged) 
    {
        if ( expenseTypeArr!=nil && [expenseTypeArr count]>0) 
        {
            NSDictionary * expenseType = [expenseTypeArr objectAtIndex:0];
            selectedDataSource = [expenseType objectForKey:@"name"];
            NSString *selectedDataIdentity=[expenseType objectForKey:@"expenseTypeIdentity"];
            [_rowData setObject:[NSNumber numberWithInt:0] forKey:@"selectedIndex"];
            [_rowData setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
            if (selectedDataSource!=nil)
            {
                [_rowData setObject:selectedDataSource forKey:@"selectedDataSource"];
                [_rowData setObject:RPLocalizedString(@"Select", @"") forKey:@"defaultValue"];
            }
            else
            {   [_rowData setObject:[NSNull null] forKey:@"defaultValue"];
                [_rowData setObject:[NSNull null] forKey:@"selectedDataSource"];
            }
            if ( expenseTypeArr!=nil && [expenseTypeArr count]>0)
            {
                [_rowData setObject:expenseTypeArr forKey:@"dataSourceArray"];
            }


        }
    }
    else 
    {
        NSDictionary *selectedExpenseEntry = [[NSUserDefaults standardUserDefaults] objectForKey: @"SELECTED_EXPENSE_ENTRY"];
        NSString *entryExpenseType = [selectedExpenseEntry objectForKey:@"expenseTypeName"];
        NSNumber *selectedTypeIndex = [NSNumber numberWithInt:0];
        if ( expenseTypeArr!=nil && [expenseTypeArr count]>0) 
        {
            NSUInteger i, count = [expenseTypeArr count];
            for (i = 0; i < count; i++) 
            {
                NSDictionary * expenseType = [expenseTypeArr objectAtIndex:i];
                if([[expenseType objectForKey:@"name"] isEqualToString:entryExpenseType]) 
                {
                    selectedDataSource = [expenseType objectForKey:@"name"];
                    selectedTypeIndex = [NSNumber numberWithUnsignedInteger:i];
                }
            }
            
        }
        selectedDataIdentity=[selectedExpenseEntry objectForKey:@"expenseTypeIdentity"];
        [_rowData setObject:entryExpenseType forKey:@"defaultValue"];
        [_rowData setObject:selectedTypeIndex forKey:@"selectedIndex"];
        [_rowData setObject:selectedDataIdentity forKey:@"selectedDataIdentity"];
        if (selectedDataSource!=nil)
        {
            [_rowData setObject:selectedDataSource forKey:@"selectedDataSource"];
        }
        else
        {
            [_rowData setObject:[NSNull null] forKey:@"selectedDataSource"];
        }
        if ( expenseTypeArr!=nil && [expenseTypeArr count]>0)
        {
            [_rowData setObject:expenseTypeArr forKey:@"dataSourceArray"];
        }
       [[firstSectionfieldsArray objectAtIndex:4] setObject:[selectedExpenseEntry objectForKey:@"netAmount"] forKey:@"defaultValue"]; 
        
    }
    
    [firstSectionfieldsArray replaceObjectAtIndex:typeIndex.row withObject:_rowData];
    //DE9698
    if (selectedDataSource!=nil)
    {
        G2SupportDataModel *supportDataMdl = [[G2SupportDataModel alloc] init];
        NSString *taxModeOfExpenseType = [supportDataMdl getExpenseModeOfTypeForTaxesFromDB:projectIdentity withType:selectedDataSource andColumnName:@"type"];
        
        
        [[NSUserDefaults standardUserDefaults]setObject:taxModeOfExpenseType forKey:@"previousTaxType"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }

}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.saveButton=nil;
    self.pickerViewC=nil;
    self.tnewExpenseEntryTable=nil;
    self.topToolbarLabel=nil;
    self.datePicker=nil;
    self.pickerView1=nil;
    self.toolbarSegmentControl=nil;
    self.numberUdfText=nil;
    self.footerView=nil;
    self.deletButton=nil;
    self.checkImageView=nil;
    
    
    //Handle screen going blank
    //    [self handleScreenBlank];
    self.receiptViewController=nil;
    self.amountviewController=nil;
    self.addDescriptionViewController=nil;
}



@end
