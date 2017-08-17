    //
//  AddDescriptionViewController.m
//  Replicon
//
//  Created by Devi Malladi on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2AddDescriptionViewController.h"
#import "G2ViewUtil.h"
#import "G2TimeEntryViewController.h"
#import "G2PendingTimesheetsViewController.h"


@implementation G2AddDescriptionViewController

@synthesize descTextView;
@synthesize textCountLable;
@synthesize clearButton; 
@synthesize descControlDelegate;
@synthesize fromEditing;
@synthesize descTextString;
@synthesize navBarTitle;
@synthesize timeEntryParentController;
@synthesize fromTimeEntryComments,fromTimeEntryUDF,fromExpenseDescription;


#define descriptionParentViewFrame CGRectMake(7, 7, 306, 185)
#define descriptionTextViewFrame CGRectMake(0, 0, 306, 160)
#define clearButtonFrame CGRectMake(12.0,155,45.0,25.0)//US4065//Juhi
#define textCountLableFrame CGRectMake(230,155, 87.0,25.0)//US4065//Juhi


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

- (void) setViewTitle: (NSString *)title
{
	[G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(title, title) ];
}

-(void)loadView
{
	[super loadView];
	if (descTextView == nil) {
		UITextView *tempdescTextView = [[UITextView alloc] init];
        self.descTextView=tempdescTextView;
       
	}
	CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame;
	UIView *view = [[UIView alloc] init];
	[view setFrame: descriptionParentViewFrame];
    //JUHI
    frame=view.frame;
    frame.size.height=screenRect.size.height-295;
    view.frame=frame;
	[view setBackgroundColor: [UIColor whiteColor]];
	view.layer.borderColor = [[UIColor lightGrayColor]CGColor];
	view.layer.borderWidth = 2.0f;
	view.layer.cornerRadius = 12.0f;
	//[descTextView setFrame:CGRectMake(13, 13, 292, 222)];//177+45
	[self.descTextView setFrame:descriptionTextViewFrame];
    //JUHI
    frame=descTextView.frame;
    frame.size.height=screenRect.size.height-320;
    self.descTextView.frame=frame;
    self.descTextView.textColor = RepliconStandardBlackColor;
	self.descTextView.scrollEnabled = YES;
	[self.descTextView setShowsVerticalScrollIndicator:YES];
	[self.descTextView setShowsHorizontalScrollIndicator:NO];
    //US4065//Juhi
    if (fromExpenseDescription || fromTimeEntryComments) {
        [self.descTextView setAutocorrectionType: UITextAutocorrectionTypeYes];
    }
    else
        [self.descTextView setAutocorrectionType: UITextAutocorrectionTypeNo];
	[self.descTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
	self.descTextView.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15];
	self.descTextView.delegate = self;
	//self.descTextView.contentInset =  UIEdgeInsetsMake(0, 11, 0, 11);//top,left,bottom,right
	self.descTextView.backgroundColor = [UIColor whiteColor];
	self.descTextView.returnKeyType = UIReturnKeyDefault;
	self.descTextView.keyboardType = UIKeyboardTypeDefault;
	self.descTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.descTextView setBackgroundColor:[UIColor clearColor]];
    [self.descTextView becomeFirstResponder];
	[view addSubview: self.descTextView];
	
	
	UIBarButtonItem *leftButton1 = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE)
																	style: UIBarButtonItemStylePlain 
																   target: self 
																   action: @selector(cancelAction:)];
	[self.navigationItem setLeftBarButtonItem:leftButton1 animated:NO];
	
	
	
	UIBarButtonItem *rightButton1 = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(@"Done", @"Done")
																	 style:UIBarButtonItemStylePlain 
																	target:self 
																	action:@selector(saveAction:)];
	[self.navigationItem setRightBarButtonItem:rightButton1 animated:NO];
		
	
	if (textCountLable == nil) {
		textCountLable = [[UILabel alloc] initWithFrame:textCountLableFrame];
        //JUHI
        frame=textCountLable.frame;
        frame.origin.y=screenRect.size.height-325;
        textCountLable.frame=frame;
	}
	[textCountLable setBackgroundColor:[UIColor clearColor]];
	[textCountLable setTextAlignment:NSTextAlignmentCenter];
	[textCountLable setTextColor:[UIColor grayColor]];
	[textCountLable setFont:[UIFont fontWithName:RepliconFontFamily size:15.0]];
	[view addSubview:textCountLable];
	
	
	if (clearButton==nil) {
		UIButton *tempclearButton=[[UIButton alloc]initWithFrame:clearButtonFrame];
        //JUHI
        frame=tempclearButton.frame;
        frame.origin.y=screenRect.size.height-325;
        tempclearButton.frame=frame;
        self.clearButton=tempclearButton;
       
	}
	[self.clearButton setTitle:RPLocalizedString(@"Clear", @"Clear") forState:UIControlStateNormal];
	[self.clearButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:14.0]];
	[self.clearButton.titleLabel setTextColor:[UIColor blueColor]];
	[self.clearButton setBackgroundColor:[UIColor clearColor]];
	[self.clearButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	[self.clearButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateHighlighted];//US4065//Juhi
	[self.clearButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[self.clearButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
	[view addSubview: self.clearButton];
	[self.view addSubview: view];
	
	
    

}
//US4275
-(void)viewDidAppear:(BOOL)animated
{
    if (fromTimeEntryComments) 
    {
        if ([timeEntryParentController isKindOfClass:[G2TimeEntryViewController class]] )
        {
            [timeEntryParentController performSelector:@selector(resignAnyKeyPads:) withObject:[timeEntryParentController   selectedIndexPath] afterDelay:0.1];
            [timeEntryParentController setIsFromDoneClicked:TRUE];
            [timeEntryParentController resetTableViewUsingSelectedIndex:nil];
        }
        
    }
    else {
        if ([timeEntryParentController isKindOfClass:[G2PendingTimesheetsViewController class]] )
        {
            [timeEntryParentController setIsFromCommentsScreen:TRUE];
        }
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
	
	[self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
	
	[self.navigationController.navigationItem setHidesBackButton:YES];
	
	if ([descTextString isEqualToString:RPLocalizedString(@"Add", @"") ]) {
		self.descTextView.text = @"";
	}else {
		self.descTextView.text=descTextString;
	}
     if (![self.descTextView.text isKindOfClass:[NSNull class] ]) 
     {
         textCountLable.text=[NSString stringWithFormat:@"%lu/255",(unsigned long)[self.descTextView.text length]];
     }
	
}



#pragma mark -
#pragma mark ButtonActions
#pragma mark -

-(void)clearAction
{
	//added below code for DE1783 to prolong highlighted color
	[clearButton setTitleColor:clearButtonHighlighetedColor forState:UIControlStateNormal];
	[self performSelector:@selector(resetClearButtonColor) withObject:nil afterDelay:0.5];
	[self.descTextView setText:RPLocalizedString(@"",@"")];
    if (![self.descTextView.text isKindOfClass:[NSNull class] ]) 
    {
       // textCountLable.text=[NSString stringWithFormat:@"0/255",[self.descTextView.text length]];
        textCountLable.text=@"0/255";
    }
	
}

-(void)resetClearButtonColor {
	//reset clear button color.
	[clearButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
}
-(void)cancelAction:(id)sender
{

	[self.navigationController popViewControllerAnimated:YES];
    
	[descControlDelegate performSelector:@selector(animateCellWhichIsSelected)];
	
}
-(void)saveAction:(id)sender
{
	[self.descTextView resignFirstResponder];
	if (fromTimeEntryComments) {
        
		[timeEntryParentController performSelector:@selector(updateComments:) withObject:self.descTextView.text];
        

	}
    else if (fromTimeEntryUDF) {
        if ([self.descTextView.text isEqualToString:@""]) {
            [timeEntryParentController performSelector:@selector(updateUDFText:) withObject:RPLocalizedString(@"Add", @"") ];
        }
		else
        {
             [timeEntryParentController performSelector:@selector(updateUDFText:) withObject:self.descTextView.text];
        }
	}
    else {
		[descControlDelegate performSelector:@selector(setDescription:) withObject:self.descTextView.text];
	}//expenses


	[self.navigationController popViewControllerAnimated:YES];
	[descControlDelegate performSelector:@selector(animateCellWhichIsSelected)];
	

}

#pragma mark -
#pragma mark UITextView Delegates
#pragma mark -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (![self.descTextView.text isKindOfClass:[NSNull class] ]) 
    {
        if ([self.descTextView.text length]>=255 && ![text isEqualToString:@""]) {
            [self.descTextView resignFirstResponder];
        }
    }
	
	return YES;
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (![self.descTextView.text isKindOfClass:[NSNull class] ]) 
    {
        textCountLable.text=[NSString stringWithFormat:@"%lu/255",(unsigned long)[self.descTextView.text length]];
        if ([self.descTextView.text length]>=255) {
            [self.descTextView resignFirstResponder];
        }
    }
	
	//DLog(@"height text view %f",descTextView.font.lineHeight);
	//DLog(@"height text view %f",descTextView.contentSize.height);
	
	if (self.descTextView.contentSize.height>140) {
        //JUHI
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGRect frame;
		//[self changeButtonFramesDynamically];
		[textCountLable setFrame:textCountLableFrame];
        
        frame=textCountLable.frame;
        frame.origin.y=screenRect.size.height-325;
        textCountLable.frame=frame;
		
        [clearButton setFrame:clearButtonFrame];
      
        frame=clearButton.frame;
        frame.origin.y=screenRect.size.height-325;
        clearButton.frame=frame;
	}
}
-(void)setDescriptionText:(NSString *)description{
	[self.descTextView setText:RPLocalizedString(description,@"set Description")];
	self.descTextView.text = RPLocalizedString(@"TEST",@"TEST");
}

-(void)changeButtonFramesDynamically
{
	[textCountLable setFrame:CGRectMake(211.0,self.descTextView.contentSize.height-10,85.0,45.0)];
	 
	 [clearButton setFrame:CGRectMake(11.0,self.descTextView.contentSize.height-10,45.0,45.0)];
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.descTextView=nil;
    self.clearButton=nil;
}





@end
