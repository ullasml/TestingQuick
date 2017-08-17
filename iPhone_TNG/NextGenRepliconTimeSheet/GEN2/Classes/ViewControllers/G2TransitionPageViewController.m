//
//  TransitionPageViewController.m
//  Replicon
//
//  Created by Ravi Shankar on 7/30/11.
//  Copyright 2011 enl. All rights reserved.
//

#import "G2RepliconServiceManager.h"
#import "G2LoginViewController.h"
#import "G2LoginViewCell.h"
#import "G2TransitionPageViewController.h"
#import "G2Constants.h"
#import "RepliconAppDelegate.h"


@implementation G2TransitionPageViewController

static G2TransitionPageViewController *instance;

@synthesize currProcessType;
@synthesize delegate,lable;


#pragma mark -
#pragma mark Initialization

+(void) initialize
{
	static BOOL initialized = NO;
	if (!initialized) {
		initialized = YES;
		instance = [[G2TransitionPageViewController alloc] init];
	}
}


/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 self = [super initWithStyle:style];
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
		[NetworkMonitor sharedInstance];	
	}
	return self;
}

#pragma mark - 
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	backGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+60)];
	[backGroundImageView setImage:[G2Util thumbnailImage:TRANSITIONPAGE_BACKGROUND]];
    [self.view addSubview:backGroundImageView];
	
	UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 110, 100)];
	
	UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[progressView setHidesWhenStopped:YES];
	[progressView startAnimating];
	[view addSubview: progressView];
	
	lable = [[UILabel alloc] initWithFrame: CGRectMake(progressView.frame.size.width + 10, progressView.frame.origin.y, 150, progressView.frame.size.height)];
	[lable setBackgroundColor: [UIColor clearColor]];
	 [view addSubview: lable];
	
	view.center = self.view.center;
	[view setBackgroundColor: [UIColor clearColor]];
	[self.view addSubview: view];
	
	
	

}

#pragma mark -
#pragma mark NetworkMonitor related

- (void) networkActivated {
	    
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



#pragma mark -
#pragma mark ServerProtocolMethods
#pragma mark -


-(void)launchHomeScreen {
	DLog(@"Launching Home Screen");
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(launchHomeViewController)];
	//[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
}


-(void)serverDidRespondWithResponse:(id)response	{
    
    
    id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
    
    if ([_serviceID intValue]== UserIntegrationDetails_Service_ID_103)
    {
        
        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
        
        if (errorDict!=nil)
        {
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"hasError"] ];
            
        }
        else
        {
            
            [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:@"hasError"] ];
            
        }
        
        return;
    }

    
    if ([_serviceID intValue]== CompleteSAMLFlowRemoteAPIURL_Service_Id_105)
    {
         [[G2RepliconServiceManager loginService] processResponse: response];
        return;
    }
    
    
	NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
	if (![status isEqualToString:@"OK"]) {	
		NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		//DE3981
		if ([message isEqualToString:@"Object reference not set to an instance of an object."]) 
        {
            message = RPLocalizedString(ExternalUserErrorMessage, ExternalUserErrorMessage) ;
        }
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		if (value!=nil) {
            	if ([_serviceID intValue] == FetchCompanyURL_ServiceID_0 || [_serviceID intValue] == FetchAuthRemoteAPIUrl_Service_Id_91 || [_serviceID intValue] == FetchNewAuthRemoteAPIURL_Service_Id_104)
                {
                    NSDictionary   *notDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"hasError",value,@"errorMsg",nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:notDict ];
                    
                    [self.view removeFromSuperview];
                    return;

                }
            
            [G2Util errorAlert:@"" errorMessage:value];
		}else {
            if ([_serviceID intValue] == FetchCompanyURL_ServiceID_0 || [_serviceID intValue] == FetchAuthRemoteAPIUrl_Service_Id_91 || [_serviceID intValue] == FetchNewAuthRemoteAPIURL_Service_Id_104)
            {
                NSDictionary   *notDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"hasError",message,@"errorMsg",nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:notDict ];
                [self.view removeFromSuperview];
                
                return;
                
            }
            [G2Util errorAlert:@"" errorMessage:message];
		}
		[self.view removeFromSuperview];
	} else {
		[delegate processResponse: response];
//        if (!delegate) {
//            [[RepliconServiceManager loginService] processResponse: response];
//        }
	}
}

-(void) serverDidFailWithError:(NSError *) error {
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
	if (![NetworkMonitor isNetworkAvailableForListener:self]) {
		[G2Util showOfflineAlert];
		return;
	}
    
    /// In case for a BAD URL Request (can only occur when we use illegal characters in company field)
    if ([error code]==-1000) {
        UIAlertView *urlAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(InvalidCompanyName,InvalidCompanyName) delegate:self cancelButtonTitle:RPLocalizedString(@"OK",@"OK") otherButtonTitles:nil];
		[urlAlertView show];
		
		
		[self.view removeFromSuperview];
    }
    
    else  if ([error code]==-1001) {
        UIAlertView *urlAlertView = [[UIAlertView alloc] initWithTitle:nil message:[error localizedDescription] delegate:self cancelButtonTitle:RPLocalizedString(@"OK",@"OK") otherButtonTitles:nil];
		[urlAlertView show];
		
		
		[self.view removeFromSuperview];
    }
	
    else  if ([error code]==-1009) {
        [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
		return;
    }
    
	else if ([self currProcessType] == ProcessType_Login) {
		/*UIAlertView *loginAlertView = [[UIAlertView alloc] initWithTitle: nil
         message: RPLocalizedString(InvaliDLogin, InvaliDLogin)
         delegate: self
         cancelButtonTitle: RPLocalizedString( @"Support", @"Support")
         otherButtonTitles: NSLocalizedString (@"OK", @"OK"), nil];*/
		UIAlertView *loginAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(InvaliDLogin,InvaliDLogin) delegate:self cancelButtonTitle:RPLocalizedString(@"OK",@"OK") otherButtonTitles:nil];
		[loginAlertView show];
		
		
		[self.view removeFromSuperview];
        
        [[G2RepliconServiceManager loginService] handleEndSessionResponse];
	}
    //US1132 issue 1:
    else if ([self currProcessType] == ProcessType_Logout)
    {
        return;
    }
    //US1132 issue 1:
    else {
        [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
		return;
	}
    
    
}

-(void) serverDidRespondWithNonJSONResponse:(id)response {
	
	[self.view removeFromSuperview];
	if (response !=nil) {
		NSString *message = [[NSString  alloc] initWithData:response encoding:NSUTF8StringEncoding];
        [G2Util errorAlert:ErrorTitle errorMessage:message];
	}
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	[delegate removeUserInformationWithCookies];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloadCompanyView)];
    }
    else
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
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
}

+(NSString *) startProcessForType: (ProcessType)processType withData: (id)dataObj withDelegate: (id)delegate {
	
	[[G2TransitionPageViewController getInstance] setCurrProcessType: processType];
	[[G2TransitionPageViewController getInstance] setDelegate: delegate];
	[[[UIApplication sharedApplication] delegate] performSelector: @selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "") ];
	//[[[UIApplication sharedApplication] delegate] performSelector: @selector(showTransitionPage:) withObject: [TransitionPageViewController getInstance]];
	
	switch (processType) {
		case ProcessType_Login:
			[[G2RepliconServiceManager loginService] sendrequestToFetchAPIURLWithDelegate: [G2TransitionPageViewController getInstance]];
			break;
		case ProcessType_Logout:
			[[G2RepliconServiceManager loginService]sendRequestForSessionLogout: [G2TransitionPageViewController getInstance]];
			break;
		case ProcessType_ExpenseSheets:
			[[G2RepliconServiceManager expensesService] fetchExpenseSheetData];
			break;
		default:
			break;
	}
	return nil;
}

+(G2TransitionPageViewController *) getInstance
{
	if (instance == nil) {
		instance = [[G2TransitionPageViewController alloc] init];
	}
	return instance;
}




@end
