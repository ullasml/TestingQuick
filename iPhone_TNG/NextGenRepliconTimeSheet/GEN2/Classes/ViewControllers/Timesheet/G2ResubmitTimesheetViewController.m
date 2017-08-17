//
//  ResubmitTimesheetViewController.m
//  ResubmitTimesheet
//
//  Created by Sridhar on 29/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ResubmitTimesheetViewController.h"
#import "G2ViewUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "G2TimeEntryViewController.h"

#import "G2ListOfTimeEntriesViewController.h"
#import "G2TimesheetModel.h"
#import "RepliconAppDelegate.h"

@implementation G2ResubmitTimesheetViewController
@synthesize submitTextView;
@synthesize resubmitButton;
@synthesize reasonLabel;
@synthesize cancelButton;
@synthesize sheetIdentity;
@synthesize selectedSheet;
@synthesize allowBlankComments;
//US2669//Juhi
@synthesize actionType;
@synthesize delegate;
//US4754
@synthesize isSaveEntry;
//US4805
@synthesize isReopenClicked;
#define REOPEN_TAG 22222
#define RESUBMIT_TAG 11111

#pragma mark -
#pragma mark Initializer
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Custom initialization
    }
    return self;
}
*/
#pragma mark -
#pragma mark ViewLife Cycle Methods

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
//	if (navigationTitleView == nil) {
//		navigationTitleView = [[NavigationTitleView alloc]initWithFrame:EntriesTopTitleViewFrame];
//	}
//	
//	[navigationTitleView addTopToolBarLabel];
//	[navigationTitleView setTopToolbarlabelFrame:EntriesTopToolbarlabelFrame];
//	[navigationTitleView setTopToolbarlabelFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
//    [navigationTitleView.topToolbarlabel setShadowColor:[UIColor darkGrayColor]];
//    [navigationTitleView.topToolbarlabel setShadowOffset:CGSizeMake(0, -1)];//emboss effect (0,1)
//	[navigationTitleView setTopToolbarlabelText:NSLocalizedString (TimeEntryResubmitNavTitle,@"")];
//	
//	[navigationTitleView addInnerTopToolBarLabel];
//	[navigationTitleView setInnerTopToolbarlabelFrame:EntriesInnerTopToolbarlabelFrame];
//	[navigationTitleView setInnerTopToolbarlabelFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
//    [navigationTitleView.innerTopToolbarLabel setShadowColor:[UIColor darkGrayColor]];
//    [navigationTitleView.innerTopToolbarLabel setShadowOffset:CGSizeMake(0, -1)];//emboss effect (0,1)
//	[navigationTitleView setInnerTopToolbarlabelText:selectedSheet];
//	
//	self.navigationItem.titleView = navigationTitleView;
    
    //[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
	//US4754
	if ([actionType isEqualToString:@"ReopenTimesheetEntry"]) {
        [G2ViewUtil setToolbarLabel:self withText: RPLocalizedString(TimeEntryReopenNavTitle,@" ")];
    }
    else
	[G2ViewUtil setToolbarLabel:self withText: RPLocalizedString(TimeEntryResubmitNavTitle,@" ")];

	[self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
	//1.Add SubmitTextView
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame;
	if (submitTextView == nil) {
		UITextView *tempsubmitTextView = [[UITextView alloc] init];
		
        self.submitTextView=tempsubmitTextView;
      
		submitTextView.frame =SubmitTextViewFrame;
        //JUHI
        frame=submitTextView.frame;
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
            frame.size.height=screenRect.size.height-315;
        }
        else{
            frame.size.height=screenRect.size.height-300;
        }
        
        self.submitTextView.frame=frame;
	}
	if ([actionType isEqualToString:@"ReopenTimesheetEntry"]&& isSaveEntry)
    {
        frame=submitTextView.frame;
        frame.size.height=screenRect.size.height-350;//JUHI
        submitTextView.frame=frame;
    }	
	submitTextView.textColor = RepliconStandardBlackColor;//US4275//Juhi
	[submitTextView setShowsVerticalScrollIndicator:YES];
	submitTextView.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15];
	submitTextView.delegate = self;
	submitTextView.backgroundColor = [UIColor whiteColor];
	submitTextView.returnKeyType = UIReturnKeyDone;
	submitTextView.keyboardType = UIKeyboardTypeDefault;
	submitTextView.scrollEnabled = YES;
    //US4275//Juhi
    [[submitTextView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[submitTextView layer] setBorderWidth:1.0];
    [[submitTextView layer] setCornerRadius:9];
    [submitTextView setClipsToBounds: YES];
    //[submitTextView setScrollEnabled:FALSE];
	submitTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:submitTextView];
	
    //2.Add SheetLabel
    //US4275//Juhi
    UILabel *sheetLabel= [[UILabel alloc]initWithFrame:SheetLabelFrame];
    //JUHI
    frame=sheetLabel.frame;
    frame.origin.y=(screenRect.size.height/screenRect.size.width)*3.33;
    sheetLabel.frame=frame;
    sheetLabel.font =[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16];
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
	reasonLabel.frame = G2ReasonLabelFrame;
    //JUHI
    frame=reasonLabel.frame;
    frame.origin.y=(screenRect.size.height/screenRect.size.width)*13.33;
    reasonLabel.frame=frame;
    reasonLabel.font =[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16];
     //US4754
    if ([actionType isEqualToString:@"ResubmitTimesheetEntry"])
        [reasonLabel setText:RPLocalizedString(PleaseIndicateReasonsforResubmittingThisTimesheet,@" ")];
    else if ([actionType isEqualToString:@"ResubmitExpenseEntry"])
        [reasonLabel setText:RPLocalizedString(PleaseIndicateReasonsforResubmittingThisExpense,@" ")];
 else if([actionType isEqualToString:@"ReopenTimesheetEntry"])
        [reasonLabel setText:RPLocalizedString(PleaseIndicateReasonsforReopeningThisTimesheet,@" ")];
	[reasonLabel setTextAlignment:NSTextAlignmentCenter];
	[reasonLabel setNumberOfLines:3];
	[reasonLabel setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:reasonLabel];
	
	//4. Add ResubmitButton
	if (resubmitButton == nil) {
	resubmitButton =[UIButton buttonWithType:UIButtonTypeCustom];
	}
	UIImage *normalImg = [G2Util thumbnailImage:submitButtonImage];
	UIImage *highlightedImg = [G2Util thumbnailImage:submitButtonImageSelected];
	[resubmitButton setBackgroundImage:normalImg forState:UIControlStateNormal];
	[resubmitButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
    //JUHI
	[resubmitButton setFrame:CGRectMake(40.0,screenRect.size.height-240, normalImg.size.width, normalImg.size.height)];
	resubmitButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
	//US4754
	if ([actionType isEqualToString:@"ReopenTimesheetEntry"]) {
        [resubmitButton setTitle:RPLocalizedString(REOPEN,@"") forState:UIControlStateNormal];
        resubmitButton.tag=REOPEN_TAG;
    }
	else{
        [resubmitButton setTitle:RPLocalizedString(ResubmitTimesheet,@"") forState:UIControlStateNormal];
        resubmitButton.tag=RESUBMIT_TAG;
    }
	[resubmitButton addTarget:self action:@selector(resubmitButtonAction) forControlEvents:UIControlEventTouchUpInside];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

}


#pragma mark -
#pragma mark Button Action Methods

-(void)resubmitButtonAction{
    //US4754
    if ([resubmitButton tag]==RESUBMIT_TAG)
    {
        //US4275//Juhi
        NSString * message=nil;
        if ([actionType isEqualToString:@"ResubmitTimesheetEntry"])
            message= [NSString stringWithFormat:@"%@ ''%@'' %@?",RPLocalizedString(RESUBMIT, @"Resubmit"),selectedSheet,RPLocalizedString(timesheetForApproval, @" timesheet for approval?")];
        else
            message=[NSString stringWithFormat:@"%@ ''%@'' %@?",RPLocalizedString(RESUBMIT, @"Resubmit"),selectedSheet,RPLocalizedString(ExpenseForApproval, @" expense for approval?") ];
        
        [self confirmAlert:RPLocalizedString(RESUBMIT, @"Resubmit") confirmMessage:message];
    }
    
 else
    {
        NSString * message=nil;
        if (![selectedSheet isEqualToString:@""]) {
            message = [NSString stringWithFormat:@"%@ ''%@'' %@?",RPLocalizedString(@"Reopen", @"Reopen"),selectedSheet,RPLocalizedString(@"timesheet", @"timesheet")];
        }
        else
            message = [NSString stringWithFormat:@"%@ %@?",RPLocalizedString(@"Reopen", @"Reopen"),RPLocalizedString(@"timesheet", @"timesheet")];
		[self confirmAlert:RPLocalizedString(@"Reopen", @"Reopen")  confirmMessage:message];
    }  
}

-(void)cancelButtonAction{
    if (!allowBlankComments) {
        [self.resubmitButton setEnabled:NO];
	}else {
		[self.resubmitButton setEnabled:YES];
	}
	[submitTextView setText:@""];
	[self.navigationController popViewControllerAnimated:YES];
}
//US4275//Juhi
-(void) confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message {
	
	UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:message
															  delegate:self cancelButtonTitle:RPLocalizedString(CANCEL_BTN_TITLE, @"Cancel") otherButtonTitles:_buttonTitle,nil];
//US4754
    if ([_buttonTitle isEqualToString:RPLocalizedString(REOPEN,@"Reopen")]) 
    {
        [confirmAlertView setTag:REOPEN_TAG];
    }
    if ([_buttonTitle isEqualToString:RPLocalizedString(RESUBMIT, @"Resubmit")]) 
    {
        [confirmAlertView setTag:RESUBMIT_TAG];
    }  
	[confirmAlertView setDelegate:self];
	[confirmAlertView show];
	
	
	
}

//US4275//Juhi
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	 //US4754
	if (buttonIndex>0  && [alertView tag]== RESUBMIT_TAG)
    {  
		DLog(@"timesheet submitted");
        if ([[NetworkMonitor sharedInstance] networkAvailable] == NO) {
            //[Util errorAlert:RPLocalizedString(NoInternetConnectivity,@"") errorMessage:NSLocalizedString (YouCannotReSubmitTimesheetWhileOffline,@"")];
            //ravi - DE2983			
#ifdef PHASE1_US2152
            [G2Util showOfflineAlert];
            return;
#endif			
        }
        else {
            DLog(@"Sending Request to Submit TimeSheet:::ListOfTimeEntriesViewController");
            if (submitTextView.text == nil) {
                [submitTextView setText:@""];
            }
            //US2669//Juhi
             if ([actionType isEqualToString:@"ResubmitTimesheetEntry"]) {
                [[G2RepliconServiceManager timesheetService] submitTimesheetWithComments:sheetIdentity 
                                                                              comments:submitTextView.text];
            }
            else if([actionType isEqualToString:@"ResubmitExpenseEntry"])
            {
                [[G2RepliconServiceManager  expensesService]sendRequestToSubmitExpenseSheetWithID:sheetIdentity comments:submitTextView.text withDelegate:delegate];
                [self.navigationController popViewControllerAnimated:YES];
            }
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:SubmittingMessage];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToListOfTimeSheets) 
                                                         name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
        }

	}
 else if(buttonIndex>0 && [alertView tag]== REOPEN_TAG){
        if ([[NetworkMonitor sharedInstance] networkAvailable] == NO) {
            //[Util errorAlert:RPLocalizedString(NoInternetConnectivity,@"") errorMessage:NSLocalizedString (YouCannotReSubmitTimesheetWhileOffline,@"")];
            //ravi - DE2983			
#ifdef PHASE1_US2152
            [G2Util showOfflineAlert];
            return;
#endif			
        }
        else {
            
            [[G2RepliconServiceManager timesheetService]reopenTimesheetWithIdentity:sheetIdentity comments:submitTextView.text];
            
            if (isSaveEntry)
            {
                if ([delegate isKindOfClass:[G2TimeEntryViewController class]])
                {
                    //DE8182
                    [self.navigationController popViewControllerAnimated:YES];
                    G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *) delegate;
                    if (timeEntryCtrl.timeSheetEntryObject!=nil)
                    {
                        [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(saveTimeEntryForSheet) 
                                                                     name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] addObserver:delegate selector:@selector(saveTimeOffEntryForSheet) 
                                                                     name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
                    }
                }
                
               
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:ReopeningMessage];
                if ([delegate isKindOfClass:[G2TimeEntryViewController class]] )
                    [delegate setSelectedSheetIdentity:sheetIdentity];
                
            }
            else{
                self.isReopenClicked=YES;//US4805
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:ReopeningMessage];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToListOfTimeSheets) 
                                                             name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
            }
        }
    }
}


-(void)popToListOfTimeSheets{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
    //US4805
    if (self.isReopenClicked)
    {
        if ([delegate isKindOfClass:[G2ListOfTimeEntriesViewController class]] ){
            G2TimesheetModel *timesheetModel=[[G2TimesheetModel alloc]init];
            NSMutableArray *timesheetArray=[timesheetModel getTimesheetsForSheetFromDB:sheetIdentity];
            
            [delegate setSheetApprovalStatus:[[timesheetArray objectAtIndex:0] objectForKey:@"approvalStatus"]];
            G2TimeSheetObject *timesheetOb=[delegate timeSheetObj];
            [timesheetOb setApproversRemaining:[[[timesheetArray objectAtIndex:0] objectForKey:@"approversRemaining"]boolValue]];
            [timesheetOb setStatus:[[timesheetArray objectAtIndex:0] objectForKey:@"approvalStatus"]];
            if ([[[timesheetArray objectAtIndex:0] objectForKey:@"disclaimerAccepted"] isEqualToString:@"[Null]"]) {
                [timesheetOb setDisclaimerAccepted:nil];
            }
            [delegate setTimeSheetObj:timesheetOb];
            [delegate setCustomFooterView:nil];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
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

	return YES;
}

-(BOOL)textViewShouldEndEditing :(UITextView*) textField{
	
	return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;{
	[resubmitButton setEnabled:YES];
	return YES;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
#pragma mark -
#pragma mark Memory Based Methods
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.reasonLabel=nil;
    self.submitTextView=nil;
   
    self.cancelButton=nil;
}



@end
