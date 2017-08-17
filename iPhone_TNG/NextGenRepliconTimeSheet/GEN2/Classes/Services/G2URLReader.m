//
//  URLReader.m
//  Replicon
//
//  Created by Devi Malladi on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2URLReader.h"
#import"G2Util.h"
#import "RepliconAppDelegate.h"
#import "Flurry.h"
#import "G2ApprovalsMainViewController.h"
#import "SNLog.h"


@implementation G2URLReader

//@synthesize recievedData;
@synthesize delegate;
@synthesize urlStr; //,dbRefId;

//@synthesize userName;
//@synthesize password;
//@synthesize companyName;
@synthesize refID;
@synthesize refDict;
@synthesize timeOutValue;
@synthesize startTime;


#define __Response_  @"response"
#define __Unauthorized_ @"Unauthorized"

- (id) init
{
	self = [super init];
	if (self != nil) {
		//if (recievedData == nil) {
		//	recievedData = [[NSMutableData alloc] initWithLength:0];
		//}
	}
	return self;
}


- (id) initWithRequest:(NSMutableURLRequest *)request delegate:(id<G2ServerResponseProtocol>) theDelegate{
	
	if (self = [self init]) {
		
		
		
		self.delegate = theDelegate;
		//DLog(@"COMPLETE REQUEST %@",request);
		
		urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		
	}
	
	return self;	
}

- (void) cancelRequest {
	
	DLog(@"\nURLReader::CANCELLING REQUEST\n");
	
	if (urlConnection == nil) {
		/* inform the user that the connection failed 
		 * popup alert view
		 */
		DLog(@"urConnection getting failed");
	}else {
		[urlConnection cancel];
	}
	
}


- (void) start {
	
	DLog(@"\nURLReader::start\n");
	
	if (urlConnection == nil) {
		/* inform the user that the connection failed 
		 * popup alert view
		 */
		DLog(@"urConnection getting failed");
	}else {
		[urlConnection start];
	}
	
}

-(void)startSynchronusRequest :(NSMutableURLRequest *)_request{
	
	NSError *err;
	NSData *responseData=[NSURLConnection sendSynchronousRequest:_request returningResponse:nil error:&err];
	NSString *response=[[NSString  alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	
	//[self setDelegate:serviceDelegate];
	if ([(NSMutableArray *)[JsonWrapper parseJson:response error:nil]count]==0) {
		
		
		
		[self.delegate serverDidFailWithError:nil];
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
//		[self errorAlert:[responseDict objectForKey:@"Status"] errorMessage:[responseDict objectForKey:@"Message"]];
        [G2Util errorAlert:@"" errorMessage:[responseDict objectForKey:@"Message"]];//DE1231//Juhi
	}else {
		//[self.delegate serverDidRespondWithResponse:dict];
	}		
}

-(void)handleCookiesResponse:(id)response
{
	//NSString *domainName = [[AppProperties getInstance] getAppPropertyFor: @"DomainName"];
	NSString *domainName = [[NSUserDefaults standardUserDefaults]objectForKey:@"ServiceURL"];
	if (domainName == nil) {
		domainName = [[G2AppProperties getInstance] getAppPropertyFor: @"DomainName"];
	}
	NSArray * cookiesArray = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:[NSURL URLWithString:domainName]];
	//storing cookies in  NSHTTPCookieStorage is a Singleton.
	[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookiesArray forURL:[NSURL URLWithString:domainName] mainDocumentURL:nil];
	
	//Recollecting it from NSHTTPCookieStorage.......
	NSArray * availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:domainName]];
	NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
	[[NSUserDefaults standardUserDefaults] setObject:headers forKey:@"cookies"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)startRequestWithTimeOutVal:(int)timeOutVal
{
	DLog(@"\nstartRequestWithTimeOutVal::start\n");
	
	[self setTimeOutValue:timeOutVal];
	[self setStartTime:[[NSDate date] timeIntervalSince1970]];
	
	if (urlConnection == nil) {
		/* inform the user that the connection failed 
		 * popup alert view
		 */
		DLog(@"urConnection getting failed");
	}else {
		[urlConnection start];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//if (buttonIndex) {	
	[[[UIApplication sharedApplication]delegate]performSelector:@selector(reloaDLogin)];
	//}	
}

- (void) errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage {
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:errorMessage
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];	
	
}

-(void)handleResponseToShowErrorMessages:(id)message
{
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	NSString *errorMessage = [NSString stringWithUTF8String:[message bytes]];
	[G2Util errorAlert:ErrorTitle errorMessage:errorMessage];
}

-(BOOL)handleExceptionsWithExceptionTypes:(id)responseInfo
{
	/*{
		refDict =     {
			refID = 33;
		};
		response =     {
			ActionIndex = 0;
			Message = "Could not find object with identity 1026 in the collection";
			Status = Exception;
			Type = "Replicon.RemoteApi.Core.ObjectNotFoundException";
		};
	}*/
	NSString *exceptionType = [[responseInfo objectForKey:@"response"]objectForKey:@"Type"];
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	if (exceptionType != nil && ![exceptionType isKindOfClass:[NSNull class]]){
		
        if ([exceptionType  rangeOfString:@"Replicon.TimeSheet.Domain.Timesheet"].length > 0)  {
            
            appDelegate.isShowPunchButton=FALSE;
            NSArray   *viewCtrls = appDelegate.navController.viewControllers;
            for (int i=0; i<[viewCtrls count]; i++) {
                if ([[viewCtrls objectAtIndex:i] isKindOfClass:[G2RootTabBarController class]]) {
                    G2RootTabBarController *rootCtrl=(G2RootTabBarController *)[viewCtrls objectAtIndex:i];
                    NSArray *rootVCArray=[rootCtrl viewControllers ];
                     for (int j=0; j<[rootVCArray count]; j++) 
                     {
                         if ([[rootVCArray objectAtIndex:j] isKindOfClass:[G2PunchClockViewController class]]) {
                              G2PunchClockViewController *punchCtrl=(G2PunchClockViewController *)[rootVCArray objectAtIndex:j];
                             [punchCtrl.punchButton setHidden:TRUE];
                             break;
                         }
                     }
                    break;
                }
            }
		}

        
		NSString *errorMessage = nil;
		if ([exceptionType  rangeOfString:ObjectNotFoundException].length > 0)  {
			errorMessage = RPLocalizedString(ObjectNotFoundMessage,"");
		}
		else if ([exceptionType  rangeOfString:ORMSecurityException].length > 0) {

            //US3634//Juhi
            //errorMessage = ORMSecurityExceptionMessage;
            if ([[[responseInfo objectForKey:@"response"]objectForKey:@"Message"] isEqualToString:@"Permission denied by security module, not permitted to load entity of type Replicon.TimeSheet.Schema.StopwatchEntry+Entity"]) 
            {
                errorMessage = RPLocalizedString(ORMSecurityExceptionStopWatchMessage,@"");
            }
            else
                errorMessage = RPLocalizedString(ORMSecurityExceptionMessage,@"");
            //US4064//Juhi
            
            NSString *userID=nil;
            NSString *companyName=nil;
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"]isKindOfClass:[NSNull class] ])
            {
                userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
                
            } 
            
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
            {
                companyName =[[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"];
            }
            else 
            {
                NSDictionary *credDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
                if (credDict != nil && ![credDict isKindOfClass:[NSNull class]]) {
                    companyName = [credDict objectForKey:@"companyName"];
                }
            }
            
            


             NSString *flurryEvent= [NSString stringWithFormat:@"SID:%@,%@",[refDict objectForKey:@"refID"],[[responseInfo objectForKey:@"response"]objectForKey:@"Message"]];
            
            if (![[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] && ![[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
            {
                [Flurry logEvent:flurryEvent withParameters:[NSDictionary  dictionaryWithObjectsAndKeys:companyName,@"CName",userID,@"UID", nil ]];
            }
            
            
            
            //HANDLE PUNCH CLOCK STATE
            RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            if(appDelegate.isLockedTimeSheet)
            {
                NSArray   *viewCtrls = appDelegate.navController.viewControllers;
                for (int i=0; i<[viewCtrls count]; i++) {
                    if ([[viewCtrls objectAtIndex:i] isKindOfClass:[G2RootTabBarController class]]) {
                        G2RootTabBarController *rootCtrl=(G2RootTabBarController *)[viewCtrls objectAtIndex:i];
                        NSArray *rootVCArray=[rootCtrl viewControllers ];
                        for (int j=0; j<[rootVCArray count]; j++) 
                        {
                            if ([[rootVCArray objectAtIndex:j] isKindOfClass:[G2PunchClockViewController class]]) {
                                G2PunchClockViewController *punchCtrl=(G2PunchClockViewController *)[rootVCArray objectAtIndex:j];
                                if ([punchCtrl.punchButton.titleLabel.text isEqualToString:RPLocalizedString(PUNCHIN, "")]) 
                                {
                                    if ([punchCtrl.hiddentimer isValid]) {
                                        [punchCtrl.hiddentimer invalidate];
                                    }
                                    if ([punchCtrl.visibleTimer isValid]) {
                                        [punchCtrl.visibleTimer invalidate];
                                    }
                                    punchCtrl.clockImageView.hidden=TRUE;
                                    punchCtrl.colonLbl.hidden=FALSE;
                                    
                                }
                                else
                                {
                                    punchCtrl.hiddentimer=[NSTimer scheduledTimerWithTimeInterval:0 target:punchCtrl selector:@selector(hideSecondsColon) userInfo:nil repeats:NO];
                                    punchCtrl.clockImageView.hidden=FALSE;
                                    
                                }
                                
                                break;
                            }
                        }
                        break;
                    }
                }
            }
           
            ///FINISH HANDLING
		}
       else if ([exceptionType  rangeOfString:ORMValidationException].length > 0 )  
       {
           
           NSArray   *viewCtrls = appDelegate.navController.viewControllers;
           BOOL isValidForApprovals=FALSE;
           for (int i=0; i<[viewCtrls count]; i++) 
           {
               if ([[viewCtrls objectAtIndex:i] isKindOfClass:[G2RootTabBarController class]]) 
               {
                   G2RootTabBarController *rootCtrl=(G2RootTabBarController *)[viewCtrls objectAtIndex:i];
                   if ([rootCtrl.selectedViewController  isKindOfClass:[G2ApprovalsNavigationController class]])
                   {
                       isValidForApprovals=TRUE;
                        break;
                   }
                  
               }
           }
           
           if (isValidForApprovals) 
           {
                errorMessage = RPLocalizedString(ORMValidationExceptionApprovals,@"");
           }
           else
           {
               return NO;
           }
		} 
        else {
			return NO;
		}
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		[G2Util errorAlert:nil errorMessage:RPLocalizedString(errorMessage, errorMessage)];
		return YES;
	}
	
	return NO;
}
#pragma mark NSURLConnection delegate


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response{
	[self handleCookiesResponse:response];
	//[self.recievedData setLength:0];
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
//	NSString *resp = [[NSString  alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
//    NSLog(resp);
	RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appdelegate.errorMessageForLogging=@"";
	id parsedData = [JsonWrapper parseJson: recievedData error: nil];
	@try {
		if (parsedData != nil && [parsedData isKindOfClass: [NSDictionary class]] ) {
			NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:refDict ,@"refDict",
										 parsedData,@"response",
										 nil];
			NSDictionary *responseDict = [dict objectForKey: __Response_];
			if(responseDict != nil && 
			   [responseDict objectForKey:@"Status"] != nil && 
			   [[responseDict objectForKey:@"Status"] isEqualToString: __Unauthorized_])
			{
//				[self errorAlert:[responseDict objectForKey:@"Status"] errorMessage:[responseDict objectForKey:@"Message"]];
                [G2Util errorAlert:@"" errorMessage:[responseDict objectForKey:@"Message"]];//DE1231//Juhi
			}else {
				NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
               
				id _serviceId = [[dict objectForKey:@"refDict"]objectForKey:@"refID"];
				if(_serviceId != nil) {
                    
                    if ([[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] || [[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
                    {
//                        [SNLog Log:2 :[NSString stringWithFormat:@"Response Received for SID :: %@",_serviceId]];
                        [SNLog Log:2 withFormat:[NSString stringWithFormat:@"Response Received for SID :: %@",_serviceId]];
                    }

                    
					[standardDefaults setObject: [NSDate date] forKey: [_serviceId stringValue]];
                    [standardDefaults synchronize];
				}
				BOOL exceptionMessage = [self handleExceptionsWithExceptionTypes:dict];
                RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
				if (exceptionMessage) 
                {
                    
                    
                    if (appDelegate.isInApprovalsMainPage)
                    {
                        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                        if(!appDelegate.isLockedTimeSheet)
                        {
                            [[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)]; 
                            
                        }
                        
                    }
                    else if (appDelegate.isUpdatingDisclaimerAcceptanceDate)
                    {
                        
                        NSArray   *viewCtrls = appDelegate.navController.viewControllers;
                        for (int i=0; i<[viewCtrls count]; i++) {
                            if ([[viewCtrls objectAtIndex:i] isKindOfClass:[G2RootTabBarController class]]) {
                                G2RootTabBarController *rootCtrl=(G2RootTabBarController *)[viewCtrls objectAtIndex:i];
                                NSArray *rootVCArray=[rootCtrl viewControllers ];
                                for (int j=0; j<[rootVCArray count]; j++) 
                                {
                                    if ([[rootVCArray objectAtIndex:j] isKindOfClass:[G2TimesheetNavigationController class]]) 
                                    {
                                       
                                        NSArray *navigationVCArray=[[rootVCArray objectAtIndex:j] viewControllers];
                                        for (int k=0; k<[navigationVCArray count]; k++) 
                                        {
                                            if ([[navigationVCArray objectAtIndex:k] isKindOfClass:[G2ListOfTimeEntriesViewController class]]) 
                                            {
                                                G2ListOfTimeEntriesViewController *listOfTimeEntriesCtrl=(G2ListOfTimeEntriesViewController *)[navigationVCArray objectAtIndex:k];
                                                [listOfTimeEntriesCtrl revertRadioButton];
                                                [listOfTimeEntriesCtrl disclaimerRequestServer];
                                                break;
                                            }
                                        }
                                        
                                        break;
                                    }
                                    
                                    
                                }
                                break;
                            }
                        }
                    }
                    
					return;
				}
				[self.delegate serverDidRespondWithResponse:dict];
			}		
		} else {
			if (recievedData != nil)
            {
                id _serviceId = [refDict objectForKey:@"refID"];
                
                if ([_serviceId intValue]== CompleteSAMLFlowRemoteAPIURL_Service_Id_105)
                {
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:refDict ,@"refDict",
                                                 parsedData,@"response",
                                                 nil];
                    [self.delegate serverDidRespondWithResponse:dict];
                }
                
                else if ([_serviceId intValue]== UserIntegrationDetails_Service_ID_103)
                {
                    
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"hasError"] ];
                    
                    
                    return;
                    
                }

                
				else if ([self.delegate respondsToSelector:@selector(serverDidRespondWithNonJSONResponse:)])
                
                {
                    id _serviceId = [refDict objectForKey:@"refID"];
                    if ([_serviceId intValue] == FetchCompanyURL_ServiceID_0 || [_serviceId intValue] == FetchAuthRemoteAPIUrl_Service_Id_91)
                    {
                       NSString *message = [[NSString  alloc] initWithData:recievedData encoding:NSUTF8StringEncoding];
                        NSDictionary   *notDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"hasError",message,@"errorMsg",nil];
                        [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:notDict ];
                        
                        
                        return;
                        
                    }
                    
					[self.delegate serverDidRespondWithNonJSONResponse: recievedData];
				}
				else {
                    id _serviceId = [refDict objectForKey:@"refID"];
                    if ([_serviceId intValue] == FetchCompanyURL_ServiceID_0 || [_serviceId intValue] == FetchAuthRemoteAPIUrl_Service_Id_91)
                    {
                        NSString *errorMessage = [NSString stringWithUTF8String:[recievedData bytes]];
                        NSDictionary   *notDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"hasError",errorMessage,@"errorMsg",nil];
                        [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:notDict ];
                        
                        
                        return;
                        
                    }
                    
					[self handleResponseToShowErrorMessages: recievedData];
				}
			}
            else {
                id _serviceId = [refDict objectForKey:@"refID"];
                if ([_serviceId intValue]== UserIntegrationDetails_Service_ID_103)
                {
                    
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"hasError"] ];
                    
                    
                    return;
                    
                }
				[self.delegate serverDidFailWithError:nil];
			}
			return;
		}
	}
	@finally {
		recievedData = nil;
	}
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
	
	return nil;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {	
	return YES;
}  

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	 RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        if ([[challenge.protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        }
        else 
        {
           
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
            BOOL isAutoLogin=FALSE;
           
            
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"firstTimeLogging"] && (![appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED])  )
            {
                
                isAutoLogin=TRUE;
                //   [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"firstTimeLogging"] ;
            }
            else
            {
                if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED] || appdelegate.errorMessageForLogging==nil ) {
                    isAutoLogin=FALSE;
                }
                else
                {
                    G2LoginModel *loginModel = [[G2LoginModel alloc] init];
                    NSMutableArray *loginDetails = [loginModel getAllUserInfoFromDb];
                    
                    
                    BOOL rememberCompany = [ [[loginDetails objectAtIndex:0] objectForKey:@"rememberCompany"] boolValue];
                    BOOL rememberUser = [ [[loginDetails objectAtIndex:0] objectForKey:@"rememberUser"] boolValue];
                    int rememberPassword = [ [[loginDetails objectAtIndex:0] objectForKey:@"rememberPassword"] intValue];
                    if (rememberPassword > 0 && rememberUser && rememberCompany   ) {
                        NSString *remPwdStartDateStr = [[loginDetails objectAtIndex:0] objectForKey:@"rememberPwdStartDate"];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                        NSDate *remPwdStartDate = [dateFormatter dateFromString:remPwdStartDateStr];
                       
                        NSDate *todayDate = [NSDate date];
                        unsigned unitFlag = NSCalendarUnitDay;
                        NSCalendar *calendar = [NSCalendar currentCalendar];
                        NSDateComponents *comps = [calendar components:unitFlag fromDate:remPwdStartDate toDate:todayDate options:0];
                        if ((rememberPassword == 1 && [comps day] < 1) || (rememberPassword == 2 && [comps day] < 7) || 
                            (rememberPassword == 3 && [comps day] < 14) || (rememberPassword == 4 && [comps day] < 30) || (rememberPassword == 5)) 
                        {
                            //Auto Loging True
                            isAutoLogin=TRUE;
                        }
                        else
                        {
                            //Auto Loging False
                            isAutoLogin=FALSE;
                        }
                        
                    }
                    else
                    {
                        //Auto Loging False
                        isAutoLogin=FALSE;
                    }
                    
                }
                
                
                
            }
            
            
            //ravi - US88 - to handle the session timeout. Once the user is logged in, remove the credentials from the userdefaults. 
            //If authentication challenge is called and there are no credentials info in userdefaults then the login page is shown.		
            if (dict == nil || [dict count] == 0) {
                [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
            } 
            else {
                
                if (isAutoLogin) {
                    NSString *login = [NSString stringWithFormat:@"%@\\%@",[dict objectForKey:@"companyName"],[dict objectForKey:@"userName"]];
                    
                    if ([challenge previousFailureCount]==0) {
                        NSURLCredential *newCredential;
                        newCredential = [NSURLCredential credentialWithUser: login 
                                                                   password:[dict objectForKey:@"password"] 
                                                                persistence:NSURLCredentialPersistenceNone];
                        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
                        
                    }else {
                        appdelegate.errorMessageForLogging=G2PASSWORD_EXPIRED;
                        [[challenge sender]cancelAuthenticationChallenge:challenge];
                        //                    [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
                        //SHOW WRONG PASSWORD ALERT
                        // [self errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:G2PASSWORD_EXPIRED];
                    }
                }
                //isAutoLogin=FALSE 
                else
                {
                    
                    appdelegate.errorMessageForLogging=SESSION_EXPIRED;
                    [[challenge sender]cancelAuthenticationChallenge:challenge];
                    [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
                    //SHOW SESSION EXPIRED ALERT
                    // [self errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:SESSION_EXPIRED];
                    
                    
                }
                
            }		
        } 
    }
    
    ///  FOR SAML
    else
    {
        if ([[challenge.protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        } 
//        else if ([challenge previousFailureCount] == 0) 
//        {
//        }
        else
        {
            appdelegate.errorMessageForLogging=SESSION_EXPIRED;
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        }
        
        
        
       
    }
	
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	DLog(@"URLReader::didFailWithError");
	
	NSNumber *_serviceId=[refDict objectForKey:@"refID"];
	if (_serviceId!=nil && ([_serviceId intValue]== ExpenseByUser_ServiceID_3  || 
							[_serviceId intValue]== FetchNextRecentExpenseSheets_26 || 
							[_serviceId intValue]== ExpenseSheetsModifiedFromLastUpdatedTime_Service_Id_60)
		) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isExpensesDataFailed"];
        [[NSUserDefaults standardUserDefaults]  synchronize];
	}
	else if (_serviceId!=nil && ([_serviceId intValue]== EntryTimesheetByUser_38)) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isExpensesDataFailed"];
         [[NSUserDefaults standardUserDefaults]  synchronize];
	}
	
    if ([_serviceId intValue]== FetchCompanyURL_ServiceID_0 || [_serviceId intValue]== FetchAuthRemoteAPIUrl_Service_Id_91)
    {
        
        
        NSDictionary   *notDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"hasError",InvalidCompanyName,@"errorMsg",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:notDict ];
        
        return;
    }
    
    if ([_serviceId intValue]== FetchCompanyURL_ServiceID_0 || [_serviceId intValue]== FetchAuthRemoteAPIUrl_Service_Id_91)
    {
        
        
        NSDictionary   *notDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],@"hasError",RPLocalizedString(InvalidCompanyName, InvalidCompanyName) ,@"errorMsg",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:notDict ];
        
        return;
    }

    if ([_serviceId intValue]== UserIntegrationDetails_Service_ID_103)
    {
        
        
      [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"hasError"] ];
        return;
    }

    
	[self.delegate serverDidFailWithError:error];
}



@end
