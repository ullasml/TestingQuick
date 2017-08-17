//
//  ReceiptsViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta R  on 26/03/13.
//  Copyright 2013 Replicon. All rights reserved.
//

#import "ReceiptsViewController.h"
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "ExpenseEntryViewController.h"

#define Image_Alert_Unsupported 5000
int  largeImageTag = 1000;

@interface ReceiptsViewController()
-(void)handleExpenseEntryReceiptResponse:(id)response;
-(void)showUnsupportedAlertMessage;
-(void) releaseCache;
@end


@implementation ReceiptsViewController

static NSString *imageContentSeperator = @"/";
static NSString *standardImageFormat = @"image";

@synthesize receiptImageView;
@synthesize recieptDelegate;
@synthesize receiptURI;
@synthesize sheetId;
@synthesize entryId;
@synthesize inNewEntry;
@synthesize defaultValue;
@synthesize canNotDelete;
@synthesize b64String;
@synthesize scrollView;
@synthesize receiptName;
//Impelemnted for Pdf Receipt //JUHI
@synthesize receiptWebView;
@synthesize receiptData;
@synthesize receiptFileType;

- (id) init
{
	self = [super init];
	if (self != nil) {
        
		UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]
										  initWithTitle:RPLocalizedString(@"Delete",@"Delete")
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
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.navigationController.navigationItem.hidesBackButton=YES;
    //[self.navigationController.navigationBar setTintColor:[Util getNavbarTintColor]];
    
    if (!canNotDelete){
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }else {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setHidesBackButton:YES];
    }
    
    if (!inNewEntry)
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        if (b64String != nil)
        {
            NSData *decodedString = [Util decodeBase64WithString: b64String];
            //Impelemnted for Pdf Receipt //JUHI
            [recieptDelegate performSelector: @selector(setReceiptFileType:) withObject:self.receiptFileType];
            if ([self.receiptFileType isEqualToString:@"pdf"])
            {
                [self setPdfOnEditing:decodedString];
            }
            else
                [self setImageOnEditing: decodedString];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        }
        else
        {
            
            if (receiptURI != nil || ![receiptURI isKindOfClass: [NSNull class]])
            {
                
                [[RepliconServiceManager expenseService] sendRequestToGetRecieptForSelectedExpense:receiptURI delegate:self];
            }
            else {
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            }
        }
    }
}
//Impelemnted for Pdf Receipt //JUHI
-(void)initializeImageView{
    UIScrollView *tempscrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView=tempscrollView;

    [scrollView setScrollEnabled:YES];
    [scrollView setDelegate:self];
    [self.view addSubview:scrollView];
    
    UIImageView *tempreceiptImageView=[[UIImageView alloc]initWithFrame:CGRectZero];
    self.receiptImageView=tempreceiptImageView;

    [receiptImageView setBackgroundColor:[UIColor blackColor]];
    [scrollView addSubview:receiptImageView];
    
   
}

-(void)initializeWebViewWithData:(NSData *)pdfData{
    UIWebView *tempreceiptWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.receiptWebView=tempreceiptWebView;

    receiptWebView.scalesPageToFit = YES;
    [receiptWebView setBackgroundColor:[UIColor clearColor]];
    [receiptWebView loadData:pdfData MIMEType: @"application/pdf" textEncodingName:@"UTF-8" baseURL:[[NSURL alloc] init]];
    [self.view addSubview:receiptWebView];
    
}
#pragma mark UIScrollViewDelegateMethods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return receiptImageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)pageScrollView {
    CGFloat zoomScale = pageScrollView.zoomScale;
    
    CGSize imageSize= receiptImageView.bounds.size;
    
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
	DLog(@"====> Orientation: %@", @(interfaceOrientation));
	return NO;
}

-(void)deleteAction:(id)sender
{
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		/*[Util confirmAlert: RPLocalizedString (@"No Internet Connectivity",@"") 
			  errorMessage: RPLocalizedString( @"You cannot modify receipt while offline.",@"")];
		return;*/
			#ifdef PHASE1_US2152
				[Util showOfflineAlert];
				return;
			#endif
	}
	NSString * message = RPLocalizedString(CONFIRM_DEL_RECEIPT_MSG, CONFIRM_DEL_RECEIPT_MSG);
	[self confirmAlert:RPLocalizedString (Delete_Button_title, Delete_Button_title) confirmMessage: message];
}



/*
 Localization for the button title and the message should be done by the calling method
 */
-(void)confirmAlert:(NSString *)_buttonTitle confirmMessage:(NSString*)message {

    UIAlertView *confirmAlertView = [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString (Cancel_Button_Title, Cancel_Button_Title)
                                   otherButtonTitle:RPLocalizedString (_buttonTitle,@"")
                                           delegate:self
                                            message:message
                                              title:nil
                                                tag:0];

	
	if (_buttonTitle == RPLocalizedString(Delete_Button_title, Delete_Button_title)) {
		confirmAlertView.tag=1;
	}



}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    
	if (alertView.tag==1) {	
		if (buttonIndex==1) {
            CLS_LOG(@"-----Delete image action on ReceiptsViewController -----");
			receiptImageView.image=nil;
			[recieptDelegate performSelector: @selector(setDeletedFlags)];

            ExpenseEntryViewController *expenseCtrl=(ExpenseEntryViewController *)recieptDelegate;
            
            if(expenseCtrl.screenMode==ADD_EXPENSE_ENTRY)
            {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }

			
			
		}
	}
	
	if (alertView.tag == largeImageTag) {

        ExpenseEntryViewController *expenseCtrl=(ExpenseEntryViewController *)recieptDelegate;
		if(expenseCtrl.screenMode==ADD_EXPENSE_ENTRY)
        {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
		
	}
}


-(void)saveAction:(id)sender
{
    CLS_LOG(@"-----Save Image action on ReceiptsViewController -----");
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    //Impelemnted for Pdf Receipt //JUHI
    if ([receiptFileType isEqualToString:@"pdf"]) {
        [self makeMyPdfSave];
        
    }
	else 
    {
        [self makeMyImageSave];
        
    }
	
	[recieptDelegate performSelector:@selector(setDescription:) withObject:RPLocalizedString(@"Yes", @"Yes") ];
	AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	[delegate setCurrVisibleViewController: nil];	

    
	ExpenseEntryViewController *expenseCtrl=(ExpenseEntryViewController *)recieptDelegate;
    if(expenseCtrl.screenMode==ADD_EXPENSE_ENTRY)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
	
}
- (void)pushToEntryView {
	
    @autoreleasepool {
        [self performSelector:@selector(makeMyImageSave) onThread:recThread withObject:nil waitUntilDone:YES];
    }
	
	
	
}  
-(void)makeMyPdfSave{
  @autoreleasepool {
      NSString *imgString= [Util encodeBase64WithData:receiptData];
      
      [recieptDelegate performSelector: @selector(setB64String:) withObject: imgString];
      //Impelemnted for Pdf Receipt //JUHI
      [recieptDelegate performSelector: @selector(setReceiptFileType:) withObject:self.receiptFileType];
      //[recieptDelegate performSelector: @selector(setB64String:) withObject: nil];
      [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
      AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
      [delegate setCurrVisibleViewController: nil];
      ExpenseEntryViewController *expenseCtrl=(ExpenseEntryViewController *)recieptDelegate;
      //Fix for ios7//JUHI
      float version=[[UIDevice currentDevice].systemVersion newFloatValue];
      if (version<7.0)
      {
          if(expenseCtrl.screenMode==ADD_EXPENSE_ENTRY)
          {
              [self dismissViewControllerAnimated:NO completion:nil];
          }
          else
          {
              [self.navigationController popViewControllerAnimated:YES];
          }
      }

  }
    	
}
-(void)makeMyImageSave
{
	@autoreleasepool {
		NSData *dataReceipt = UIImageJPEGRepresentation([Util resizeImage:receiptImageView.image withinMax:1600], 0.5);
		NSString *imgString= [Util encodeBase64WithData:dataReceipt];
		
		[recieptDelegate performSelector: @selector(setB64String:) withObject: imgString];
    //Impelemnted for Pdf Receipt //JUHI
    [recieptDelegate performSelector: @selector(setReceiptFileType:) withObject:self.receiptFileType];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
		AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
		[delegate setCurrVisibleViewController: nil];	


		ExpenseEntryViewController *expenseCtrl=(ExpenseEntryViewController *)recieptDelegate;
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion newFloatValue];
        if (version<7.0)
        {
            if(expenseCtrl.screenMode==ADD_EXPENSE_ENTRY)
            {
                [self dismissViewControllerAnimated:NO completion:nil];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }	}
}

-(void)setImageOnEditing:(NSData *)decodedImage{
	@autoreleasepool {
		UIImage *image = [UIImage imageWithData:decodedImage];
    //Impelemnted for Pdf Receipt //JUHI
    if (image!=nil)
    {
        [self initializeImageView];
        if (scrollView!=nil)
        {
            //Fix for ios7//JUHI
        	float version=[[UIDevice currentDevice].systemVersion newFloatValue];
        	CGRect frame=self.view.frame;
        	if (version>=7.0)
        	{
                frame.origin.y=0.0;
                
        	}
            [scrollView setFrame:frame];
            [self resetScrollView];
        }
        [self setImage:image];
    }
	}
}
//Impelemnted for Pdf Receipt //JUHI
-(void)setPdfOnEditing:(NSData *)urlData{
    
    if ( urlData )
    {
        self.receiptData=urlData;
        [self initializeWebViewWithData:urlData];

    }
    
    	
}
-(void)setImage:(UIImage*)image {
	image = [Util rotateImage:image byOrientationFlag:image.imageOrientation];

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
		AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
		[delegate setCurrVisibleViewController: nil];	


		ExpenseEntryViewController *expenseCtrl=(ExpenseEntryViewController *)recieptDelegate;
		if(expenseCtrl.screenMode==ADD_EXPENSE_ENTRY)
        {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
	}
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
	AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	[delegate setCurrVisibleViewController: nil];	

	ExpenseEntryViewController *expenseCtrl=(ExpenseEntryViewController *)recieptDelegate;
    if(expenseCtrl.screenMode==ADD_EXPENSE_ENTRY)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (void) serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState {
	

	[[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
	
    if (applicationState == Foreground)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
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



-(void)showErrorAlert:(NSError *) error
{

        [Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
    
}

- (void) serverDidRespondWithResponse:(id) response {
    
    if (response!=nil)
    {
		
        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
        
        if (errorDict!=nil)
        {

                NSString *errorMessage=[[errorDict objectForKey:@"details"] objectForKey:@"displayText"];
            if (errorMessage!=nil && ![errorMessage isKindOfClass:[NSNull class]])
            {
                [Util errorAlert:@"" errorMessage:errorMessage];
            }
            else
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)];
                NSString *serviceURL = [response objectForKey:@"serviceURL"];
                [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];            }
            
            
            
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            
        }
        else
        {
            
             NSMutableDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
            
            if (responseDict != nil && ![responseDict isKindOfClass:[NSNull class]])
            {
				[self handleExpenseEntryReceiptResponse: responseDict];
				[[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
			}
        }
    }
    
    
	
}


- (void) serverDidRespondWithDownloadCancelled:(id)response
{
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:self
                                            message:RPLocalizedString(LARGE_RECEIPT_IMAGE_MEMORY_WARNING,@" ")
                                              title:nil
                                                tag:largeImageTag];


}
#pragma mark IMAGE_MEMORY_WARNIG
-(void)showUnsupportedAlertMessage
{
    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:self
                                            message:RPLocalizedString(@"This receipt is in a format not supported by the image viewer \n \n Please log in to Replicon to view the receipt",@" ")
                                              title:nil
                                                tag:Image_Alert_Unsupported];

	[[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

	//unsupportedImageAlert = nil;		//fixed memory leak
}


-(void)handleExpenseEntryReceiptResponse:(id)response{
	
     NSMutableDictionary *imageDict=[response objectForKey:@"image"];
   self.receiptURI=[response objectForKey:@"uri"];
    if ([recieptDelegate isKindOfClass:[ExpenseEntryViewController class]])
    {
        ExpenseEntryViewController *expenseEntryVC=(ExpenseEntryViewController *)recieptDelegate;
        ExpenseEntryObject *obj=expenseEntryVC.expenseEntryObject;
        obj.expenseEntryExpenseReceiptUri=self.receiptURI;
    }
	NSString *imageFormat=[imageDict objectForKey:@"mimeType"];
	
    NSArray *imageContentsTypeArray = [Util splitStringSeperatedByToken:imageContentSeperator forString:imageFormat];
	NSString *fileFormat =nil;
	NSString *fileType=nil;
	if (imageContentsTypeArray !=nil && [imageContentsTypeArray count]>0) {
		fileFormat=[imageContentsTypeArray objectAtIndex:0];
		fileType=[imageContentsTypeArray objectAtIndex:1];
        self.receiptFileType=fileType;
	}
	NSMutableArray *appleSupportedImageFormats=[Util getAppleSupportedImageFormats];
	
	if ( ![fileFormat isEqualToString: standardImageFormat] || ![appleSupportedImageFormats containsObject: fileType]) {
        //Impelemnted for Pdf Receipt //JUHI
        if ([fileType isEqualToString:@"pdf"])
        {
            NSData *decodedString  = [Util decodeBase64WithString: [imageDict objectForKey:@"base64ImageData"]];
            [self setPdfOnEditing: decodedString];
            decodedString = nil;
            
        }
        else{
            [self showUnsupportedAlertMessage];
            response=nil;
        }
		
	}else {
		NSData *decodedString  = [Util decodeBase64WithString: [imageDict objectForKey:@"base64ImageData"]];
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

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

@end
