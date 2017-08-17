//
//  NewExpenseSheetViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "NewExpenseSheetViewController.h"
#import "Util.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+Additions.h"
#import "ListOfExpenseSheetsViewController.h"
@implementation NewExpenseSheetViewController

@synthesize	tnewExpenseSheetDelegate;
@synthesize descriptionTextField;
@synthesize date_reimbursement_tableview;
@synthesize tnewExpenseSheetVariables;

@synthesize saveButton;
@synthesize reimbursementCurrencyArr;
@synthesize reimbursementCurrencyPickerView;
@synthesize selectedDate;
@synthesize selectedCurrency;
@synthesize  highlightedIndexPath;
@synthesize  pickerViewC;

@synthesize datePicker;
@synthesize  pickerBackgroundView;
@synthesize  keyboardToolbar;
@synthesize sectionHeader;

static int descField_row= 0;
static int dateField_row = 1;
static int currencyField_row = 2;
#define DATE_INDEX  [NSIndexPath indexPathForRow:dateField_row inSection:0]
#define CURRENCY_INDEX  [NSIndexPath indexPathForRow:currencyField_row inSection:0]
#define toolbar_Y 264

#pragma mark -
#pragma mark Initialization

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self.view setBackgroundColor:RepliconStandardBackgroundColor];
					
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Cancel_Button_Title, Cancel_Button_Title)
																		 style: UIBarButtonItemStylePlain
																		target: self action:@selector(cancelAction:)];
		[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
		
		
		UIBarButtonItem *tempsaveButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Save_Button_Title, Save_Button_Title)
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(saveAction:)];
        self.saveButton=tempsaveButton;
        
		[self.navigationItem setRightBarButtonItem:saveButton animated:NO];
		[saveButton setTag:2];
		[saveButton setEnabled:NO];
        
        NSMutableArray *tempReimbursementCurrencyArr=[[NSMutableArray alloc]init];
        self.reimbursementCurrencyArr=tempReimbursementCurrencyArr;
        
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)loadView
{
	[super loadView];
	
	[Util setToolbarLabel:self withText: RPLocalizedString(@"New Expense Sheet",@"New Expense sheet")];
	
	//Add Date-Reimburse Table
	if (date_reimbursement_tableview == nil) {
		UITableView *tempdate_reimbursement_tableview = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                                                      0.0,
                                                                                                      self.view.frame.size.width,
                                                                                                      225.0) style:UITableViewStylePlain];
        self.date_reimbursement_tableview=tempdate_reimbursement_tableview;
        self.date_reimbursement_tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
        
	}
	[date_reimbursement_tableview setScrollEnabled:NO];
	[date_reimbursement_tableview setBackgroundColor:RepliconStandardBackgroundColor];
    date_reimbursement_tableview.backgroundView=nil;
	[date_reimbursement_tableview setDelegate:self];
	[date_reimbursement_tableview setDataSource:self];
	[self.view addSubview:date_reimbursement_tableview];
	

	
	//Add Description Textfield.
	if (descriptionTextField==nil) {
		UITextField *tempdescriptionTextField = [[UITextField alloc] initWithFrame:CGRectMake(10,8.0,CGRectGetWidth(self.view.bounds)-20,37.0)];
        self.descriptionTextField=tempdescriptionTextField;
       
	}
	
    
    descriptionTextField.font=[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14];

    descriptionTextField.placeholder=RPLocalizedString(Description_PlaceHolder, Description_PlaceHolder);
	[descriptionTextField setDelegate:self];
	[descriptionTextField setTextAlignment:NSTextAlignmentLeft];
	[descriptionTextField setHighlighted:YES];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    descriptionTextField.leftView = paddingView;
    descriptionTextField.leftViewMode = UITextFieldViewModeAlways;
	[descriptionTextField setBorderStyle:UITextBorderStyleNone];
    [descriptionTextField.layer setBorderColor:[[Util colorWithHex:@"#CCCCCC" alpha:1] CGColor]];
    [descriptionTextField.layer setBorderWidth: 1.5];
    [descriptionTextField.layer setCornerRadius:9.0f];
    [descriptionTextField.layer setMasksToBounds:YES];
    descriptionTextField.clipsToBounds = YES;
    descriptionTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    descriptionTextField.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
	[descriptionTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[descriptionTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
	[descriptionTextField setReturnKeyType:UIReturnKeyDone];
    descriptionTextField.enablesReturnKeyAutomatically = YES;
	[descriptionTextField setBackgroundColor:[UIColor whiteColor]];
	[descriptionTextField becomeFirstResponder];
	
	if (tnewExpenseSheetVariables == nil) {
		tnewExpenseSheetVariables = [[NSArray alloc] initWithObjects:@"",RPLocalizedString(@"Filing Date", @"") ,RPLocalizedString(@"Reimbursement Currency", @"") ,nil];//DE2217
	}

	//add date picker
	if (datePicker == nil) {
        
		UIDatePicker *tempdatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
        self.datePicker=tempdatePicker;
        
	}
    
    if (pickerBackgroundView == nil) {
        UIView *temppickerBackgroundView = [UIView new];
        self.pickerBackgroundView=temppickerBackgroundView;
    }
    [self.pickerBackgroundView setFrame:CGRectMake(0.0, self.view.height-self.datePicker.height, self.view.width, self.datePicker.height)];
    
    datePicker.frame = (CGRect){self.pickerBackgroundView.position,self.pickerBackgroundView.size};
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    datePicker.hidden = YES;
    datePicker.date = [NSDate date];
	
	if (reimbursementCurrencyPickerView == nil) {
		UIPickerView *tempreimbursementCurrencyPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.reimbursementCurrencyPickerView=tempreimbursementCurrencyPickerView;
       
	}

	reimbursementCurrencyPickerView.frame = (CGRect){CGPointZero,self.pickerBackgroundView.size};
	reimbursementCurrencyPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	reimbursementCurrencyPickerView.delegate = self;
	reimbursementCurrencyPickerView.showsSelectionIndicator = YES;
	[reimbursementCurrencyPickerView setHidden:YES];
	[pickerBackgroundView addSubview:reimbursementCurrencyPickerView];
	
	
	//Set Current Date
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormat setLocale:locale];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[dateFormat setDateFormat:@"MMMM dd,yyyy"];
	NSDate *currentDate = [NSDate date];
	self.selectedDate = [dateFormat stringFromDate:currentDate];
	NSIndexPath *index;
	index = [NSIndexPath indexPathForRow:DATE-1 inSection:0];
	cell = (ExpenseEntryCustomCell *)[self.date_reimbursement_tableview cellForRowAtIndexPath:index];
	[cell.fieldButton setText:selectedDate];
	
	
	[self configurePicker];
	
}

#pragma mark -
#pragma mark View lifecycle


-(void)configurePicker{

    CGFloat heightOfToolBar=50;
	UIToolbar *tempkeyboardToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0,self.datePicker.y-heightOfToolBar, self.view.width, heightOfToolBar)];


    
    self.keyboardToolbar=tempkeyboardToolbar;
   
	keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
	
	
		
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				target:self
																				action:@selector(pickerDone:)];
	
	UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				 target:nil
																				 action:nil];
	NSArray *toolArray = [NSArray arrayWithObjects:
						  spaceButton,
						  doneButton,
						  nil];
	[keyboardToolbar setItems:toolArray];
	
    doneButton.tintColor=RepliconStandardWhiteColor;
    UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
    [keyboardToolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [keyboardToolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
	[pickerBackgroundView setHidden:YES];
	[self.view addSubview:pickerBackgroundView];
	[self.view addSubview:keyboardToolbar];

	
}

- (void)reloadPickerDataForSelectedPicker:(NSInteger)_selectedPicker{
	
	selectedPicker =_selectedPicker;
	if (selectedPicker==KEYBOARD) {
		[reimbursementCurrencyPickerView setHidden:NO];
		[datePicker setHidden:NO];
		[pickerBackgroundView setHidden:YES];
		[pickerBackgroundView addSubview:datePicker];
		
		
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
	
	self.highlightedIndexPath = CURRENCY_INDEX;
	

	
	
	[reimbursementCurrencyPickerView setHidden:NO];
	[pickerBackgroundView setHidden:NO];
	[pickerBackgroundView addSubview:reimbursementCurrencyPickerView];
	[self.view addSubview:pickerBackgroundView];
	[descriptionTextField resignFirstResponder];//DE5806//Juhi
	[datePicker setHidden:YES];

    [reimbursementCurrencyPickerView reloadAllComponents];
	
}
-(void)handleDatePicker
{
	
	self.highlightedIndexPath = DATE_INDEX;
	

	[datePicker setHidden:NO];
	[self.view addSubview:datePicker];
	[descriptionTextField resignFirstResponder];
	[reimbursementCurrencyPickerView setHidden:YES];		
}


-(void)showDatePicker
{
	[datePicker addTarget:self
				   action:@selector(updateSelectedDate)
		 forControlEvents:UIControlEventValueChanged];
}
-(void)cancelAction:(id)sender{
    
    CLS_LOG(@"-----Cancel action on NewExpenseSheetViewController-----");
	[self dismissViewControllerAnimated:YES completion:nil];
	
}


-(void)updateSelectedDate{
	
	//NSDateFormatter *df = [[NSDateFormatter alloc] init];
    //	df.dateStyle = NSDateFormatterLongStyle;
	id dateSelected = [Util convertPickerDateToString:datePicker.date];
	self.selectedDate=[NSString stringWithFormat:@"%@", dateSelected];
	
	NSIndexPath *index;
	index = [NSIndexPath indexPathForRow:dateField_row inSection:0];
	cell = (ExpenseEntryCustomCell *)[self.date_reimbursement_tableview cellForRowAtIndexPath:index];
	[cell.fieldButton setText:selectedDate];
}
- (void)pickerDone:(UIBarButtonItem *)button{
	if (selectedPicker !=0) {
		selectedPicker =0;
	}
	[descriptionTextField resignFirstResponder];
	[reimbursementCurrencyPickerView setHidden:YES];
	[pickerBackgroundView setHidden:YES];
	[datePicker setHidden:YES];
	[keyboardToolbar setHidden:YES];
    [self.date_reimbursement_tableview deselectRowAtIndexPath:self.highlightedIndexPath animated:NO];
	
	
	
}
-(void)dateAction:(id)sender{
	if ([sender tag]==DATE) {
		[keyboardToolbar setHidden:NO];
		[self reloadPickerDataForSelectedPicker:[sender tag]];
	}else {
		
	}
	
}
-(void)reimburseCurrencyAction:(id)sender{
    
	if ([sender tag]==REIMBURSEMENT_CURRENCY) {
        
        if (![NetworkMonitor isNetworkAvailableForListener:self])
        {
            [Util showOfflineAlert];
            return;
        }
        else
        {
            selectedPicker =[sender tag];
            
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updateCurrencyAfterDownloading)
                                                         name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION
                                                       object:nil];
            //Implemented as per US8683//JUHI
            ExpenseModel *expensesModel=[[ExpenseModel alloc]init];
            NSMutableArray *array=[expensesModel getSystemCurrenciesFromDatabase];
           
            if ([array count]>0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            }
            else
            [[RepliconServiceManager expenseService]fetchExpenseCurrencyAndPaymentMethodDatawithDelegate:self];
        }
        
		
	}


	
}


-(void)updateCurrencyAfterDownloading
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    ExpenseModel *expensesModel=[[ExpenseModel alloc]init];  
    self.reimbursementCurrencyArr=[expensesModel getSystemCurrenciesFromDatabase];
    
    [keyboardToolbar setHidden:NO];
    [self reloadPickerDataForSelectedPicker:selectedPicker];
    
    
    UILabel *currencyLbl=[(ExpenseEntryCustomCell *)[self. date_reimbursement_tableview cellForRowAtIndexPath:CURRENCY_INDEX] fieldButton ];
    NSString *defaultCurrencyName=currencyLbl.text;
    int selProjIndex = [Util getObjectIndex:self.reimbursementCurrencyArr withKey:@"currenciesName" forValue:defaultCurrencyName];
    if(selProjIndex > -1 )
    {
        [self pickerView:reimbursementCurrencyPickerView didSelectRow:selProjIndex inComponent:0];
        [self.reimbursementCurrencyPickerView selectRow: selProjIndex inComponent:0 animated: NO];
    }
    else
    {
        if ([reimbursementCurrencyArr count]>0)
        {
            [self pickerView:reimbursementCurrencyPickerView didSelectRow:0 inComponent:0];
            [self.reimbursementCurrencyPickerView selectRow: 0 inComponent:0 animated: NO];
        }
       
    }
    
   
}


#pragma mark -
#pragma mark Table view data source

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
	return 53.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 0.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

	return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat LeadingTrailingPaddingForCell = 20.0f;
	static NSString *CellIdentifier = @"Cell";
    CGFloat width = CGRectGetWidth(self.view.frame);
	cell  = (ExpenseEntryCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {

        cell = [[ExpenseEntryCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier width:width];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
	}
	
	//if (indexPath.section == 1) {
    
    
    for (UIView *subview in cell.contentView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    if (indexPath.row == 0)
    {
        [cell.contentView addSubview:self.descriptionTextField];
        
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
	
	else if (indexPath.row == 1) {
		[cell addFieldsForNewExpenseSheet:(width-(2 * LeadingTrailingPaddingForCell))/2 height: 50.0];
        
		
		[cell.fieldName setText:[tnewExpenseSheetVariables objectAtIndex:indexPath.row]];
		[cell.fieldButton setTag:DATE];
		self.selectedDate=[Util convertPickerDateToString:datePicker.date];
		[cell.fieldButton setText:selectedDate];

		
		
	}else if (indexPath.row == 2) {
		[cell addFieldsForNewExpenseSheet:(width-(2 * LeadingTrailingPaddingForCell))/2 height:50.0];
		[cell.fieldName setFrame:CGRectMake(11.0, 3, (width-(2 * LeadingTrailingPaddingForCell))/2, 50)];
		[cell.fieldName setText:[tnewExpenseSheetVariables objectAtIndex:indexPath.row]];
		[cell.fieldButton setTag:REIMBURSEMENT_CURRENCY];
		
		NSString *selectedCurrencyId = nil;
		if (selectedCurrency == nil) {
            LoginModel *loginModel=[[LoginModel alloc]init];
            NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];
           
            if ([userDetailsArray count]!=0)
            {
                NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
                NSString *baseCurrencyName=[userDict objectForKey:@"baseCurrencyName"];
                NSString *baseCurrencyUri=[userDict objectForKey:@"baseCurrencyUri"];
                
                if (baseCurrencyName!=nil && baseCurrencyUri!=nil && ![baseCurrencyName isKindOfClass:[NSNull class]] && ![baseCurrencyUri isKindOfClass:[NSNull class]] )
                {
                    selectedCurrency = baseCurrencyName;
                    selectedCurrencyId = baseCurrencyUri;
                    NSMutableDictionary *baseCurrencyDict=[NSMutableDictionary dictionary];
                    [baseCurrencyDict setObject:baseCurrencyName forKey:@"currenciesName"];
                    [baseCurrencyDict setObject:baseCurrencyUri forKey:@"currenciesUri"];
                    [self.reimbursementCurrencyArr addObject:baseCurrencyDict];
                    
                }
                else
                {
                    selectedCurrency = RPLocalizedString(SELECT_STRING, SELECT_STRING);
                }
                
            }
            

		}
		
		if ( reimbursementCurrencyArr!=nil && [reimbursementCurrencyArr count]>0) {
			NSUInteger i, count = [reimbursementCurrencyArr count];
			for (i = 0; i < count; i++) {
				NSDictionary * currenciesDict = [reimbursementCurrencyArr objectAtIndex:i];
				if([[currenciesDict objectForKey:@"currenciesUri"] isEqualToString:selectedCurrencyId]) {
					selectedIndex = i;
				}
			}
		}
		
		[cell.fieldButton setText:selectedCurrency];
		
		[reimbursementCurrencyPickerView reloadComponent:0];
		[reimbursementCurrencyPickerView selectRow:selectedIndex inComponent:0 animated:YES];
	}
	
    //CELL SEPARATOR IMAGE VIEW
    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
	UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 52, width,lowerImage.size.height)];
    [lineImageView setImage:lowerImage];
    [cell.contentView bringSubviewToFront:lineImageView];
	[cell.contentView addSubview:lineImageView];

	
	return cell;
	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	

	
	[self hilightTheCellTapped:indexPath];
    
}


#pragma mark newCellTappedMethods

-(ExpenseEntryCustomCell*)getCellForIndexPath:(NSIndexPath*)indexPath
{
	ExpenseEntryCustomCell *cellAtIndex = (ExpenseEntryCustomCell *)[self.date_reimbursement_tableview cellForRowAtIndexPath: indexPath];
	return cellAtIndex;
}

-(void)hilightTheCellTapped:(NSIndexPath*)indexPath
{
	
	self.highlightedIndexPath = indexPath;
	id cellSelected = [self getCellForIndexPath:indexPath];
	
	
	
    if (indexPath.row == descField_row) {
		
	}
    
	else if (indexPath.row == dateField_row) {
		[self dateAction:[cellSelected fieldButton]];
	}
	
	else if (indexPath.row == currencyField_row) {
		[self reimburseCurrencyAction:[cellSelected fieldButton]];
	}
	
}



#pragma mark -
#pragma mark PickerView Delegates



- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (reimbursementCurrencyArr != nil && ![reimbursementCurrencyArr isKindOfClass:[NSNull class]] &&[reimbursementCurrencyArr count]>0)
    {
        selectedCurrency =[[reimbursementCurrencyArr objectAtIndex:row]objectForKey:@"currenciesName"];
        NSIndexPath *index;
        
        index = [NSIndexPath indexPathForRow:currencyField_row inSection:0];
        cell = (ExpenseEntryCustomCell *)[self.date_reimbursement_tableview cellForRowAtIndexPath:index];
        [cell.fieldButton setText:selectedCurrency];
        selectedIndex=row;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr;
    if (reimbursementCurrencyArr != nil && ![reimbursementCurrencyArr isKindOfClass:[NSNull class]] &&[reimbursementCurrencyArr count]>0)
    {
		returnStr = [[reimbursementCurrencyArr objectAtIndex:row] objectForKey:@"currenciesName"];
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

- (NSInteger)pickerView:(UIPickerView *)pickerViews numberOfRowsInComponent:(NSInteger)component
{
	if ([reimbursementCurrencyArr count]>0)
    {
        [pickerViews setUserInteractionEnabled:YES];
    }
    else
    {
        [pickerViews setUserInteractionEnabled:NO];
    }

	
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
	[keyboardToolbar setHidden:YES];
	
	if (selectedPicker == 1)
		selectedPicker = 0;
	if (selectedPicker == 2)
		selectedPicker = 0;

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
   [keyboardToolbar setHidden:YES];
    [self.date_reimbursement_tableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:descField_row inSection:0] animated:FALSE scrollPosition:UITableViewScrollPositionNone];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	//DLog(@"textFieldShouldReturn");
    [self pickerDone:nil];
	return YES;
}
-(void)saveAction:(id)sender
{
	if (![NetworkMonitor isNetworkAvailableForListener:self]) {
		[Util showOfflineAlert];
		return;
	}
	CLS_LOG(@"-----Save action on NewExpenseSheetViewController-----");
    ExpenseEntryCustomCell *entryCell=(ExpenseEntryCustomCell *)[self.date_reimbursement_tableview cellForRowAtIndexPath:CURRENCY_INDEX];
    if ([entryCell.fieldButton.text isEqualToString:RPLocalizedString(SELECT_STRING, SELECT_STRING)])
    {
        [Util errorAlert:@"" errorMessage:RPLocalizedString(DateError, DateError)];
        [self.date_reimbursement_tableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:descField_row inSection:0] animated:FALSE scrollPosition:UITableViewScrollPositionNone];
         return;
    }
    
	NSDate *sheetDate = [Util convertStringToPickerDate:selectedDate];
    NSDictionary *dateDict=[Util convertDateToApiDateDictionary:sheetDate];

    NSMutableDictionary *expenseDetailsDict=[NSMutableDictionary dictionary];
    
	[expenseDetailsDict setObject:dateDict forKey:@"date"];
    
    if ([self.reimbursementCurrencyArr count] > 0) {
        NSString *curremciesUri = [[self.reimbursementCurrencyArr objectAtIndex:selectedIndex] objectForKey:@"currenciesUri"];
        if (curremciesUri != nil && ![curremciesUri isKindOfClass:[NSNull class]]) {
            
            [expenseDetailsDict setObject:[descriptionTextField text] forKey:@"description"];
            [expenseDetailsDict setObject:curremciesUri forKey:@"reimbursementCurrencyUri"];
            
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            
            [[RepliconServiceManager expenseService]sendRequestToCreateNewExpensesDataForExpenseURIForExpenseSheetDict:expenseDetailsDict withDelegate:self];
        }
    }
	
	[keyboardToolbar setHidden:YES];
	[descriptionTextField resignFirstResponder];
	[datePicker setHidden:YES];
	[reimbursementCurrencyPickerView setHidden:YES];
	
    [self.date_reimbursement_tableview deselectRowAtIndexPath:self.highlightedIndexPath animated:TRUE];
}

#pragma mark -
#pragma mark ServerProtocolMethods
#pragma mark -

- (void) serverDidRespondWithResponse:(id) response {
	
   if (response!=nil)
   {
       NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
       
       if (errorDict!=nil)
       {
           
           BOOL isErrorThrown=FALSE;
           
           
           NSArray *notificationsArr=[[errorDict objectForKey:@"details"] objectForKey:@"notifications"];
           NSString *errorMsg=@"";
           for (int i=0; i<[notificationsArr count]; i++)
           {
               
               NSDictionary *notificationDict=[notificationsArr objectAtIndex:i];
               if (![errorMsg isEqualToString:@""])
               {
                   errorMsg=[NSString stringWithFormat:@"%@\n%@",errorMsg,[notificationDict objectForKey:@"displayText"]];
                   isErrorThrown=TRUE;
               }
               else
               {
                   errorMsg=[NSString stringWithFormat:@"%@",[notificationDict objectForKey:@"displayText"]];
                   isErrorThrown=TRUE;
                   
               }
           }
           
           if (!isErrorThrown)
           {
               errorMsg=[[errorDict objectForKey:@"details"] objectForKey:@"displayText"];
               
           }
           
           if (errorMsg!=nil && ![errorMsg isKindOfClass:[NSNull class]])
           {
               [Util errorAlert:@"" errorMessage:errorMsg];
           }
           else
           {
               [Util errorAlert:@"" errorMessage:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)];
               NSString *serviceURL = [response objectForKey:@"serviceURL"];
               [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
           }
           
           
       }
       else
       {
            NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
           [self handleReceivedData:responseDict];
           
           NSMutableDictionary *expenseEntryDetailsDict=[responseDict objectForKey:@"details"];
           NSString *expenseSheetUri=[expenseEntryDetailsDict objectForKey:@"uri"];
           [tnewExpenseSheetDelegate performSelector:@selector(gotoExpenseSheetEntry:) withObject:expenseSheetUri];
           [self dismissViewControllerAnimated:YES completion:nil];
       }
   }
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    
    
    
	
}
- (void) serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState {
	
		
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
	
    if (applicationState == Foreground)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;
        }
        else
        {
            [Util handleNSURLErrorDomainCodes:error];
        }
    }
    
	

	return;
 
}

-(void)handleReceivedData:(NSMutableDictionary *)responseDict
{
    NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
    NSMutableDictionary *expenseEntryDetailsDict=[responseDict objectForKey:@"details"];
    NSString *expenseSheetUri=[expenseEntryDetailsDict objectForKey:@"uri"];
    SQLiteDB *myDB = [SQLiteDB getInstance];
       
    NSString*statusUri=[[[responseDict objectForKey:@"approvalDetails"] objectForKey:@"approvalStatus"] objectForKey:@"uri"];
    
    NSString*status=nil;
    
    
    if ([statusUri isEqualToString:APPROVED_STATUS_URI])
    {
        status=APPROVED_STATUS;
    }
    else if ([statusUri isEqualToString:NOT_SUBMITTED_STATUS_URI])
    {
        status=NOT_SUBMITTED_STATUS;
    }
    else if ([statusUri isEqualToString:WAITING_FOR_APRROVAL_STATUS_URI])
    {
        status=WAITING_FOR_APRROVAL_STATUS;
    }
    else if ([statusUri isEqualToString:REJECTED_STATUS_URI])
    {
        status=REJECTED_STATUS;
    }
    
    
    NSString *description=[expenseEntryDetailsDict objectForKey:@"description"];
    if (description!=nil && ![description isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:description forKey:@"description"];
    }
    
    
    NSDictionary *expenseDateDict=[expenseEntryDetailsDict objectForKey:@"date"];
    NSDate *expenseDate=[Util convertApiDateDictToDateFormat:expenseDateDict];
    NSNumber *expenseDateToStore=[NSNumber numberWithDouble:[expenseDate timeIntervalSince1970]];
    if (expenseDateToStore!=nil && ![expenseDateToStore isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:expenseDateToStore forKey:@"expenseDate"];
    }

    
    
    if (status!=nil && ![status isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:status forKey:@"approvalStatus"];
    }
    if (expenseSheetUri!=nil && ![expenseSheetUri isKindOfClass:[NSNull class]])
    {
        [dataDict setObject:expenseSheetUri forKey:@"expenseSheetUri"];
    }
 
    

        NSMutableDictionary *incurredAmountTotalDict=[expenseEntryDetailsDict objectForKey:@"incurredAmountTotal"];
        if (incurredAmountTotalDict!=nil)
        {
            NSString *incurredAmount=[Util getRoundedValueFromDecimalPlaces:[[incurredAmountTotalDict objectForKey:@"amount"] newDoubleValue]withDecimalPlaces:2];
            NSString *incurredAmountCurrencyName=[[incurredAmountTotalDict objectForKey:@"currency"] objectForKey:@"displayText"];
            NSString *incurredAmountCurrencyUri=[[incurredAmountTotalDict objectForKey:@"currency"] objectForKey:@"uri"];
      
            if (incurredAmount!=nil && ![incurredAmount isKindOfClass:[NSNull class]])
            {
                 [dataDict setObject:incurredAmount forKey:@"incurredAmount"];
            }
           
            if (incurredAmountCurrencyName!=nil && ![incurredAmountCurrencyName isKindOfClass:[NSNull class]])
            {
                 [dataDict setObject:incurredAmountCurrencyName forKey:@"incurredAmountCurrencyName"];
            }
           
            if (incurredAmountCurrencyUri!=nil && ![incurredAmountCurrencyUri isKindOfClass:[NSNull class]])
            {
                 [dataDict setObject:incurredAmountCurrencyUri forKey:@"incurredAmountCurrencyUri"];
            }
           

        }
        
        NSDictionary *reimbursementAmountTotalDict=[expenseEntryDetailsDict objectForKey:@"reimbursementAmountTotal"];
        if (reimbursementAmountTotalDict!=nil)
        {
            NSString *reimbursementAmount=[Util getRoundedValueFromDecimalPlaces:[[reimbursementAmountTotalDict objectForKey:@"amount"] newDoubleValue]withDecimalPlaces:2];;
            NSString *reimbursementAmountCurrencyName=[[reimbursementAmountTotalDict objectForKey:@"currency"] objectForKey:@"displayText"];
            NSString *reimbursementAmountCurrencyUri=[[reimbursementAmountTotalDict objectForKey:@"currency"] objectForKey:@"uri"];

            if (reimbursementAmount!=nil && ![reimbursementAmount isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:reimbursementAmount forKey:@"reimbursementAmount"];
            }
            
            if (reimbursementAmountCurrencyName!=nil && ![reimbursementAmountCurrencyName isKindOfClass:[NSNull class]])
            {
                 [dataDict setObject:reimbursementAmountCurrencyName forKey:@"reimbursementAmountCurrencyName"];
            }
           
            if (reimbursementAmountCurrencyUri!=nil && ![reimbursementAmountCurrencyUri isKindOfClass:[NSNull class]])
            {
                [dataDict setObject:reimbursementAmountCurrencyUri forKey:@"reimbursementAmountCurrencyUri"];
            }
            
            
        }
    
    
   
    if ([expenseEntryDetailsDict objectForKey:@"trackingNumber"]!=nil&&![[expenseEntryDetailsDict objectForKey:@"trackingNumber"]isKindOfClass:[NSNull class]])
    {
        NSString *trackingNumber=[expenseEntryDetailsDict objectForKey:@"trackingNumber"];
        [dataDict setObject:trackingNumber forKey:@"trackingNumber"];
        
        
    }
    
        [myDB insertIntoTable:@"ExpenseSheets" data:dataDict intoDatabase:@""];
    }
    


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  
}

-(void)showErrorAlert:(NSError *) error
{
/*
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
            [Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED) ];
        }
        
    }
    else  if ([appdelegate.errorMessageForLogging isEqualToString:PASSWORD_EXPIRED]) {
        [Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(PASSWORD_EXPIRED, PASSWORD_EXPIRED) ];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    else
    {
        [Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
    }
*/
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
   
    self.reimbursementCurrencyPickerView=nil;
    self.pickerViewC=nil;
    
    self.datePicker=nil;
    self.pickerBackgroundView=nil;
    self.keyboardToolbar=nil;
    self.sectionHeader=nil;
}

- (void)dealloc
{
    self.date_reimbursement_tableview.delegate = nil;
    self.date_reimbursement_tableview.dataSource = nil;
}


@end

