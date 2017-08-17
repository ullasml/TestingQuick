//
//  URLReader.m
//  Replicon
//
//  Created by Devi Malladi on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "URLReader.h"
#import"Util.h"
#import "AppDelegate.h"
#import "SNLog.h"
#import "LoginModel.h"
#import <Crashlytics/Crashlytics.h>
#import "ACSimpleKeychain.h"
#import "FrameworkImport.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsExpenseHistoryViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsTimeOffHistoryViewController.h"
#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "AttendanceNavigationController.h"
#import "PunchHistoryNavigationController.h"
#import "ShiftsNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "TeamTimeNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
#import "EventTracker.h"
#import <repliconkit/repliconkit.h>

#define SUCCESS_RESPONSE_CODE 200
#define FORBIDDEN_RESPONSE_CODE 403


@implementation URLReader


@synthesize delegate;
@synthesize urlStr; 
@synthesize refID;
@synthesize refDict;
@synthesize timeOutValue;
@synthesize startTime;
@synthesize testCode;


- (id) init
{
	self = [super init];
	if (self != nil)
    {
		
	}
	return self;
}


- (id) initWithRequest:(NSMutableURLRequest *)request delegate:(id<ServerResponseProtocol>) theDelegate{
	
	if (self = [self init])
    {
		
		self.delegate = theDelegate;
        urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		
	}
	
	return self;
}

- (void) cancelRequest {
	
	DLog(@"\nURLReader::CANCELLING REQUEST\n");
	
	if (urlConnection == nil)
    {
		DLog(@"urConnection getting failed");
	}
    else
    {
		[urlConnection cancel];
	}
	
}


- (void) start {
	
	DLog(@"\nURLReader::start\n");
	
	if (urlConnection == nil)
    {
		
		DLog(@"urConnection getting failed");
	}
    else
    {
		[urlConnection start];
	}
	
}

-(void)startSynchronusRequest :(NSMutableURLRequest *)_request{
	
	NSError *err;
	NSData *responseData=[NSURLConnection sendSynchronousRequest:_request returningResponse:nil error:&err];
	NSString *response=[[NSString  alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	
	if ([(NSMutableArray *)[JsonWrapper parseJson:response error:nil]count]==0) {
		
		NSDictionary *headerFields = _request.allHTTPHeaderFields;
        if ([[headerFields objectForKey:ApplicationStateHeaders]intValue]==Foreground && [Util requestMadeAfterApplicationWasLaunched:[headerFields objectForKey:RequestTimestamp]])
        {
            [self.delegate serverDidFailWithError:nil applicationState:Foreground];
        }
        else
        {
            [self.delegate serverDidFailWithError:nil applicationState:Background];
        }
		
		return;
	}
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:refDict ,@"refDict",
								 [JsonWrapper parseJson:response error:nil],@"response",
								 nil];
   
	
	NSDictionary *responseDict = [dict objectForKey: __Response_];
	if(responseDict != nil &&
	   [responseDict objectForKey:@"Status"] != nil &&
	   [[responseDict objectForKey:@"Status"] isEqualToString: __Unauthorized_])
	{
        
        [Util errorAlert:@"" errorMessage:[responseDict objectForKey:@"Message"]];
	}
    
}

-(void)handleCookiesResponse:(id)response
{
    NSString *serviceEndpointRootUrl = [[NSUserDefaults standardUserDefaults]objectForKey:@"serviceEndpointRootUrl"];
      NSString *domainName=nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"]!=nil)
    {
        NSArray *componentsArr=[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] componentsSeparatedByString:@"."];
        
        if ([componentsArr count]==4)
        {
            domainName=[NSString stringWithFormat:@"https://%@/", [[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString]];
        }
        else
        {
            NSArray *domainArr=[serviceEndpointRootUrl componentsSeparatedByString:@".staging"];
            
            if ([domainArr count]>1)
            {
                
                domainName=[[domainArr objectAtIndex:0] stringByAppendingString:@".staging"];
                
            }
            if (domainName == nil) {
                domainName = [[AppProperties getInstance] getAppPropertyFor: @"StagingDomainName"];
            }
            if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"beta"] || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"demo"]|| [[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"test"]|| [[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] hasPrefix:@"sl"] || [[[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] lowercaseString] hasPrefix:@"qa"])
            {
                NSArray *domainArr=[serviceEndpointRootUrl componentsSeparatedByString:@".com"];
                
                if ([domainArr count]>1)
                {
                    
                    domainName=[[domainArr objectAtIndex:0] stringByAppendingString:@".com"];
                    
                }
                
                if (domainName == nil) {
                    domainName = [[AppProperties getInstance] getAppPropertyFor: @"DomainName"];
                }
            }

        }
        
        
    }
    
    else
    {
        NSArray *domainArr=[serviceEndpointRootUrl componentsSeparatedByString:@".com"];
      
        if ([domainArr count]>1)
        {

            domainName=[[domainArr objectAtIndex:0] stringByAppendingString:@".com"];

        }
        
        if (domainName == nil) {
            domainName = [[AppProperties getInstance] getAppPropertyFor: @"DomainName"];
        }

    }
    
    
    NSLog(@"%@",[NSHTTPCookieStorage sharedHTTPCookieStorage]);
    
	    
    NSArray* allCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:domainName]];

    
    
     SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB deleteFromTable:@"cookies" inDatabase:@""];
    


    [myDB insertCookieData:[NSKeyedArchiver archivedDataWithRootObject:allCookies]];
   
}



-(void)startRequestWithTimeOutVal:(int)timeOutVal
{
	DLog(@"\nstartRequestWithTimeOutVal::start\n");
	
	[self setTimeOutValue:timeOutVal];
	[self setStartTime:[[NSDate date] timeIntervalSince1970]];
	
	if (urlConnection == nil)
    {
		DLog(@"urConnection getting failed");
	}
    else
    {
		[urlConnection start];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(launchLoginViewController)];
}

- (void) errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage {

    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:self
                                            message:errorMessage
                                              title:title
                                                tag:LONG_MIN];
}

-(void)handleResponseToShowErrorMessages:(id)message
{
	NSString *errorMessage = [NSString stringWithUTF8String:[message bytes]];
	[Util errorAlert:@"" errorMessage:errorMessage];
}

#pragma mark -
#pragma mark NSURLConnection delegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response{
	[self handleCookiesResponse:response];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger code = [httpResponse statusCode];
    NSLog(@"%d",code);

    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response HTTP Code ::::: %ld ",(long)code] forLogLevel:LoggerCocoaLumberjack];

    
    CLS_LOG(@"Response HTTP Code ::::: %ld ",(long)code);
    
    
    //US8470 Ullas M L
    if (code==SUCCESS_RESPONSE_CODE)
    {
        id _serviceId = [refDict objectForKey:@"refID"];
        if(_serviceId != nil)
        {
            
            int service_ID=[_serviceId intValue];
            if (service_ID==GetFirstTimesheets_ID_93||
                service_ID==NextRecentTimesheetDetails_Service_ID_3||
                service_ID==GetTimesheetUpdateData_Service_ID_87||
                service_ID==GetExpenseSheetData_Service_ID_27||
                service_ID==GetNextExpenseSheetData_Service_ID_28||
                service_ID==GetExpenseSheetUpdateData_Service_ID_88)
            {
                if ([response respondsToSelector:@selector(allHeaderFields)]) {
                    NSDictionary *dictionary = [httpResponse allHeaderFields];
                    NSString *serverTimestamp=[dictionary objectForKey:@"Date"];
                    
                    if (serverTimestamp!=nil && ![serverTimestamp isKindOfClass:[NSNull class]])
                    {
                        NSString *key=@"";
                        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                        if (service_ID==GetFirstTimesheets_ID_93||
                            service_ID==NextRecentTimesheetDetails_Service_ID_3||
                            service_ID==GetTimesheetUpdateData_Service_ID_87)
                        {
                            key=@"TimeSheetLastModifiedTime";
                            if (service_ID==GetFirstTimesheets_ID_93)
                            {
                                [defaults removeObjectForKey:@"ErrorTimeSheetLastModifiedTime"];
                                [defaults setObject:serverTimestamp forKey:@"ErrorTimeSheetLastModifiedTime"];
                            }
                        }
                        else if (service_ID==GetExpenseSheetData_Service_ID_27||
                                 service_ID==GetNextExpenseSheetData_Service_ID_28||
                                 service_ID==GetExpenseSheetUpdateData_Service_ID_88)
                        {
                            key=@"ExpenseSheetLastModifiedTime";
                        }
                        //Implementation of TimeSheetLastModified
                        

                       
                       
                        [defaults removeObjectForKey:key];
                        [defaults setObject:serverTimestamp forKey:key];
                        [defaults synchronize];
                    }
                    
                    
                }
            }
            
            
            
        }
    }
    else if (code==FORBIDDEN_RESPONSE_CODE)
    {
        
        id _serviceId = [refDict objectForKey:@"refID"];
        if(_serviceId != nil)
        {
            
            if ([_serviceId intValue]!= HomeSummaryDetails_Service_ID_1 && [_serviceId intValue]!=UserIntegrationDetails_Service_ID_0 &&  [_serviceId intValue]!=UserIntegrationDetailsiOS7_Service_ID_89 &&  [_serviceId intValue]!=UserIntegrationDetailsForFreeTrail_Service_ID_113 )
            {
                NSString *responseHeaders=response.description;

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for SID ::::: %@ \n  ---and headers--- \n%@\n ----- \n",_serviceId,responseHeaders] forLogLevel:LoggerCocoaLumberjack];

                
                CLS_LOG(@"Response Received for SID ::::: %@ \n  ---and headers--- \n%@\n ----- \n",_serviceId,responseHeaders);
                
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                
                [UIAlertView showAlertViewWithCancelButtonTitle:nil
                                               otherButtonTitle:RPLocalizedString(APP_REFRESH_DATA_TITLE, @"")
                                                       delegate:appDelegate
                                                        message:RPLocalizedString(USER_FRIENDLY_ERROR_MSG, @" ")
                                                          title:nil
                                                            tag:555];

                [self cancelRequest];
                
                

                NSString *serviceURL = [[[connection currentRequest] URL] absoluteString];
                [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(USER_FRIENDLY_ERROR_MSG, USER_FRIENDLY_ERROR_MSG) serviceURL:serviceURL];
            }
            
            
        }
        
        
        
    }
    
    
    
    testCode=code;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	
	if (startTime > 0 && ((startTime + timeOutValue) < [[NSDate date] timeIntervalSince1970])) {
		if ([self.delegate respondsToSelector:@selector(serverDidRespondWithDownloadCancelled:)]) {
			[self cancelRequest];
			[self.delegate serverDidRespondWithDownloadCancelled:[NSNumber numberWithInt:timeOutValue]];
			return;
		}
	}
	
	if (recievedData == nil) {
		recievedData = [[NSMutableData alloc] initWithData:data];
	} else {
		[recievedData appendData:data];
	}
    
	
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *responseStr = [[NSString  alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
 //   NSLog(@"%@",responseStr);
  
   /////// [IMPORTANT]UNCOMMENT THIS ONLY FOR DEBUGING. PLEASE DON"T PROMOTE TO PRODUCTION.

    /*if ([[refDict objectForKey:@"refID"]intValue]==4)
    {
        //if you are reading from txt file (comment the next line if you are using this function)
        //[self simulateResponseFromJsonFixture];

        //if you are reading from plist file (comment the previous line if you are using this function)
        //[self simulateResponseFromPlist];
    }*/

   
    
    id parsedData = [JsonWrapper parseJson: recievedData error: nil];
	@try
    {
        NSURL *responseURL = [[connection currentRequest] URL];
        BOOL isErrorPresent = (testCode == 504 || testCode == 503 || testCode == 303);
		if (parsedData != nil && [parsedData isKindOfClass: [NSDictionary class]] )
        {
            if (isErrorPresent)
                return [self errorWith:responseURL withDomain:serviceUnavailabilityIssue withCode:testCode request:connection.currentRequest];

			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         refDict ,@"refDict",
										 parsedData,@"response",
                                         [responseURL absoluteString],@"serviceURL",
										 nil];
            
			NSDictionary *responseDict = [dict objectForKey: __Response_];
			if(responseDict != nil &&[responseDict objectForKey:@"Status"] != nil &&
			   [[responseDict objectForKey:@"Status"] isEqualToString: __Unauthorized_])
			{
                [Util errorAlert:@"" errorMessage:[responseDict objectForKey:@"Message"]];
			}
            else
            {
				NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                
				id _serviceId = [[dict objectForKey:@"refDict"]objectForKey:@"refID"];
				if(_serviceId != nil)
                {
                    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for SID ::::: %@ \n %@",_serviceId,responseStr] forLogLevel:LoggerCocoaLumberjack];

                    
                    CLS_LOG(@"Response Received for SID ---- %@ \n %@",_serviceId,responseStr);
                    NSString *strServiceID=[NSString stringWithFormat:@"%@",_serviceId];
					[standardDefaults setObject: [NSDate date] forKey: strServiceID];
                    [standardDefaults synchronize];
                    
                    if ([_serviceId intValue]==FirstProgramsAndProjectsSummaryDetails_Service_ID_153||
                        [_serviceId intValue]==GetProjectsBasedOnPrograms_Service_ID_154||
                        [_serviceId intValue]==FirstProgramsSummaryDetails_Service_ID_155||
                        [_serviceId intValue]==NextProgramsSummaryDetails_Service_ID_156||
                        [_serviceId intValue]== FirstClientsAndProjectsSummaryDetails_Service_ID_13||
                        [_serviceId intValue]== FirstTasksSummaryDetails_Service_ID_16||
                        [_serviceId intValue]== GetProjectsBasedOnclient_Service_ID_18 || [_serviceId intValue]== GetBillingData_Service_ID_22 || [_serviceId intValue]==GetActivityData_Service_ID_24 ||[_serviceId intValue]==GetBreakData_Service_ID_90||[_serviceId intValue]==GetPageOfTimeOffTypesAvailableForTimeAllocationFilteredByTextSearch_75 ||[_serviceId intValue]==GetActivitiesForUser_Service_ID_106||[_serviceId intValue]==GetNextActivitiesForUser_Service_ID_107||[_serviceId intValue]==GetOEFDropDownTagOption_Service_ID_171||[_serviceId intValue]==GetNextOEFDropDownTagOption_Service_ID_172
                        )
                    {
                        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                        NSString *storedString=[NSString stringWithFormat:@"%@",[defaults objectForKey:@"SearchString"]];
                        NSString *searchString=[NSString stringWithFormat:@"%@",[[dict objectForKey:@"refDict"]objectForKey:@"params"]];
                        if (![searchString isEqualToString:storedString])
                        {
                            return;
                        }
                        
                    }
                    
                    

				}
				
                BOOL exceptionMessage = FALSE;
                
                if([_serviceId intValue]==999 || [_serviceId intValue]==GetUserByUserName_145 || [_serviceId intValue]==ContactMobileSupport_149 || [_serviceId intValue]== GetServerDownStatus_150 || [_serviceId intValue]== HomeSummaryDetails_Service_ID_1)
                {
                    
                }
                else
                {
                    exceptionMessage = [self checkForExceptions:dict];
                }
                
				if (!exceptionMessage)
                {
                    //Fault Exception Implementation For flurry//JUHI
                    if (Util.isRelease)
                    {
                        NSString *companyName=nil;
                        NSString *correlationId=nil;
                        NSString *userID=nil;
                        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"]isKindOfClass:[NSNull class] ])
                        {
                            userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
                            
                        }
                        // MOBI-471
                        ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
                        NSDictionary *credentials =  nil;
                        if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
                            credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
                            if (credentials != nil && ![credentials isKindOfClass:[NSNull class]])
                            {
                                companyName = [credentials valueForKey:ACKeychainCompanyName];
                            }
                        }
                        
                        if ([responseDict objectForKey:@"error"]!=nil && ![[responseDict objectForKey:@"error"] isKindOfClass:[NSNull class]] ) {
                            NSDictionary *errorDict=[responseDict objectForKey:@"error"];
                            if ([errorDict objectForKey:@"code"]!=nil && ![[errorDict objectForKey:@"code"] isKindOfClass:[NSNull class]]) {
                                if ([[errorDict objectForKey:@"code"] isEqualToString:FAULT_CONTRACT_EXCEPTION])
                                {
                                    if ([errorDict objectForKey:@"correlationId"]!=nil && ![[errorDict objectForKey:@"correlationId"] isKindOfClass:[NSNull class]]) {
                                        correlationId=[NSString stringWithFormat:@"%@",[errorDict objectForKey:@"correlationId"]];
                                    }
                                    
                                    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:companyName,@"CName",userID,@"userID",correlationId,@"correlationId", nil];
                                    [EventTracker.sharedInstance log:@"FaultException"
                                                   withParameters:params];
                                }
                            }
                        
                             
                        }
                       
                        
                    }
                    
                    if ([_serviceId intValue]!= ContactMobileSupport_149)
                    {
                        [self.delegate serverDidRespondWithResponse:dict];
                    }

                    if ([_serviceId intValue]== HomeSummaryDetails_Service_ID_1)
                    {
                        NSMutableDictionary *lastHomeFlowServiceResponseDict = [NSMutableDictionary dictionaryWithDictionary:dict];
                        [lastHomeFlowServiceResponseDict setObject:recievedData forKey:@"response"];
                        [[NSUserDefaults standardUserDefaults] setObject:lastHomeFlowServiceResponseDict forKey:@"lastHomeFlowServiceResponse"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    
				}
                
				
			}
		}
        else
        {
			if (recievedData != nil)
            {
                id _serviceId = [refDict objectForKey:@"refID"];

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Parsed Data is nil\n"] forLogLevel:LoggerCocoaLumberjack];

                
                CLS_LOG(@"Parsed Data is nil\n");
                    if(_serviceId != nil && responseStr!=nil)
                    {
                        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for SID ::::: %@ \n %@",_serviceId,responseStr] forLogLevel:LoggerCocoaLumberjack];
                        
                         CLS_LOG(@"Response Received for SID ::::: %@ \n %@",_serviceId,responseStr);
                        
                        //SERVICE HANDLES FOR FREE TRAILS
                        if ([responseStr length] < 100) {
                            if ([_serviceId intValue]== ValidateCompanyNameForFreeTrial_Service_ID_111)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:COMPANY_NAME_VALIDATION_DATA_NOTIFICATION  object:responseStr  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:false] forKey:@"isError"]];
                                return;
                            }
                            else if ([_serviceId intValue]== ValidateEmailAddressForfreeTrial_Service_ID_110)
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:EMAIL_VALIDATION_DATA_NOTIFICATION  object:responseStr  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:false] forKey:@"isError"]];
                                return;
                            }
                        }

                    }
                    
//                }

                if ([_serviceId intValue]== CurrentGenFetchRemoteApiUrl_73)
                {
                   
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
                    
                    
                    return;
                    
                }
                
                else if ([_serviceId intValue]== ApprovalsCountDetails_Service_ID_6 || [_serviceId intValue]== GetMyNotificationSummary_148)
                {
                    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                    appDelegate.isCountPendingSheetsRequestInQueue=FALSE;
                    
                }

                if (isErrorPresent)
                    [self errorWith:responseURL withDomain:serviceUnavailabilityIssue withCode:testCode request:connection.currentRequest];
                else{
                    [self errorWith:responseURL withDomain:__NonJsonResponse withCode:404 request:connection.currentRequest];
                }
			}
            else
            {
                id _serviceId = [refDict objectForKey:@"refID"];

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Parsed Data and Received Data is nil\n"] forLogLevel:LoggerCocoaLumberjack];

                
                CLS_LOG(@"Parsed Data and Received Data is nil\n");
                    if(_serviceId != nil && responseStr!=nil)
                    {
                        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for SID ::::: %@ \n %@",_serviceId,responseStr] forLogLevel:LoggerCocoaLumberjack];

                        
                         CLS_LOG(@"Response Received for SID ::::: %@ \n %@",_serviceId,responseStr);
                    }
                    
//                }
                
                if ([_serviceId intValue]== ApprovalsCountDetails_Service_ID_6 || [_serviceId intValue]== GetMyNotificationSummary_148)
                {
                    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                    appDelegate.isCountPendingSheetsRequestInQueue=FALSE;
                    
                }

                if ([_serviceId intValue]!= ContactMobileSupport_149 && [_serviceId intValue]!= GetServerDownStatus_150 && [_serviceId intValue]!= CurrentGenFetchRemoteApiUrl_73)
                {

                    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                                   otherButtonTitle:nil
                                                           delegate:nil
                                                            message:RPLocalizedString(UNKNOWN_ERROR_MESSAGE,UNKNOWN_ERROR_MESSAGE)
                                                              title:nil
                                                                tag:LONG_MIN];

                
                     NSString *serviceURL = [responseURL absoluteString];
                     [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, serviceURL) serviceURL:serviceURL];
                 }
                     
                else if ([_serviceId intValue]== CurrentGenFetchRemoteApiUrl_73)
                {
                    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK",@"OK")
                                                   otherButtonTitle:nil
                                                           delegate:nil
                                                            message:RPLocalizedString(COMPANY_NOT_EXISTS_ERROR_MESSAGE, COMPANY_NOT_EXISTS_ERROR_MESSAGE)
                                                              title:nil
                                                                tag:LONG_MIN];

                }
                
               
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                
                if ([_serviceId intValue]!= UserIntegrationDetails_Service_ID_0 && [_serviceId intValue]!= UserIntegrationDetailsiOS7_Service_ID_89 && [_serviceId intValue]!= UserIntegrationDetailsForFreeTrail_Service_ID_113 && [_serviceId intValue]!= ContactMobileSupport_149  && [_serviceId intValue]!= GetServerDownStatus_150 && [_serviceId intValue]!= CurrentGenFetchRemoteApiUrl_73 )
                {
                    
                    [[[UIApplication sharedApplication]delegate]performSelector:@selector(launchLoginViewController)];
                }
                else
                {
                    
                    
                }
                
                
            }
			return;
		}
	}
	@finally
    {
		 recievedData = nil;
	}
}


-(void)errorWith:(NSURL*)responseUrl withDomain:(NSString*)domain withCode:(NSInteger)code request:(NSURLRequest *)_request
{
    id _serviceId = [refDict objectForKey:@"refID"];
    NSString *errorMessage = [NSString stringWithUTF8String:[recievedData bytes]];
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:errorMessage forKey:NSLocalizedDescriptionKey];
    [details setValue:[responseUrl absoluteString] forKey:@"NSErrorFailingURLStringKey"];
    NSError *error = nil;;
    error = [NSError errorWithDomain:domain code:code userInfo:details];
    if ([_serviceId intValue]!= ContactMobileSupport_149 && [_serviceId intValue]!= GetServerDownStatus_150)
    {
        NSDictionary *headerFields = _request.allHTTPHeaderFields;
        if ([[headerFields objectForKey:ApplicationStateHeaders]intValue]==Foreground && [Util requestMadeAfterApplicationWasLaunched:[headerFields objectForKey:RequestTimestamp]])
        {
            [self.delegate serverDidFailWithError:error applicationState:Foreground];
        }
        else
        {
            [self.delegate serverDidFailWithError:nil applicationState:Background];
        }
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
	
	return nil;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    
    if ([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        return YES;
    }
    else
	   return NO;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([[challenge.protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    	
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"URLReader::didFailWithError");
    NSLog(@"%@",[error description]);
    
    [self cancelRequest];

    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

    
      CLS_LOG(@"Response Failed ::::: %@ ",[error description]);
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    id _serviceId = [refDict objectForKey:@"refID"];
    if ([_serviceId intValue]== UserIntegrationDetails_Service_ID_0)
    {
        
        
        NSDictionary   *notDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"isError",RPLocalizedString(COMPANY_NOT_EXISTS_ERROR_MESSAGE, COMPANY_NOT_EXISTS_ERROR_MESSAGE),@"errorMsg",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:notDict ];
        
        return;
    }
    
    else if ([_serviceId intValue]== CurrentGenFetchRemoteApiUrl_73)
    {
        
        
        [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
        
        
        return;
        
    }
    else if ([_serviceId intValue]== ApprovalsCountDetails_Service_ID_6 || [_serviceId intValue]== GetMyNotificationSummary_148)
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        appDelegate.isCountPendingSheetsRequestInQueue=FALSE;
       
    }
    else if ([_serviceId intValue]== HomeSummaryDetails_Service_ID_1)
    {
        NSMutableDictionary *lastHomeFlowServiceResponse = [[[NSUserDefaults standardUserDefaults]objectForKey:@"lastHomeFlowServiceResponse"]mutableCopy];
        if (lastHomeFlowServiceResponse)
        {
            id parsedData = [JsonWrapper parseJson: lastHomeFlowServiceResponse[@"response"] error: nil];
            if (parsedData != nil && [parsedData isKindOfClass: [NSDictionary class]] )
            {
                [lastHomeFlowServiceResponse setObject:parsedData forKey:@"response"];
                [self.delegate serverDidRespondWithResponse:lastHomeFlowServiceResponse];
                return;
            }
        }

    }

    
    if ([_serviceId intValue]!= ContactMobileSupport_149 && [_serviceId intValue]!= GetServerDownStatus_150 && [_serviceId intValue]!= GetMyNotificationSummary_148)
    {
        NSDictionary *headerFields = connection.currentRequest.allHTTPHeaderFields;
        if ([[headerFields objectForKey:ApplicationStateHeaders]intValue]==Foreground && [Util requestMadeAfterApplicationWasLaunched:[headerFields objectForKey:RequestTimestamp]])
        {
            [self.delegate serverDidFailWithError:error applicationState:Foreground];
        }
        else
        {
            [self.delegate serverDidFailWithError:nil applicationState:Background];
        }
    }
}

#pragma mark -
#pragma mark Exception handler
/************************************************************************************************************
 @Function Name   : checkForExceptions
 @Purpose         : To check for known exceptions
 @param           : (NSDictionary *)response
 @return          : BOOL to check is exception or not
 *************************************************************************************************************/

-(BOOL)checkForExceptions:(NSDictionary *)response
{
    BOOL exception=NO;
    
    NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
    
    NSString *errorURI=@"";
    if (errorDict!=nil)
    {
        
        NSArray *notificationsArr=[[errorDict objectForKey:@"details"] objectForKey:@"notifications"];
        if (notificationsArr!=nil && ![notificationsArr isKindOfClass:[NSNull class]])
        {
            for (int i=0; i<[notificationsArr count]; i++)
            {
                
                NSDictionary *notificationDict=[notificationsArr objectAtIndex:i];
                
                errorURI=[notificationDict objectForKey:@"failureUri"];
                
                exception=[self validateForFailureURIWithURI:errorURI forErrorDict:response];
                
                if (exception)
                {
                    break;
                }
                
            }
        }
    

        
    }

/*
    NSString  *errorReason = [errorDict objectForKey:@"reason"];
    
    if (errorReason != nil && ![errorReason isKindOfClass:[NSNull class]]) {
        if ([errorReason rangeOfString:@"All access checks failed to authorize access to the following objects:"].location!=NSNotFound) {
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

            [UIAlertView showAlertViewWithCancelButtonTitle:nil
                                           otherButtonTitle:RPLocalizedString(APP_REFRESH_DATA_TITLE, @"")
                                                   delegate:appDelegate
                                                    message:RPLocalizedString(USER_FRIENDLY_ERROR_MSG, @" ")
                                                      title:nil
                                                        tag:555];

            return exception;
        }
    }
*/
    
    if (!exception)
    {
        errorURI=[[errorDict objectForKey:@"details"] objectForKey:@"failureUri"];
        exception=[self validateForFailureURIWithURI:errorURI forErrorDict:response];
    }
    
    
    return exception;
}

-(BOOL)validateForFailureURIWithURI:(NSString *)errorURI forErrorDict:(NSDictionary *)responseDictionary
{

    NSString *serviceURL = [responseDictionary objectForKey:@"serviceURL"];

    BOOL exception=NO;
    BOOL uriError=NO;
    NSDictionary *errorDictionary = [[responseDictionary objectForKey:@"response"]objectForKey:@"error"];
     AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *errorMessage=@"";
    if (![errorURI isKindOfClass:[NSNull class]] && errorURI!=nil )
    {
        if ([errorURI isEqualToString:COMPANY_NOT_EXISTS_ERROR])
        {
            errorMessage=RPLocalizedString(COMPANY_NOT_EXISTS_ERROR_MESSAGE, COMPANY_NOT_EXISTS_ERROR_MESSAGE);
            //[appDelegate launchCompanyViewController];
            exception=YES;
            // [appDelegate launchLoginViewController];
            NSDictionary   *notDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"isError",RPLocalizedString(COMPANY_NOT_EXISTS_ERROR_MESSAGE, COMPANY_NOT_EXISTS_ERROR_MESSAGE),@"errorMsg",nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:notDict ];
           
            return exception;
        }
        else if ([errorURI isEqualToString:USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR] || [errorURI isEqualToString:USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_1])
        {
            errorMessage=RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE);
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                [appDelegate launchLoginViewController:NO];
                
            }
            else
            {
                //[appDelegate launchLoginViewController:YES];
                NSDictionary   *notDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"isError",USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR,@"errorMsg",nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:notDict ];
                [appDelegate resetValuesForWrongPassword];
            }
            
          
            exception= YES;
        }
        else if ([errorURI isEqualToString:USER_AUTHENTICATION_CHANGE_ERROR] || [errorURI isEqualToString:USER_AUTHENTICATION_CHANGE_ERROR_1])
        {
            errorMessage=RPLocalizedString(USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE, USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE);
            [appDelegate launchLoginViewController:NO];
            exception= YES;
        }
        else if ([errorURI isEqualToString:COMPANY_DISABLED_ERROR] || [errorURI isEqualToString:COMPANY_DISABLED_ERROR_1])
        {
            errorMessage=RPLocalizedString(COMPANY_DISABLED_ERROR_MESSAGE, COMPANY_DISABLED_ERROR_MESSAGE);
            [appDelegate launchLoginViewController:NO];
            exception= YES;
        }
        else if ([errorURI isEqualToString:USER_DISABLED_ERROR] || [errorURI isEqualToString:USER_DISABLED_ERROR_1])
        {
            errorMessage=RPLocalizedString(USER_DISABLED_ERROR_MESSAGE,@"");
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                [appDelegate launchLoginViewController:NO];
                
            }
            else
            {
                [appDelegate launchLoginViewController:YES];
            }
            exception= YES;
        }
        
        else if ([errorURI isEqualToString:UNKNOWN_ERROR] || [errorURI isEqualToString:UNKNOWN_ERROR_1])
        {
            errorMessage=RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE);
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                
                [appDelegate launchLoginViewController:NO];
                
            }
            else
            {
                [appDelegate launchLoginViewController:YES];
            }
            exception= YES;
            
            
             [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
        }
        
        else if ([errorURI isEqualToString:NO_AUTH_CREDENTIALS_PROVIDED_ERROR] || [errorURI isEqualToString:NO_AUTH_CREDENTIALS_PROVIDED_ERROR_1])
        {
            errorMessage=RPLocalizedString(NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE, NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE);
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                [appDelegate launchLoginViewController:NO];
                
            }
            else
            {
                [appDelegate launchLoginViewController:NO];
            }
            exception= YES;
            
             [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE, NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE) serviceURL:serviceURL];
        }
        
        else if ([errorURI isEqualToString:PASSWORD_EXPIRED] || [errorURI isEqualToString:PASSWORD_EXPIRED])
        {
            errorMessage=RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE);
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                [appDelegate launchLoginViewController:NO];
                
            }
            else
            {
                [appDelegate launchLoginViewController:YES];
            }
            
            exception= YES;
        }
        //implemented as per US7521
        else if ([errorURI isEqualToString:PASSWORD_EXPIRED1] || [errorURI isEqualToString:PASSWORD_EXPIRED1])
        {
            errorMessage=RPLocalizedString(PASSWORD_EXPIRED_MESSAGE, PASSWORD_EXPIRED_MESSAGE);
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                [appDelegate launchLoginViewController:NO];
                
            }
            else
            {
                [appDelegate launchLoginViewController:YES];
            }
            exception= YES;
        }

        
        else
        {
            exception=NO;
        }
        
        
        
    }
    
    else if (errorDictionary!=nil && ![errorDictionary isKindOfClass:[NSNull class]])
    {
        id typeStr=[errorDictionary objectForKey:@"type"];
        if (typeStr!=nil && ![typeStr isKindOfClass:[NSNull class]])
        {
            if ([typeStr isEqualToString:@"InvalidTimesheetFormatError1"])
            {
                errorMessage=RPLocalizedString(TIMESHEET_FORMAT_NOT_SUPPORTED_IN_MOBILE, TIMESHEET_FORMAT_NOT_SUPPORTED_IN_MOBILE);
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                exception= YES;
                
                 [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMessage serviceURL:serviceURL];
                
            }
            else if ([typeStr isEqualToString:@"OperationExecutionTimeoutError1"])
            {
                errorMessage=RPLocalizedString(ERROR_URLErrorTimedOut_FromServer, ERROR_URLErrorTimedOut_FromServer);
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                exception= YES;
                
                [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMessage serviceURL:serviceURL];
                
            }
            //Fix for MOBI-839//JUHI
            else if ([typeStr isEqualToString:@"UriError1"])
            {
                UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;
                
                if ([allViewController isKindOfClass:[TimesheetNavigationController class]])
                {
                     errorMessage=RPLocalizedString(Timesheet_URLError_Msg, @"");
                }
                else if ([allViewController isKindOfClass:[ExpensesNavigationController class]]){
                     errorMessage=RPLocalizedString(Expense_URLError_Msg, @"");
                }
                else if ([allViewController isKindOfClass:[BookedTimeOffNavigationController class]]){
                    errorMessage=RPLocalizedString(TimeOff_URLErroe_Msg, @"");
                }
                else if ([allViewController isKindOfClass:[ApprovalsNavigationController class]]){
                    ApprovalsNavigationController *approvalsNavController=(ApprovalsNavigationController *)allViewController;
                    NSArray *approvalsControllers = approvalsNavController.viewControllers;
                    for (UIViewController *viewController in approvalsControllers)
                    {
                        if ([viewController isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
                        {
                            errorMessage=RPLocalizedString(Pending_Timesheet_URLError_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsTimesheetHistoryViewController class]])
                        {
                            errorMessage=RPLocalizedString(Previous_Timesheet_URLError_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsPendingExpenseViewController class]])
                        {
                            errorMessage=RPLocalizedString(Pending_Expense_URLError_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsExpenseHistoryViewController class]])
                        {
                            errorMessage=RPLocalizedString(Previous_Expense_URLError_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
                        {
                            errorMessage=RPLocalizedString(Pending_TimeOff_URLErroe_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsTimeOffHistoryViewController class]])
                        {
                            errorMessage=RPLocalizedString(Previous_TimeOff_URLErroe_Msg, @"");
                        }
                    }
                    
                }
                else if ([allViewController isKindOfClass:[SupervisorDashboardNavigationController class]]){
                    SupervisorDashboardNavigationController *supervisorDashboardNavigationController=(SupervisorDashboardNavigationController *)allViewController;
                    NSArray *approvalsControllers = supervisorDashboardNavigationController.viewControllers;
                    for (UIViewController *viewController in approvalsControllers)
                    {
                        if ([viewController isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
                        {
                            errorMessage=RPLocalizedString(Pending_Timesheet_URLError_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsTimesheetHistoryViewController class]])
                        {
                            errorMessage=RPLocalizedString(Previous_Timesheet_URLError_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsPendingExpenseViewController class]])
                        {
                            errorMessage=RPLocalizedString(Pending_Expense_URLError_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsExpenseHistoryViewController class]])
                        {
                            errorMessage=RPLocalizedString(Previous_Expense_URLError_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
                        {
                            errorMessage=RPLocalizedString(Pending_TimeOff_URLErroe_Msg, @"");
                        }
                        else if ([viewController isKindOfClass:[ApprovalsTimeOffHistoryViewController class]])
                        {
                            errorMessage=RPLocalizedString(Previous_TimeOff_URLErroe_Msg, @"");
                        }
                    }
                    
                }
                uriError=YES;
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                exception= YES;
            }
        }
    }
    

    
    if (exception)
    {
        //Implementation For Mobi-190//Reset Password//JUHI
        if ([errorMessage isEqualToString:RPLocalizedString(PASSWORD_EXPIRED_MESSAGE, PASSWORD_EXPIRED_MESSAGE)])
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:self.delegate
                                                    message:errorMessage
                                                      title:@""
                                                        tag:9123];

        }
        else if (uriError)
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:appDelegate
                                                    message:errorMessage
                                                      title:@""
                                                        tag:1001];
            
            
            [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMessage serviceURL:serviceURL];
        }
        else
            [Util errorAlert:@"" errorMessage:errorMessage];
    }
    
    return exception;
}


-(void)simulateResponseFromJsonFixture
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray *paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory1 = [paths1 objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory1 stringByAppendingPathComponent:@"simulate_response.txt"];
    BOOL success = [fileManager fileExistsAtPath:writableDBPath];
    
    
    NSError *error;
    if (success )
    {
        [fileManager removeItemAtPath:writableDBPath error:&error];
    }
    NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"simulate_response.txt"];
    [fileManager copyItemAtPath:defaultPath toPath:writableDBPath error:&error];
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success )
    {
        NSString* fileContents = [NSString stringWithContentsOfFile:writableDBPath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
        NSMutableData* data = [[fileContents dataUsingEncoding:NSUTF8StringEncoding]mutableCopy];
        recievedData=data;
    }
}

-(void)simulateResponseFromPlist
{

    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *path = [mainBundle pathForResource:@"simulate_response_dict" ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:path];
    NSError *error;
    NSPropertyListFormat format;
    if(plistData != nil && plistData != NULL && plistData) {
        NSDictionary * plist = [NSPropertyListSerialization propertyListWithData:plistData
                                                          options:NSPropertyListImmutable
                                                           format:&format
                                                            error:&error];
       NSString *str = [JsonWrapper writeJson:plist error:&error];

       NSMutableData* data = [[str dataUsingEncoding:NSUTF8StringEncoding]mutableCopy];
       recievedData=data;

    }

 }

@end
