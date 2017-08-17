//
//  NewExpenseSheetViewController.m
//  Replicon
//
//  Created by Swapna P on 4/1/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2NewExpenseSheetViewController.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation G2NewExpenseSheetViewController

@synthesize	descriptionLabel,tnewExpenseSheetDelegate;
@synthesize descriptionTextField;
@synthesize date_reimbursement_tableview;
@synthesize tnewExpenseSheetVariables;
@synthesize nextPreviousControl;
@synthesize saveButton;
@synthesize reimbursementCurrencyArr;
@synthesize reimbursementCurrencyPickerView;
@synthesize selectedDate;
@synthesize selectedCurrency;
@synthesize  highlightedIndexPath;
@synthesize  pickerViewC;
@synthesize toolbarSegmentControl;
@synthesize datePicker;
@synthesize  pickerBackgroundView;
@synthesize  keyboardToolbar;
@synthesize sectionHeader;

static int dateField_row = 0;
static int currencyField_row = 1;
#define DATE_INDEX  [NSIndexPath indexPathForRow:dateField_row inSection:0]
#define CURRENCY_INDEX  [NSIndexPath indexPathForRow:currencyField_row inSection:0]

#pragma mark -
#pragma mark Initialization

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self.view setBackgroundColor:NewExpenseSheetBackgroundColor];
        
		if (supportDataModel == nil) {
			supportDataModel = [[G2SupportDataModel alloc] init];
		}
		if (expenseDetailsDict == nil) {
			expenseDetailsDict = [NSMutableDictionary dictionary];
		}
		
		reimbursementCurrencyArr = [supportDataModel getSystemCurrenciesFromDatabase];
		
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE)
																		 style: UIBarButtonItemStylePlain 
																		target: self action:@selector(cancelAction:)];
		[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
		
		
		UIBarButtonItem *tempsaveButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(G2SAVE_BTN_TITLE, G2SAVE_BTN_TITLE)
													  style:UIBarButtonItemStylePlain 
													 target:self 
													 action:@selector(saveAction:)];
        self.saveButton=tempsaveButton;
        
		[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
		[saveButton setTag:2];
		[saveButton setEnabled:NO];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)loadView
{

	[super loadView];
	if (expensesModel == nil) {
		expensesModel = [[G2ExpensesModel alloc] init];
	}
	[G2ViewUtil setToolbarLabel:self withText: RPLocalizedString(@"New Expense Sheet",@"New Expense sheet")];
	
	//Add Date-Reimburse Table
	if (date_reimbursement_tableview == nil) {
		UITableView *tempdate_reimbursement_tableview = [[UITableView alloc] initWithFrame:CGRectMake(03.0,
																					 85.0,
																					 self.view.frame.size.width-04.0,
																					 225.0) style:UITableViewStyleGrouped];
        self.date_reimbursement_tableview=tempdate_reimbursement_tableview;
       
	}
	[date_reimbursement_tableview setScrollEnabled:NO];
	[date_reimbursement_tableview setBackgroundColor:NewExpenseSheetBackgroundColor];
    date_reimbursement_tableview.backgroundView=nil;
	[date_reimbursement_tableview setDelegate:self];
	[date_reimbursement_tableview setDataSource:self];
	[self.view addSubview:date_reimbursement_tableview];
    
	
	
	
	//Add Description Label
	if (descriptionLabel ==nil) {
		UILabel *tempdescriptionLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,10,300,30)];
        self.descriptionLabel=tempdescriptionLabel;
        
		[descriptionLabel setText:RPLocalizedString(@"Sheet Name",@"Sheet Name")];
		
		[descriptionLabel setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:descriptionLabel];
	}
	[descriptionLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	
	
	//Add Description Textfield.	
	if (descriptionTextField==nil) {
		UITextField *tempdescriptionTextField = [[UITextField alloc] initWithFrame:CGRectMake(10,40,300,44)];
        self.descriptionTextField=tempdescriptionTextField;
        
	}
	
	[descriptionTextField setDelegate:self];
	[descriptionTextField setTextAlignment:NSTextAlignmentLeft];
	[descriptionTextField setHighlighted:YES];
    //US4065//Juhi
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    descriptionTextField.leftView = paddingView;
    descriptionTextField.leftViewMode = UITextFieldViewModeAlways;
	[descriptionTextField setBorderStyle:UITextBorderStyleNone];
    [descriptionTextField.layer setBorderColor:[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.5] CGColor]];
    [descriptionTextField.layer setBorderWidth: 1.5];
    [descriptionTextField.layer setCornerRadius:9.0f];
    [descriptionTextField.layer setMasksToBounds:YES];
    descriptionTextField.clipsToBounds = YES;
    descriptionTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    descriptionTextField.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
	[descriptionTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[descriptionTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
	[descriptionTextField setReturnKeyType:UIReturnKeyNext];
	[descriptionTextField setBackgroundColor:[UIColor whiteColor]];
	[descriptionTextField setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
	
	
	if (tnewExpenseSheetVariables == nil) {
		tnewExpenseSheetVariables = [[NSArray alloc] initWithObjects:RPLocalizedString(@"Date", @"") ,RPLocalizedString(@"Reimbursement Currency", @"") ,nil];//DE2217
	}
	
	if (pickerBackgroundView == nil) {
		UIView *temppickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height+64)-320, 320, 320)];
        self.pickerBackgroundView=temppickerBackgroundView;
        
	}
	
	//add date picker
	if (datePicker == nil) {
        //JUHI
        UIDatePicker *tempdatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height+64)-320, 325, 216)];
        self.datePicker=tempdatePicker;
        
	}
	datePicker.datePickerMode = UIDatePickerModeDate;
	datePicker.hidden = YES;
	datePicker.date = [NSDate date];
	
	if (reimbursementCurrencyPickerView == nil) {
		UIPickerView *tempreimbursementCurrencyPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.reimbursementCurrencyPickerView=tempreimbursementCurrencyPickerView;
        
	}
	
	CGSize pickerSize = [reimbursementCurrencyPickerView sizeThatFits:CGSizeZero];
	reimbursementCurrencyPickerView.frame = CGRectMake(	0.0,
													   0.0,
													   pickerSize.width,
													   216);//48.0,216.0
	
	reimbursementCurrencyPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	reimbursementCurrencyPickerView.delegate = self;
	reimbursementCurrencyPickerView.showsSelectionIndicator = YES;
	[reimbursementCurrencyPickerView setHidden:YES];
	[pickerBackgroundView addSubview:reimbursementCurrencyPickerView];

	
	//Set Current Date
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"MMMM dd,yyyy"];
	NSDate *currentDate = [NSDate date];
	selectedDate = [dateFormat stringFromDate:currentDate];
	NSIndexPath *index;
	index = [NSIndexPath indexPathForRow:DATE-1 inSection:0];
	cell = (G2ExpenseEntryCellView *)[self.date_reimbursement_tableview cellForRowAtIndexPath:index];
	[cell.fieldButton setTitle:selectedDate forState:UIControlStateNormal];
	
	
	[self configurePicker];
    [descriptionTextField becomeFirstResponder];
	
}

#pragma mark -
#pragma mark View lifecycle
-(void)viewWillAppear:(BOOL)animated {
	//added below call to resolve bug DE1722#6
	[self moveTableToTop:0];
}

-(void)configurePicker{
	
	//JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    CGRect frame;
    if (version>=7.0)
    {
        frame=CGRectMake(0,screenRect.size.height-301,320.0,45.0);
	}
    else{
        frame=CGRectMake(0,screenRect.size.height-320,320.0,45.0);
	}
    
    
	UIToolbar *tempkeyboardToolbar = [[UIToolbar alloc] initWithFrame:frame];
    self.keyboardToolbar=tempkeyboardToolbar;
   
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	keyboardToolbar.tintColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.5];
	
	UISegmentedControl *temptoolbarSegmentControl = [[UISegmentedControl alloc] initWithItems:
							 [NSArray arrayWithObjects:RPLocalizedString( @"Previous",@""),RPLocalizedString(@"Next",@""),nil]];
    self.toolbarSegmentControl=temptoolbarSegmentControl;
   
	
	[toolbarSegmentControl setFrame:CGRectMake(10.0,
											   8.0,
											   140.0, 
											   31.0)];
	//[toolbarSegmentControl setSelectedSegmentIndex:NEXT];
//	[toolbarSegmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:SHEET_PREVIOUS];
	[toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:SHEET_NEXT];
	[toolbarSegmentControl addTarget:self 
							  action:@selector(segmentClick:) 
					forControlEvents:UIControlEventValueChanged];
	[toolbarSegmentControl setMomentary:YES];
	//Fix for ios7//JUHI
    if (version>=7.0)
    {
        [toolbarSegmentControl setTintColor:RepliconStandardWhiteColor];
        
        
    }
	else{
        [toolbarSegmentControl setTintColor:[UIColor clearColor]];
       
    }
	[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:0];
	UIBarButtonItem *controlItem = [[UIBarButtonItem alloc] initWithCustomView:toolbarSegmentControl];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				target:self
																				action:@selector(pickerDone:)];
	
	
	UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																				 target:nil
																				 action:nil];
	NSArray *toolArray = [NSArray arrayWithObjects:
						  controlItem,
						  spaceButton,
						  doneButton,
						  nil];
	[keyboardToolbar setItems:toolArray];
	
	
	[pickerBackgroundView setHidden:YES];
	[self.view addSubview:pickerBackgroundView];
	[self.view addSubview:keyboardToolbar];
	//Handling Leaks
	
	
}

- (void)reloadPickerDataForSelectedPicker:(NSInteger)_selectedPicker{
	
	selectedPicker =_selectedPicker;
	if (selectedPicker==KEYBOARD) {
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion newFloatValue];
        if (version>=7.0)
        {
            [reimbursementCurrencyPickerView setHidden:YES];
            [datePicker setHidden:YES];
            [pickerBackgroundView setHidden:YES];
        }
        else{
            
            [reimbursementCurrencyPickerView setHidden:NO];
            [datePicker setHidden:NO];
            [pickerBackgroundView setHidden:YES];
            [pickerBackgroundView addSubview:datePicker];
            

        }
				
		
	}
	if (selectedPicker==DATE) {
		[self handleDatePicker];
		[self showDatePicker];
	}
	
	if (selectedPicker == REIMBURSEMENT_CURRENCY) {
		[self handleCurrencyPicker];
	}
	
	
}

-(void)handleCurrencyPicker
{
	[self deHeighLightTheCellTapped:DATE_INDEX];
	self.highlightedIndexPath = CURRENCY_INDEX;
	id dateCell = [self getCellForIndexPath:CURRENCY_INDEX];
	[date_reimbursement_tableview selectRowAtIndexPath:CURRENCY_INDEX animated:NO scrollPosition:UITableViewScrollPositionNone];
	[dateCell setCellViewState:YES];
	
	[reimbursementCurrencyPickerView setHidden:NO];
	[pickerBackgroundView setHidden:NO];
	[pickerBackgroundView addSubview:reimbursementCurrencyPickerView];
	[self.view addSubview:pickerBackgroundView];
	[descriptionTextField resignFirstResponder];//DE5806//Juhi
	[datePicker setHidden:YES];
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if ((screenRect.size.height/screenRect.size.width)<=1.5)
    {
        [self moveTableToTop:-55.0];
    }
	
	[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:SHEET_PREVIOUS];
	[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:SHEET_NEXT];
	
}
-(void)handleDatePicker
{
	[self deHeighLightTheCellTapped:CURRENCY_INDEX];
	self.highlightedIndexPath = DATE_INDEX;
	id dateCell = [self getCellForIndexPath:DATE_INDEX];
	[date_reimbursement_tableview selectRowAtIndexPath:DATE_INDEX animated:NO 
										scrollPosition:UITableViewScrollPositionNone];
	[dateCell setCellViewState:YES];
	
	[datePicker setHidden:NO];
	[self.view addSubview:datePicker];
	[descriptionTextField resignFirstResponder];
	[reimbursementCurrencyPickerView setHidden:YES];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
        [pickerBackgroundView setHidden:YES];
	}
    
	[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:SHEET_PREVIOUS];
	[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:SHEET_NEXT];
	
}
-(void)moveTableToTop:(float)y
{
	[self.date_reimbursement_tableview  setFrame:CGRectMake(0.0,y,320.0,225.0)];
}

-(void)showDatePicker
{
	[datePicker addTarget:self
				   action:@selector(updateSelectedDate)
		 forControlEvents:UIControlEventValueChanged];
}
-(void)cancelAction:(id)sender{
	[self dismissViewControllerAnimated:YES completion:nil];
	[tnewExpenseSheetDelegate performSelector:@selector(newSheetIsAdded)];
}


-(void)updateSelectedDate{
	
	//NSDateFormatter *df = [[NSDateFormatter alloc] init];
//	df.dateStyle = NSDateFormatterLongStyle;
	id dateSelected = [G2Util convertPickerDateToString:datePicker.date];
	selectedDate=[NSString stringWithFormat:@"%@", dateSelected];
	
	NSIndexPath *index;
	index = [NSIndexPath indexPathForRow:0 inSection:0];
	cell = (G2ExpenseEntryCellView *)[self.date_reimbursement_tableview cellForRowAtIndexPath:index];
    //[cell.fieldButton setTitleColor:RepliconStandardBlueColor forState:UIControlStateNormal];
	[cell.fieldButton setTitle:selectedDate forState:UIControlStateNormal];
   // [cell.fieldButton setTitleColor:RepliconStandardBlueColor forState:UIControlStateNormal];
	
}
- (void)pickerDone:(UIBarButtonItem *)button{
	if (![descriptionTextField.text isKindOfClass:[NSNull class] ])
    {
        if ([[descriptionTextField text]length] == 0) {
            //		[Util errorAlert:RPLocalizedString(DescriptoinError, DescriptoinError) errorMessage:@""];
            //		return;
            [G2Util errorAlert:@"" errorMessage:RPLocalizedString(DescriptoinError, DescriptoinError)];//DE1231//Juhi
        }
    }
	
	
	[self moveTableToTop:0];
	if (selectedPicker !=0) {
		selectedPicker =0;
	}
	[descriptionTextField resignFirstResponder];
	[reimbursementCurrencyPickerView setHidden:YES];
	[pickerBackgroundView setHidden:YES];
	[datePicker setHidden:YES];
	[keyboardToolbar setHidden:YES];
	
	[self deHeighLightTheCellTapped:highlightedIndexPath];
	
}
-(void)dateAction:(id)sender{
	if (![descriptionTextField.text isKindOfClass:[NSNull class] ])
    {
        if ([[descriptionTextField text]length] == 0) {
            //		[Util errorAlert:RPLocalizedString(DescriptoinError, DescriptoinError) errorMessage:@""];
            [G2Util errorAlert:@"" errorMessage:RPLocalizedString(DescriptoinError, DescriptoinError)];//DE1231//Juhi
            [self deHeighLightTheCellTapped:highlightedIndexPath];highlightedIndexPath=nil;
            return;
        }
    }

	
	if ([sender tag]==DATE) {
		[keyboardToolbar setHidden:NO];
		[self reloadPickerDataForSelectedPicker:[sender tag]];
	}else {
		
	}
	
}
-(void)reimburseCurrencyAction:(id)sender{
	
	if ([sender tag]==REIMBURSEMENT_CURRENCY) {
		[keyboardToolbar setHidden:NO];
		[self reloadPickerDataForSelectedPicker:[sender tag]];
	}else {
		
	}
	
}
- (void)segmentClick:(UISegmentedControl *)segmentControl{
	
	if (segmentControl.selectedSegmentIndex == SHEET_PREVIOUS) {
		[self pickerPrevious:nil];
		
	}
	if (segmentControl.selectedSegmentIndex == SHEET_NEXT) {
		[self pickerNext:nil];
	}
	
}

- (void)pickerPrevious:(UIBarButtonItem *)button{
	
	if (selectedPicker > 0) {
		
		if (selectedPicker == 2) {
			[self deHeighLightTheCellTapped:CURRENCY_INDEX];
			[self  handleDatePicker];
		} 
		if (selectedPicker == 1) {
			[self deHeighLightTheCellTapped:DATE_INDEX];
			
			
			[descriptionTextField becomeFirstResponder];
			[datePicker setHidden:YES];
			[reimbursementCurrencyPickerView setHidden:YES];
			[self moveTableToTop:0.0];	
			[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:SHEET_PREVIOUS];
			[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:SHEET_NEXT];
		}
		
		if (selectedPicker > 0)
			selectedPicker --;
		
	}
}

- (void)pickerNext:(UIBarButtonItem *)button{
	
	
	if (selectedPicker < 1) {
		
		selectedPicker ++;
        if (![descriptionTextField.text isKindOfClass:[NSNull class] ])
        {
            if ([[descriptionTextField text]length] == 0) {
                selectedPicker--;
                //			[Util errorAlert:RPLocalizedString(DescriptoinError, DescriptoinError) errorMessage:@""];
                [G2Util errorAlert:@"" errorMessage:RPLocalizedString(DescriptoinError, DescriptoinError)];//DE1231//Juhi
                return;
            }
        }

		[self reloadPickerDataForSelectedPicker:selectedPicker];
		
	}else if (selectedPicker == 1){

		selectedPicker++;
		[self deHeighLightTheCellTapped:DATE_INDEX];
		//[self hilightTheCellTapped:CURRENCY_INDEX];
		[self handleCurrencyPicker];
	}else if (selectedPicker == 2) {
	}
}


#pragma mark -
#pragma mark Table view data source

//Fix forDE3560//Juhi
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)tableCell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableCell setBackgroundColor:[UIColor whiteColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;	
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	
	if ([tnewExpenseSheetVariables count]>0) {
		return [tnewExpenseSheetVariables count];
	}
	return 1;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;//US4065//Juhi
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 100;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (section == 0) {
		if (sectionHeader == nil) {
			UIView *tempsectionHeader = [[UIView alloc] initWithFrame:CGRectMake(10,30,100,40)];
            self.sectionHeader=tempsectionHeader;
           
		}
		[sectionHeader addSubview:descriptionLabel];
		[sectionHeader addSubview:descriptionTextField];
		[sectionHeader setBackgroundColor:NewExpenseSheetBackgroundColor];
		return sectionHeader;
	}
	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	cell  = (G2ExpenseEntryCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[G2ExpenseEntryCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		//[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	}
	
	//if (indexPath.section == 1) {
	
	if (indexPath.row == 0) {
		[cell addFieldsForNewExpenseSheet: 140.0 height: 38.0];
		
		[cell.fieldName setText:[tnewExpenseSheetVariables objectAtIndex:indexPath.row]];
		[cell.fieldButton setTag:DATE];
		selectedDate=[G2Util convertPickerDateToString:datePicker.date];
		[cell.fieldButton setTitle:selectedDate forState: UIControlStateNormal];
        [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[cell.fieldButton addTarget:self 
							 action:@selector(dateAction:) forControlEvents:UIControlEventTouchUpInside];
		
		
	}
    if (indexPath.row == 1) {
		[cell addFieldsForNewExpenseSheet:140.0 height:38.0];
		[cell.fieldName setFrame:CGRectMake(11.0, 5, 180, 38)];//11.0,5.0,//DE2217
        
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion newFloatValue];
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(127.0, 8.0, 178.0, 30.0);
            
        }
        else{
            frame=CGRectMake(179, 5,110 , 38);
        }
        
		[cell.fieldButton setFrame:frame];
		[cell.fieldName setText:[tnewExpenseSheetVariables objectAtIndex:indexPath.row]];
		[cell.fieldButton setTag:REIMBURSEMENT_CURRENCY];
		
		NSString *selectedCurrencyId = nil;
		if (selectedCurrency == nil) {
			selectedCurrency = [[[supportDataModel getBaseCurrencyFromDatabase]objectAtIndex:0] objectForKey:@"symbol"];
			selectedCurrencyId = [[[supportDataModel getBaseCurrencyFromDatabase]objectAtIndex:0] objectForKey:@"identity"];
		}
		
		if ( reimbursementCurrencyArr!=nil && [reimbursementCurrencyArr count]>0) {
			NSUInteger i, count = [reimbursementCurrencyArr count];
			for (i = 0; i < count; i++) {
				NSDictionary * currenciesDict = [reimbursementCurrencyArr objectAtIndex:i];
				if([[currenciesDict objectForKey:@"identity"] isEqualToString:selectedCurrencyId]) {
					selectedIndex = i;
				}
			}
		}
		
		[cell.fieldButton setTitle:selectedCurrency forState:UIControlStateNormal];
        [cell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
		[cell.fieldButton addTarget:self 
							 action:@selector(reimburseCurrencyAction:) forControlEvents:UIControlEventTouchUpInside];//popUpReimburseCurrencyPicker
		
		[reimbursementCurrencyPickerView reloadComponent:0];
		[reimbursementCurrencyPickerView selectRow:selectedIndex inComponent:0 animated:YES];
	}
	
	
	return cell;
	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	
	
    
	/*if (indexPath != highlightedIndexPath) {
		[self deHeighLightTheCellTapped:highlightedIndexPath];
         
	}*/
	
	[self hilightTheCellTapped:indexPath];
   
}


#pragma mark newCellTappedMethods

-(G2ExpenseEntryCellView*)getCellForIndexPath:(NSIndexPath*)indexPath
{
	G2ExpenseEntryCellView *cellAtIndex = (G2ExpenseEntryCellView *)[self.date_reimbursement_tableview cellForRowAtIndexPath: indexPath]; 
	return cellAtIndex;
}

-(void)hilightTheCellTapped:(NSIndexPath*)indexPath
{
	
	self.highlightedIndexPath = indexPath;
	id cellSelected = [self getCellForIndexPath:indexPath];
	
	//[date_reimbursement_tableview selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	[cellSelected setCellViewState:YES];
	
	if (indexPath.row == dateField_row) {
		[self dateAction:[cellSelected fieldButton]];
	}
	
	if (indexPath.row == currencyField_row) {
		[self reimburseCurrencyAction:[cellSelected fieldButton]];
	}

	
	
}


-(void)deHeighLightTheCellTapped:(NSIndexPath*)indexPath
{
	self.highlightedIndexPath = indexPath;
	id cellSelected = [self getCellForIndexPath:indexPath];
	[date_reimbursement_tableview deselectRowAtIndexPath:indexPath animated:NO];
	[cellSelected setCellViewState:NO];
	
}
#pragma mark -
#pragma mark PickerView Delegates



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (reimbursementCurrencyArr != nil && ![reimbursementCurrencyArr isKindOfClass:[NSNull class]] &&[reimbursementCurrencyArr count]>0)
    {
        selectedCurrency =[[reimbursementCurrencyArr objectAtIndex:row]objectForKey:@"symbol"];
        NSIndexPath *index;
        
        index = [NSIndexPath indexPathForRow:1 inSection:0];
        cell = (G2ExpenseEntryCellView *)[self.date_reimbursement_tableview cellForRowAtIndexPath:index];
        [cell.fieldButton setTitle:selectedCurrency forState:UIControlStateNormal];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr;
	if ([reimbursementCurrencyArr count]>0){
		returnStr = [[reimbursementCurrencyArr objectAtIndex:row] objectForKey:@"symbol"];
		return returnStr;
		
	}
	
	return nil;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	
	if (component == 0){
		return 340.0;	
	}
	
	return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	
	
	if ([reimbursementCurrencyArr count]>0) {
		return [reimbursementCurrencyArr count];
	}
	return 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

#pragma mark UITextField Delegates
#pragma mark -


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
	[keyboardToolbar setHidden:NO];
    CGRect frame=keyboardToolbar.frame;
    frame.origin.y=screenRect.size.height-324;
    keyboardToolbar.frame=frame;
	[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:0];
	[self deHeighLightTheCellTapped:highlightedIndexPath];
	if (selectedPicker == 1)
		selectedPicker = 0;
	//[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:1];
	//DE5806//Juhi
	if (selectedPicker == 2)
		selectedPicker = 0;
    [self moveTableToTop:0.0];
    return YES;
}  

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *textEntered=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if (![textEntered isKindOfClass:[NSNull class] ])
    {
        if ([textEntered length]>0) {
            [self.navigationController.navigationItem.rightBarButtonItem setEnabled:YES];
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmedString = [textEntered stringByTrimmingCharactersInSet:whitespace];
            // Text was empty or only with whitespaces.
            //DE3065 Ullas
            if ([trimmedString length] == 0)
              [saveButton setEnabled:NO];
            else
              [saveButton setEnabled:YES];
        }else {
            [saveButton setEnabled:NO];
        }
    }
	
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	if (selectedPicker !=0) {
		selectedPicker =1;
	}
	[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:1];
}          

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame=keyboardToolbar.frame;
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
        frame.origin.y=screenRect.size.height-301;
        
    }
    else{
       frame.origin.y=screenRect.size.height-320;
    }

    
    keyboardToolbar.frame=frame;
	return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	//DLog(@"textFieldShouldReturn");
	[self pickerNext:nil];
	return YES;
}
-(void)saveAction:(id)sender
{
	if (![NetworkMonitor isNetworkAvailableForListener:self]) {
		[G2Util showOfflineAlert];
		return;
	}
	
	
	NSDate *sheetDate = [G2Util convertStringToDate1:selectedDate];
	
	unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
	//NSCalendar *calendar = [NSCalendar currentCalendar];//DE3171
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; //DE3171
	NSDateComponents *comps = [calendar components:reqFields fromDate:sheetDate];
	
	NSInteger year = [comps year];
	NSInteger month = [comps month];
	NSInteger day = [comps day];
	
	[expenseDetailsDict setObject:[NSNumber numberWithInteger:day] forKey:@"DAY"];
	[expenseDetailsDict setObject:[NSNumber numberWithInteger:month] forKey:@"MONTH"];
	[expenseDetailsDict setObject:[NSNumber numberWithInteger:year] forKey:@"YEAR"];
	[expenseDetailsDict setObject:[descriptionTextField text] forKey:@"description"];
	
	[expenseDetailsDict setObject:@"" forKey:@"trackingNumber"];
	
	[expenseDetailsDict setObject:selectedCurrency forKey:@"reimburseCurrency"];
	[expenseDetailsDict setObject:[[[supportDataModel getIdentityForSelectedCurrency:selectedCurrency] objectAtIndex:0] 
								   objectForKey:@"identity"]
						   forKey:@"identity"];
	
	
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		
		[expensesModel saveExpenseSheetToDataBaseWithDictionary:expenseDetailsDict];
		NSArray *arr = [expensesModel getExpenseSheetsFromDataBase];
		NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
		[standardUserDefaults setObject:arr forKey:@"expenseSheetsArray"];
		 [standardUserDefaults synchronize];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ExpenseSheetEnableNotification"
															object:nil];
		[self dismissViewControllerAnimated:YES completion:nil];
	}else {
		
		[self dismissViewControllerAnimated:YES completion:nil];
		[[G2RepliconServiceManager expensesService]sendRequestToCreateNewExpenseSheet:expenseDetailsDict delegate:self];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
	}
	
	[keyboardToolbar setHidden:YES];
	[descriptionTextField resignFirstResponder];
	[datePicker setHidden:YES];
	[reimbursementCurrencyPickerView setHidden:YES];
	
}

#pragma mark -
#pragma mark ServerProtocolMethods
#pragma mark -

-(void)handleExpenseSheetSaveResponse:(id) response {
	
	[tnewExpenseSheetDelegate performSelector:@selector(newSheetIsAdded)];
	
	[expensesModel insertExpenseSheetsInToDataBase:response];
	NSString *sheetId = [[response objectAtIndex:0] objectForKey:@"Identity"];
	NSString *reimburseCurrency = [expenseDetailsDict objectForKey:@"reimburseCurrency"];
	[expensesModel updateReimbursmentCurrencyForExpenseSheet:reimburseCurrency :sheetId];
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
	NSMutableArray *expenseSheetArray=[expensesModel getExpenseSheetsFromDataBase];
	[standardUserDefaults setObject:expenseSheetArray forKey: @"expenseSheetsArray"];
     [standardUserDefaults synchronize];
	/*[[NSNotificationCenter defaultCenter] postNotificationName:@"ExpenseEntriesEnableNotification"
														object:expenseSheetArray];*/
	[tnewExpenseSheetDelegate performSelector:@selector(gotoExpenseSheetFirstEntry:) withObject:nil];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) serverDidRespondWithResponse:(id) response {
	
	if (response!=nil) {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if ([status isEqualToString:@"OK"]) {
			
			if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == SaveExpenseSheet_27) {
				
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				if (responseArray!=nil && [responseArray count]>0) {
					[self handleExpenseSheetSaveResponse:responseArray];
					[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				}
			}
		}else {
			NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
//			[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//DE1231//Juhi
		}
	}
	
}
- (void) serverDidFailWithError:(NSError *) error {
	
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
			[G2Util showOfflineAlert];
		return;
	}
	
    [self showErrorAlert:error];

	return;
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
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:self
                                                    message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                      title:nil
                                                        tag:SAML_SESSION_TIMEOUT_TAG];
        }
        else 
        {
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED) ];
        }
       
    }
    else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
        [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(G2PASSWORD_EXPIRED, G2PASSWORD_EXPIRED) ];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    else
    {
        [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
    }
}


#pragma mark NetworkMonitor
-(void) networkActivated {
	//do nothing
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
    self.saveButton=nil;
    self.descriptionTextField=nil;
    self.date_reimbursement_tableview=nil;
    self.nextPreviousControl=nil;
    self.reimbursementCurrencyPickerView=nil;
    self.pickerViewC=nil;
    self.toolbarSegmentControl=nil;
    self.descriptionLabel=nil;
    self.datePicker=nil;
    self.pickerBackgroundView=nil;
    self.keyboardToolbar=nil;
    self.sectionHeader=nil;
}





@end

