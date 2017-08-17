//
//  ReceiptsViewController.m
//  Replicon
//
//  Created by Manoj  on 03/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ReceiptsViewController.h"
#import "G2RepliconServiceManager.h"
#import "RepliconAppDelegate.h"
#import "G2EditExpenseEntryViewController.h"

#define Image_Alert_Unsupported 5000
int  G2largeImageTag = 1000;

@interface G2ReceiptsViewController()
-(void)handleExpenseEntryReceiptResponse:(id)response;
-(void)showUnsupportedAlertMessage;
-(void) releaseCache;
@end


@implementation G2ReceiptsViewController

static NSString *imageContentSeperator = @"/";
static NSString *standardImageFormat = @"image";

@synthesize receiptImageView;
@synthesize recieptDelegate;
@synthesize sheetStatus;
@synthesize inNewEntry;
@synthesize defaultValue;
@synthesize canNotDelete;
@synthesize b64String;
@synthesize scrollView;

- (id) init
{
	self = [super init];
	if (self != nil) {

       UIScrollView *tempscrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        self.scrollView=tempscrollView;
        
        [scrollView setScrollEnabled:YES];
        [scrollView setDelegate:self];
        [self.view addSubview:scrollView];
		
		UIImageView *tempreceiptImageView=[[UIImageView alloc]initWithFrame:CGRectZero];
        self.receiptImageView=tempreceiptImageView;
       
		[receiptImageView setBackgroundColor:[UIColor blackColor]];
        [scrollView addSubview:receiptImageView];
        
		UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]
										  initWithTitle:RPLocalizedString(@"Delete", @"")
										  style:UIBarButtonItemStylePlain
										  target:self
										  action:@selector(deleteAction:)];
		self.navigationItem.leftBarButtonItem = deleteButton;

		
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
										initWithTitle:RPLocalizedString(@"Done", @"")
										style:UIBarButtonItemStylePlain
										target:self
										action:@selector(saveAction:)];
		self.navigationItem.rightBarButtonItem = saveButton;

	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    CGRect frame=self.view.frame;
    if (version>=7.0)
    {
        frame.origin.y=0;
        [scrollView setFrame:frame];
	}
    else{
        [scrollView setFrame:frame];
	}
    
    [self resetScrollView];
    
	[self.view setBackgroundColor:[UIColor blackColor]];
	self.navigationController.navigationItem.hidesBackButton=YES;
	//[self.navigationController.navigationBar setTintColor:[Util getNavbarTintColor]];
	
	if (!canNotDelete){
		[self.navigationItem.leftBarButtonItem setEnabled:YES];
	}else {
		[self.navigationItem setLeftBarButtonItem:nil];
		[self.navigationItem setHidesBackButton:YES];
	}
	
	if (!inNewEntry) {
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		NSDictionary *expenseEntry = [standardUserDefaults objectForKey:@"SELECTED_EXPENSE_ENTRY"];
		//NSString *entryIdentity = [expenseEntry objectForKey: @"identity"];
		if (b64String != nil) {
			NSData *decodedString = [G2Util decodeBase64WithString: b64String];
			[self setImageOnEditing: decodedString];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		} else	{
			if (expenseEntry != nil || ![expenseEntry isKindOfClass: [NSNull class]]) {
				//TODO: check if image has already been uploaded (check description for YES or ADD)
				if (![[expenseEntry objectForKey: @"expenseReceipt"] isEqualToString: @"No"]) {
					[[G2RepliconServiceManager expensesService] sendRequestToGetRecieptForSelectedExpense: [expenseEntry objectForKey:@"identity"] delegate:self];
					//[[RepliconServiceManager expensesService] sendRequsetWithTimeOutValue:60];
				} else {
					[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				}
				
			}
		}
	}
}


#pragma mark UIScrollViewDelegateMethods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return receiptImageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)pageScrollView {
    CGFloat zoomScale = pageScrollView.zoomScale;
    CGSize imageSize = receiptImageView.bounds.size;
    CGSize zoomedImageSize = CGSizeMake(imageSize.width * zoomScale, imageSize.height * zoomScale);
    CGSize pageSize = pageScrollView.bounds.size;
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (pageSize.width > zoomedImageSize.width) {
        inset.left = (pageSize.width - zoomedImageSize.width) / 2;
        inset.right = -inset.left;
    }
    if (pageSize.height > zoomedImageSize.height) {
        inset.top = (pageSize.height - zoomedImageSize.height) / 2;
        inset.bottom = -inset.top;
    }
    [pageScrollView setContentInset:inset];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation	{
	DLog(@"====> Orientation: %ld", (long)interfaceOrientation);
	return NO;
}

-(void)deleteAction:(id)sender
{
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		/*[Util confirmAlert: NSLocalizedString (@"No Internet Connectivity",@"") 
			  errorMessage: RPLocalizedString( @"You cannot modify receipt while offline.",@"")];
		return;*/
			#ifdef PHASE1_US2152
				[G2Util showOfflineAlert];
				return;
			#endif
	}
	NSString * message = RPLocalizedString(CONFIRM_DEL_RECEIPT_MSG, CONFIRM_DEL_RECEIPT_MSG);
	[self confirmAlert:RPLocalizedString(DELETE, DELETE) confirmMessage: message];
}



/*
 Localization for the button title and the message should be done by the calling method
 */
-(void)confirmAlert:(NSString *)_buttonTitle confirmMessage:(NSString*)message {
	UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle: nil message: message
															  delegate: self cancelButtonTitle: RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE)
													 otherButtonTitles: RPLocalizedString(_buttonTitle,@""),nil];
	[confirmAlertView setDelegate:self];
	[confirmAlertView setTag:0];
	
	if (_buttonTitle == RPLocalizedString(DELETE, DELETE)) {
		confirmAlertView.tag=1;

	}
    [confirmAlertView show];
    

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
    
	if (alertView.tag==1) {	
		if (buttonIndex==1) {
			receiptImageView.image=nil;
			[recieptDelegate performSelector: @selector(setDeletedFlags)];


			[self.navigationController popViewControllerAnimated:YES];
			[recieptDelegate performSelector:@selector(animateCellWhichIsSelected)];
		}
	}
	
	if (alertView.tag == G2largeImageTag) {


		[self.navigationController popViewControllerAnimated:YES];
		[recieptDelegate performSelector:@selector(animateCellWhichIsSelected)];
	}
}


-(void)saveAction:(id)sender
{
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
	[self makeMyImageSave];
	
	[recieptDelegate performSelector:@selector(setDescription:) withObject:RPLocalizedString(@"Yes", @"Yes") ];
	RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	[delegate setCurrVisibleViewController: nil];	

    
	[self.navigationController popViewControllerAnimated:YES];
	[recieptDelegate performSelector:@selector(animateCellWhichIsSelected)];
}
- (void)pushToEntryView {  
	
    @autoreleasepool {  
		[self performSelector:@selector(makeMyImageSave) onThread:recThread withObject:nil waitUntilDone:YES];
	}  
	
}  

-(void)makeMyImageSave
{
	@autoreleasepool {
		NSData *dataReceipt = UIImageJPEGRepresentation([G2Util resizeImage:receiptImageView.image withinMax:1600], 0.5);
		NSString *imgString= [G2Util encodeBase64WithData:dataReceipt];
		
		[recieptDelegate performSelector: @selector(setB64String:) withObject: imgString];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
		[delegate setCurrVisibleViewController: nil];	


		//Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version<7.0)
    {
        [self.navigationController popViewControllerAnimated:YES];
	}
	}
}

-(void)setImageOnEditing:(NSData *)decodedImage{
	@autoreleasepool {
		UIImage *image = [UIImage imageWithData:decodedImage];
    [self setImage:image];
	}
}

-(void)setImage:(UIImage*)image {
	image = [G2Util rotateImage:image byOrientationFlag:image.imageOrientation];

    [receiptImageView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
	[receiptImageView setImage:image];
    
    [scrollView setContentSize:receiptImageView.frame.size];
    [self resetScrollView];
}

-(void)resetScrollView {
    CGSize frameSize = scrollView.frame.size;
    CGSize contentSize = scrollView.contentSize;
    if (contentSize.width == 0 && receiptImageView.image != nil) {
        contentSize = receiptImageView.image.size;
    }
    
    float widthRatio = (float)frameSize.width / (float)contentSize.width;
    float heightRatio = (float)frameSize.height / (float)contentSize.height;
    float minScale = MIN(MIN(widthRatio, heightRatio), 1.0);
    [scrollView setMaximumZoomScale:3.0];
    [scrollView setMinimumZoomScale:minScale];
    [scrollView setZoomScale:minScale];
}

#pragma mark actionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex==0) {
		RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
		[delegate setCurrVisibleViewController: nil];	


		[self.navigationController popViewControllerAnimated:YES];
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	[delegate setCurrVisibleViewController: nil];	

	[self.navigationController popViewControllerAnimated:YES];
}


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

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
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void) serverDidFailWithError:(NSError *) error {
	

	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		[G2Util showOfflineAlert];
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

- (void) serverDidRespondWithResponse:(id) response {
	if (response!=nil) {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if ([status isEqualToString:@"OK"]) {
			NSArray *expenseReceiptArray = [[response objectForKey:@"response"]objectForKey:@"Value"];
			if (expenseReceiptArray != nil && [expenseReceiptArray count] != 0) {
				[self handleExpenseEntryReceiptResponse: expenseReceiptArray];
				[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];				
			}
		}
	}
}


- (void) serverDidRespondWithDownloadCancelled:(id)response
{
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	UIAlertView * largeImageAlert=[[UIAlertView alloc] 
									initWithTitle:nil 
									message: RPLocalizedString(LARGE_RECEIPT_IMAGE_MEMORY_WARNING,@" ") 
									delegate: self 
									cancelButtonTitle: RPLocalizedString(OK_BTN_TITLE, OK_BTN_TITLE) 
									otherButtonTitles:nil,nil];
	[largeImageAlert setTag:G2largeImageTag];
	largeImageAlert.delegate = self;
	[largeImageAlert show];
	
	
	
	
}
#pragma mark IMAGE_MEMORY_WARNIG
-(void)showUnsupportedAlertMessage
{
	UIAlertView * unsupportedImageAlert=[[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(@"This receipt is in a format not supported by the image viewer \n \n Please log in to Replicon to view the receipt",@" ") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil] ;//US4337//Juhi
	[unsupportedImageAlert setTag:Image_Alert_Unsupported];
	[unsupportedImageAlert show];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
	//unsupportedImageAlert = nil;		//fixed memory leak
}


-(void)handleExpenseEntryReceiptResponse:(id)response{
	G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
	NSMutableArray *receiptArray = [expensesModel getReceiptInfoForSelectedExpense:response];
	
	NSString *imageFormat=[[receiptArray objectAtIndex:0] objectForKey: @"CONTENT_TYPE"];
	NSArray *imageContentsTypeArray = [G2Util splitStringSeperatedByToken:imageContentSeperator originalString:imageFormat];
	NSString *fileFormat =nil;
	NSString *fileType=nil;
	if (imageContentsTypeArray !=nil && [imageContentsTypeArray count]>0) {
		fileFormat=[imageContentsTypeArray objectAtIndex:0];
		fileType=[imageContentsTypeArray objectAtIndex:1];
	}
	NSMutableArray *appleSupportedImageFormats=[G2Util getAppleSupportedImageFormats];
	
	if ( ![fileFormat isEqualToString: standardImageFormat] || ![appleSupportedImageFormats containsObject: fileType]) {
		[self showUnsupportedAlertMessage];
		response=nil;
		receiptArray=nil;
	}else {
		NSData *decodedString  = [G2Util decodeBase64WithString: [[receiptArray objectAtIndex:0] objectForKey:@"BASE64_STRING"]];
		[self setImageOnEditing: decodedString];
		decodedString = nil;
	}

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	//self.view = nil;
//	DLog(@"ReceiptsViewController=====>Memory Warning: %@", self.modalViewController);
	
    [super didReceiveMemoryWarning];

	/*RepliconAppDelegate *delegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	[recieptDelegate performSelector:@selector(setDescription:) withObject:@"Add"];
	if (delegate != nil)	{
		[delegate expenseEntryMemoryWarning];
	}*/
    // Release any cached data, images, etc that aren't in use.
	[self releaseCache];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.receiptImageView=nil;
    self.scrollView=nil;
}

-(void) releaseCache
{
	if (b64String != nil && ![b64String isKindOfClass: [NSNull class]]) {
		
		b64String = nil;
	}
}




@end
