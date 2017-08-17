#import "AmountViewController.h"
#import "Constants.h"
#import "Util.h"
#import "ExpenseModel.h"
#import "AmountCellView.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ExpenseEntryViewController.h"
#import "RepliconServiceManager.h"
#import "Fonts-iPhone.h"
#import "Colors-iPhone.h"
#import "UIView+Additions.h"

@implementation AmountViewController
@synthesize scrollView;
@synthesize amountTableView;
@synthesize expenseType;
@synthesize flatExpenseFieldsArray;
@synthesize ratedLablesArray;
@synthesize expenseTaxesInfoArray;
@synthesize fieldValuesArray;
@synthesize ratedExpenseArray;
@synthesize defaultValuesArray;
@synthesize pickerDataSourceArray;
@synthesize addRateAndAmountLables;
@synthesize taxesLablesArray;
@synthesize currencyLabel;
@synthesize currencyTappedButton;
@synthesize currencyValueLabel;
@synthesize rateTappedButton;
@synthesize ratedBaseCurrency;
@synthesize ratedLabel;
@synthesize ratedValueLable;
@synthesize ratedTaxesLabel;
@synthesize ratedTaxValueLable;
@synthesize ratedValuesArray;
@synthesize footerViewAmount;
@synthesize totalAmountLabel;
@synthesize totalAmountValue;
@synthesize rate;
@synthesize amountValueEntered;
@synthesize isAmountEdit;
@synthesize kilometerUnitValue;
@synthesize textFieldSelected;
@synthesize selectedIndexPath;
@synthesize buttonTitle;
@synthesize inEditState;
@synthesize pickerView;
@synthesize toolbar;
@synthesize doneButton;
@synthesize spaceButton;
@synthesize amountControllerDelegate;
@synthesize canNotEdit;
@synthesize selectedCurrencyUri;
@synthesize numberKeyPad;

static int tag_Taxes = 1000;
static CGFloat viewheightWithTable;
static int amountField_Tag = 1;
static int ratedField_Tag = 100;
static int  ratedWithTaxes_Tag = 200;
static BOOL  taxAmountEdited = NO;
static float keyBoardHeight=260.0;

#define PICKER_ROW_HEIGHT 40
#define Toolbar_Height 45
#define CELL_HEIGHT 44
#define HEADER_HEIGHt 30
#define SPACE_FIELD 10
#define HEADER_HEIGHT 40.0
#define TOTAL_AMOUNT_LABEL_HEIGHT 40.0
#define GAP_FROM_TOTAL_TO_BOTTOM 30.0
#define TABLE_ROW_HEIGHT 44.0
#define LABEL_HEIGHT 30.0
#define GAP_FROM_AMOUNT_TO_TAXFIELDS 30.0
#define FOOTER_VIEW_HEIGHT 40
#define RATE_AMOUNT_CURRECY_FIELD_COUNT 3
#define PICKER_VIEW_TAG_AMOUNT_VIEW 888
#pragma mark -
#pragma mark View lifeCycle Methods

-(void)initializeView
{
    NSInteger sectionsNumber = [self getNumberofSectionsInTableView:expenseType];
    for (NSInteger i = 0; i < sectionsNumber; i++) {

        NSInteger numberOfRowsInTable = [self getNumberOfRowsInSection:i
                                                               andType:expenseType];

        if ([expenseType isEqualToString:Flat_With_Taxes] || [expenseType isEqualToString:Flat_WithOut_Taxes])
        {
            totalRows += numberOfRowsInTable;
        }
        else
        {
            totalRows = numberOfRowsInTable;
        }
    }

    tableHeight = totalRows * CELL_HEIGHT + sectionsNumber * HEADER_HEIGHt + 52;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.delegate = self;

    if ([expenseType isEqualToString:Flat_With_Taxes] || [expenseType isEqualToString:Flat_WithOut_Taxes])
    {
        scrollHeight = totalRows * TABLE_ROW_HEIGHT + sectionsNumber * HEADER_HEIGHT + TOTAL_AMOUNT_LABEL_HEIGHT + GAP_FROM_TOTAL_TO_BOTTOM + Toolbar_Height * 2;
    }
    else
    {
        scrollHeight = totalRows * TABLE_ROW_HEIGHT + sectionsNumber * HEADER_HEIGHT + RATE_AMOUNT_CURRECY_FIELD_COUNT * LABEL_HEIGHT + GAP_FROM_AMOUNT_TO_TAXFIELDS + [expenseTaxesInfoArray count] * LABEL_HEIGHT + TOTAL_AMOUNT_LABEL_HEIGHT;
    }

    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.bounds.size.height + 10);

    totalRows = 0;
    
    self.amountTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, scrollHeight)
                                                        style:UITableViewStylePlain];

    self.amountTableView.delegate = self;
    self.amountTableView.dataSource = self;
    self.amountTableView.scrollEnabled = NO;
    self.amountTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.amountTableView.backgroundColor = [UIColor clearColor];
    self.amountTableView.backgroundView = nil;

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(Cancel_Button_Title, @"")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(cancelAction:)];


    if (self.canNotEdit)
    {
        [self.navigationItem setLeftBarButtonItem:nil
                                         animated:NO];
    }
    else
    {
        [self.navigationItem setLeftBarButtonItem:leftButton
                                         animated:NO];
    }


    UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(Done_Button_Title, @"")
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(doneAction:)];
    [self.navigationItem setRightBarButtonItem:rightButton1 animated:NO];



    footerViewAmount = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                self.amountTableView.frame.size.height,
                                                                self.amountTableView.frame.size.width,
                                                                FOOTER_VIEW_HEIGHT)];
    footerViewAmount.backgroundColor = TimesheetTotalHoursBackgroundColor;

    if (totalAmountLabel == nil)
    {
        self.totalAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6.0, 150, 25)];
    }

    totalAmountLabel.backgroundColor = [UIColor clearColor];
    totalAmountLabel.text = RPLocalizedString(TOTAL_AMOUNT, @"");
    totalAmountLabel.font = [UIFont fontWithName:RepliconFontFamilyRegular
                                                  size:RepliconFontSize_16];
    [footerViewAmount addSubview:totalAmountLabel];

    if (totalAmountValue == nil)
    {
        self.totalAmountValue = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 170, 6.0, 160, 25)];
    }

    totalAmountValue.backgroundColor = [UIColor clearColor];
    totalAmountValue.font = [UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_16];
    totalAmountValue.textAlignment = NSTextAlignmentRight;
    [footerViewAmount addSubview:totalAmountValue];

    if ([expenseType isEqualToString:Flat_WithOut_Taxes] || [expenseType isEqualToString:Flat_With_Taxes])
    {
        [footerViewAmount addSubview:totalAmountLabel];
        [footerViewAmount addSubview:totalAmountValue];
        [footerViewAmount setHidden:NO];
        if ([expenseType isEqualToString:Flat_WithOut_Taxes])
        {
            [self.amountTableView setScrollEnabled:NO];
        }
        [totalAmountValue setText:[self.fieldValuesArray objectAtIndex:[self.fieldValuesArray count] - 1]];

    }
    else
    {
        self.amountTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, TABLE_ROW_HEIGHT);
        NSLog(@"%@",self.expenseStatus);
        if([self.expenseStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] || [self.expenseStatus isEqualToString:APPROVED_STATUS])
        {
        }
        else
        {
        NSString *kilo = [NSString stringWithFormat:@"%@",defaultValuesArray.firstObject];
        double kilometersInDouuble=[kilo newDoubleValue];
        UITextField *txtField = [[UITextField alloc]init];
        txtField.text = [Util getRoundedValueFromDecimalPlaces:kilometersInDouuble withDecimalPlaces:2];
        [self updateRatedExpenseData:txtField];
        }
        UIView *footerView = [[UIView alloc] init];
        if ([expenseType isEqualToString:Rated_WithOut_Taxes])
        {
            [footerView setFrame:CGRectMake(0.0,
                    ([defaultValuesArray count] + 2) * 30 - 10,
                    self.amountTableView.frame.size.width,
                    40.0)];
            [footerViewAmount setHidden:YES];
            [totalAmountLabel setFrame:CGRectMake(10, ([defaultValuesArray count] + 2) * 30, 130, 14)];
            [totalAmountValue setFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 130, ([defaultValuesArray count] + 2) * 30, 111, 14)];
            [totalAmountValue setText:[self.defaultValuesArray objectAtIndex:[defaultValuesArray count] - 1]];

        }
        else if ([expenseType isEqualToString:Rated_With_Taxes])
        {
            [footerView setFrame:CGRectMake(0.0,
                    125 + ([expenseTaxesInfoArray count] + 1) * 30,
                    self.amountTableView.frame.size.width,
                    40.0)];
            footerViewAmount.hidden = YES;
            totalAmountLabel.frame = CGRectMake(10, 140 + ([expenseTaxesInfoArray count] + 1) * 30, 130, 14);
            totalAmountValue.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 130, 140 + ([expenseTaxesInfoArray count] + 1) * 30, 111, 14);
            totalAmountValue.text = self.ratedValuesArray[ratedValuesArray.count - 1];
        }

        footerView.backgroundColor = TimesheetTotalHoursBackgroundColor;
        [self.scrollView addSubview:footerView];
        [self.scrollView addSubview:totalAmountLabel];
        [self.scrollView addSubview:totalAmountValue];
    }

    self.amountTableView.tableFooterView = footerViewAmount;
    [scrollView addSubview:self.amountTableView];
    [self.view addSubview:scrollView];
    viewheightWithTable = tableHeight;
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
    self.amountTableView.delegate = nil;
    self.amountTableView.dataSource = nil;
}

- (void)loadView
{
    [super loadView];

    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [Util setToolbarLabel:self
                 withText:RPLocalizedString(AMOUNT, @"")];
    [self initializeView];
    self.flatExpenseFieldsArray = [NSMutableArray arrayWithObjects:
            RPLocalizedString(CURRENCY, @""),
            RPLocalizedString(AMOUNT, @""),
            nil];

    self.ratedLablesArray = [NSMutableArray arrayWithObjects:
            RPLocalizedString(RATE, @""),
            RPLocalizedString(AMOUNT, @""),
            nil];

    self.addRateAndAmountLables = [NSMutableArray array];
    self.taxesLablesArray = [NSMutableArray array];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyBoardNotifications];
    [self.amountTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION_AND_DONE_ACTION
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION
                                                  object:nil];

    [self pickerDone:nil];
}

#pragma mark -
#pragma mark  UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([expenseType isEqualToString:Flat_WithOut_Taxes])
    {
		return 1;
	}
    else if ([expenseType isEqualToString:Flat_With_Taxes])
    {
		return 2;
	}
    else
    {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if ([expenseType isEqualToString:Flat_WithOut_Taxes] ||[expenseType isEqualToString:Flat_With_Taxes])
    {
        if (section == 0)
        {
            return 30;
        }
        else if (section ==1)
        {
            if ([expenseTaxesInfoArray count]>0)
            {
                return 30;
            }
            else
            {
                return 0;
            }

        }

    }
    else
    {
        return 0;
    }
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {


	if ([expenseType isEqualToString:Flat_WithOut_Taxes])
	{
        if ([self.flatExpenseFieldsArray count]>0)
            return 2;
	}
    else if ([expenseType isEqualToString:Flat_With_Taxes])
    {
		if (section==0)
        {
            if ([self.flatExpenseFieldsArray count]>0)
                return 2;
        }
        else
			return [self.expenseTaxesInfoArray count];
	}
    else if ([expenseType isEqualToString:Rated_WithOut_Taxes] || [expenseType isEqualToString:Rated_With_Taxes])
    {
        if ([self.ratedExpenseArray count]>0)
            return 1;
	}

	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0)
    {
        if ([expenseType isEqualToString:Flat_WithOut_Taxes] ||[expenseType isEqualToString:Flat_With_Taxes])
        {
            UILabel	*expenseLabel= [[UILabel alloc] initWithFrame:CGRectMake(10,1.0,250.0,30.0)];

            [expenseLabel setBackgroundColor:[UIColor clearColor]];
            [expenseLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
            [expenseLabel setText:RPLocalizedString(PRE_TAX_AMOUNT,@"")];

            UIView *expenseHeader = [UIView new];
            [expenseHeader addSubview:expenseLabel];
            [expenseHeader setBackgroundColor:TimesheetTotalHoursBackgroundColor];

            return expenseHeader;

        }
        else
        {
            UIView	*otherHeader = [UIView new];
            [otherHeader setBackgroundColor:RepliconStandardWhiteColor];
            return otherHeader;
        }
    }

    else if (section ==1)
    {
        if ([expenseTaxesInfoArray count]>0)
        {
            if ([expenseType isEqualToString:Flat_WithOut_Taxes] ||[expenseType isEqualToString:Flat_With_Taxes])
            {
                UILabel	*otherLabel= [[UILabel alloc] initWithFrame:CGRectMake(10,1.0,250.0,30.0)];

                [otherLabel setBackgroundColor:[UIColor clearColor]];
                [otherLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
                [otherLabel setText:RPLocalizedString(TAXES,@"")];

                UIView	*otherHeader = [UIView new];
                [otherHeader addSubview:otherLabel];
                [otherHeader setBackgroundColor:TimesheetTotalHoursBackgroundColor];

                return otherHeader;

            }

        }
    }
	return nil;


}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	AmountCellView *cell  = (AmountCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil)
    {
		cell = [[AmountCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	cell.amountDelegate=self;
	if ([expenseType isEqualToString:Flat_WithOut_Taxes] || [expenseType isEqualToString:Flat_With_Taxes])
    {
		if(indexPath.section == 0)
        {
            [cell addFieldLabelAndButton:indexPath.row width:CGRectGetWidth(self.view.bounds)];
            if (self.flatExpenseFieldsArray != nil && [self.flatExpenseFieldsArray count] > 0) {
                [cell.fieldLable setText:[self.flatExpenseFieldsArray objectAtIndex:indexPath.row]];
            }
			if (indexPath.row == 0)
            {
                if (self.fieldValuesArray != nil && [self.fieldValuesArray count] > 0) {
                    [cell.fieldButton setTitle:[self.fieldValuesArray objectAtIndex:indexPath.row] forState:UIControlStateNormal];
                }
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ )
                {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UITextField class] ])
                    {
                        [cell.fieldText setText:@""];
                    }
                }
			}
			if (indexPath.row == 1) {
                if (self.fieldValuesArray != nil && [self.fieldValuesArray count] > 0) {
                    [cell.fieldText setText:[self.fieldValuesArray objectAtIndex:indexPath.row]];
                }
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ ) {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UIButton class] ]) {
                        [cell.fieldButton setTitle:@"" forState:UIControlStateNormal];
                    }
                }
			}
		}
	}
	if ([expenseType isEqualToString:Flat_With_Taxes] &&  (indexPath.section==1))
	{
		for (int i=0; i<[expenseTaxesInfoArray count]; i++) {
			if (indexPath.row==i) {
				[cell addFieldLabelAndButton:indexPath.row+tag_Taxes width:CGRectGetWidth(self.view.bounds)];
                if (self.expenseTaxesInfoArray != nil && [self.expenseTaxesInfoArray count] > 0) {
                    [cell.fieldLable setText:[[expenseTaxesInfoArray objectAtIndex:i] objectForKey:@"name"]];
                }
                if (self.fieldValuesArray != nil && [self.fieldValuesArray count] > 0) {
                    [cell.fieldText setText:[self.fieldValuesArray objectAtIndex:i+2]];
                }
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ ) {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UIButton class] ]) {
                        [cell.fieldButton setTitle:@"" forState:UIControlStateNormal];
                    }
                }
			}
		}
	}
	if ([expenseType isEqualToString:Rated_WithOut_Taxes]) {
		if(indexPath.section == 0){
			if (indexPath.row == 0){
				[cell addFieldLabelAndButton:indexPath.row+100 width:CGRectGetWidth(self.view.bounds)];
                if (self.ratedExpenseArray != nil && [self.ratedExpenseArray count] > 0) {
                    [cell.fieldLable setText:[ratedExpenseArray objectAtIndex:indexPath.row]];
                }
                if (self.defaultValuesArray != nil && [self.defaultValuesArray count] > 0) {
                    [cell.fieldText setText:[defaultValuesArray objectAtIndex:indexPath.row]];
                }
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ ) {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UIButton class] ]) {
                        [cell.fieldButton setTitle:@"" forState:UIControlStateNormal];
                    }
                }
			}
		}
		[self addCurrencyLabelWithY:30.0 andTag :1000];
		for (int x=0; x<[ratedLablesArray count]-1; x++) {
			[self addRateAndAmountFields:74+SPACE_FIELD+(x*30) withTag:x];
		}
	}
	if ([expenseType isEqualToString:Rated_With_Taxes]) {

		if(indexPath.section == 0){
			if (indexPath.row == 0){
				[cell addFieldLabelAndButton:indexPath.row+200 width:CGRectGetWidth(self.view.bounds)];
                if (self.ratedExpenseArray != nil && [self.ratedExpenseArray count] > 0) {
                    [cell.fieldLable setText:[ratedExpenseArray objectAtIndex:indexPath.row]];
                }
                if (self.defaultValuesArray != nil && [self.defaultValuesArray count] > 0) {
                    [cell.fieldText setText:[defaultValuesArray objectAtIndex:indexPath.row]];
                }
                for (int i = 0; i < [[cell.contentView subviews] count]; i++ ) {
                    if ([[[cell.contentView subviews] objectAtIndex:i] isKindOfClass:[UIButton class] ]) {
                        [cell.fieldButton setTitle:@"" forState:UIControlStateNormal];
                    }
                }
			}
		}
		[self addCurrencyLabelWithY:30.0 andTag:1000];

		for (int x=0; x<[ratedLablesArray count]; x++)
        {
            [self addRateAndAmountFields:74+SPACE_FIELD+(x*30) withTag:x];
		}
		for (int x=0; x<[expenseTaxesInfoArray count]; x++)
        {
			float yPos=60.0+(x+3)*30;
			[self ratedTaxesLable:x withY:yPos];
		}
	}
	if ([expenseType isEqualToString:Flat_With_Taxes] || [expenseType isEqualToString:Flat_WithOut_Taxes])
    {
		[self configurePicker];
	}
    else
    {
        [self configureToolBar];
    }
    if (canNotEdit)
    {
        [self disableAllFieldsForWaitingSheets:cell];
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
-(void)disableAllFieldsForWaitingSheets:(AmountCellView*)cellObj
{
        [cellObj setUserInteractionEnabled:NO];
        [doneButton setEnabled:NO];
        [cellObj grayedOutRequiredCell];
       	[self.navigationItem setRightBarButtonItem:nil animated:NO];
}


#pragma mark -
#pragma mark View addition Methods

-(void)addCurrencyLabelWithY:(float)y andTag:(int)tag
{
    if (!canNotEdit)
    {
        self.currencyTappedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.currencyTappedButton setFrame:CGRectMake(0,CELL_HEIGHT,self.view.bounds.size.width,44.0)];
        [self.currencyTappedButton setBackgroundColor:[UIColor clearColor]];
        [self.currencyTappedButton addTarget:self action:@selector(currencyTappedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:self.currencyTappedButton];
    }



	UILabel *tempcurrencyLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,CELL_HEIGHT+SPACE_FIELD ,130 ,30 )];
    self.currencyLabel=tempcurrencyLabel;

	[self.currencyLabel setBackgroundColor:[UIColor clearColor]];
	[self.currencyLabel setTag:tag];
	[self.currencyLabel setText:RPLocalizedString(CURRENCY, @"Currency") ];
	//[self.currencyLabel setTextColor:[Util colorWithHex:@"#555555" alpha:1]];

    if (canNotEdit)
    {
        [self.currencyLabel setTextColor:RepliconStandardGrayColor];
    }
    else
    {
          [self.currencyLabel setTextColor:RepliconStandardBlackColor];
    }


	[self.currencyLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
	[self.scrollView addSubview:self.currencyLabel];
    [self.scrollView bringSubviewToFront:self.currencyLabel];

    viewheightWithTable=viewheightWithTable+currencyLabel.frame.size.height;


	UILabel *tempcurrencyValueLabel = [[UILabel alloc]init];
    self.currencyValueLabel=tempcurrencyValueLabel;

	[self.currencyValueLabel setFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-130,CELL_HEIGHT+SPACE_FIELD ,111 ,30 )];
	[self.currencyValueLabel setText:self.ratedBaseCurrency];
    if (canNotEdit)
    {
        [self.currencyValueLabel setTextColor:RepliconStandardGrayColor];
    }
    else
    {
        [self.currencyValueLabel setTextColor:RepliconStandardBlackColor];
    }
	[self.currencyValueLabel setBackgroundColor:[UIColor clearColor]];
	[self.currencyValueLabel setTag:tag+100];
	[self.currencyValueLabel setTextAlignment:NSTextAlignmentRight];

	[self.currencyValueLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];

    [self.scrollView addSubview:self.currencyValueLabel];
    [self.scrollView bringSubviewToFront:self.currencyValueLabel];



}

-(void)addRateAndAmountFields:(float)y withTag:(int)tag
{
    if (tag==0)
    {
        if (!canNotEdit)
        {
            self.rateTappedButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.rateTappedButton setFrame:CGRectMake(0,y,self.view.bounds.size.width,30.0)];
            [self.rateTappedButton setBackgroundColor:[UIColor clearColor]];
            [self.rateTappedButton addTarget:self action:@selector(rateTappedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:self.rateTappedButton];
        }

    }



	UILabel *tempratedLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,y ,130 ,30 )];
    self.ratedLabel=tempratedLabel;

	[ratedLabel setBackgroundColor:[UIColor clearColor]];
	[ratedLabel setTag:tag];
	[ratedLabel setText:[ratedLablesArray objectAtIndex:tag]];
    if (tag==0)
    {
        if (canNotEdit)
        {
            [ratedLabel setTextColor:RepliconStandardGrayColor];
        }
        else
        {
            [ratedLabel setTextColor:RepliconStandardBlackColor];
        }
    }
    else
    {
        [ratedLabel setTextColor:[Util colorWithHex:@"#555555" alpha:1]];
    }



	[ratedLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
	[self.scrollView addSubview:self.ratedLabel];
    [self.scrollView bringSubviewToFront:self.ratedLabel];

    viewheightWithTable=viewheightWithTable+ratedLabel.frame.size.height;


	UILabel *tempratedValueLable = [[UILabel alloc]init];
    self.ratedValueLable=tempratedValueLable;

	[ratedValueLable setFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-130,y ,111 ,30 )];
	[ratedValueLable setText:[defaultValuesArray objectAtIndex:tag+1]];
    if (tag==0)
    {
        if([amountControllerDelegate isKindOfClass:[ExpenseEntryViewController class]])
        {
            ExpenseEntryViewController *expenseEntryCtrl=(ExpenseEntryViewController *)amountControllerDelegate;
            expenseEntryCtrl.expenseEntryObject.expenseEntryRateAmount=[defaultValuesArray objectAtIndex:tag+1];

        }
    }

	[ratedValueLable setBackgroundColor:[UIColor clearColor]];
	[ratedValueLable setTag:tag+100];
	[ratedValueLable setTextAlignment:NSTextAlignmentRight];

    if (tag==0)
    {
        if (canNotEdit)
        {
            [ratedValueLable setTextColor:RepliconStandardGrayColor];
        }
        else
        {
            [ratedValueLable setTextColor:RepliconStandardBlackColor];
        }
    }
    else
    {
         [ratedValueLable setTextColor:RepliconStandardBlackColor];
    }

	[ratedValueLable setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
    [self.scrollView addSubview:ratedValueLable];
    [self.scrollView bringSubviewToFront:ratedValueLable];

    [addRateAndAmountLables addObject:ratedValueLable];


}


-(void)ratedTaxesLable:(int)tagValue withY:(float)yPosition
{

	ratedTaxesLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,yPosition ,130 ,30 )];
	[ratedTaxesLabel setBackgroundColor:[UIColor clearColor]];
	[ratedTaxesLabel setTag:tagValue];
	[ratedTaxesLabel setTextColor:[Util colorWithHex:@"#555555" alpha:1]];
	[ratedTaxesLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
	[ratedTaxesLabel setText:[[expenseTaxesInfoArray objectAtIndex:tagValue]objectForKey:@"name"]];
	[self.scrollView addSubview:ratedTaxesLabel];

    viewheightWithTable=viewheightWithTable+ratedTaxesLabel.frame.size.height;

	ratedTaxValueLable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)-130,yPosition ,111 ,30 )];
	[ratedTaxValueLable setBackgroundColor:[UIColor clearColor]];
	[ratedTaxValueLable setText:[ratedValuesArray objectAtIndex:tagValue]];
	[ratedTaxValueLable setTag:tagValue+20];
	[ratedTaxValueLable setTextAlignment:NSTextAlignmentRight];
	[ratedTaxValueLable setTextColor:RepliconStandardBlackColor];
	[ratedTaxValueLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
	[self.scrollView addSubview:ratedTaxValueLable];

    [taxesLablesArray addObject:ratedTaxValueLable];

}

#pragma mark -
#pragma mark Cancel/Done methods
-(void)cancelAction:(id)sender
{
    CLS_LOG(@"-----Cancel action on AmountViewController -----");
    [self.toolbar removeFromSuperview];
    [self.pickerView removeFromSuperview];



    pickerView=nil;

    toolbar=nil;
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    for (UIView *view in appDelegate.window.subviews)
    {
        if ([view isKindOfClass:[UIPickerView class]])//Mobi-240 Ullas M L
        {
            if ([view tag]==PICKER_VIEW_TAG_AMOUNT_VIEW)
            {
                [view removeFromSuperview];
            }

        }
    }
    [textFieldSelected resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)doneAction:(id)sender
{


    //////////DOWNLOAD CURRENCIES IF NOT ALREADY DONE

    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [Util showOfflineAlert];
        return;
    }
    else
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION_AND_DONE_ACTION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doneActionAfterDownloading)
                                                     name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION_AND_DONE_ACTION
                                                   object:nil];
        //Implemented as per US8683//JUHI
        ExpenseModel *expensesModel=[[ExpenseModel alloc]init];
        NSMutableArray *array=[expensesModel getSystemCurrenciesFromDatabase];

        if ([array count]>0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION_AND_DONE_ACTION object:nil];
        }
        else
            [[RepliconServiceManager expenseService]fetchExpenseCurrencyAndPaymentMethodDatawithDelegate:self];
    }



}

-(void)doneActionAfterDownloading
{

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION_AND_DONE_ACTION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

    UITextField *amountTxtField=nil;
    if ([expenseType isEqualToString:Rated_With_Taxes] || [expenseType isEqualToString:Rated_WithOut_Taxes])
    {
        amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
                                             [NSIndexPath indexPathForRow:0 inSection:0]] fieldText ];
    }
    else
    {
        amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
                                             [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
    }

    if(amountTxtField!=nil && ![amountTxtField isKindOfClass:[NSNull class]])
    {
        if ([amountTxtField.text isEqualToString:RPLocalizedString(SELECT, @"") ]||[amountTxtField.text isEqualToString:RPLocalizedString(ADD, @"") ])
        {
            [Util errorAlert:@"" errorMessage:RPLocalizedString( @"Please enter expense amount",@"")];
            [self pickerDone:nil];

            return;
        }
    }

    if ([expenseType isEqualToString:Flat_With_Taxes] || [expenseType isEqualToString:Flat_WithOut_Taxes])
    {
        UIButton *currencyButton=[(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
                                                     [NSIndexPath indexPathForRow:0 inSection:0]] fieldButton ];
        if ([currencyButton.titleLabel.text isEqualToString:RPLocalizedString(SELECT, @"") ])
        {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(DateError,@"")];
            [self pickerDone:nil];
             [self.navigationController popViewControllerAnimated:YES];
            return;
        }

    }
    CLS_LOG(@"-----Done action on AmountViewController -----");
    [self.toolbar removeFromSuperview];
    [self.pickerView removeFromSuperview];


    pickerView=nil;

    toolbar=nil;

    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    for (UIView *view in appDelegate.window.subviews)
    {
        if ([view isKindOfClass:[UIPickerView class]])//Mobi-240 Ullas M L
        {
            if ([view tag]==PICKER_VIEW_TAG_AMOUNT_VIEW)
            {
                [view removeFromSuperview];
            }

        }
    }
    [textFieldSelected resignFirstResponder];
    if ([expenseType isEqualToString:Rated_With_Taxes] || [expenseType isEqualToString:Rated_WithOut_Taxes])
    {
        if (textFieldSelected.tag==100||textFieldSelected.tag==200) {
            [self performSelector:@selector(updateRatedExpenseData:) withObject:textFieldSelected];
        }

        [self dehighLightRateTappedRow];

        [amountControllerDelegate performSelector:@selector(setValuesForRatedExpenseType:andCurrencyName:) withObject:[NSMutableArray arrayWithObjects:defaultValuesArray,ratedValuesArray,nil] withObject:self.ratedBaseCurrency];
        [amountControllerDelegate performSelector:@selector(setDescription:) withObject:totalAmountValue.text];
        [amountControllerDelegate performSelector:@selector(setRatedUnits:) withObject:amountTxtField.text];
        [amountControllerDelegate performSelector:@selector(setTotalAmountToRatedType:andCurrenyName:) withObject:totalAmountValue.text withObject:self.ratedBaseCurrency];




    }

    if ([expenseType isEqualToString:Flat_WithOut_Taxes] || [expenseType isEqualToString:Flat_With_Taxes])
    {

        if ([expenseType isEqualToString:Flat_WithOut_Taxes])
        {
            if (![[amountTxtField text] isEqualToString:RPLocalizedString(SELECT, @"")])
            {
                [amountTxtField resignFirstResponder];
                //				if (amountValueEntered!=nil)
                //                {
                //					[amountTxtField setText:[NSString stringWithFormat:@"%@",amountValueEntered]];
                //				}
                //                else
                //                {
                //					[amountTxtField setText:@"0.00"];
                //				}
            }
            [totalAmountValue setText:amountTxtField.text];
            [amountControllerDelegate performSelector:@selector(setDescription:) withObject:totalAmountValue.text];
            [self.fieldValuesArray replaceObjectAtIndex:1 withObject:totalAmountValue.text];
            [self.fieldValuesArray replaceObjectAtIndex:2 withObject:totalAmountValue.text];
        }

        else if ([expenseType isEqualToString:Flat_With_Taxes])
        {
            [amountTxtField resignFirstResponder];
            NSString *formattedAmountString =nil;
            if (amountValueEntered!=nil && !([amountValueEntered isEqualToString:RPLocalizedString(SELECT, @"")]))
            {
                double netAmount=[amountValueEntered newDoubleValue];
                formattedAmountString = [Util getRoundedValueFromDecimalPlaces:netAmount withDecimalPlaces:2];
                [amountTxtField setText:[NSString stringWithFormat:@"%@",formattedAmountString]];
            }
            if (textFieldSelected != nil && textFieldSelected.tag<[flatExpenseFieldsArray count])
            {
                [self performSelector:@selector(updateValues:) withObject:amountTxtField];
            }


            if (textFieldSelected.tag>=1000)
            {
                [self taxAmountEditedByUser:textFieldSelected];
            }
            [amountControllerDelegate performSelector:@selector(setDescription:) withObject:totalAmountValue.text];
        }
        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
        NSString *currencyId= [expenseModel getSystemCurrencyUriFromDBForCurrencyName:[self.fieldValuesArray objectAtIndex:0]];
        if (currencyId==nil||[currencyId isKindOfClass:[NSNull class]])
        {
            currencyId=self.selectedCurrencyUri;
        }

        [amountControllerDelegate performSelector:@selector(setAmountArrayBaseCurrency:withUri:)
                                       withObject:self.fieldValuesArray withObject:currencyId];

        [amountControllerDelegate performSelector:@selector(setCurrencyUri:currencyName:) withObject:currencyId withObject:[self.fieldValuesArray objectAtIndex:0]];


    }



     [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Picker Delegates methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return self.view.frame.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return PICKER_ROW_HEIGHT;
}
- (NSInteger)pickerView:(UIPickerView *)pickerViews numberOfRowsInComponent:(NSInteger)component
{
	if ([pickerDataSourceArray count]>0)
    {
        [pickerViews setUserInteractionEnabled:YES];
    }
    else
    {
        [pickerViews setUserInteractionEnabled:NO];
    }

    return [pickerDataSourceArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerDataSourceArray != nil && ![pickerDataSourceArray isKindOfClass:[NSNull class]] &&[pickerDataSourceArray count]>0)
    {
        return [[pickerDataSourceArray objectAtIndex:row] objectForKey:@"currenciesName"];
    }
    return nil;

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    CLS_LOG(@"-----Currency picker row selected on AmountViewController -----");
    if (pickerDataSourceArray != nil && ![pickerDataSourceArray isKindOfClass:[NSNull class]] &&[pickerDataSourceArray count]>0)
    {
        if ([expenseType isEqualToString:Flat_With_Taxes] || [expenseType isEqualToString:Flat_WithOut_Taxes])
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            AmountCellView *amountCell = (AmountCellView *)[self.amountTableView cellForRowAtIndexPath:indexPath];
            [amountCell.fieldButton setTitle:[[pickerDataSourceArray objectAtIndex:row] objectForKey:@"currenciesName"] forState:UIControlStateNormal];
            [self.fieldValuesArray replaceObjectAtIndex:0 withObject:[[pickerDataSourceArray objectAtIndex:row]objectForKey:@"currenciesName"]];
        }
        else
        {
            self.ratedBaseCurrency=[[pickerDataSourceArray objectAtIndex:row]objectForKey:@"currenciesName"];
            [self.currencyValueLabel setText:self.ratedBaseCurrency];
            
        }
    }
    
}

#pragma mark -
#pragma mark Picker Methods
-(void)SendRequestToGetSystemCurrencies
{
    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [Util showOfflineAlert];
        return;
    }
    else
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatePaymentAfterDownloading:)
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
-(void)updatePaymentAfterDownloading:(id)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];


    //Implemented as per US8683//JUHI
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    if (inEditState==YES)
    {
		[self showToolBarWithAnimationForUsdAction];
	}
    else
    {
		[ self showToolBarWithAnimation];
	}
    [self showDataPicker:YES];
    [self.pickerView reloadAllComponents];

    if ([expenseType isEqualToString:Flat_With_Taxes] || [expenseType isEqualToString:Flat_WithOut_Taxes])
    {
        UIButton *currencyButton=[(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
                                                     [NSIndexPath indexPathForRow:0 inSection:0]] fieldButton ];
        NSString *defaultCurrencyName=currencyButton.titleLabel.text;
        int selProjIndex = [Util getObjectIndex:self.pickerDataSourceArray withKey:@"currenciesName" forValue:defaultCurrencyName];
        if(selProjIndex > -1 )
        {
            [self pickerView:pickerView didSelectRow:selProjIndex inComponent:0];
            [self.pickerView selectRow: selProjIndex inComponent:0 animated: NO];
        }
        else
        {
            if ([pickerDataSourceArray count]>0)
            {
                [self pickerView:pickerView didSelectRow:0 inComponent:0];
                 [self.pickerView selectRow: 0 inComponent:0 animated: NO];
            }


        }


    }
    else
    {
        if (self.pickerDataSourceArray.count>0 && [self.ratedBaseCurrency isKindOfClass:[NSString class]])
        {
            int index=0;
            for (NSDictionary *currencyDict in pickerDataSourceArray )
            {
                NSString *currenyName=[currencyDict objectForKey:@"currenciesName"];
                if ([currenyName isEqualToString:self.ratedBaseCurrency])
                {
                    [self.pickerView selectRow:index inComponent:0 animated:FALSE];
                }
                index++;
            }

        }

    }

}
-(void)configureToolBar
{
    UIPickerView *temppickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerView=temppickerView;
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    UIBarButtonItem *tmpDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:self
                                                                                   action:@selector(pickerDone:)];
	self.doneButton=tmpDoneButton;


	UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
	self.spaceButton=tmpSpaceButton;


	if (toolbar == nil) {
		toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.pickerView.y-Toolbar_Height, self.view.width, Toolbar_Height)];
	}
	
    UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
    self.doneButton.tintColor=RepliconStandardWhiteColor;
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
	[toolbar setTranslucent:YES];
    toolbar.hidden=YES;

	NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
	[toolbar setItems:toolArray];
    [appDelegate.window addSubview:toolbar];

}
-(void)configurePicker
{
	AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
	CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIPickerView *temppickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerView=temppickerView;
    [self.pickerView setBackgroundColor:RepliconStandardWhiteColor];
	CGSize pickerSize = [pickerView sizeThatFits:CGSizeZero];
	[pickerView setFrame: CGRectMake(0.0,
                                     screenRect.size.height-pickerSize.height ,
                                     screenRect.size.width,
                                     pickerSize.height)];

	pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	pickerView.delegate = self;
    pickerView.dataSource = self;
	pickerView.showsSelectionIndicator = YES;
	pickerView.hidden = YES;
    pickerView.tag=PICKER_VIEW_TAG_AMOUNT_VIEW;
    UIBarButtonItem *tmpDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:self
                                                                                   action:@selector(pickerDone:)];
	self.doneButton=tmpDoneButton;


	UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
	self.spaceButton=tmpSpaceButton;


	if (toolbar == nil) {
		toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, pickerView.y-Toolbar_Height, self.view.width, Toolbar_Height)];
	}
    self.doneButton.tintColor=RepliconStandardWhiteColor;
    UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
	[toolbar setTranslucent:YES];
    toolbar.hidden=YES;

	NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
	[toolbar setItems:toolArray];
    [appDelegate.window addSubview:toolbar];
	[appDelegate.window addSubview:pickerView];

}
-(void)showDataPicker:(BOOL)showDataPicker
{

    if (showDataPicker)
    {
        CGFloat toolBarYPosition = self.pickerView.y-Toolbar_Height;
        [self updateToolBarYPosition:toolBarYPosition];
        [self.toolbar setHidden:NO];
        [self.pickerView setHidden:NO];
        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
        self.pickerDataSourceArray=[expenseModel getSystemCurrenciesFromDatabase];
        
    }
    else
    {
        [self.toolbar setHidden:YES];
        [self.pickerView setHidden:YES];
        [pickerDataSourceArray removeAllObjects];
    }

}

-(void)pickerDone:(UIBarButtonItem *)button
{
    if ([expenseType isEqualToString:Flat_With_Taxes] || [expenseType isEqualToString:Flat_WithOut_Taxes])
    {
         [self resetTableViewUsingSelectedIndex:nil];
    }

    [textFieldSelected resignFirstResponder];
    self.pickerView.hidden=YES;
    self.toolbar.hidden=YES;

    UITextField *amountTxtField=nil;
    if (amountTxtField!=nil && ![[amountTxtField text] isEqualToString:RPLocalizedString(SELECT, @"")])
    {

		if (textFieldSelected.tag<[flatExpenseFieldsArray count])
        {
			[self performSelector:@selector(updateValues:) withObject:amountTxtField];
		}
	}
    else
    {
        if (selectedFieldTag!=0 && ![[amountTxtField text] isEqualToString:RPLocalizedString(SELECT, @"")])
        {
            if (textFieldSelected.tag<[flatExpenseFieldsArray count])
            {
                amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
                                                     [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
                [self performSelector:@selector(updateValues:) withObject:amountTxtField];
            }
        }

	}

	if (textFieldSelected.tag==100||textFieldSelected.tag==200)
    {
		[self performSelector:@selector(updateRatedExpenseData:) withObject:textFieldSelected];
	}


	if (self.selectedIndexPath != nil && ![self.selectedIndexPath isKindOfClass:[NSNull class]])
    {
      [self dehilightCellWhenFocusChanged:self.selectedIndexPath];
    }

    [self dehighLightCurrencyTappedRow];
    [self dehighLightRateTappedRow];


}


#pragma mark -
#pragma mark AmountCell methods
-(void)setEnteredAmountValue:(NSString *)_textValue
{
	double amountDoubleValue = [_textValue newDoubleValue];
	NSString *tempString =  [Util getRoundedValueFromDecimalPlaces:amountDoubleValue withDecimalPlaces:2];
	if (tempString != nil)
    {
       self.amountValueEntered = tempString;
    }

	if (self.fieldValuesArray != nil)
    {
		[self.fieldValuesArray replaceObjectAtIndex:1 withObject:amountValueEntered];
	}
}
-(void)updateValues:(UITextField*)textField
{
	if (textField.tag==1)
    {
		if (amountValueEntered!=nil)
        {

			self.amountValueEntered = [amountValueEntered stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] ;
			textField.text=[NSString stringWithFormat:@"%@",amountValueEntered];
            self.isAmountEdit=YES;
		}
		[self.fieldValuesArray replaceObjectAtIndex:1 withObject:amountValueEntered];

		if ([expenseType isEqualToString:Flat_With_Taxes])
        {
			[self calculateTaxesForEnterdAmount:amountValueEntered];
		}
        else if ([expenseType isEqualToString:Flat_WithOut_Taxes])
        {
            [totalAmountValue setText:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[amountValueEntered newDoubleValue] withDecimalPlaces:2]]];
        }
	}


}
/************************************************************************************************************
 @Function Name   : calculateTaxesForEnterdAmount
 @Purpose         : To calculate the Flat expenses data for Flat With/Without tax and Update UI
 @param           : amountEnterd
 @return          : nil
 *************************************************************************************************************/

-(void)calculateTaxesForEnterdAmount:(NSString*)amountEnterd
{
	[self.fieldValuesArray replaceObjectAtIndex:1 withObject:amountEnterd];
	double netAmount=[amountEnterd newDoubleValue];

        NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
        NSDecimalNumber *netAmountDecimal=[[NSDecimalNumber alloc] initWithDouble:netAmount];
        NSDecimalNumber *roundedNetAmount= [netAmountDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

        double totalTax=0;
        NSDecimalNumber *roundedTotalTaxAmount=[[NSDecimalNumber alloc] initWithDouble:0.0];
        for (int i=0; i<[expenseTaxesInfoArray count]; i++)
        {
            NSNumber *taxAmount;
            NSString *taxFormula=nil;

            if (isAmountEdit)
            {
                taxFormula= [[[expenseTaxesInfoArray objectAtIndex:i]objectForKey:@"formula"] lowercaseString];
            }
            else if (taxAmountEdited)
            {
                taxFormula = [[fieldValuesArray objectAtIndex:i+2] lowercaseString];
            }

            if ([taxFormula rangeOfString:@"$net"].location!=NSNotFound)
            {
                taxFormula=[taxFormula stringByReplacingOccurrencesOfString:@"$net"withString:[NSString stringWithFormat:@"%f", [roundedNetAmount newDoubleValue]]];
                NSPredicate *pred = [NSPredicate predicateWithFormat:[taxFormula stringByAppendingString:@" == 42"]];
                NSExpression *exp = [(NSComparisonPredicate *)pred leftExpression];
                if (netAmount==0)
                {
                    taxAmount=[NSNumber numberWithInt:0];
                }
                else
                {
                    taxAmount = [exp expressionValueWithObject:nil context:nil];
                }

            }
            else
            {
                if (netAmount==0)
                {
                    taxAmount=[NSNumber numberWithInt:0];
                }
                else
                {
                    taxAmount=[NSNumber numberWithDouble:[taxFormula newDoubleValue]];
                }

            }



            NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
            NSDecimalNumber *doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[taxAmount newDoubleValue]];
            NSDecimalNumber *roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];


            [self.fieldValuesArray replaceObjectAtIndex:i+2 withObject:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[roundedTaxAmount newDoubleValue] withDecimalPlaces:2]]];

            UITextField *taxTxtField = [(AmountCellView *)[self.amountTableView cellForRowAtIndexPath:
                                                           [NSIndexPath indexPathForRow:i inSection:1]] fieldText ];
            [taxTxtField setText:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[roundedTaxAmount newDoubleValue] withDecimalPlaces:2]]];

            totalTax=totalTax +[roundedTaxAmount newDoubleValue];

            NSDecimalNumber *totalTaxDecimal=[[NSDecimalNumber alloc] initWithDouble:totalTax];
            roundedTotalTaxAmount=[totalTaxDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
        }

        NSDecimalNumber *totalAmountWithTaxes=(NSDecimalNumber *)[Util getTotalAmount:roundedNetAmount withTaxAmount:roundedTotalTaxAmount];
        [self.fieldValuesArray replaceObjectAtIndex:[fieldValuesArray count]-1 withObject:[NSString stringWithFormat:@"%@",
                                                                                           [Util getRoundedValueFromDecimalPlaces:[totalAmountWithTaxes newDoubleValue] withDecimalPlaces:2]]];

        [totalAmountValue setText:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[totalAmountWithTaxes newDoubleValue] withDecimalPlaces:2]]];



}

/************************************************************************************************************
 @Function Name   : updateRatedExpenseData
 @Purpose         : To calculate the rated expenses data for Rated With/Without tax and Update UI
 @param           : kilometerTextField
 @return          : nil
 *************************************************************************************************************/

-(void)updateRatedExpenseData:(UITextField*)kilometerTextField
{
	self.kilometerUnitValue=kilometerTextField.text;

	double kilometersInDouuble=[kilometerUnitValue newDoubleValue];

	kilometerTextField.text=[Util getRoundedValueFromDecimalPlaces:kilometersInDouuble withDecimalPlaces:2];
	[defaultValuesArray replaceObjectAtIndex:0 withObject:kilometerUnitValue];

    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
    NSDecimalNumber *netAmount=[[NSDecimalNumber alloc] initWithDouble:kilometersInDouuble*rate];
    NSDecimalNumber *roundedNetAmount= [netAmount decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

	NSString *formattedRateString = [[NSString alloc] initWithFormat:@"%0.04lf",rate];


    if ([[Util detectDecimalMark] isEqualToString:@","])
    {
        formattedRateString=[formattedRateString stringByReplacingOccurrencesOfString:@"." withString:@","];
    }

	NSString *formattedNetAmountString = [Util getRoundedValueFromDecimalPlaces:[roundedNetAmount newDoubleValue] withDecimalPlaces:2];

    for (int k=0; k<[addRateAndAmountLables count]; k++)
    {
        if (k==0)
        {
            [[addRateAndAmountLables objectAtIndex:0] setText:formattedRateString];
        }
        if (k==1)
        {
            [[addRateAndAmountLables objectAtIndex:1] setText:formattedNetAmountString];
        }
    }
	[defaultValuesArray replaceObjectAtIndex:1 withObject:formattedRateString];
	[defaultValuesArray replaceObjectAtIndex:2 withObject:formattedNetAmountString];


	double totalTax=0;
	NSNumber *taxAmount;
    NSDecimalNumber *roundedTotalTaxAmount=[[NSDecimalNumber alloc] initWithDouble:0];
	for (int i=0; i<[expenseTaxesInfoArray count]; i++)
    {
		NSString *taxFormula=[[[expenseTaxesInfoArray objectAtIndex:i] objectForKey:@"formula"] lowercaseString];
        NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
        NSDecimalNumber *doubleDecimal;
        NSDecimalNumber *roundedTaxAmount;
        if ([taxFormula rangeOfString:@"$net"].location!=NSNotFound)
        {

            taxFormula=[taxFormula stringByReplacingOccurrencesOfString:@"$net"withString:[NSString stringWithFormat:@"%f", [roundedNetAmount newDoubleValue]]];
            NSPredicate *pred = [NSPredicate predicateWithFormat:[taxFormula stringByAppendingString:@" == 42"]];
            NSExpression *exp = [(NSComparisonPredicate *)pred leftExpression];
            taxAmount = [exp expressionValueWithObject:nil context:nil];



            doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[taxAmount newDoubleValue]];
            roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

            [ratedValuesArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[roundedTaxAmount newDoubleValue] withDecimalPlaces:2]]];
        }
        else
        {
			taxAmount=[NSNumber numberWithDouble:[taxFormula newDoubleValue]];
            doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:[taxAmount newDoubleValue]];
            roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
            [ratedValuesArray replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[roundedTaxAmount newDoubleValue] withDecimalPlaces:2]]];
		}


		[[taxesLablesArray objectAtIndex:i] setText:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[roundedTaxAmount newDoubleValue] withDecimalPlaces:2]]];

        totalTax=totalTax +[roundedTaxAmount newDoubleValue];
        NSDecimalNumber *totalTaxDecimal=[[NSDecimalNumber alloc] initWithDouble:totalTax];
        roundedTotalTaxAmount=[totalTaxDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

	}

	NSDecimalNumberHandler *roundingBehavior1 = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
    netAmount=[netAmount decimalNumberByRoundingAccordingToBehavior:roundingBehavior1];
	NSDecimalNumber *totalAmount=(NSDecimalNumber *)[Util getTotalAmount:netAmount withTaxAmount:roundedTotalTaxAmount];
	[totalAmountValue setText:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[totalAmount newDoubleValue] withDecimalPlaces:2]]];
    [ratedValuesArray replaceObjectAtIndex:[ratedValuesArray count]-1 withObject:totalAmountValue.text];

}

-(void)taxAmountEditedByUser:(UITextField*)taxTextField
{
	taxAmountEdited = YES;
	double totalTax=0;
	UITextField *netAmountField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
													  [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];
	NSString *netAmountString=nil;
	if (netAmountField.text==nil && [netAmountField.text isEqualToString:RPLocalizedString(SELECT, @"")]) {
		netAmountField.text=[NSString stringWithFormat:@"%@",@"0.00"];
	}
	netAmountString=netAmountField.text;
	if (netAmountString == nil)
    {
		netAmountString = [self.fieldValuesArray objectAtIndex:1];
	}
	[self  setAmountValueEntered:netAmountString];
	double netAmount=[netAmountString newDoubleValue];

    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:FALSE raiseOnOverflow:TRUE raiseOnUnderflow:TRUE raiseOnDivideByZero:TRUE];
    NSDecimalNumber *netAmountDecimal=[[NSDecimalNumber alloc] initWithDouble:netAmount];
    NSDecimalNumber *roundedNetAmount= [netAmountDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

    NSDecimalNumber *roundedTotalTaxAmount=[[NSDecimalNumber alloc] initWithDouble:netAmount];


	for (int i=0; i<[expenseTaxesInfoArray count]; i++)
    {
		UITextField *taxTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
													   [NSIndexPath indexPathForRow:i inSection:1]] fieldText ];
		NSString *taxValueExisted=taxTxtField.text;
		double taxDoubleValue=0.0;
        if (taxValueExisted!=nil && ![taxValueExisted isEqualToString:@"0.00"])
        {
			taxDoubleValue =[taxValueExisted newDoubleValue];
		}
        else
        {

            if (taxValueExisted==nil) {
                taxDoubleValue = [[self.fieldValuesArray objectAtIndex:i+2] newDoubleValue];
            }

            else
            {
                NSNumber *taxAmount;
                NSString *taxFormula=[[fieldValuesArray objectAtIndex:i+2] lowercaseString];
                if ([taxFormula rangeOfString:@"$net"].location!=NSNotFound)
                {
                    taxFormula=[taxFormula stringByReplacingOccurrencesOfString:@"$net"withString:[NSString stringWithFormat:@"%f", [roundedNetAmount newDoubleValue]]];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:[taxFormula stringByAppendingString:@" == 42"]];
                    NSExpression *exp = [(NSComparisonPredicate *)pred leftExpression];
                    taxAmount = [exp expressionValueWithObject:nil context:nil];
                    taxDoubleValue= [taxAmount newDoubleValue];


                }
                else
                {
                    taxAmount=[NSNumber numberWithDouble:[taxFormula newDoubleValue]];
                    taxDoubleValue =[taxAmount newDoubleValue];
                }
            }


		}

        NSDecimalNumber *doubleDecimal = [[NSDecimalNumber alloc] initWithDouble:taxDoubleValue];
        NSDecimalNumber *roundedTaxAmount = [doubleDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];

        [self.fieldValuesArray replaceObjectAtIndex:i+2 withObject:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[roundedTaxAmount newDoubleValue] withDecimalPlaces:2]]];

        [taxTxtField setText:[NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:[roundedTaxAmount newDoubleValue] withDecimalPlaces:2]]];

		totalTax=totalTax+[roundedTaxAmount newDoubleValue];
        NSDecimalNumber *totalTaxDecimal=[[NSDecimalNumber alloc] initWithDouble:totalTax];
        roundedTotalTaxAmount=[totalTaxDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
	}

    NSDecimalNumber *totalAmount=(NSDecimalNumber *)[Util getTotalAmount:roundedNetAmount withTaxAmount:roundedTotalTaxAmount];
	[self.fieldValuesArray replaceObjectAtIndex:[self.fieldValuesArray count]-1 withObject:[NSString stringWithFormat:@"%@",
                                                                                            [Util getRoundedValueFromDecimalPlaces:[totalAmount newDoubleValue] withDecimalPlaces:2]]];
	[totalAmountValue setText:[Util getRoundedValueFromDecimalPlaces:[totalAmount newDoubleValue] withDecimalPlaces:2]];
	[self updateAmountValue];

}
-(void)updateAmountValue
{
	UITextField *amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
													  [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];

	NSString *amountText = amountTxtField.text;
	if (amountText == nil)
    {
		amountText = [self.fieldValuesArray objectAtIndex:1];
	}
	double amtDoubleValue =[amountText newDoubleValue];
	NSString *tempAmount = [NSString stringWithFormat:@"%@",[Util getRoundedValueFromDecimalPlaces:amtDoubleValue withDecimalPlaces:2]];
	self.amountValueEntered = tempAmount;
	self.amountValueEntered = [amountValueEntered stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	amountTxtField.text=[NSString stringWithFormat:@"%@",amountValueEntered];
	[self.fieldValuesArray replaceObjectAtIndex:1 withObject:amountValueEntered];
}
-(void)userSelectedTextField:(UITextField*)textField
{
	if (textField.tag > amountField_Tag)
    {
		[self updateAmountValue];
	}
	[self setTextFieldSelected:textField];

	if (textField.tag<[flatExpenseFieldsArray count])
    {
		self.amountValueEntered=@"";

		[self addAmountAction];
	}
	selectedFieldTag=textField.tag;

}

-(void)addAmountAction
{
	if (selectedFieldTag==0)
    {
		selectedFieldTag++;

	}
}
-(void)showKilometersOverLay:(UITextField*)kilometerTextField
{
	[self setTextFieldSelected:kilometerTextField];

}

-(void)getTagFromTextFiled:(UITextField*)textFiledTapped
{
	NSIndexPath *tappedIndexPath = nil;
	int section = 0;
	if (textFiledTapped.tag >= tag_Taxes)
    {
		section = 1;
	}
	NSInteger row = 0;
	if (textFiledTapped.tag == amountField_Tag )
    {
		row = 1;
	}
    else if (textFiledTapped.tag >= tag_Taxes)
    {
		row = textFiledTapped.tag - tag_Taxes;
	}
    else if (textFiledTapped.tag == ratedField_Tag)
    {
		row = textFiledTapped.tag - ratedField_Tag;
	}
    else if (textFiledTapped.tag == ratedWithTaxes_Tag)
    {
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

    if ([expenseType isEqualToString:Flat_With_Taxes] || [expenseType isEqualToString:Flat_WithOut_Taxes])
    {
         [self resetTableViewUsingSelectedIndex:tappedIndexPath];
    }



}
-(void)buttonActionsHandling:(UIButton*)sender :(UIEvent*)event
{
    UITouch * touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView: self. amountTableView];
	NSIndexPath * indexPath = [self. amountTableView indexPathForRowAtPoint: location];
    [self. amountTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	if (self.selectedIndexPath != nil  && ![self.selectedIndexPath isKindOfClass:[NSNull class]] && self.selectedIndexPath != indexPath)
    {
		[self dehilightCellWhenFocusChanged:self.selectedIndexPath];
	}
    [self performSelector:@selector(cellTappedAtIndex:) withObject:indexPath];

}



-(void)buttonActions:(UIButton*)sender
{
    selectedFieldTag=sender.tag;
	if (sender.tag==0)
    {
		buttonTitle=sender.titleLabel.text;
		[self addUsdAction];
	}
	else if (sender.tag==1)
    {
		[self addAmountAction];
	}

}
-(void)addUsdAction
{

	if (selectedFieldTag>0)
    {
		selectedFieldTag--;
		UITextField *amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
														  [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];

		[amountTxtField resignFirstResponder];
		if (amountValueEntered!=nil)
        {

			[amountTxtField setText:[NSString stringWithFormat:@"%@",amountValueEntered]];
		}

	}
    else
    {
		UITextField *amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
														  [NSIndexPath indexPathForRow:1 inSection:0]] fieldText ];


		[amountTxtField resignFirstResponder];
	}



    [self SendRequestToGetSystemCurrencies];
}

- (void)showToolBarWithAnimationForUsdAction
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];

    CGRect frame = pickerView.frame;
	frame.origin.y = self.view.frame.size.height -keyBoardHeight;
	pickerView.frame= frame;
    [UIView commitAnimations];
}



-(NSInteger)getNumberOfRowsInSection:(NSInteger)section andType:(NSString *)tmpExpenseType
{

    if ([tmpExpenseType isEqualToString:Flat_WithOut_Taxes])
	{
		return 2;
	}
    else if ([tmpExpenseType isEqualToString:Flat_With_Taxes])
    {
		if (section==0)
        {
			return 2;
		}
        else
        {
			return [expenseTaxesInfoArray count];
		}
	}
    else if ([tmpExpenseType isEqualToString:Rated_WithOut_Taxes] || [tmpExpenseType isEqualToString:Rated_With_Taxes])
    {
		return 1;
	}

	return 0;

}

-(NSInteger)getNumberofSectionsInTableView:(NSString *)tmpType
{
    if ([tmpType isEqualToString:Flat_With_Taxes])
    {
		return 2;
	}
    else
    {
		return 1;
	}


}
#pragma mark -
#pragma mark keyBoard Handling Methods

-(void)registerForKeyBoardNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];

}

- (void)showToolBarWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	[self.toolbar setHidden:NO];
    [UIView commitAnimations];
}
- (void)hideToolBarWithAnimation
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	[self.toolbar setHidden:YES];
	[UIView commitAnimations];
}

-(void) keyboardWillShow:(NSNotification *)note
{
    self.pickerView.hidden=YES;
    NSDictionary *info  = note.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat toolBarYPosition = screenRect.size.height-keyboardFrame.size.height-Toolbar_Height;
    [self updateToolBarYPosition:toolBarYPosition];
	[self showToolBarWithAnimation];
}

- (void)updateToolBarYPosition:(CGFloat)positionY {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    CGRect toolBarFrame = self.toolbar.frame;
    toolBarFrame.origin.y = positionY;
    [self.toolbar setFrame:toolBarFrame];
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note
{
	[self hideToolBarWithAnimation];

}
#pragma mark -
#pragma mark Highlight/Dehighlight cell Methods
-(void)dehilightCellWhenFocusChanged:(NSIndexPath*)indexPath
{
    [self. amountTableView deselectRowAtIndexPath:indexPath animated:NO];
	id cellObj = [self getCellAtIndexPath:indexPath];
	[[cellObj fieldLable] setTextColor:RepliconStandardBlackColor];
	[(UIButton *)[cellObj fieldButton] setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
	[[cellObj fieldText] setTextColor:RepliconStandardBlackColor];
    [cellObj setBackgroundColor:RepliconStandardBackgroundColor];
}
-(void)highLightTheSelectedCell:(NSIndexPath*)tappedIndex
{
//    CGPoint offset = [self.scrollView contentOffset];
//    scrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.frame.size.height+tableHeight-157);
//    CGRect rect1 = CGRectMake(self.view.frame.origin.x, offset.y, self.view.frame.size.width, 157);
//    [self.scrollView scrollRectToVisible:rect1 animated:NO];

    id cellObj = [self getCellAtIndexPath:tappedIndex];
    [cellObj setBackgroundColor:[UIColor lightGrayColor]];
    //[[cellObj fieldLable] setTextColor:iosStandaredWhiteColor];
    //[[cellObj fieldText] setTextColor:iosStandaredWhiteColor];
    //[[cellObj fieldButton]setTitleColor:iosStandaredWhiteColor forState:UIControlStateNormal];


}

-(void)cellTappedAtIndex:(NSIndexPath*)cellIndexPath
{
	id cellObj = [self getCellAtIndexPath:cellIndexPath];

	if (self.selectedIndexPath != nil  && ![self.selectedIndexPath isKindOfClass:[NSNull class]] && self.selectedIndexPath != cellIndexPath)
    {
		if (cellIndexPath.row != 0 && cellIndexPath.section != 0)
        {
            [self dehilightCellWhenFocusChanged:self.selectedIndexPath];
        }


		id textCell = [self getCellAtIndexPath:self.selectedIndexPath];
		if ([textCell fieldText] != nil)
        {
			[pickerView setHidden:YES];
			[[textCell fieldText] resignFirstResponder];
		}
	}
	if (cellIndexPath.row == 0 && cellIndexPath.section == 0 && [[cellObj fieldLable].text isEqualToString:RPLocalizedString(CURRENCY, @"") ])
    {

		[self buttonActions:[cellObj fieldButton]];
		[self highLightTheSelectedCell:cellIndexPath];
	}
    else
    {
		[[cellObj fieldText] becomeFirstResponder];
	}

	self.selectedIndexPath = cellIndexPath;

    if ([expenseType isEqualToString:Flat_With_Taxes] || [expenseType isEqualToString:Flat_WithOut_Taxes])
    {
         [self resetTableViewUsingSelectedIndex:cellIndexPath];
    }



}
-(AmountCellView *)getCellAtIndexPath:(NSIndexPath*)cellIndexPath
{
	AmountCellView *cellObj = (AmountCellView *)[self. amountTableView cellForRowAtIndexPath:cellIndexPath];
	return cellObj;
}


-(void)resetTableViewUsingSelectedIndex:(NSIndexPath*)selectedIndex
{

    if (selectedIndex!=nil)
    {
        [self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-keyBoardHeight)];
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.bounds.size.height+10);


	}
    if (selectedIndex==nil)
    {
        [self.scrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
         scrollView.contentSize = CGSizeMake(self.view.frame.size.width,self.view.bounds.size.height+10);

    }

}

-(void)currencyTappedButtonClicked:(id)sender
{
    [self highLightCurrencyTappedRow];
     [self configurePicker];
    [self SendRequestToGetSystemCurrencies];
//    [self showDataPicker:TRUE];
//    [self.pickerView reloadAllComponents];

}

-(void)highLightCurrencyTappedRow
{
    [self pickerDone:nil];

    if (self.selectedIndexPath != nil && ![self.selectedIndexPath isKindOfClass:[NSNull class]])
    {
        [self dehilightCellWhenFocusChanged:self.selectedIndexPath];
    }
    UITextField *amountTxtField=nil;
    if ([expenseType isEqualToString:Rated_With_Taxes] || [expenseType isEqualToString:Rated_WithOut_Taxes])
    {
        amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
                                             [NSIndexPath indexPathForRow:0 inSection:0]] fieldText ];
        [amountTxtField resignFirstResponder];
    }
    [self.currencyTappedButton setBackgroundColor:[UIColor lightGrayColor]];
    [self.currencyTappedButton setUserInteractionEnabled:FALSE];
}

-(void)dehighLightCurrencyTappedRow
{
    [self.currencyLabel setTextColor:[UIColor blackColor]];
    [self.currencyValueLabel setTextColor:[UIColor blackColor]];
    [self.currencyTappedButton setBackgroundColor:[UIColor clearColor]];
    [self.currencyTappedButton setUserInteractionEnabled:TRUE];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self pickerDone:nil];
}

-(void)rateTappedButtonClicked:(id)sender
{
    [self highLightRateTappedRow];

}

-(void)highLightRateTappedRow
{
    [self pickerDone:nil];

    if (addRateAndAmountLables.count>0 )
    {
        UILabel  *valueLbl=[addRateAndAmountLables objectAtIndex:0];
        NSInteger tag=(valueLbl.tag-100);
        UILabel *lbl=nil;
        for (id subview in self.scrollView.subviews)
        {
            if ([subview isKindOfClass:[UILabel class]])
            {
                UILabel *templbl=(UILabel *)subview;
                if (templbl.tag==tag && [templbl.text isEqualToString:RPLocalizedString(RATE, @"")])
                {
                    lbl=templbl;
                    break;
                }
            }
        }

        [lbl setTextColor:[UIColor whiteColor]];
        [valueLbl setTextColor:[UIColor whiteColor]];
        [self.rateTappedButton setBackgroundColor:[UIColor lightGrayColor]];
        [self.rateTappedButton setUserInteractionEnabled:FALSE];

        UITextField *fieldText=[[UITextField alloc]initWithFrame:valueLbl.frame];
        fieldText.keyboardAppearance = UIKeyboardAppearanceDefault;
        [fieldText setBackgroundColor:[UIColor clearColor]];
        fieldText.returnKeyType = UIReturnKeyDefault;
        //Fix for ios7//JUHI
        float version= [[UIDevice currentDevice].systemVersion newFloatValue];

        if (version>=7.0)
        {
            fieldText.keyboardAppearance=UIKeyboardAppearanceDark;
        }
        fieldText.keyboardType = UIKeyboardTypeNumberPad;
        fieldText.borderStyle = UITextBorderStyleNone;
        fieldText.clearButtonMode = UITextFieldViewModeWhileEditing;
        fieldText.textAlignment = NSTextAlignmentRight;
        [fieldText setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
        [fieldText setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        fieldText.tag=6782;
        fieldText.text=valueLbl.text;
        [fieldText setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
        [fieldText setDelegate:self];
        [self.scrollView addSubview:fieldText];
        [self.scrollView bringSubviewToFront:fieldText];
        [fieldText becomeFirstResponder];
        valueLbl.hidden=TRUE;
    }



}



-(void)dehighLightRateTappedRow
{

    if (addRateAndAmountLables.count>0 )
    {
        UILabel  *valueLbl=[addRateAndAmountLables objectAtIndex:0];
        NSInteger tag=(valueLbl.tag-100);
        UILabel *lbl=nil;
        for (id subview in self.scrollView.subviews)
        {
            if ([subview isKindOfClass:[UILabel class]])
            {
                UILabel *templbl=(UILabel *)subview;
                if (templbl.tag==tag && [templbl.text isEqualToString:RPLocalizedString(RATE, @"")])
                {
                    lbl=templbl;
                    break;
                }
            }
        }


        [lbl setTextColor:[UIColor blackColor]];
        [valueLbl setTextColor:[UIColor blackColor]];
        [self.rateTappedButton setBackgroundColor:[UIColor clearColor]];
        [self.rateTappedButton setUserInteractionEnabled:TRUE];


        UITextField *fieldText=(UITextField *)[self.scrollView viewWithTag:6782];
        if (fieldText!=nil)
        {
            rate=[fieldText.text newDoubleValue];
            UITextField *amountTxtField = [(AmountCellView *)[self. amountTableView cellForRowAtIndexPath:
                                                              [NSIndexPath indexPathForRow:0 inSection:0]] fieldText ];

            [self updateRatedExpenseData:amountTxtField];
            [fieldText removeFromSuperview];

            if([amountControllerDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                ExpenseEntryViewController *expenseEntryCtrl=(ExpenseEntryViewController *)amountControllerDelegate;
                expenseEntryCtrl.expenseEntryObject.expenseEntryRateAmount=fieldText.text;

            }
        }

        valueLbl.hidden=FALSE;
    }




}



#pragma mark - TextField delegate protocol

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{


    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!self.numberKeyPad)
    {
        self.numberKeyPad = [NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:self withMinus:NO andisDoneShown:NO withResignButton:NO];
        if ([textField textAlignment] == NSTextAlignmentRight)
        {
            [self.numberKeyPad.decimalPointButton setTag:333];
        }
    }
    else
    {
        //if we go from one field to another - just change the textfield, don't reanimate the decimal point button
        self.numberKeyPad.currentTextField = textField;
    }


    //textField.textAlignment = NSTextAlignmentCenter;
    if ([textField textAlignment] == NSTextAlignmentRight)
    {
        if (![textField.text isKindOfClass:[NSNull class] ])
        {
            if ([textField.text length] > 1)
                if ([textField.text characterAtIndex:[textField.text length]-1] != ' ')
                {
                    [textField setText:[NSString stringWithFormat:@"%@ ",[textField text]]];
                }
        }

    }


}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {



    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{

    if ([textField textAlignment] == NSTextAlignmentRight) {
        if (![textField.text isKindOfClass:[NSNull class] ])
        {
            if ([textField.text length] > 1) {

            }
        }

    }

    if (textField == numberKeyPad.currentTextField) {
        /*
         Hide the number keypad
         */
        [self.numberKeyPad removeButtonFromKeyboard];
        self.numberKeyPad = nil;
    }


}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{


    if (![textField.text isKindOfClass:[NSNull class] ])
    {
        if ([textField.text length]>= 4)
        {
            if (!([string isEqualToString:@""] && range.length == 1) && [textField.text length] >=10 )
            {
                return NO;
            }
        }
    }





    if ([textField textAlignment] == NSTextAlignmentRight) {
        [Util updateRightAlignedTextField:textField withString:string withRange:range withDecimalPlaces:4];
        return NO;
    }
    return YES;
}




#pragma mark -
#pragma mark Memory Based Methods
- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.scrollView=nil;
    self.footerViewAmount=nil;
    self.pickerView=nil;
    self.toolbar=nil;
    self.doneButton=nil;
    self.spaceButton=nil;
    self.textFieldSelected=nil;
    self.amountTableView=nil;
    self.currencyLabel=nil;
    self.currencyValueLabel=nil;
    self.ratedLabel=nil;
    self.ratedValueLable=nil;
    self.ratedTaxesLabel=nil;
    self.ratedTaxValueLable=nil;
    self.totalAmountLabel =nil;
    self.totalAmountValue=nil;
}



@end
