//
//  AmountViewController.m
//  Replicon
//
//  Created by Manoj  on 09/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
// 

#import "G2AmountViewController.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"

//#import "EditExpenseEntryViewController.h"

@implementation G2AmountViewController
@synthesize amountTableView;
@synthesize flatWithTaxesArray;
@synthesize expenseTaxesInfoArray,doneTapped;
@synthesize typeString;
@synthesize ratedExpenseArray;
@synthesize ratedLabel;
@synthesize ratedLablesArray;
@synthesize textFieldSelected;
@synthesize amountValueEntered;
@synthesize fieldValuesArray;
@synthesize amountControllerDelegate;
@synthesize currecncyString;
@synthesize ratedValuesArray;
@synthesize defaultValuesArray;
@synthesize kilometerUnitValue;
@synthesize taxesLablesArray;
@synthesize ratedBaseCurrency;
@synthesize totalAmountValue;
@synthesize buttonTitle;
@synthesize rate;
@synthesize inEditState;
@synthesize flatExpenseFieldsArray;
@synthesize  selectedIndexPath;
@synthesize currencyLabel;
@synthesize currencyValueLabel;
@synthesize ratedValueLable;
@synthesize pickerViewC;
@synthesize pickerView1;
@synthesize toolbarSegmentControl;
@synthesize totalAmountLable;
@synthesize currenciesArray;
@synthesize addRateAndAmountLables;
@synthesize scrollView;
@synthesize isFromAddExpense;
@synthesize isFromEditExpense;
@synthesize isComplexAmountComputation;
static int tag_Taxes = 1000;
static float keyBoardHeight=260.0;
static BOOL  taxAmountEdited = NO;

static int amountField_Tag = 1;
static int ratedField_Tag = 100;
static int  ratedWithTaxes_Tag = 200;
NSInteger totalRows;
CGFloat tableHieght;
CGFloat scrollHieght;
static CGFloat viewheightWithTable;
BOOL boolSelectedRated_WithOut_Taxes ;
#define HEADER_HEIGHT 40.0
#define TOTAL_AMOUNT_LABEL_HEIGHT 40.0
#define GAP_FROM_TOTAL_TO_BOTTOM 30.0
#define TABLE_ROW_HEIGHT 44.0
#define RATE_AMOUNT_CURRECY_FIELD_COUNT 3
#define LABEL_HEIGHT 30.0
#define GAP_FROM_AMOUNT_TO_TAXFIELDS 30.0
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

-(NSInteger)getNumberofSectionsInTableView:(NSString *)tmpType
{
    
    if ([tmpType isEqualToString:Flat_WithOut_Taxes])
    {
        boolSelectedRated_WithOut_Taxes=NO;
		return 1;
	}
    else if ([tmpType isEqualToString:Flat_With_Taxes])
    {
        boolSelectedRated_WithOut_Taxes=NO;
		return 2;
	}
    else 
    {
        
        boolSelectedRated_WithOut_Taxes=NO;
		return 1;
	}
    
    
}

-(NSInteger)getNumberOfRowsInSection:(NSInteger)section andType:(NSString *)tmpType
{
    
    if ([tmpType isEqualToString:Flat_WithOut_Taxes])
	{
		return 2;
	}
    else if ([tmpType isEqualToString:Flat_With_Taxes]) 
    {
		if (section==0) {
			return 2;
		}
        else 
        {
            
            return [expenseTaxesInfoArray count]-1;
		}
	} 
    else if ([tmpType isEqualToString:Rated_WithOut_Taxes] || [tmpType isEqualToString:Rated_With_Taxes])
    {
		return 1;
	}
	
	return 0;
    
}


- (id) init
{
	self = [super init];
	if (self != nil) {
		//self.title=RPLocalizedString( @"Amount",@"");
		isCurrencySelected=NO;
		if (supportDataModel==nil) {
			supportDataModel=[[G2SupportDataModel alloc]init];
		}
		
        
                
	}
	return self;
}

-(void)intialiseView
{  //US4335 Ullas M L
    self.flatExpenseFieldsArray=[NSMutableArray arrayWithObjects:RPLocalizedString(@"Currency", @"") ,RPLocalizedString(@"Amount", @"") ,nil];
    self.ratedLablesArray=[NSMutableArray arrayWithObjects:RPLocalizedString(@"Rate", @"") ,RPLocalizedString(@"Amount", @"") ,nil] ;
    
    NSString *tmpTypeString=[expenseTaxesInfoArray objectAtIndex:[expenseTaxesInfoArray count]-1]; 
    NSInteger sectionsNumber=[self getNumberofSectionsInTableView:tmpTypeString];
    
    
    
    for (NSInteger i=0; i<sectionsNumber; i++) 
    {
        
        NSInteger numberOfRowsInTable=[self getNumberOfRowsInSection:i andType:tmpTypeString];
        
        if ([tmpTypeString isEqualToString:Flat_With_Taxes]||[tmpTypeString isEqualToString:Flat_WithOut_Taxes])
        {   totalRows+=numberOfRowsInTable;
        }
        else
        {   totalRows=numberOfRowsInTable;
        }
        
    }
    tableHieght=totalRows*44.0+sectionsNumber*30+52;
    UIScrollView *tempScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView=tempScrollView;
    
   
    
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator=YES;
    scrollView.delegate=self;
    
    if ([tmpTypeString isEqualToString:Flat_With_Taxes]||[tmpTypeString isEqualToString:Flat_WithOut_Taxes])
        scrollHieght=totalRows*TABLE_ROW_HEIGHT+sectionsNumber*HEADER_HEIGHT+TOTAL_AMOUNT_LABEL_HEIGHT+GAP_FROM_TOTAL_TO_BOTTOM;
    else
        scrollHieght=totalRows*TABLE_ROW_HEIGHT+sectionsNumber*HEADER_HEIGHT+RATE_AMOUNT_CURRECY_FIELD_COUNT*LABEL_HEIGHT+GAP_FROM_AMOUNT_TO_TAXFIELDS+([expenseTaxesInfoArray count]-1)*LABEL_HEIGHT+TOTAL_AMOUNT_LABEL_HEIGHT;
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width,scrollHieght);
    totalRows=0;
    
    UITableView *tempamountTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , scrollHieght) style:UITableViewStyleGrouped];
    self.amountTableView=tempamountTableView;
   
    [self. amountTableView setDelegate:self];
    [self. amountTableView setDataSource:self];
    [self.amountTableView setScrollEnabled:NO];
    //[self.amountTableView setBackgroundColor:[UIColor clearColor]];
    //self.amountTableView.canCancelContentTouches = NO;
    [self.amountTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];//DE5655 Ullas M L
    [self. amountTableView setBackgroundColor:[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0]];
    self. amountTableView.backgroundView=nil;
    [self.view setBackgroundColor:[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0]];
    
    
    
    UIBarButtonItem *leftButton1 = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(CANCEL_BTN_TITLE, @"Cancel") 
                                                                    style:UIBarButtonItemStylePlain 
                                                                   target:self 
                                                                   action:@selector(cancelAction:)];
    
    [self.navigationItem setLeftBarButtonItem:leftButton1 animated:NO];
   
    
    
    /*UILabel *topToolbarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200,20)];
     [topToolbarLabel setNumberOfLines:0];
     [topToolbarLabel setLineBreakMode:NSLineBreakByTruncatingTail];
     [topToolbarLabel setFont:[UIFont boldSystemFontOfSize: RepliconFontSize_16]];
     [topToolbarLabel setTextAlignment:NSTextAlignmentCenter];
     [topToolbarLabel setBackgroundColor:[UIColor clearColor]];
     [topToolbarLabel setTextColor:[UIColor whiteColor]];
     [topToolbarLabel setTextAlignment: NSTextAlignmentCenter];
     [topToolbarLabel setText: RPLocalizedString(@"Amount", @"Amount")];
     self.navigationItem.titleView = topToolbarLabel;
     
     */
    [G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(@"Amount", @"Amount")];
    
    
    UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(@"Done", @"Done")  
                                                                     style:UIBarButtonItemStylePlain 
                                                                    target:self 
                                                                    action:@selector(doneAction:)];
    [self.navigationItem setRightBarButtonItem:rightButton1 animated:NO];
   
    
    
    if (expensesModel==nil) {
        expensesModel = [[G2ExpensesModel alloc]init];
    }
    
    self.currenciesArray = [supportDataModel getSystemCurrenciesFromDatabase]; 
    //[self addPicker];
    
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    footerViewAmount = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                self.amountTableView.frame.size.height,
                                                                self.amountTableView.frame.size.width,
                                                                screenRect.size.height-180)];
    [footerViewAmount setBackgroundColor:[UIColor clearColor]];
    
    if (totalAmountLable==nil) {
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(12,20.0 ,150 ,25 );
            
        }
        else{
            frame=CGRectMake(20,20.0 ,150 ,25 );
            
        }
        UILabel *temptotalAmountLable = [[UILabel alloc]initWithFrame:frame];
        self.totalAmountLable=temptotalAmountLable;
        
    }
    [totalAmountLable setBackgroundColor:[UIColor clearColor]];
    [totalAmountLable setText:RPLocalizedString(@"TOTAL AMOUNT",@"Total amount label")];
    [totalAmountLable setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
    [totalAmountLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
    [footerViewAmount addSubview:totalAmountLable];
    //[scrollView addSubview:totalAmountLable];
    
    if (totalAmountValue==nil) {
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(132,20.0 ,170 ,25 );
            
        }
        else{
            frame=CGRectMake(130,20.0 ,170 ,25 );
            
        }
        UILabel *temptotalAmountValue = [[UILabel alloc]initWithFrame:frame];
        self.totalAmountValue=temptotalAmountValue;
       
    }
    [totalAmountValue setBackgroundColor:[UIColor clearColor]];
    [totalAmountValue setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];//US4065//Juhi
    [totalAmountValue setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
    [totalAmountValue setTextAlignment:NSTextAlignmentRight];
    [footerViewAmount addSubview:totalAmountValue];
    //[scrollView addSubview:totalAmountLable];
    
    
    [self.amountTableView setTableFooterView:footerViewAmount];
    //[scrollView addSubview:footerViewAmount];//US4065//Juhi
    self.addRateAndAmountLables=[NSMutableArray array];
    self.taxesLablesArray=[NSMutableArray array];
    //textFieldSelected=[[UITextField alloc] init];
    //defaultValuesArray=[[NSArray arrayWithObjects:@"Select",@"$0.0",@"$0.0",nil] retain];
    doneTapped=NO;
    
    //tableHieght=tableHieght+footerViewAmount.frame.size.height+60;
    
    
    viewheightWithTable=tableHieght;
    [scrollView addSubview:self. amountTableView]; 
    [self.view addSubview:scrollView];

    
}

-(void)cancelAction:(id)sender
{
	//DE4881 Ullas M L
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appdelegate.isUserPressedCancel=YES;
	if ([pickerViewC isHidden] == NO) {
		[pickerViewC setHidden:YES];
	}
	if (self.selectedIndexPath !=nil) {
		id cellObj = [self getCellAtIndexPath:self.selectedIndexPath];
		if ([cellObj fieldText] != nil) {
            //CGRect frame=self.amountTableView.frame;
            //frame.size.height=self.view.frame.size.height;
            //self.amountTableView.frame=frame;
			[[cellObj fieldText] resignFirstResponder];
		}
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
	}
	
	if (doneTapped==NO) {
//		if (fieldValuesArray!=nil) {
//			fieldValuesArray=nil;
//			expenseTaxesInfoArray=nil;
//			//setAmountValuesArray:nil];
//			//[amountControllerDelegate performSelector:@selector(setAmountArrayToNil)];
//		}
//		if (ratedValuesArray!=nil) {
//			ratedValuesArray=nil;
//		}
//		if (defaultValuesArray!=nil) {
//			defaultValuesArray=nil;
//		}
	}

    
	[self.navigationController popViewControllerAnimated:YES];
	[amountControllerDelegate performSelector:@selector(animateCellWhichIsSelected)];
}

-(void)doneAction:(id)sender
{
	//if (textFieldSelected != nil) {
//		[textFieldSelected resignFirstResponder];
//	}
    
//    if ([amountControllerDelegate isKindOfClass:[EditExpenseEntryViewController class]]) {
//        [(EditExpenseEntryViewController *)amountControllerDelegate setfirstSectionFields];
//        [(EditExpenseEntryViewController *)amountControllerDelegate setSecondSectionFields];
//
//    }
    

	
	if ([pickerViewC isHidden] == NO) {
		[pickerViewC setHidden:YES];
	}
	if (self.selectedIndexPath !=nil) {
		id cellObj = [self getCellAtIndexPath:self.selectedIndexPath];
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
		if ([cellObj fieldText] != nil) {
            //CGRect frame=self.amountTableView.frame;
            //frame.size.height=self.view.frame.size.height;
            //self.amountTableView.frame=frame;
			[[cellObj fieldText] resignFirstResponder];
		}
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
	}
	
	
	doneTapped=YES;
	UITextField *amountTxtField=nil;
	if ([typeString isEqualToString:Rated_With_Taxes] || [typeString isEqualToString:Rated_WithOut_Taxes]){
		amountTxtField = [(G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
											 [NSIndexPath indexPathForRow:0 inSection:0]] fieldText ];
	}else {
		amountTxtField = [(G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
											 [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
	}

	if(amountTxtField!=nil && ![amountTxtField isKindOfClass:[NSNull class]])
	{
		if ([amountTxtField.text isEqualToString:RPLocalizedString(@"Select", @"") ]) {
			[G2Util errorAlert:@"" errorMessage:RPLocalizedString( @"Please enter expense amount",@"")];
            [self pickerDone:nil];
			return;
		}
	}
	
	if ([typeString isEqualToString:Rated_With_Taxes] || [typeString isEqualToString:Rated_WithOut_Taxes])
	{
		if (textFieldSelected.tag==100||textFieldSelected.tag==200) {
			[self performSelector:@selector(updateRatedExpenseData:) withObject:textFieldSelected];
		}
		
		[amountControllerDelegate performSelector:@selector(setValuesForRatedExpenseType:) withObject:[NSMutableArray arrayWithObjects:defaultValuesArray,ratedValuesArray,nil]];
		[amountControllerDelegate performSelector:@selector(setDescription:) withObject:totalAmountValue.text];
		[amountControllerDelegate performSelector:@selector(setRatedUnits:) withObject:amountTxtField.text];
		[amountControllerDelegate performSelector:@selector(setTotalAmountToRatedType:) withObject:totalAmountValue.text];
        [amountControllerDelegate setIsComplexAmountCalucationScenario:NO];
	}
	
	
	if ([typeString isEqualToString:Flat_WithOut_Taxes] || [typeString isEqualToString:Flat_With_Taxes]) {
		
		if ([typeString isEqualToString:Flat_WithOut_Taxes]) {
			if (![[amountTxtField text] isEqualToString:RPLocalizedString(@"Select", @"")]) {
                //CGRect frame=self.amountTableView.frame;
                //frame.size.height=self.view.frame.size.height;
                //self.amountTableView.frame=frame;
				[amountTxtField resignFirstResponder];
				if (amountValueEntered!=nil) {
					[amountTxtField setText:[NSString stringWithFormat:@"%@",amountValueEntered]];
				}else {
					[amountTxtField setText:@"0.00"];	
				}
			}
			[totalAmountValue setText:amountTxtField.text];
			[amountControllerDelegate performSelector:@selector(setDescription:) withObject:totalAmountValue.text];
			[self.fieldValuesArray replaceObjectAtIndex:1 withObject:totalAmountValue.text];
		}
		
		if ([typeString isEqualToString:Flat_With_Taxes]) {
            //CGRect frame=self.amountTableView.frame;
            //frame.size.height=self.view.frame.size.height;
           // self.amountTableView.frame=frame;
			[amountTxtField resignFirstResponder];
			NSString *formattedAmountString =nil;
			if (amountValueEntered!=nil && !([amountValueEntered isEqualToString:RPLocalizedString(@"Select", @"")])) {
				double netAmount=[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amountValueEntered]; 
				formattedAmountString = [G2Util formatDoubleAsStringWithDecimalPlaces:netAmount];
				[amountTxtField setText:[NSString stringWithFormat:@"%@",formattedAmountString]];
			}
			if (textFieldSelected != nil && textFieldSelected.tag<[flatExpenseFieldsArray count])
					[self performSelector:@selector(updateValues:) withObject:amountTxtField];
			
			if (textFieldSelected.tag>=1000) {
				[self taxAmountEditedByUser:textFieldSelected];
			}
			[amountControllerDelegate performSelector:@selector(setDescription:) withObject:totalAmountValue.text];
		}
		[amountControllerDelegate performSelector:@selector(setAmountArrayBaseCurrency:) 
									   withObject:self.fieldValuesArray];		
	}
	
	if ([typeString isEqualToString:Flat_WithOut_Taxes] || [typeString isEqualToString:Flat_With_Taxes]) {
		NSString *currencyId= [supportDataModel getSystemCurrencyIdFromDBUsingCurrencySymbol:[self.fieldValuesArray objectAtIndex:0]];
		[amountControllerDelegate performSelector:@selector(setCurrencyId:selectedIndex:) withObject:currencyId 
									   withObject:[NSNumber numberWithInt:defaultRowInPicker]];
	}else if ([typeString isEqualToString:Rated_With_Taxes] || [typeString isEqualToString:Rated_WithOut_Taxes]) {
		//NSString *currencyId= [supportDataModel getSystemCurrencyIdFromDBUsingCurrencySymbol:ratedBaseCurrency];
		//[amountControllerDelegate performSelector:@selector(setCurrencyId:selectedIndex:) withObject:currencyId
		//								withObject:[NSNumber numberWithInt:defaultRowInPicker]];
	}
	//[amountControllerDelegate setCurrencyIdentity:currencyId];
    
     //DE4881 Ullas M L
        if (isFromAddExpense==YES && isFromEditExpense==NO) 
        {
            
            [[NSUserDefaults standardUserDefaults] setObject:self.fieldValuesArray forKey:@"PreviousArrayForAdd"] ;
            [[NSUserDefaults standardUserDefaults] synchronize];

        }
     //DE4881 Ullas M L
        if (isFromAddExpense==NO && isFromEditExpense==YES) 
        {
            
            [[NSUserDefaults standardUserDefaults] setObject:self.fieldValuesArray forKey:@"PreviousArrayForEdit"] ;
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
		[self.navigationController popViewControllerAnimated:YES];
	[amountControllerDelegate performSelector:@selector(animateCellWhichIsSelected)];
}

-(void)viewWillAppear:(BOOL)animated
{
    //DE4881 Ullas M L
    if (isFromAddExpense==NO && isFromEditExpense==YES) 
    {
        if (self.fieldValuesArray!=nil && ![self.fieldValuesArray isKindOfClass:[NSNull class]] ) 
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.fieldValuesArray forKey:@"PreviousArrayForEdit"] ;
            [[NSUserDefaults standardUserDefaults] synchronize];


        }
        
       
    }   
	//[ratedExpenseArray retain];
//	if (fieldValuesArray != nil) {
//		NSMutableArray *tempfieldValuesArray = [[NSMutableArray alloc] initWithArray:fieldValuesArray];
//        self.fieldValuesArray=tempfieldValuesArray;

//						//	arrayWithArray:fieldValuesArray];
//	}
    [self intialiseView];
    
	self.typeString=[expenseTaxesInfoArray objectAtIndex:[expenseTaxesInfoArray count]-1]; 
	if ([typeString isEqualToString:Flat_WithOut_Taxes] || [typeString isEqualToString:Flat_With_Taxes]) {
		[totalAmountValue setText:[self.fieldValuesArray objectAtIndex:[self.fieldValuesArray count]-1]];
			[self addPicker]; 
	}
	
	
	if ([typeString isEqualToString:Flat_WithOut_Taxes] /*|| [typeString isEqualToString:Rated_WithOut_Taxes]*/){
		[footerViewAmount setHidden:YES];
		[self. amountTableView setScrollEnabled:NO];
	}
	//US4336 Ullas M L
    if ([typeString isEqualToString:Rated_WithOut_Taxes]){
		[footerViewAmount setHidden:NO];
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect totalAmountLableframe;
        CGRect totalAmountValueFrame;
        if (version>=7.0)
        {
            totalAmountLableframe=CGRectMake(12,20+([defaultValuesArray count]+2)*30,130 ,14 );
            totalAmountValueFrame=CGRectMake(193,20+([defaultValuesArray count]+2)*30,111 ,14 );
        }
        else{
            totalAmountLableframe=CGRectMake(20,20+([defaultValuesArray count]+2)*30,130 ,14 );
            totalAmountValueFrame=CGRectMake(190,20+([defaultValuesArray count]+2)*30,111 ,14 );
        }
        [totalAmountLable setFrame:totalAmountLableframe];//US4065//Juhi
		[totalAmountValue setFrame:totalAmountValueFrame];//US4065//Juhi
		[totalAmountValue setTextAlignment:NSTextAlignmentRight];
		[self.scrollView addSubview:totalAmountLable];
		[self.scrollView addSubview:totalAmountValue];
		[self. amountTableView setScrollEnabled:NO];
        viewheightWithTable=viewheightWithTable+totalAmountLable.frame.size.height;
        [totalAmountValue setText:[defaultValuesArray objectAtIndex:[defaultValuesArray count]-1]];
		
	}
	if ( [typeString isEqualToString:Rated_With_Taxes]){
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect totalAmountLableframe;
        CGRect totalAmountValueFrame;
        if (version>=7.0)
        {
            totalAmountLableframe=CGRectMake(20,270+([defaultValuesArray count])*30,130 ,14 );
            totalAmountValueFrame=CGRectMake(190,270+([defaultValuesArray count])*30,111 ,14 );
        }
        else{
            totalAmountLableframe=CGRectMake(20,190+[expenseTaxesInfoArray count]*30,130 ,14 );
            totalAmountValueFrame=CGRectMake(190,190+[expenseTaxesInfoArray count]*30,111 ,14 );
        }

		[totalAmountLable setFrame:totalAmountLableframe];//US4065//Juhi
		[totalAmountValue setFrame:totalAmountValueFrame];//US4065//Juhi
		[totalAmountValue setTextAlignment:NSTextAlignmentRight];
		[self.scrollView addSubview:totalAmountLable];
		[self.scrollView addSubview:totalAmountValue];
		[self. amountTableView setScrollEnabled:NO];
		viewheightWithTable=viewheightWithTable+totalAmountLable.frame.size.height;
        [totalAmountValue setText:[ratedValuesArray objectAtIndex:[ratedValuesArray count]-1]];//DE5853 Ullas M L
	}

	if (ratedValuesArray != nil) {
		self.ratedValuesArray = [NSMutableArray arrayWithArray:ratedValuesArray];
	}//not to remove..
	if (defaultValuesArray != nil) {
		self.defaultValuesArray = [NSMutableArray arrayWithArray:defaultValuesArray];
	}
	
	[self registerForKeyBoardNotifications];
	[self updateCurrencyPicker];
	[self. amountTableView reloadData];
    
     self.tabBarController.tabBar.hidden = YES;
}

-(void)updateCurrencyPicker
{
	NSString *baseCurrencyStr = nil;
	if (self.fieldValuesArray!=nil && [self.fieldValuesArray count]>0) {
		baseCurrencyStr= [self.fieldValuesArray objectAtIndex:0];
	}
if ( currenciesArray!=nil && [currenciesArray count]>0) {
	NSUInteger count = [currenciesArray count];
    int i;
	for (i = 0; i < count; i++) {
		NSDictionary * currenciesDict = [currenciesArray objectAtIndex:i];
		if([[currenciesDict objectForKey:@"symbol"] isEqualToString:baseCurrencyStr]) {
			defaultRowInPicker = i;
		}
	}
}
}
#pragma mark keyBoard Handling Methods

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


- (void)showToolBarWithAnimationForUsdAction{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    CGRect frame = pickerViewC.frame;
	frame.origin.y = self.view.frame.size.height -keyBoardHeight;
	pickerViewC.frame= frame;
	
    [UIView commitAnimations];
}


- (void)showToolBarWithAnimation{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    CGRect frame = pickerViewC.frame;
	if (inEditState==YES) {
		//+self.navigationController.tabBarController.tabBar.frame.size.height//To know tabbar height.........
		frame.origin.y = self.view.frame.size.height -keyBoardHeight;
	}else {
		frame.origin.y = self.view.frame.size.height -keyBoardHeight ;
	}
	
	pickerViewC.frame= frame;
	
    [UIView commitAnimations];
}
- (void)hideToolBarWithAnimation {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	
    CGRect frame = pickerViewC.frame;
	if (inEditState==YES) {
		//+self.navigationController.tabBarController.tabBar.frame.size.height
		frame.origin.y = self.view.frame.size.height;
	}else {
		frame.origin.y = self.view.frame.size.height;
	}
	
    pickerViewC.frame = frame;
	
	[UIView commitAnimations];
}

-(void) keyboardWillShow:(NSNotification *)note
{
	[self showToolBarWithAnimation];
}

-(void) keyboardWillHide:(NSNotification *)note
{
	
	[self hideToolBarWithAnimation];
	
}


-(void)viewWillDisappear:(BOOL)animated
{
	[self.tabBarController.tabBar setHidden:NO];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([typeString isEqualToString:Flat_WithOut_Taxes]){
		return 1;
	}else if ([typeString isEqualToString:Flat_With_Taxes]){
		return 2;
	}else {
		return 1;
	}
	
	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
   
        [cell setBackgroundColor:[UIColor whiteColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	
		  //return 35;
    if (section==1) {
        return 40;
    }
    else
        return 40; 
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;//US4065//Juhi
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	UIImage *lineImage = [G2Util thumbnailImage:G2Cell_HairLine_Image];
    return lineImage.size.height;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    
	if ([typeString isEqualToString:Flat_WithOut_Taxes])
	{
		return 2;
	}else if ([typeString isEqualToString:Flat_With_Taxes]) {
		if (section==0) {
			return 2;
		}else {
			return [expenseTaxesInfoArray count]-1;
		}
	} else if ([typeString isEqualToString:Rated_WithOut_Taxes] || [typeString isEqualToString:Rated_With_Taxes]) {
		return 1;
	}
	
	return 0;
}

//US4335 Ullas M L
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) 
    {
		UILabel	*expenseLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.15,9.0,250.0,30.0)];
		
		[expenseLabel setBackgroundColor:[UIColor clearColor]];
		[expenseLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
		[expenseLabel setTextColor:RepliconStandardBlackColor];
		
		if ([typeString isEqualToString:Rated_WithOut_Taxes]||[typeString isEqualToString:Rated_With_Taxes]) {
            [expenseLabel setText:RPLocalizedString(@"Quantity",@"")];
        }
        
        if ([typeString isEqualToString:Flat_WithOut_Taxes] ||[typeString isEqualToString:Flat_With_Taxes]) {
            [expenseLabel setText:RPLocalizedString(@"Pre-Tax Amount",@"")];
        }
		
		UIView *expenseHeader = [UIView new];
		[expenseHeader addSubview:expenseLabel];
		
		return expenseHeader;
	} 
    
    else if (section ==1)
    {
		UILabel	*otherLabel= [[UILabel alloc] initWithFrame:CGRectMake(10,9.0,250.0,30.0)];
		
		[otherLabel setBackgroundColor:[UIColor clearColor]];
		[otherLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
		[otherLabel setTextColor:RepliconStandardBlackColor];
		[otherLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
		
		
        if ([typeString isEqualToString:Rated_WithOut_Taxes]||[typeString isEqualToString:Rated_With_Taxes]) {
            [otherLabel setText:RPLocalizedString(@"Taxes",@"")];
        }
        
        if ([typeString isEqualToString:Flat_WithOut_Taxes] ||[typeString isEqualToString:Flat_With_Taxes]) {
            [otherLabel setText:RPLocalizedString(@"Taxes",@"")];
        }
		
		UIView	*otherHeader = [UIView new];
		[otherHeader addSubview:otherLabel];
		
		return otherHeader;
	} 
	return nil;
    
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	G2AmountCellView *cell  = (G2AmountCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	
	if (cell == nil) {
		cell = [[G2AmountCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        //DE3566//Juhi
        //[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
	}
    
   
	
	cell.amountDelegate=self;
	if ([typeString isEqualToString:Flat_WithOut_Taxes] || [typeString isEqualToString:Flat_With_Taxes]){
		
		if(indexPath.section == 0){
			if (indexPath.row == 0){
				[cell addFieldLabelAndButton:indexPath.row];
				[cell.fieldLable setText:[flatExpenseFieldsArray objectAtIndex:indexPath.row]];
				[cell.fieldButton setTitle:[self.fieldValuesArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ ) {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UITextField class] ]) {
                        [cell.fieldText setText:@""];
                    }
                    
                    
                }				
			}
			if (indexPath.row == 1) {
				[cell addFieldLabelAndButton:indexPath.row];
				cell.fieldLable.text=[flatExpenseFieldsArray objectAtIndex:indexPath.row];
				[cell.fieldText setText:[self.fieldValuesArray objectAtIndex:indexPath.row]];
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ ) {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UIButton class] ]) {
                        [cell.fieldButton setTitle:@"" forState:UIControlStateNormal];
                    }
                    
                    
                }
                

                
			}
		}
		
	}
	
	if ([typeString isEqualToString:Flat_With_Taxes] &&  (indexPath.section==1)) 
	{
		for (int i=0; i<[expenseTaxesInfoArray count]-1; i++) {
			if (indexPath.row==i) {
				[cell addFieldLabelAndButton:indexPath.row+tag_Taxes];
				[cell.fieldLable setText:[[expenseTaxesInfoArray objectAtIndex:i]objectForKey:@"name"]];
				[cell.fieldText setText:[self.fieldValuesArray objectAtIndex:i+2]];
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ ) {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UIButton class] ]) {
                        [cell.fieldButton setTitle:@"" forState:UIControlStateNormal];
                    }
                    
                   
                }

			}
			
		}
	}
	
	
	if ([typeString isEqualToString:Rated_WithOut_Taxes]) {
		if(indexPath.section == 0){
			if (indexPath.row == 0){
				[cell addFieldLabelAndButton:indexPath.row+100];
				[cell.fieldLable setText:[ratedExpenseArray objectAtIndex:indexPath.row]];
				[cell.fieldText setText:[defaultValuesArray objectAtIndex:indexPath.row]];
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ ) {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UIButton class] ]) {
                        [cell.fieldButton setTitle:@"" forState:UIControlStateNormal];
                    }
                    
                    
                }

				
			}
		}
		
		[self addCurrencyLabel:30.0 :1000];//US4336 Ullas M L
		for (int x=0; x<[ratedLablesArray count]-1; x++) {
			[self addRateAndAmountFields:120.0+(x*30) :x];
		}
		
	}
	
	if ([typeString isEqualToString:Rated_With_Taxes]) {
                
		if(indexPath.section == 0){
			if (indexPath.row == 0){
				[cell addFieldLabelAndButton:indexPath.row+200];
				[cell.fieldLable setText:[ratedExpenseArray objectAtIndex:indexPath.row]];
				[cell.fieldText setText:[defaultValuesArray objectAtIndex:indexPath.row]];
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ ) {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UIButton class] ]) {
                        [cell.fieldButton setTitle:@"" forState:UIControlStateNormal];
                    }
                    
                    
                }
			}
		}
		
		[self addCurrencyLabel:30.0 :1000];
		
		for (int x=0; x<[ratedLablesArray count]; x++) {
            [self addRateAndAmountFields:120.0+(x*30) :x];//US4065//Juhi
		}
		
		for (int x=0; x<[expenseTaxesInfoArray count]-1; x++){
			float yPos=110.0+(x+3)*30;//US4065//Juhi
			[self ratedTaxesLable:x :yPos];
			
			
		}
	}
	

	if (typeString != nil && ([typeString isEqualToString:Rated_With_Taxes] || [typeString isEqualToString:Rated_WithOut_Taxes])) {
		[self addPicker];
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    
    if (self.selectedIndexPath != nil && ![self.selectedIndexPath isKindOfClass:[NSNull class]]&& self.selectedIndexPath != indexPath) {
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
	}
	[self cellTappedAtIndex:indexPath];
}


-(void)addCurrencyLabel:(float)y :(int)tag {
    
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    CGRect frame;
    
    if (version>=7.0)
    {
        frame=CGRectMake(12,90 ,130 ,30 );
        
    }
    else{
        frame=CGRectMake(20,90 ,130 ,30 );
        
    }
	UILabel *tempcurrencyLabel = [[UILabel alloc]initWithFrame:frame];
    self.currencyLabel=tempcurrencyLabel;
    
	[currencyLabel setBackgroundColor:[UIColor clearColor]];
	[currencyLabel setTag:tag];
	[currencyLabel setText:RPLocalizedString(@"Currency", @"Currency") ];
	[currencyLabel setTextColor:RepliconStandardBlackColor];
	[currencyLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//US4065//Juhi//DE5654 Ullas
	//[self.view addSubview:currencyLabel];
    viewheightWithTable=viewheightWithTable+currencyLabel.frame.size.height;
    
    [self.scrollView addSubview:currencyLabel];
	
	
	UILabel *tempcurrencyValueLabel = [[UILabel alloc]init];
    self.currencyValueLabel=tempcurrencyValueLabel;
    
	[currencyValueLabel setFrame:CGRectMake(190,90 ,111 ,30 )];//US4065//Juhi
	[currencyValueLabel setText:ratedBaseCurrency];
	[currencyValueLabel setBackgroundColor:[UIColor clearColor]];
	[currencyValueLabel setTag:tag+100];
	[currencyValueLabel setTextAlignment:NSTextAlignmentRight];
	[currencyValueLabel setTextColor:RepliconStandardBlackColor];//US4065//Juhi
	[currencyValueLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
	//[addRateAndAmountLables addObject:currencyValueLabel];
	//[self.view addSubview:currencyValueLabel];
    [self.scrollView addSubview:currencyValueLabel];
}

-(void)addRateAndAmountFields:(float)y :(int)tag
{
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    CGRect frame;
    
    if (version>=7.0)
    {
        frame=CGRectMake(12,y ,130 ,30 );
        
    }
    else{
        frame=CGRectMake(20,y ,130 ,30 );
        
    }
	
	UILabel *tempratedLabel = [[UILabel alloc]initWithFrame:frame];
    self.ratedLabel=tempratedLabel;
    
	[ratedLabel setBackgroundColor:[UIColor clearColor]];
	[ratedLabel setTag:tag];
	[ratedLabel setText:[ratedLablesArray objectAtIndex:tag]];
	[ratedLabel setTextColor:RepliconStandardBlackColor];
	[ratedLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//US4065//Juhi//DE5654 Ullas
	//[self.view addSubview:ratedLabel];
    viewheightWithTable=viewheightWithTable+ratedLabel.frame.size.height;
   
    [self.scrollView addSubview:ratedLabel];

	
	
	UILabel *tempratedValueLable = [[UILabel alloc]init];
    self.ratedValueLable=tempratedValueLable;
   
	[ratedValueLable setFrame:CGRectMake(190,y ,111 ,30 )];//US4065//Juhi
	[ratedValueLable setText:[defaultValuesArray objectAtIndex:tag+1]];
	[ratedValueLable setBackgroundColor:[UIColor clearColor]];
	[ratedValueLable setTag:tag+100];
	[ratedValueLable setTextAlignment:NSTextAlignmentRight];
	[ratedValueLable setTextColor:RepliconStandardBlackColor];//US4065//Juhi
	[ratedValueLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
	[addRateAndAmountLables addObject:ratedValueLable];
	//[self.view addSubview:ratedValueLable];
    [self.scrollView addSubview:ratedValueLable];

	
}


-(void)ratedTaxesLable:(int)tagValue :(float)yPosition
{
	
	ratedTaxesLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,yPosition ,130 ,30 )];
	[ratedTaxesLabel setBackgroundColor:[UIColor clearColor]];
	[ratedTaxesLabel setTag:tagValue];
	[ratedTaxesLabel setTextColor:RepliconStandardBlackColor];
	[ratedTaxesLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//US4065//Juhi//DE5654 Ullas
	[ratedTaxesLabel setText:[[expenseTaxesInfoArray objectAtIndex:tagValue]objectForKey:@"name"]];
	//[self.view addSubview:ratedTaxesLabel];
    viewheightWithTable=viewheightWithTable+ratedTaxesLabel.frame.size.height;
   
    [self.scrollView addSubview:ratedTaxesLabel];
	
	
	ratedTaxValueLable = [[UILabel alloc]initWithFrame:CGRectMake(190,yPosition ,111 ,30 )];//US4065//Juhi
	//[ratedTaxValueLable setFrame:CGRectMake(210,yPosition ,140 ,30 )];
	[ratedTaxValueLable setBackgroundColor:[UIColor clearColor]];
	[ratedTaxValueLable setText:[ratedValuesArray objectAtIndex:tagValue]];
	[ratedTaxValueLable setTag:tagValue+20];
	[ratedTaxValueLable setTextAlignment:NSTextAlignmentRight];
	[ratedTaxValueLable setTextColor:RepliconStandardBlackColor];//US4065//Juhi
	[ratedTaxValueLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//DE5654 Ullas
	
	
	[taxesLablesArray addObject:ratedTaxValueLable];
	//[self.view addSubview:ratedTaxValueLable];
    [self.scrollView addSubview:ratedTaxValueLable];
}

#pragma mark PickerMethods
-(void)addPicker
{
	
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
	pickerView1.tag = 0;
	
	
	UISegmentedControl *temptoolbarSegmentControl = [[UISegmentedControl alloc] initWithItems:
							 [NSArray arrayWithObjects:RPLocalizedString(@"Previous", @"") ,RPLocalizedString(@"Next", @""),nil]];
    self.toolbarSegmentControl=temptoolbarSegmentControl;
   
	
	[toolbarSegmentControl setFrame:CGRectMake(10.0,
											   8.0,
											   140.0, 
											   31.0)];
	//[toolbarSegmentControl setSelectedSegmentIndex:NEXT];
//	[toolbarSegmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:G2PREVIOUS_AMOUNT];
	[toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:G2NEXT_AMOUNT];
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
    
    
	[pickerViewC setBackgroundColor:[UIColor clearColor]];
	//[pickerViewC.toolbar setFrame:CGRectMake(0, 160, 320, 45)];
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

- (void)segmentClick:(UISegmentedControl *)segmentControl{
	
	if (segmentControl.selectedSegmentIndex == G2PREVIOUS_AMOUNT) {
		[self pickerPrevious:nil];
		[toolbarSegmentControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
	}
	if (segmentControl.selectedSegmentIndex == G2NEXT_AMOUNT) {
		[self pickerNext:nil];
		[toolbarSegmentControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
	}
	
}

-(NSString*)replaceStringToCalculateAmount:(NSString*)currentString replaceWith:(NSString*)replString originalString:(NSString*)string
{
	NSMutableString *requiredString=[NSMutableString stringWithFormat:@"%@",string];
    if (![requiredString isKindOfClass:[NSNull class] ]) 
    {
        [requiredString replaceOccurrencesOfString:currentString withString:replString options:0 range:NSMakeRange(0, [requiredString length])];
    }
	
	
	return requiredString;
}

- (void)pickerDone:(UIBarButtonItem *)button{
    [self resetTableViewUsingSelectedIndex:nil];  
	if (button.tag==0) {
		[pickerViewC setHidden:YES];
		[textFieldSelected resignFirstResponder];
	}else {
		doneTapped=YES;
	}
	
	UITextField *amountTxtField=nil;
    //DE2432
//	if (selectedFieldTag==0) {
//		amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
//											 [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
//		
//		if ([[amountTxtField text] isEqualToString:RPLocalizedString(@"Select", @"")]) {
//			[amountTxtField setText:@"0.00"];
//			self.amountValueEntered=@"0.00";
//			//[totalAmountValue setText:[NSString stringWithFormat:@"%@0.0",[fieldValuesArray objectAtIndex:0]]];
//		}else {
//			//NSString *requiredValue=[self replaceStringToCalculateAmount:[fieldValuesArray objectAtIndex:selectedFieldTag] 
//			//															 replaceWith:@"" originalString:amountValueEntered];
//			if ([typeString isEqualToString:Flat_WithOut_Taxes]) {
//				[amountTxtField setText:[NSString stringWithFormat:@"%@",amountValueEntered]];
//			}else if ([typeString isEqualToString:Flat_With_Taxes]) {
//				//[amountTxtField setText:[NSString stringWithFormat:@"%@ %@",[fieldValuesArray objectAtIndex:selectedFieldTag],amountValueEntered]];
//				[self setValueToSelectedTaxField:textFieldSelected];
//				
//			}
//		}
//		//[self performSelector:@selector(updateValues:) withObject:amountTxtField];
//	}
    //DE2432
	if (amountTxtField!=nil && ![[amountTxtField text] isEqualToString:RPLocalizedString(@"Select", @"")]) {
		
		if (textFieldSelected.tag<[flatExpenseFieldsArray count]) {
			[self performSelector:@selector(updateValues:) withObject:amountTxtField];
		}
	}else {
        //DE2432
        if (selectedFieldTag!=0 && ![[amountTxtField text] isEqualToString:RPLocalizedString(@"Select", @"")]) {
            if (textFieldSelected.tag<[flatExpenseFieldsArray count]) {
                amountTxtField = [(G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
                                                     [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
                //[self performSelector:@selector(updateValues:) withObject:textFieldSelected];
                [self performSelector:@selector(updateValues:) withObject:amountTxtField];
            }
        }
		
	}
	
	
	
	
	if (textFieldSelected.tag==100||textFieldSelected.tag==200) {
		[self performSelector:@selector(updateRatedExpenseData:) withObject:textFieldSelected];
	}
	
	if (textFieldSelected.tag>=1000) {
		//[self taxAmountEditedByUser:textFieldSelected];
		//[self setValueToSelectedTaxField:textFieldSelected];
	}
	
	if (self.selectedIndexPath != nil && ![self.selectedIndexPath isKindOfClass:[NSNull class]]) 
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
	
}
- (void)pickerPrevious:(UIBarButtonItem *)button{
	
	NSIndexPath *currencyIndex = [NSIndexPath indexPathForRow:0 inSection:0];
	if (self.selectedIndexPath != nil  && ![self.selectedIndexPath isKindOfClass:[NSNull class]] && currencyIndex != self.selectedIndexPath) {
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
	}
	//if (selectedFieldTag==AMOUNT) {
//		//selectedFieldTag--;
//		[self addUsdAction];
//	}
	[self  cellTappedAtIndex:currencyIndex];
	
}
-(void)pickerNext:(UIBarButtonItem *)button{
	//if (selectedFieldTag==CURRENCY) {
	//	if (isCurrencySelected==NO) {
			[fieldValuesArray replaceObjectAtIndex:selectedFieldTag withObject:[[currenciesArray objectAtIndex:defaultRowInPicker]objectForKey:@"symbol"]];
	//	}
	//	[self addAmountAction];
	NSIndexPath *amountIndex = [NSIndexPath indexPathForRow:1 inSection:0];
	
	if (self.selectedIndexPath !=nil && self.selectedIndexPath != amountIndex) {
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
	}
	[self  cellTappedAtIndex:amountIndex];
	//}
}

-(G2AmountCellView *)getCellAtIndexPath:(NSIndexPath*)cellIndexPath
{
	G2AmountCellView *cellObj = (G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:cellIndexPath];
	return cellObj;
}

#pragma mark -
#pragma mark Picker Delegates methods

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 280;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if ([currenciesArray count]!=0) {
		return [currenciesArray count];	
	}
	return 0;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if(pickerView.tag == G2CURRENCY){
		return [[currenciesArray objectAtIndex:row] objectForKey:@"symbol"] ;
	}
	return nil;
	
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if(pickerView.tag == G2CURRENCY){
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                G2AmountCellView *amountCell = (G2AmountCellView *)[self.amountTableView cellForRowAtIndexPath:indexPath];
		[amountCell.fieldButton setTitle:[[currenciesArray objectAtIndex:row] objectForKey:@"symbol"] forState:UIControlStateNormal];
		//currecncyString=[[[currenciesArray objectAtIndex:row]objectForKey:@"symbol"]retain];
		[self.fieldValuesArray replaceObjectAtIndex:0 withObject:[[currenciesArray objectAtIndex:row]objectForKey:@"symbol"]];
		isCurrencySelected=YES;
		defaultRowInPicker = (int)row;
	}	
}

#pragma mark ButtonActions
-(void)buttonActions:(UIButton*)sender
{
    selectedFieldTag=sender.tag;
	if (sender.tag==0) {
		buttonTitle=sender.titleLabel.text;
		[self addUsdAction];
	}
	
	if (sender.tag==1) {
		[self addAmountAction];
	}
	
	
	if (sender.tag==100||sender.tag==200) {
	}
	
	if (sender.tag>=1000) {
		[pickerViewC setHidden:NO];
		[toolbarSegmentControl setHidden:YES];
	}
}

-(void)addUsdAction	
{
	
	if (selectedFieldTag>0) {
		selectedFieldTag--;
		UITextField *amountTxtField = [(G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
														  [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
        //CGRect frame=self.amountTableView.frame;
        //frame.size.height=self.view.frame.size.height;
        //self.amountTableView.frame=frame;
		[amountTxtField resignFirstResponder];//used to hide keyBoard when previousPressed
		if (amountValueEntered!=nil) {
			//[amountTxtField setText:@""];
			[amountTxtField setText:[NSString stringWithFormat:@"%@",amountValueEntered]];
		}
		
	}else {
		UITextField *amountTxtField = [(G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
														  [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
        //DE4062//Juhi
        //CGRect frame=self.amountTableView.frame;
        //frame.size.height=157.0;
        //self.amountTableView.frame=frame;

		[amountTxtField resignFirstResponder];
	}
	
	
	
	if (inEditState==YES) {
		[self showToolBarWithAnimationForUsdAction];
	}else {
		[ self showToolBarWithAnimation];
	}
	
	
	
	[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:G2PREVIOUS_AMOUNT];
	[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:G2NEXT_AMOUNT];
	[pickerView1 setHidden:NO];
	[pickerViewC setHidden:NO];
	
	[pickerView1 selectRow: defaultRowInPicker inComponent:0 animated: YES];	
	[toolbarSegmentControl setHidden:NO];
}



-(void)addAmountAction
{
	//[self hideToolBarWithAnimation];
	if (selectedFieldTag==0) {
		selectedFieldTag++;
/*        REMOVED FOR DE3291
//		UITextField *amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
//														  [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
//		
//		[amountTxtField becomeFirstResponder];  */
	}
	[pickerViewC setHidden:NO];
	[pickerView1 setHidden:YES];
	[toolbarSegmentControl setHidden:NO];
	[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:G2PREVIOUS_AMOUNT];
	[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:G2NEXT_AMOUNT];
	
}


-(void)getValueFromZCal:(NSString*)value
{
	G2AmountCellView *amontCell;
	NSIndexPath *index;
	index = [NSIndexPath indexPathForRow:G2AMOUNT inSection:0];
	amontCell = (G2AmountCellView *)[ self. amountTableView cellForRowAtIndexPath:index];
	[amontCell.fieldButton setTitle:value forState:UIControlStateNormal];
	
}


-(void)updateValues:(UITextField*)textField
{
	if (textField.tag==1) {
		if (amountValueEntered!=nil) {
			//existedAmount=[self replaceStringToCalculateTaxAmounts:[fieldValuesArray objectAtIndex:0] replaceWith:@"" originalString:textField.text];
			//amountValueEntered=[NSString stringWithFormat:@"%@ %@",[fieldValuesArray objectAtIndex:0],existedAmount]; 
			self.amountValueEntered = [amountValueEntered stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
			textField.text=[NSString stringWithFormat:@"%@",amountValueEntered];
            isAmountEdit=YES;
		}
		
		//[fieldValuesArray replaceObjectAtIndex:1 withObject:textField.text];
		[self.fieldValuesArray replaceObjectAtIndex:1 withObject:amountValueEntered];
		
		if ([typeString isEqualToString:Flat_With_Taxes]) {
			[self calculateTaxesForEnterdAmount:amountValueEntered];
		}
	}
	
	
}

-(void)calculateTaxesForEnterdAmount:(NSString*)amountEnterd
{
	[self.fieldValuesArray replaceObjectAtIndex:1 withObject:amountEnterd];
	double netAmount=[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amountEnterd];
    //Fix for DE3434//Juhi
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
    NSDecimalNumber *netAmountDecimal=[[NSDecimalNumber alloc] initWithDouble:netAmount];
    NSDecimalNumber *roundedNetAmount= [netAmountDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
	//float netAmount=[amountEnterd floatValue];
	double totalTax=0;
    NSDecimalNumber *roundedTotalTaxAmount=[[NSDecimalNumber alloc] initWithDouble:0.0];
	for (int i=0; i<[expenseTaxesInfoArray count]-1; i++) {
		NSNumber *taxAmount;
        
		NSString *taxFormula=nil;
        if (isAmountEdit)
        {
           taxFormula= [[expenseTaxesInfoArray objectAtIndex:i]objectForKey:@"formula"];
        }
        else if (taxAmountEdited)
        {
            taxFormula = [fieldValuesArray objectAtIndex:i+2];
        }
        
        //Fix for DE3565//Juhi
        taxFormula=[taxFormula lowercaseString];
        
        //Fix for DE3201//Juhi
        if ([taxFormula rangeOfString:@"$net"].location!=NSNotFound)
        {      
            taxFormula=[taxFormula stringByReplacingOccurrencesOfString:@"$net"withString:[NSString stringWithFormat:@"%f", [roundedNetAmount doubleValue]]];
            NSPredicate *pred = [NSPredicate predicateWithFormat:[taxFormula stringByAppendingString:@" == 42"]];
            NSExpression *exp = [(NSComparisonPredicate *)pred leftExpression];
            taxAmount = [exp expressionValueWithObject:nil context:nil];
            
            
        }
        
        
        //        NSArray *multiplierForTax = [Util getMultiplier:taxFormula];
        //        
        //		if ([multiplierForTax count]>0)
        //        {
        //            if([multiplierForTax count]==2)
        //            {
        //                NSNumber *multiplierValue=[NSNumber numberWithDouble:[[multiplierForTax objectAtIndex:1] doubleValue]];
        //                taxAmount=[NSNumber numberWithDouble:netAmount*[multiplierValue doubleValue]];
        //            }
        //            else
        //            {
        //                NSNumber *multiplierValue1=[NSNumber numberWithDouble:[[multiplierForTax objectAtIndex:1] doubleValue]];
        //                NSNumber *multiplierValue2 =[NSNumber numberWithDouble:[[multiplierForTax objectAtIndex:2] doubleValue]];
        //                taxAmount =[NSNumber numberWithDouble:(netAmount+(netAmount*[multiplierValue1 doubleValue]))* [multiplierValue2 doubleValue]];
        //            }
        //		}
        
        else {
			taxAmount=[NSNumber numberWithDouble:[taxFormula doubleValue]];
		} 
		//Fix for DE3434//Juhi
        NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE]; 
        NSDecimalNumber *doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[taxAmount doubleValue]];
        NSDecimalNumber *roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

		//taxAmount=[NSNumber numberWithFloat:netAmount*[multiplierForTax floatValue]];
		[self.fieldValuesArray replaceObjectAtIndex:i+2 withObject:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]]];
		//[fieldValuesArray replaceObjectAtIndex:i+2 withObject:[NSString stringWithFormat:@"%@%0.02f",[fieldValuesArray objectAtIndex:0],[taxAmount floatValue]]];
		UITextField *taxTxtField = [(G2AmountCellView *)[self.amountTableView cellForRowAtIndexPath:
													   [NSIndexPath indexPathForRow:i inSection:1]] fieldText ];
		[taxTxtField setText:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]]];
		//[taxTxtField setText:[NSString stringWithFormat:@"%@%0.02f",[fieldValuesArray objectAtIndex:0],[Util formatDoubleAsStringWithDecimalPlaces:[taxAmount floatValue]]]];
                totalTax=totalTax +[roundedTaxAmount doubleValue];
		//totalTax=totalTax +[taxAmount doubleValue];
        
        //Fix for DE3434//JUHI
        NSDecimalNumber *totalTaxDecimal=[[NSDecimalNumber alloc] initWithDouble:totalTax];
        roundedTotalTaxAmount=[totalTaxDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
	}
    //Fix for DE3434//Juhi
	//NSNumber *totalAmountWithTaxes =[Util getTotalAmount:[NSNumber numberWithDouble:netAmount] taxAmount:[NSNumber numberWithDouble:totalTax]];
    NSDecimalNumber *totalAmountWithTaxes=(NSDecimalNumber *)[G2Util getTotalAmount:roundedNetAmount taxAmount:roundedTotalTaxAmount];
	[self.fieldValuesArray replaceObjectAtIndex:[fieldValuesArray count]-1 withObject:[NSString stringWithFormat:@"%@",
																				  [G2Util formatDoubleAsStringWithDecimalPlaces:[totalAmountWithTaxes doubleValue]]]];
	//[fieldValuesArray replaceObjectAtIndex:[fieldValuesArray count]-1 withObject:[NSString stringWithFormat:@"%@%0.02f",[fieldValuesArray objectAtIndex:0],[totalAmountWithTaxes floatValue]]];
	[totalAmountValue setText:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[totalAmountWithTaxes doubleValue]]]];
	//[totalAmountValue setText:[NSString stringWithFormat:@"%@%0.02f",[fieldValuesArray objectAtIndex:0],[totalAmountWithTaxes floatValue]]];
	
}

-(void)taxAmountEditedByUser:(UITextField*)taxTextField
{
	taxAmountEdited = YES;
	//[taxTextField setText:[NSString stringWithFormat:@"%@ %@",[fieldValuesArray objectAtIndex:0],[taxTextField.text floatValue]]];
	double totalTax=0;
	UITextField *netAmountField = [(G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
													  [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
	NSString *netAmountString=nil;
	if (netAmountField.text==nil && [netAmountField.text isEqualToString:RPLocalizedString(@"Select", @"")]) {
		netAmountField.text=[NSString stringWithFormat:@"%@",@"0.00"];
	}
	netAmountString=netAmountField.text;
	if (netAmountString == nil) {
		netAmountString = [self.fieldValuesArray objectAtIndex:1];
	}
	[self  setAmountValueEntered:netAmountString];
	double netAmount=[G2Util getValueFromFormattedDoubleWithDecimalPlaces:netAmountString];
    
    //Fix for DE3434//Juhi
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
    NSDecimalNumber *netAmountDecimal=[[NSDecimalNumber alloc] initWithDouble:netAmount];
    NSDecimalNumber *roundedNetAmount= [netAmountDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    NSDecimalNumber *roundedTotalTaxAmount=[[NSDecimalNumber alloc] initWithDouble:netAmount];
    
    
	for (int i=0; i<[expenseTaxesInfoArray count]-1; i++) {
		UITextField *taxTxtField = [(G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
													   [NSIndexPath indexPathForRow:i inSection:1]] fieldText ];
		NSString *taxValueExisted=taxTxtField.text;
		double taxDoubleValue=0.0;
         //Fix for DE3345//Juhi
//		if (taxValueExisted!=nil) {
//			taxDoubleValue =[Util getValueFromFormattedDoubleWithDecimalPlaces:taxValueExisted];
//		}
        if (taxValueExisted!=nil && ![taxValueExisted isEqualToString:@"0.00"]) {
			taxDoubleValue =[G2Util getValueFromFormattedDoubleWithDecimalPlaces:taxValueExisted];
		}
        else {
            //Fix for DE3345//Juhi
            if (taxValueExisted==nil) {
                taxDoubleValue = [[self.fieldValuesArray objectAtIndex:i+2] doubleValue];
            }
            //			taxDoubleValue = [[fieldValuesArray objectAtIndex:i+2] doubleValue];
            else{
                NSNumber *taxAmount;
                NSString *taxFormula=[fieldValuesArray objectAtIndex:i+2];//[[fieldValuesArray objectAtIndex:i+2]objectForKey:@"formula"];
                taxFormula=[taxFormula lowercaseString];
                
                
                if ([taxFormula rangeOfString:@"$net"].location!=NSNotFound)
                {      
                    taxFormula=[taxFormula stringByReplacingOccurrencesOfString:@"$net"withString:[NSString stringWithFormat:@"%f", [roundedNetAmount doubleValue]]];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:[taxFormula stringByAppendingString:@" == 42"]];
                    NSExpression *exp = [(NSComparisonPredicate *)pred leftExpression];
                    taxAmount = [exp expressionValueWithObject:nil context:nil];
                    taxDoubleValue= [taxAmount doubleValue];
                    
                    
                }
                else {
                    taxAmount=[NSNumber numberWithDouble:[taxFormula doubleValue]];
                    taxDoubleValue =[taxAmount doubleValue];
                }
            }
            
            
		}
		//Fix for DE3434//Juhi
        NSDecimalNumber *doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:taxDoubleValue];
        NSDecimalNumber *roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
		
        [self.fieldValuesArray replaceObjectAtIndex:i+2 withObject:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]]];
        
//        //DE5663//Juhi
//        [[expenseTaxesInfoArray objectAtIndex:i]removeObjectForKey:@"formula"];
//        [[expenseTaxesInfoArray objectAtIndex:i] setObject:[NSString stringWithFormat:@"%@",[Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]] forKey:@"formula"];
        
          //Fix for DE3345//Juhi
//		if (taxTxtField.tag==taxTextField.tag) {
//			[taxTextField setText:[NSString stringWithFormat:@"%@",[Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]]];
//			
//		}
        [taxTxtField setText:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]]];
        
		totalTax=totalTax+[roundedTaxAmount doubleValue];
        //Fix for DE3434//Juhi
        NSDecimalNumber *totalTaxDecimal=[[NSDecimalNumber alloc] initWithDouble:totalTax];
        roundedTotalTaxAmount=[totalTaxDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
	}
    //Fix for DE3434//Juhi
	//NSNumber *totalAmount=[Util getTotalAmount:[NSNumber numberWithDouble:netAmount] taxAmount:[NSNumber numberWithDouble:totalTax]];
    NSDecimalNumber *totalAmount=(NSDecimalNumber *)[G2Util getTotalAmount:roundedNetAmount taxAmount:roundedTotalTaxAmount];
	[self.fieldValuesArray replaceObjectAtIndex:[self.fieldValuesArray count]-1 withObject:[NSString stringWithFormat:@"%@",
																				  [G2Util formatDoubleAsStringWithDecimalPlaces:[totalAmount doubleValue]]]];
	[totalAmountValue setText:[G2Util formatDoubleAsStringWithDecimalPlaces:[totalAmount doubleValue]]];
	[self updateAmountValue];
	
	//[self setValueToSelectedTaxField:taxTextField];
}

-(void)updateAmountValue
{
	UITextField *amountTxtField = [(G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
													  [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
	
	NSString *amountText = amountTxtField.text;
	if (amountText == nil) {
		amountText = [self.fieldValuesArray objectAtIndex:1];
	}
	double amtDoubleValue =[G2Util getValueFromFormattedDoubleWithDecimalPlaces:amountText];
	NSString *tempAmount = [NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:amtDoubleValue]];
	self.amountValueEntered = tempAmount;
	self.amountValueEntered = [amountValueEntered stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	amountTxtField.text=[NSString stringWithFormat:@"%@",amountValueEntered];
	[self.fieldValuesArray replaceObjectAtIndex:1 withObject:amountValueEntered];
}
-(NSString*)replaceStringToCalculateTaxAmounts:(NSString*)currentString replaceWith:(NSString*)replString originalString:(NSString*)string
{
	
	NSMutableString *requiredString=[NSMutableString stringWithFormat:@"%@",string];
	
	if ([requiredString rangeOfString:currentString].location == NSNotFound) {
		
		return nil;
	} else {
        if (![requiredString isKindOfClass:[NSNull class] ]) 
        {
            [requiredString replaceOccurrencesOfString:currentString withString:replString options:0 range:NSMakeRange(0, [requiredString length])];
        }
		
	}
	
	return requiredString;
}


-(void)userSelectedTextField:(UITextField*)textField
{
	if (textField.tag > amountField_Tag) {
		[self updateAmountValue];
	}
	[self setTextFieldSelected:textField];
	
	if (textField.tag<[flatExpenseFieldsArray count]) {
		self.amountValueEntered=@"";
		
		[self addAmountAction];
	}else {
		[pickerViewC setHidden:NO];
		[toolbarSegmentControl setHidden:YES];
		
		//[self  taxAmountEditedByUser:textField];
	}
	
	selectedFieldTag=textField.tag;
	
}

-(void)setValueToSelectedTaxField:(UITextField*)textField
{
	
	for (int i=0; i<[expenseTaxesInfoArray count]-1; i++) {
		UITextField *taxTxtField = [(G2AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
													   [NSIndexPath indexPathForRow:i inSection:1]] fieldText ];
		double taxEntered=	[G2Util getValueFromFormattedDoubleWithDecimalPlaces:taxTxtField.text];
//		[fieldValuesArray replaceObjectAtIndex:i+2 withObject:[NSString stringWithFormat:@"%@",[self replaceStringToCalculateAmount:buttonTitle replaceWith:@"" originalString:taxTxtField.text]]];
		
		//double taxEntered = [Util getValueFromFormattedDoubleWithDecimalPlaces:[fieldValuesArray objectAtIndex:i+2]];
		[taxTxtField setText:[G2Util formatDoubleAsStringWithDecimalPlaces:taxEntered]];
		
		
		//[taxTxtField setText:[NSString stringWithFormat:@"%@ %@",[fieldValuesArray objectAtIndex:0],[Util formatDoubleAsStringWithDecimalPlaces:[[fieldValuesArray objectAtIndex:i+2]doubleValue]]]];

		[self.fieldValuesArray replaceObjectAtIndex:i+2 withObject:taxTxtField.text];
		//[taxTxtField setText:[NSString stringWithFormat:@"%@%0.02f",[fieldValuesArray objectAtIndex:0],[[fieldValuesArray objectAtIndex:i+2]floatValue]]];
	}
	[self.fieldValuesArray replaceObjectAtIndex:[self.fieldValuesArray count]-1 withObject:totalAmountValue.text];
	double totalChangedByTax = [G2Util getValueFromFormattedDoubleWithDecimalPlaces:[self.fieldValuesArray objectAtIndex:[self.fieldValuesArray count]-1]];
	[totalAmountValue setText:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:totalChangedByTax]]];
	[self.fieldValuesArray replaceObjectAtIndex:[self.fieldValuesArray count]-1 withObject:totalAmountValue.text];
}

//To show Overlay when user tapped the kilometer unitFeld to enter value
-(void)showKilometersOverLay:(UITextField*)kilometerTextField
{
	[pickerViewC setHidden:NO];
	[toolbarSegmentControl setHidden:YES];
	[self setTextFieldSelected:kilometerTextField];
	//textFieldSelected=kilometerTextField;
}

//To Update data for rated expense and Taxfields.. 
-(void)updateRatedExpenseData:(UITextField*)kilometerTextField
{
	kilometerUnitValue=kilometerTextField.text;
	//kilometerUnitValue=[NSString stringWithFormat:@"%@",[Util formatDoubleAsStringWithDecimalPlaces:[kilometerTextField.text floatValue]]];
	double kilometersInDouuble=[G2Util getValueFromFormattedDoubleWithDecimalPlaces:kilometerUnitValue]; 
    
	kilometerTextField.text=[NSString stringWithFormat:@"%0.02lf",kilometersInDouuble];
	[defaultValuesArray replaceObjectAtIndex:0 withObject:kilometerUnitValue];
    //Fix for DE3434//Juhi
    //DE7062
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];  
//    NSDecimalNumber *doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:rate];
//    NSDecimalNumber *roundedDecimalNumber = (NSDecimalNumber *)[doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
	NSDecimalNumber *netAmount=[[NSDecimalNumber alloc] initWithDouble:kilometersInDouuble*rate];
    NSDecimalNumber *roundedNetAmount= [netAmount decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
//	double netAmount=kilometersInDouuble*rate;
	NSString *formattedRateString = [[NSString alloc] initWithFormat:@"%0.04lf",rate];
	//[Util formatDoubleAsStringWithDecimalPlaces:rate];
	NSString *formattedNetAmountString = [G2Util formatDoubleAsStringWithDecimalPlaces:[roundedNetAmount doubleValue]];
    //US4366 Ullas M L
    for (int k=0; k<[addRateAndAmountLables count]; k++) {
        if (k==0) {
            [[addRateAndAmountLables objectAtIndex:0] setText:formattedRateString];
        }
        if (k==1) {
            [[addRateAndAmountLables objectAtIndex:1] setText:formattedNetAmountString];
        }
    }
	
	
	[defaultValuesArray replaceObjectAtIndex:1 withObject:formattedRateString];
	[defaultValuesArray replaceObjectAtIndex:2 withObject:formattedNetAmountString];
	
	
	double totalTax=0;
	NSNumber *taxAmount;
    NSDecimalNumber *roundedTotalTaxAmount=[[NSDecimalNumber alloc] initWithDouble:0];
	for (int i=0; i<[expenseTaxesInfoArray count]-1; i++) {
		NSString *taxFormula=[[expenseTaxesInfoArray objectAtIndex:i] objectForKey:@"formula"];
        //Fix for DE3565//Juhi
        taxFormula=[taxFormula lowercaseString];
		//NSNumber *multiplierAmount = [Util getMultiplier:taxFormula];
        
        //  NSArray *multiplierAmount = [Util getMultiplier:taxFormula];
        //        NSNumber *multiplierValue;
        //        
        //		if ([multiplierAmount count]>0)
        //        {
        //            if([multiplierAmount count]==2)
        //            {
        //               multiplierValue =[NSNumber numberWithDouble:[[multiplierAmount objectAtIndex:1] doubleValue]];
        //               // taxAmount=[NSNumber numberWithDouble:netAmount*[multiplierValue doubleValue]];
        //            }
        //            else
        //            {
        //                multiplierValue=[NSNumber numberWithDouble:[[multiplierAmount objectAtIndex:1] doubleValue]];
        //                NSNumber *multiplierValue1 =[NSNumber numberWithDouble:[[multiplierAmount objectAtIndex:2] doubleValue]];
        //               // taxAmount =[NSNumber numberWithDouble:(netAmount+(netAmount*[multiplierValue doubleValue]))* [multiplierValue1 doubleValue]];
        //            }
        //		} 
        
        //Fix for DE3201//Juhi
      //  NSString *NetAmount=[NSString stringWithFormat:@"%d", netAmount] ;
        //Fix for DE3434//Juhi
        NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE]; 
        NSDecimalNumber *doubleDecimal; 
        NSDecimalNumber *roundedTaxAmount;
        if ([taxFormula rangeOfString:@"$net"].location!=NSNotFound)
        {      
             //Fix for DE3434//Juhi
            //taxFormula=[taxFormula stringByReplacingOccurrencesOfString:@"$Net"withString:formattedNetAmountString];
            //DE7062
            taxFormula=[taxFormula stringByReplacingOccurrencesOfString:@"$net"withString:[NSString stringWithFormat:@"%f", [roundedNetAmount doubleValue]]];
            NSPredicate *pred = [NSPredicate predicateWithFormat:[taxFormula stringByAppendingString:@" == 42"]];
            NSExpression *exp = [(NSComparisonPredicate *)pred leftExpression];
            taxAmount = [exp expressionValueWithObject:nil context:nil];
            
            //Fix for DE3434//Juhi
        
           doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[taxAmount doubleValue]];
          roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
            
            [ratedValuesArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]]];
        }
        //		if (multiplierValue!=nil && ![multiplierValue isKindOfClass:[NSNull class]]) {
        //			taxAmount=[NSNumber numberWithDouble:netAmount*[multiplierValue doubleValue]];
        //		}
        else {
			taxAmount=[NSNumber numberWithDouble:[taxFormula doubleValue]];
            doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[taxAmount doubleValue]];
            roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
            [ratedValuesArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]]];
		}
		
//		if ([taxFormula rangeOfString:formattedNetAmountString].location!=NSNotFound)
//        {    taxFormula=[taxFormula stringByReplacingOccurrencesOfString:@"$Net"withString:formattedNetAmountString];
//            NSPredicate *pred = [NSPredicate predicateWithFormat:[taxFormula stringByAppendingString:@" == 42"]];
//            NSExpression *exp = [pred leftExpression];
//            taxAmount = [exp expressionValueWithObject:nil context:nil];
//            DLog(@"%@", taxAmount);  
//            
//			[ratedValuesArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@",[Util formatDoubleAsStringWithDecimalPlaces:[taxAmount doubleValue]]]];
//		}
//        else {
//			[ratedValuesArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@",[Util formatDoubleAsStringWithDecimalPlaces:[taxAmount doubleValue]]]];
//		}
		
		[[taxesLablesArray objectAtIndex:i] setText:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[roundedTaxAmount doubleValue]]]];
       
        totalTax=totalTax +[roundedTaxAmount doubleValue];
        NSDecimalNumber *totalTaxDecimal=[[NSDecimalNumber alloc] initWithDouble:totalTax];
        roundedTotalTaxAmount=[totalTaxDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
		//totalTax=totalTax +[taxAmount doubleValue];
		//totalTax=totalTax +[taxAmount doubleValue];
	}
	
    //DE7062
	NSDecimalNumberHandler *roundingBehavior1 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE]; 
    netAmount=[netAmount decimalNumberByRoundingAccordingToBehavior:roundingBehavior1]; 
	NSDecimalNumber *totalAmount=(NSDecimalNumber *)[G2Util getTotalAmount:netAmount taxAmount:roundedTotalTaxAmount]; 
	[totalAmountValue setText:[NSString stringWithFormat:@"%@",[G2Util formatDoubleAsStringWithDecimalPlaces:[totalAmount doubleValue]]]];
    [ratedValuesArray replaceObjectAtIndex:[ratedValuesArray count]-1 withObject:totalAmountValue.text];//DE5853 Ullas M L

}
#pragma mark AmountCell methods
-(void)setEnteredAmountValue:(NSString *)_textValue{
	
	double amountDoubleValue = [G2Util getValueFromFormattedDoubleWithDecimalPlaces:_textValue];
	NSString *tempString =  [G2Util formatDoubleAsStringWithDecimalPlaces:amountDoubleValue];
	if (tempString != nil)
		self.amountValueEntered = tempString;
	if (self.fieldValuesArray != nil) {
		[self.fieldValuesArray replaceObjectAtIndex:1 withObject:amountValueEntered];
	}
}

/* // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
	 [super loadView];
	
 }



 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
	 
 }*/
 

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }R
 */

#pragma mark NewlyAddedImplementations

-(void)cellTappedAtIndex:(NSIndexPath*)cellIndexPath
{
    
    
    //CGRect frame=self.amountTableView.frame;
    //frame.size.height=200;
    //self.amountTableView.frame=frame;
    
	id cellObj = [self getCellAtIndexPath:cellIndexPath];
	
	if (self.selectedIndexPath != nil  && ![self.selectedIndexPath isKindOfClass:[NSNull class]] && self.selectedIndexPath != cellIndexPath) {
		if (cellIndexPath.row != 0 && cellIndexPath.section != 0)
			[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
		id textCell = [self getCellAtIndexPath:self.selectedIndexPath];
		if ([textCell fieldText] != nil) {
			[pickerViewC setHidden:YES];
            //CGRect frame=self.amountTableView.frame;
            //frame.size.height=self.view.frame.size.height;
            //self.amountTableView.frame=frame;
			[[textCell fieldText] resignFirstResponder];
		}
	}
	if (cellIndexPath.row == 0 && cellIndexPath.section == 0 && [[cellObj fieldLable].text isEqualToString:RPLocalizedString(@"Currency", @"") ]) {
       
		[self buttonActions:[cellObj fieldButton]];
		[self highLightTheSelectedCell:cellIndexPath];
	}else {
		[[cellObj fieldText] becomeFirstResponder];
	}
	
	self.selectedIndexPath = cellIndexPath;
    
    [self resetTableViewUsingSelectedIndex:cellIndexPath];
   
}

-(void)resetTableViewUsingSelectedIndex:(NSIndexPath*)selectedIndex
{
    //US4065//Juhi//US4335 Ullas M L
    if (selectedIndex!=nil)  
    {
        //JUHI
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
		if (selectedIndex.section == 0) {
            //JUHI
			[self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,screenRect.size.height-320)];
            CGFloat offsetHeight=0.0;
            if ([typeString isEqualToString:Flat_With_Taxes]) 
            {
                offsetHeight=5.0;   
            } 
            
            else if ([typeString isEqualToString:Rated_WithOut_Taxes] )
            {
               offsetHeight=-30.0;   
            }
            else if ([typeString isEqualToString:Rated_With_Taxes]) 
            {
                offsetHeight=20.0;
            }

            self.scrollView.contentSize=CGSizeMake(self.view.frame.size.width,scrollHieght+offsetHeight);
            [self.scrollView setContentOffset:CGPointMake(0.0,(((selectedIndex.row+0)*TABLE_ROW_HEIGHT))) animated:YES];
            
            
	    }
        else if(selectedIndex.section == 1)
        {
            //JUHI
            [self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,screenRect.size.height-320)];
            self.scrollView.contentSize=CGSizeMake(self.view.frame.size.width,scrollHieght);
            if ((screenRect.size.height/screenRect.size.width)>1.5)
            {
                [self.scrollView setContentOffset:CGPointMake(0.0,(((selectedIndex.row)*TABLE_ROW_HEIGHT))) animated:YES];
            }
            else
                [self.scrollView setContentOffset:CGPointMake(0.0,(((selectedIndex.row+2)*TABLE_ROW_HEIGHT))) animated:YES];
        }
		
		
	}
    if (selectedIndex==nil) 
    {
        [self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width,scrollHieght);

    }
    
}

-(void)getTagFromTextFiled:(UITextField*)textFiledTapped
{
	NSIndexPath *tappedIndexPath = nil;
	int section = 0;
	if (textFiledTapped.tag >= tag_Taxes) {
		section = 1;
	}
	NSInteger row = 0;
	if (textFiledTapped.tag == amountField_Tag ) {
		row = 1;
	}else if (textFiledTapped.tag >= tag_Taxes) {
		row = textFiledTapped.tag - tag_Taxes;
	}else if (textFiledTapped.tag == ratedField_Tag) {
		row = textFiledTapped.tag - ratedField_Tag;
	}else if (textFiledTapped.tag == ratedWithTaxes_Tag) {
		row = textFiledTapped.tag - ratedWithTaxes_Tag;
	}

	tappedIndexPath = [NSIndexPath indexPathForRow:row inSection:section];

	if (self.selectedIndexPath!= nil &&  self.selectedIndexPath != tappedIndexPath) 
    {
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
        
        [self. amountTableView deselectRowAtIndexPath:self.selectedIndexPath animated:NO];
	}
	[self highLightTheSelectedCell:tappedIndexPath];
    
    
	
	self.selectedIndexPath = tappedIndexPath;
    [self resetTableViewUsingSelectedIndex:tappedIndexPath];
	

}

-(void)highLightTheSelectedCell:(NSIndexPath*)tappedIndex
{
//	[self. amountTableView selectRowAtIndexPath:tappedIndex animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (boolSelectedRated_WithOut_Taxes) 
    {
        
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height+viewheightWithTable-157);
          
        
    }
    else
    {
        CGPoint offset = [self.scrollView contentOffset];
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width,screenRect.size.height+tableHieght-157);
        CGRect rect1 = CGRectMake(self.view.frame.origin.x, offset.y, self.view.frame.size.width, screenRect.size.height-323);
        [self.scrollView scrollRectToVisible:rect1 animated:NO];
    } 
    
		id cellObj = [self getCellAtIndexPath:tappedIndex];
        [cellObj setBackgroundColor:RepliconStandardBlueColor];//fix for DE3019//Juhi
        [[cellObj fieldLable] setTextColor:iosStandaredWhiteColor];
        [[cellObj fieldText] setTextColor:iosStandaredWhiteColor];
        [(UIButton*)[cellObj fieldButton]setTitleColor:iosStandaredWhiteColor forState:UIControlStateNormal];
    
     
	
}

-(void)dehilightCellWhenFocusChanged:(NSIndexPath*)indexPath
{
//	[self. amountTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
    
     if (boolSelectedRated_WithOut_Taxes) 
    {
        
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height-viewheightWithTable-157);
    }
    else
    {

    //scrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height-tableHieght-157);
       
    } 
    
	[self. amountTableView deselectRowAtIndexPath:indexPath animated:NO];
	id cellObj = [self getCellAtIndexPath:indexPath];
	[[cellObj fieldLable] setTextColor:RepliconStandardBlackColor];
	[(UIButton*)[cellObj fieldButton] setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	[[cellObj fieldText] setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
    [cellObj setBackgroundColor:iosStandaredWhiteColor];//fix for DE3019//Juhi

	//self.selectedIndexPath = nil;Fix for DE3019 // Juhi*/
}

-(void)buttonActionsHandling:(UIButton*)sender :(UIEvent*)event
{
	UITouch * touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView: self. amountTableView];
	NSIndexPath * indexPath = [self. amountTableView indexPathForRowAtPoint: location];
    
    [self. amountTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
	if (self.selectedIndexPath != nil  && ![self.selectedIndexPath isKindOfClass:[NSNull class]] && self.selectedIndexPath != indexPath) {
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
	}
	
	[self performSelector:@selector(cellTappedAtIndex:) withObject:indexPath];
	
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.amountTableView=nil;
    self.ratedLabel=nil;
    self.ratedValueLable=nil;
    self.currencyLabel=nil;
    self.currencyValueLabel=nil;
    self.pickerViewC=nil;
    self.pickerView1=nil;
    self.toolbarSegmentControl=nil;
    self.totalAmountValue=nil;
    self.totalAmountLable=nil;
    self.scrollView=nil;
}






@end
