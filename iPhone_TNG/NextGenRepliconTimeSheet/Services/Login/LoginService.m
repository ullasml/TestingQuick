#import "LoginService.h"
#import "Util.h"
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "SQLiteDB.h"
#import "LoginModel.h"
#import "DropDownViewController.h"

#import <Crashlytics/Crashlytics.h>
#import "ResetPasswordViewController.h"
#import "SettingUpViewController.h"
#import "ACSimpleKeychain.h"
#import "HRSettingUpViewController.h"
#import "FrameworkImport.h"
#import "TabModuleNameProvider.h"
#import "AppDelegate.h"
#import "BreakTypeRepository.h"
#import "HomeSummaryDelegate.h"
#import "EventTracker.h"
#import <repliconkit/AppConfig.h>
#import "MobileMonitorURLProvider.h"

#import "InjectorProvider.h"
#import "FrameworkImport.h"
#import <Blindside/Blindside.h>
#import <repliconkit/repliconkit.h>

@interface LoginService ()

@property (nonatomic) TabModuleNameProvider *tabModuleNameProvider;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak) AppDelegate *appDelegate; // App Delegate will never be deallocated, so this is safe.
@property (nonatomic, weak) id<LoginDelegate> loginDelegate;
@property (nonatomic, weak) id<HomeSummaryDelegate> homeSummaryDelegate;
@property (nonatomic, strong) MobileMonitorURLProvider *mobileMonitorURLProvider;
@property (nonatomic, strong) AppConfig *appConfig;
@end


@implementation LoginService
@synthesize activityIndicatorParentViewControllerdelegate;

#define NEW_APP_AVAILBLE_ALERT_TAG 0
#define NEW_APP_REQUIRED_ALERT_TAG 1

#pragma mark -
#pragma mark Server Response methods


- (instancetype)initWithTabModuleNameProvider:(TabModuleNameProvider *)tabModuleNameProvider
                                 userDefaults:(NSUserDefaults *)userDefaults
                              spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                          homeSummaryDelegate:(id<HomeSummaryDelegate>)homeSummaryDelegate
                                  appDelegate:(AppDelegate *)appDelegate
                     mobileMonitorURLProvider:(MobileMonitorURLProvider *)mobileMonitorURLProvider
                                    appConfig:(AppConfig *)appConfig {
    self = [super init];
    if (self) {
        self.tabModuleNameProvider = tabModuleNameProvider;
        self.userDefaults = userDefaults;
        self.spinnerDelegate = spinnerDelegate;
        self.homeSummaryDelegate = homeSummaryDelegate;
        self.appDelegate = appDelegate;
        self.mobileMonitorURLProvider = mobileMonitorURLProvider;
        self.appConfig = appConfig;
    }
    return self;
}

- (void) serverDidRespondWithResponse:(id) response
{

	if (response!=nil)
    {
        id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];

        if ([_serviceID intValue]== CurrentGenFetchRemoteApiUrl_73)
        {
            NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
            if ([status isEqualToString:@"OK"])
            {
               [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:FALSE] forKey:@"isError"] ];

            }
            else
            {

                [[NSNotificationCenter defaultCenter]postNotificationName:CURRENTGEN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];

            }

            return;
        }
        
        else if ([_serviceID intValue]== HomeSummaryDetails_Service_ID_1)
        {
            self.appDelegate.isReceivedOldHomeFlowServiceData=TRUE;
            
        }
        
        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];

        if (errorDict!=nil)
        {
            BOOL isErrorThrown=FALSE;
            if ([_serviceID intValue]== ApprovalsCountDetails_Service_ID_6 || [_serviceID intValue]== GetMyNotificationSummary_148)
            {
                self.appDelegate.isCountPendingSheetsRequestInQueue=FALSE;
                //Not to handle errors for this service i.e when fetching count of approvals
                return;
            }
            else if ([_serviceID intValue]== GetVersionUpdateDetails_74)
            {
                //Not to handle errors for this service i.e when GetVersionUpdateDetails
                return;
            }
            
            else if ([_serviceID intValue]== LightWeightHomeSummaryDetails_Service_ID_158)
            {
                LoginModel *loginModel=[[LoginModel alloc]init];
                NSMutableArray *userDetailsArr=[loginModel getAllUserDetailsInfoFromDb];
                if ([userDetailsArr count]>0)
                {
                    // SUPPRESS ERRORS
                    return;
                }
   
            }
            else if ([_serviceID intValue]== HomeSummaryDetails_Service_ID_1)
            {
                
               
                [[NSNotificationCenter defaultCenter] postNotificationName:@"OldHomeFlowServiceReceivedData" object:nil];
                
                // SUPPRESS ERRORS
                    
                return;

            }
            
            
            NSArray *notificationsArr=[[errorDict objectForKey:@"details"] objectForKey:@"notifications"];
            NSString *errorMsg=@"";
            if (notificationsArr!=nil && ![notificationsArr isKindOfClass:[NSNull class]])
            {
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
            

            [self.spinnerDelegate hideTransparentLoadingOverlay];



           if ([_serviceID intValue]== GetDropDownOption_Service_ID_68)
            {
                NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                     forKey:@"isErrorOccured"];
                [[NSNotificationCenter defaultCenter] postNotificationName:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
            }//Fix for defect DE15459
            if ([_serviceID intValue]== GetNextDropDownOption_Service_ID_69)
            {
                NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                     forKey:@"isErrorOccured"];
                [[NSNotificationCenter defaultCenter] postNotificationName:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
            }//Implementation For Mobi-190//Reset Password//JUHI
            if ([_serviceID intValue]== ResetPassword_Service_ID_103)
            {
                NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                     forKey:@"isErrorOccured"];
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEPASSWORD_NOTIFICATION object:nil userInfo:dataDict];
            }
            if ([_serviceID intValue]== GetTenantFromCompanyKey_151)
            {
                NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                     forKey:@"isError"];
                [[NSNotificationCenter defaultCenter] postNotificationName:TENANT_RESPONSE_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
            }
            if ([_serviceID intValue]== createPasswordResetRequest_152)
            {
                NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                     forKey:@"isError"];
                [[NSNotificationCenter defaultCenter] postNotificationName:CREATE_PASSWORD_RESET_RESPONSE_NOTIFICATION object:nil userInfo:dataDict];
            }
            if ([_serviceID intValue]== SendPasswordResetRequestEmail_ID_170)
            {
                NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                     forKey:@"isError"];
                [[NSNotificationCenter defaultCenter] postNotificationName:SEND_PASSWORD_RESET_REQUEST_EMAIL_RESPONSE_NOTIFICATION object:nil userInfo:dataDict];
            }
            if ([_serviceID intValue]== GetMyNotificationSummary_148)
            {
                NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                     forKey:@"isError"];
                [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
            }
        }
        else
        {
           
            
           if ([_serviceID intValue]== UserIntegrationDetailsiOS7_Service_ID_89)
            {
				
                [self handleUserIntegrationDetailsforiOS7URLResponse:response];

            }

            else if ([_serviceID intValue]== UserIntegrationDetailsForFreeTrail_Service_ID_113)
            {

                [self handleUserIntegrationDetailsURLForFreeTrialResponse:[[response objectForKey:@"response"]objectForKey:@"d"]];

            }


            else if ([_serviceID intValue]== HomeSummaryDetails_Service_ID_1)
            {
                self.appDelegate.isNotFirstTimeLaunch = YES;
                NSDictionary *responseDictionary = response[@"response"];
                NSDictionary *responseDataDictionary = responseDictionary[@"d"];
                [self handleHomeSummaryResponse:responseDataDictionary];
            }
            
            else if ([_serviceID intValue]== LightWeightHomeSummaryDetails_Service_ID_158)
            {

                self.appDelegate.isNotFirstTimeLaunch=TRUE;
                [self handleLightWeightHomeSummaryResponse:[[response objectForKey:@"response"]objectForKey:@"d"] andIsLaunchHomeView:[[[response objectForKey:@"refDict"]objectForKey:@"params"]boolValue]];
                
                
            }
            
            else if ([_serviceID intValue]== GetDropDownOption_Service_ID_68)
            {
                [self handleUserDefinedOptionFields:response];

                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;


            }
            else if ([_serviceID intValue]== GetNextDropDownOption_Service_ID_69)
            {
                [self handleNextUserDefinedOptionFields:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];

                return;

            }

            else if ([_serviceID intValue]== GetVersionUpdateDetails_74)
            {
                [self handleGetVersionUpdateDetails:response];

                return;

            }
            else if ([_serviceID intValue]== ApprovalsCountDetails_Service_ID_6)
            {
                [self handleCountOfApprovalsForUser:response];
                self.appDelegate.isCountPendingSheetsRequestInQueue=FALSE;
                return;

            }
            //Implementation For Mobi-190//Reset Password//JUHI
            else if ([_serviceID intValue]== ResetPassword_Service_ID_103)
            {
                [self handlePasswordUpdate:response];

            }
            else if ([_serviceID intValue]== User_LogOut_Service_ID_70)
            {
                if ([[self.userDefaults objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
                {
                    NSString* companyName = nil;
                    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
                    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
                        NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
                        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
                            companyName = [credentials valueForKey:ACKeychainCompanyName];
                        }
                    }
                     NSString *serviceEndpointRootUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"];
                    NSArray *rootUrlArr=[serviceEndpointRootUrl componentsSeparatedByString:@"/services"];
                    NSString *openUrl=[NSString stringWithFormat:@"%@/%@/LogOut",rootUrlArr[0],companyName];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOGOUT_RESPONSE_NOTIFICATION object:nil];
                }
            }

            else if ([_serviceID intValue]== GetMyNotificationSummary_148)
            {
                [self handleCountOfGetMyNotificationSummary:response];
                self.appDelegate.isCountPendingSheetsRequestInQueue=FALSE;
                [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:response];
                return;

            }
            else if ([_serviceID intValue]== GetServerDownStatus_150)
            {
                [self handleServerDownStatusResponse:response];
                return;

            }
            else if ([_serviceID intValue]== GetTenantFromCompanyKey_151)
            {
                NSDictionary   *dateDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE],@"isError",[response objectForKey:@"response"],@"response",nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:TENANT_RESPONSE_RECEIVED_NOTIFICATION object:nil userInfo:dateDict ];
                return;

            }
            else if ([_serviceID intValue]== createPasswordResetRequest_152)
            {
                NSDictionary   *dateDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE],@"isError",[response objectForKey:@"response"],@"response",nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:CREATE_PASSWORD_RESET_RESPONSE_NOTIFICATION object:nil userInfo:dateDict ];
                return;

            }
            else if ([_serviceID intValue]== SendPasswordResetRequestEmail_ID_170)
            {
                NSDictionary   *dataDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE],@"isError",[response objectForKey:@"response"],@"response",nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:SEND_PASSWORD_RESET_REQUEST_EMAIL_RESPONSE_NOTIFICATION object:nil userInfo:dataDict ];
                return;
                
            }
            else if ([_serviceID intValue]== GetOEFDropDownTagOption_Service_ID_171)
            {
                [self handleOEFTagOptionFields:response];

                [self.spinnerDelegate hideTransparentLoadingOverlay];
                return;


            }
            else if ([_serviceID intValue]== GetNextOEFDropDownTagOption_Service_ID_172)
            {
                [self handleNextOEFTagOptionFields:response];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
                
                return;
                
            }


        }


    }

}

- (void) serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        if (applicationState == Foreground)
        {
            [Util showOfflineAlert];

        }
        return;
	}
	if ([activityIndicatorParentViewControllerdelegate isKindOfClass:[LoginViewController class]])
    {
        NSDictionary   *gen3ValidationerrorDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE],@"isError",nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:gen3ValidationerrorDict ];
    }


    if (applicationState == Foreground)
    {
        [Util handleNSURLErrorDomainCodes:error];
    }
    
    return;




}

#pragma mark -
#pragma mark Server Request methods

/************************************************************************************************************
 @Function Name   : sendrequestToFetchUserIntegrationDetailsWithDelegate
 @Purpose         : Called to get the user’s authentication type,
 the SAML provider URL,
 the URI to the rest of the services,
 and the URI to the the remote API.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/




-(void)sendrequestToFetchUserIntegrationDetailsForiOS7WithDelegate:(id )delegate buttonType:(NSString*)buttonType{

    NSString *companyName = nil;
    NSString *loginName = nil;
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
            companyName = [credentials valueForKey:ACKeychainCompanyName];
            loginName   = [credentials valueForKey:ACKeychainUsername];
        }
    }

	NSMutableDictionary *queryDict = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
									  companyName,@"companyKey",
									  loginName,@"loginName",
                                      [NSString stringWithFormat:@"%@?requestcookies=true", [[AppProperties getInstance] getAppPropertyFor: @"SSOTargetURL"]],@"targetUrl",
                                      nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];


	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString * urlStr=[NSString stringWithFormat:@"%@/%@",[Util getServerBaseUrl],[[AppProperties getInstance] getServiceURLFor: @"GetUserIntegrationDetails"]];

    DLog(@"URL:::%@",urlStr);

    [paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
    [self setActivityIndicatorParentViewControllerdelegate:delegate];
	[self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    
    if ([delegate isKindOfClass:[SettingUpViewController class]]||[delegate isKindOfClass:[HRSettingUpViewController class]])
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName: @"UserIntegrationDetailsForFreeTrial"]];
    }
    else
    {
        [self setServiceID: [ServiceUtil getServiceIDForServiceName: @"UserIntegrationDetailsiOS7"]];
    }
    
	
	[self setServiceDelegate:self];
    [self executeRequest:buttonType];



}

//HERE CURRENT GEN AUTH API IS BEING CALLED TO CHECK FOR THE RIGHT APP

-(void)sendrequestToFetchAuthRemoteAPIUrl:(id )delegate {

    NSString *companyName = nil;
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
            companyName = [credentials valueForKey:ACKeychainCompanyName];
        }
    }


    NSString *urlStr;
    if ([self.userDefaults objectForKey:@"urlPrefixesStr"]!=nil) {
        urlStr=[NSString stringWithFormat:@"http://%@.%@/FetchRemoteApiUrl.ashx?Version=%@&CompanyKey=%@&Output=json",[self.userDefaults objectForKey:@"urlPrefixesStr"],@"services.dev.replicon.com",@"8.27.23.3",companyName];
    }
    else
    {
        urlStr=[NSString stringWithFormat:@"http://%@.%@/FetchRemoteApiUrl.ashx?Version=%@&CompanyKey=%@&Output=json",@"services",@"replicon.com",@"8.27.23.3",companyName];
    }

    DLog(@"URL:::%@",urlStr);

    [self setRequest:[RequestBuilder buildGETRequestWithParamDict:[NSDictionary dictionaryWithObject:urlStr forKey:@"URLString"]]];
	[self setServiceID: [ServiceUtil getServiceIDForServiceName: @"CurrentGenFetchRemoteApiUrl"]];
	[self setServiceDelegate: self];
	[self executeRequest];

}



-(void)sendrequestToGetVersionUpdateDetails
{


	NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];


    NSString *major=@"0";
    NSString *minor=@"0";
    NSString *build=@"0";
    NSString *revision=@"0";

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSArray *versionArray=[version componentsSeparatedByString:@"."];

    if ([versionArray count]==1)
    {
        major=[versionArray objectAtIndex:0];
    }
    else if ([versionArray count]==2)
    {
        major=[versionArray objectAtIndex:0];
        minor=[versionArray objectAtIndex:1];
    }
    else if ([versionArray count]==3)
    {
        major=[versionArray objectAtIndex:0];
        minor=[versionArray objectAtIndex:1];
        build=[versionArray objectAtIndex:2];
    }
    else if ([versionArray count]==4)
    {
        major=[versionArray objectAtIndex:0];
        minor=[versionArray objectAtIndex:1];
        build=[versionArray objectAtIndex:2];
        revision=[versionArray objectAtIndex:2];
    }


    NSMutableDictionary *versionDict=[NSMutableDictionary dictionary];
    [versionDict setObject:major forKey:@"major"];
    [versionDict setObject:minor forKey:@"minor"];
    [versionDict setObject:build forKey:@"build"];
    [versionDict setObject:revision forKey:@"revision"];

    [queryDict setObject:@"urn:replicon-global:application:ios" forKey:@"applicationUri"];
    [queryDict setObject:versionDict forKey:@"version"];


	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];

    

   NSString * urlStr=[NSString stringWithFormat:@"%@/%@",[Util getServerBaseUrl],[[AppProperties getInstance] getServiceURLFor: @"GetVersionUpdateDetails"]];

    /// This is an exception for "GetVersionUpdateDetails"
    if ([[[self.userDefaults objectForKey:@"urlPrefixesStr"] lowercaseString] isEqualToString:@"dev-int.replicon.ca:805"] )
    {
        urlStr = [NSString stringWithFormat:@"https://%@.%@/%@",
                  [[AppProperties getInstance] getAppPropertyFor: @"ProductionBaseURLName"],
                  [[AppProperties getInstance] getAppPropertyFor: @"DomainName"],
                  [[AppProperties getInstance] getServiceURLFor: @"GetVersionUpdateDetails"]];
    }

    DLog(@"URL:::%@",urlStr);

	[paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];


    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];


	[self setServiceID: [ServiceUtil getServiceIDForServiceName: @"GetVersionUpdateDetails"]];
	[self setServiceDelegate:self];
	[self executeRequest];



}

/************************************************************************************************************
 @Function Name   : sendrequestToFetchHomeSummaryWithDelegate
 @Purpose         : Called to get the user’s details like type of the user internal or saml,
 timesheet,expenses & approval capabilities.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)sendrequestToFetchHomeSummaryWithDelegate:(id<LoginDelegate>)delegate
{
    self.loginDelegate = delegate;
	NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];

	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor: @"GetHomeSummary"]];

    DLog(@"URL:::%@",urlStr);

	[paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];
    [self setActivityIndicatorParentViewControllerdelegate:delegate];

    if ([delegate isKindOfClass:[LoginViewController class]] || [delegate isKindOfClass:[ResetPasswordViewController class]] || [delegate isKindOfClass:[self class]] || [delegate isKindOfClass:[AppDelegate class]]  )
    {
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDictAndBasicAuth:paramDict]];
    }
    else
    {
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    }

	[self setServiceID: [ServiceUtil getServiceIDForServiceName: @"HomeSummaryDetails"]];
	[self setServiceDelegate:self];
	[self executeRequest];

}


-(void)sendrequestToFetchLightWeightHomeSummaryWithDelegate:(id )delegate andLaunchHomeView:(id)isLaunchHomeView {
    
    
    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor: @"GetHomeSummary2"]];
    
    DLog(@"URL:::%@",urlStr);
    
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setActivityIndicatorParentViewControllerdelegate:delegate];
    
    
    
    if ([delegate isKindOfClass:[LoginViewController class]] || [delegate isKindOfClass:[ResetPasswordViewController class]] || [delegate isKindOfClass:[self class]] || [delegate isKindOfClass:[AppDelegate class]]  )
    {
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDictAndBasicAuth:paramDict]];
    }
    else
    {
        [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    }
    
    [self setServiceID: [ServiceUtil getServiceIDForServiceName: @"GetHomeSummary2"]];
    [self setServiceDelegate:self];
    [self executeRequest:isLaunchHomeView];
    
}


/************************************************************************************************************
 @Function Name   : sendrequestToDropDownOptionForDropDownUri:(NSString*)dropDownUri WithDelegate:(id )delegate
 @Purpose         : Called to get the DropDownOption details for DropDownUri
 @param           : DropDownUri and delegate
 @return          : nil
 *************************************************************************************************************/

- (void)sendrequestToDropDownOptionForDropDownUri:(NSString*)dropDownUri WithDelegate:(id )delegate
{
    LoginModel *loginModel=[[LoginModel alloc]init];
    [loginModel deleteAllDropDownOptionsInfoFromDB];

    NSNumber *pageCount=[NSNumber numberWithInt:1];
    [self.userDefaults setObject:pageCount forKey:@"NextDropDownOptionDownloadPageNo"];
    [self.userDefaults synchronize];

    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"dropDownOptionDownloadCount"];

    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [pageCount stringValue],@"page",
                                      [pageSize stringValue],@"pageSize",
                                      dropDownUri ,@"customFieldUri",
                                      nil];

    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetDropDownOption"]];

    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetDropDownOption"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}

-(void)sendrequestForNextDropDownOptionForDropDownUri:(NSString *)dropDownUri WithDelegate:(id)delegate
{

    int nextFetchPageNo=[[self.userDefaults objectForKey:@"NextDropDownOptionDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [self.userDefaults setObject:nextFetchPageNumber forKey:@"NextDropDownOptionDownloadPageNo"];
    [self.userDefaults synchronize];

    NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"dropDownOptionDownloadCount"];

    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [pageNum stringValue],@"page",
                                      [pageSize stringValue],@"pageSize",
                                      dropDownUri ,@"customFieldUri",
                                      nil];

    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetDropDownOption"]];

    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextDropDownOption"]];
    [self setServiceDelegate:self];
    [self executeRequest];
}

- (void)sendrequestForObjectExtensionTagsForDropDownUri:(NSString *)dropDownUri searchString:(NSString *)searchString WithDelegate:(id)delegate
{
    LoginModel *loginModel=[[LoginModel alloc]init];
    [loginModel deleteAllOEFDropDownTagOptionsInfoFromDB];

    NSNumber *pageCount=[NSNumber numberWithInt:1];
    [self.userDefaults setObject:pageCount forKey:@"NextOEFDropDownTagOptionDownloadPageNo"];
    [self.userDefaults synchronize];

    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"oefDropDownTagOptionDownloadCount"];


    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [pageCount stringValue],@"page",
                                      [pageSize stringValue],@"pageSize",
                                      dropDownUri ,@"objectExtensionTagDefinitionUri",
                                      nil];

    if (searchString!=nil && ![searchString isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *textSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             searchString ,@"queryText",
                                             @"true",@"searchInDisplayText",
                                             @"false",@"searchInName",
                                            nil];
        [queryDict setObject:textSearchDict forKey:@"textSearch"];
    }

    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetPageOfObjectExtensionTagsFilteredBySearch"]];

    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetPageOfObjectExtensionTagsFilteredBySearch"]];
    [self setServiceDelegate:self];
    [self executeRequest:searchString];
}

- (void)sendrequestForNextObjectExtensionTagsForDropDownUri:(NSString *)dropDownUri searchString:(NSString *)searchString WithDelegate:(id)delegate
{

    int nextFetchPageNo=[[self.userDefaults objectForKey:@"NextOEFDropDownTagOptionDownloadPageNo"] intValue];
    NSNumber *nextFetchPageNumber=[NSNumber numberWithInt:nextFetchPageNo+1];
    [self.userDefaults setObject:nextFetchPageNumber forKey:@"NextOEFDropDownTagOptionDownloadPageNo"];
    [self.userDefaults synchronize];

    NSNumber *pageNum=[NSNumber numberWithInt:nextFetchPageNo+1];
    NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"oefDropDownTagOptionDownloadCount"];

    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [pageNum stringValue],@"page",
                                      [pageSize stringValue],@"pageSize",
                                      dropDownUri ,@"objectExtensionTagDefinitionUri",
                                      nil];


    if (searchString!=nil && ![searchString isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *textSearchDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             searchString ,@"queryText",
                                             @"true",@"searchInDisplayText",
                                             @"false",@"searchInName",
                                             nil];
        [queryDict setObject:textSearchDict forKey:@"textSearch"];
    }

    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetPageOfObjectExtensionTagsFilteredBySearch"]];

    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetNextPageOfObjectExtensionTagsFilteredBySearch"]];
    [self setServiceDelegate:self];
    [self executeRequest:searchString];
}

-(void)sendrequestToLogOut
{
	NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];

	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor: @"LogoutMySession"]];

    DLog(@"URL:::%@",urlStr);

	[paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];



    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];


	[self setServiceID: [ServiceUtil getServiceIDForServiceName: @"LogoutMySession"]];
	[self setServiceDelegate:self];
	[self executeRequest];

}

-(void)sendrequestToUpdateMySessionTimeoutDuration {


	NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      [NSNull null],@"sessionTimeoutDuration",
                                      nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];

	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor: @"UpdateMySessionTimeoutDuration"]];

    DLog(@"URL:::%@",urlStr);

	[paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];



    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];


	[self setServiceID: [ServiceUtil getServiceIDForServiceName: @"UpdateMySessionTimeoutDuration"]];
	[self setServiceDelegate:self];
	[self executeRequest];

}

-(void)fetchGetMyNotificationSummary
{

    self.appDelegate.isCountPendingSheetsRequestInQueue=TRUE;




    NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;

    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"GetMyNotificationSummary"]];



    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"GetMyNotificationSummary"]];
    [self setServiceDelegate:self];
    [self executeRequest];


}

//Implementation For Mobi-190//Reset Password//JUHI
/************************************************************************************************************
 @Function Name   : sendRequestToUpdatePasswordWithOldPassword:(NSString*)oldPswd newPassword:(NSString*)newPswd confirmNewPassword:(NSString*)confirmPswd andDelegate:
 @Purpose         : Called to update USER Password
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)sendRequestToUpdatePasswordWithOldPassword:(NSString*)oldPswd newPassword:(NSString*)newPswd andDelegate:(id)delegate
{
    NSString *companyName = nil;
    NSString *loginName = nil;
    // MOBI-471
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
            companyName = [credentials valueForKey:ACKeychainCompanyName];
            loginName   = [credentials valueForKey:ACKeychainUsername];
        }
    }

    NSMutableDictionary *tenantDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSNull null] ,@"uri",
                                     [NSNull null],@"slug",
                                     companyName,@"companyKey",nil];

    NSMutableDictionary *identityDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       loginName ,@"loginName",nil];



    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      tenantDict ,@"tenant",
                                      identityDict,@"identity",
                                      oldPswd,@"oldPassword",
                                      newPswd,@"newPassword",
                                      [Util getRandomGUID],@"unitOfWorkId", nil];

    NSError *err = nil;
    NSString *str = [JsonWrapper writeJson:queryDict error:&err];

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor:@"ResetPassword"]];



    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [paramDict setObject:str forKey:@"PayLoadStr"];
    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ResetPassword"]];
    [self setServiceDelegate:self];
    [self executeRequest:newPswd];


}

-(void)sendrequestToRegisterForPushNotification:(NSString *)deviceID
{


    NSMutableDictionary *queryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      deviceID ,@"notificationAddress",nil];
	NSError *err = nil;
	NSString *str = [JsonWrapper writeJson:queryDict error:&err];

	NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    urlStr=[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:@"serviceEndpointRootUrl"],[[AppProperties getInstance] getServiceURLFor: @"RegisterForPushNotifications"]];

    DLog(@"URL:::%@",urlStr);

	[paramDict setObject:urlStr forKey:@"URLString"];
	[paramDict setObject:str forKey:@"PayLoadStr"];



    [self setRequest:[RequestBuilder buildPOSTRequestWithParamDict:paramDict]];


	[self setServiceID: [ServiceUtil getServiceIDForServiceName: @"RegisterForPushNotifications"]];
	[self setServiceDelegate:self];
	[self executeRequest];

}

- (void)sendrequestToLogtoCustomerSupportWithMsg:(NSString *)erroMsg serviceURL:(NSString *)serviceURL {

    if (![[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"])
    {
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        NSString *urlStr=nil;
        if ([self.appConfig getNewMarketingServices]) {
            urlStr =  [NSString stringWithFormat:@"%@/%@",[self.mobileMonitorURLProvider baseUrlForMobileMonitor],[[AppProperties getInstance] getServiceURLFor: @"ContactMobileSupport_NewMarketingService"]];
        } else {
            urlStr =  [NSString stringWithFormat:@"https://www.replicon.com/contactMobileSupport"];
        }
        
        // urlStr =  [NSString stringWithFormat:@"http://tsonline.com.au/contactMobileSupport"];
        DLog(@"URL:::%@",urlStr);

        [paramDict setObject:urlStr forKey:@"URLString"];

        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        [dataDict setObject:@"iOS Replicon Mobile 3" forKey:@"productName"];
        [dataDict setObject:erroMsg forKey:@"errorMsg"];

        ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
        if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
            NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
            if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
                NSString *companyName = [credentials valueForKey:ACKeychainCompanyName];
                NSString *loginName   = [credentials valueForKey:ACKeychainUsername];

                if (companyName!=nil && ![companyName isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:companyName forKey:@"company"];
                }
                else
                {
                    [dataDict setObject:@"Unknown" forKey:@"company"];
                }

                if (loginName!=nil && ![loginName isKindOfClass:[NSNull class]])
                {
                    [dataDict setObject:loginName forKey:@"username"];
                }
                else
                {
                    [dataDict setObject:@"Unknown" forKey:@"username"];
                }

            }
        }


        NSString* finalLogsStr =nil;

        DDFileLogger *fileLogger = [LogUtil ddFileLogger];

        NSString* text = [NSString stringWithContentsOfFile:fileLogger.currentLogFileInfo.filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
    if (fileLogger.currentLogFileInfo.fileSize<(384 * 1024))
    {
        NSArray *sortedLogFileNames = [LogUtil ddLogFileManagerDefault].sortedLogFileNames;
        if (sortedLogFileNames.count>=2)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *path1 = [NSString stringWithFormat:@"%@%@",[documentsDirectory stringByAppendingFormat:@"/logs/"],sortedLogFileNames[1]];
            NSString* text1 = [NSString stringWithContentsOfFile:path1
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];
            text = [NSString stringWithFormat:@"%@\n%@",text1,text];
        }
    }

        text = [[[text stringByStrippingTags] stringByRemovingNewLinesAndWhitespace] stringByDecodingHTMLEntities];
        text=[text stringByReplacingOccurrencesOfString:@"&" withString:@" "];

        if (finalLogsStr)
        {
            finalLogsStr=[NSString stringWithFormat:@"%@\n%@",finalLogsStr,text];
        }
        else
        {
            finalLogsStr=[NSString stringWithFormat:@"%@",text];
        }

        if (finalLogsStr)
        {
            if ([finalLogsStr isEqualToString:@"(null)"])
            {
                [dataDict setObject:@"No Logs Found" forKey:@"description"];
            }
            else
            {
                [dataDict setObject:finalLogsStr forKey:@"description"];
            }

        }
        else
        {
            [dataDict setObject:@"No Logs Found" forKey:@"description"];
        }

        id errorID = [Util getRandomGUID];
        [dataDict setObject:errorID forKey:@"errorID"];

        NSString *htmlBody=[ReportTechnicalErrors createHTMLToSupportForTechErrorsWithData:dataDict];

        NSString *emailID=@"mobileccerrorlogs@replicon.com";
        NSString *subject=[NSString stringWithFormat:@"Error (iOS Mobile): %@",erroMsg];


        CLSLog(@"Error ID ---- %@",errorID);
        NSString *networkType= [ReportTechnicalErrors fetchNetworkType];
        if (networkType)
        {
            CLSLog(@"Network Type at time of reporting ---- %@",networkType);
        }

        NSString *recordUrl = @"unknown";
        if (serviceURL!=nil && ![serviceURL isKindOfClass:[NSNull class]])
        {
            if ([self.userDefaults objectForKey:@"serviceEndpointRootUrl"]!=nil && ![[self.userDefaults objectForKey:@"serviceEndpointRootUrl"] isKindOfClass:[NSNull class]])
            {
                NSArray *urlArray = [serviceURL componentsSeparatedByString:[self.userDefaults objectForKey:@"serviceEndpointRootUrl"]];
                if (urlArray.count==2)
                {
                    recordUrl = urlArray[1];
                }
                else if (urlArray.count==1)
                {
                    recordUrl = serviceURL;
                }
            }
            else
            {
                recordUrl = serviceURL;
            }

        }

        // log inhouse, release errors to GA
         /* GA Remove reoprting all technical errors - MO-29  */
        /*id<BSInjector, BSBinder> injector = [InjectorProvider injector];
        GATracker *gaTracker = [injector getInstance:[GATracker class]]; */

        if ([erroMsg isEqualToString:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)])
        {
            [[Crashlytics sharedInstance] recordCustomExceptionName:UNKNOWN_ERROR_MESSAGE reason:recordUrl frameArray:@[]];
            
            /* GA Remove reoprting all technical errors - MO-29  */
            
//            [gaTracker trackNonFatalError:[UNKNOWN_ERROR_MESSAGE lowercaseString] withErrorID:errorID withErrorType:@"technical"];
            
            
            /* Send only technical errors - MO-29  */
            
            if (CommonUtil.isRelease || CommonUtil.isInHouse)
            {
                emailID=@"mobileccerrorlogs@replicon.com";
                [paramDict setObject:[NSString stringWithFormat:@"html_msg=%@&email=%@&subject=%@",htmlBody,emailID,subject] forKey:@"PayLoadStr"];
                
                [self setRequest:[RequestBuilder buildPOSTRequestForContactingSupportWithParamDict:paramDict]];
                [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"ContactMobileSupport"]];
                [self setServiceDelegate:self];
                [self executeRequest];
                
            }
            

        }
        
         /* GA Remove reoprting all technical errors - MO-29  */
        
        /*else
        {
            NSArray *temp = [self.appDelegate.peristedLocalizableStringsDict allKeysForObject:erroMsg];
            if (temp.count>0)
            {
                NSString *englishString = [temp objectAtIndex:0];
                if(englishString)
                {
                    [gaTracker trackNonFatalError:[englishString lowercaseString] withErrorID:errorID withErrorType:@"na"];
                }
            }
            else
            {
                [gaTracker trackNonFatalError:erroMsg withErrorID:errorID withErrorType:@"na"];
            }
        }
      */

        
    }
}

- (void)sendRequestToCheckServerDownStatusWithServiceURL:(NSString *)serviceURL {

    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSString *urlStr=nil;
    if ([self.appConfig getNewMarketingServices]) {
        urlStr =  [NSString stringWithFormat:@"%@/%@",[self.mobileMonitorURLProvider baseUrlForMobileMonitor],[[AppProperties getInstance] getServiceURLFor:@"getServerDownStatus_NewMarketingService"]];
    } else {
        urlStr =  [NSString stringWithFormat:@"https://www.replicon.com/%@",[[AppProperties getInstance] getServiceURLFor:@"getServerDownStatus"]];
    }
    
    //urlStr=@"http://tsonline.com.au/getSystemDownTimeInfoForMobile";
    DLog(@"URL:::%@",urlStr);
    [paramDict setObject:urlStr forKey:@"URLString"];
    [self setRequest:[RequestBuilder buildGETRequestWithParamDict:paramDict]];
    [self setServiceID: [ServiceUtil getServiceIDForServiceName:@"getServerDownStatus"]];
    [self setServiceDelegate:self];
    [self executeRequest:serviceURL];
}

#pragma mark -
#pragma mark handle response methods

/************************************************************************************************************
 @Function Name   : handleUserIntegrationDetailsURLResponse
 @Purpose         : Called to store the user integration details URLs ie to know whether user internal/saml.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/




-(void)handleUserIntegrationDetailsforiOS7URLResponse:(id)responseData
{
    id response = [[responseData objectForKey:@"response"]objectForKey:@"d"];
    NSString *buttonType = [[responseData objectForKey:@"refDict"]objectForKey:@"params"];

    if ([response objectForKey:@"serviceEndpointRootUrl"]==nil)
    {
         [Util errorAlert:@"" errorMessage:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)];
        NSString *serviceURL = [responseData objectForKey:@"serviceURL"];
        [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
        return;
    }

    [self.userDefaults setObject:[response objectForKey:@"serviceEndpointRootUrl"] forKey:@"serviceEndpointRootUrl"];

    BOOL loadGoogleView = FALSE;
    NSString  *ssoOpenUrl = nil;
    NSString *currentversionName = nil;

    int isSupportSAML = 0;
    int isSupportSSO= 0;
    int isSupportInternal = 0;

    if ([(NSMutableArray *)[response objectForKey:@"authenticationServiceProviders"] count]>0)
    {
        for (int i=0; i<[(NSMutableArray *)[response objectForKey:@"authenticationServiceProviders"] count]; i++) {
            NSDictionary *authenticationServiceProvidersDict=[[response objectForKey:@"authenticationServiceProviders"] objectAtIndex:i];
            NSString *protocolStr=[authenticationServiceProvidersDict objectForKey:@"protocol"];


            if ([protocolStr isEqualToString:@"urn:replicon-global:authentication-protocol:web-browser-sso"])
            {


                NSString *tempString = [authenticationServiceProvidersDict objectForKey:@"requestUrl"];
                if ( [[tempString capitalizedString] rangeOfString:[@"OAuth2" capitalizedString]].location != NSNotFound ) {
                    ssoOpenUrl = [authenticationServiceProvidersDict objectForKey:@"requestUrl"];
                    isSupportSSO = 1;

                }

                else
                {

                    if ( [[tempString capitalizedString] rangeOfString:[@"OpenId" capitalizedString]].location != NSNotFound )
                    {
                    }
                    else
                    {
                        [self.userDefaults setObject:[authenticationServiceProvidersDict objectForKey:@"requestUrl"] forKey:@"RequestServiceURL"];
                        isSupportSAML = 1;
                    }


                }



            }
            if([protocolStr isEqualToString:@"urn:replicon-global:authentication-protocol:replicon"])
            {
                isSupportInternal = 1;
            }


        }

        if([buttonType isEqualToString:@"Sign In"])
        {
            if (isSupportInternal==1) {
                [self.userDefaults setObject:@"INTERNAL"  forKey:@"AuthMode"];
            }
            else if (isSupportSAML==1)
            {
                [self.userDefaults setObject:@"SAML"  forKey:@"AuthMode"];
            }
            else if(isSupportSAML == 0 && isSupportInternal == 0){
                [self.userDefaults setObject:ssoOpenUrl forKey:@"RequestServiceURL"];
                [self.userDefaults setObject:@"SAML"  forKey:@"AuthMode"];
                loadGoogleView = TRUE;
                isSupportSAML = 1;
            }
        }
        else
        {
            if (isSupportSSO == 1) {
                [self.userDefaults setObject:ssoOpenUrl forKey:@"RequestServiceURL"];
                [self.userDefaults setObject:@"SAML"  forKey:@"AuthMode"];
                loadGoogleView = TRUE;
                isSupportSAML = 1;
            }
            else if (isSupportSAML == 1)
            {
                [self.userDefaults setObject:@"SAML"  forKey:@"AuthMode"];
            }
            else{
                [self.userDefaults setObject:@"INTERNAL"  forKey:@"AuthMode"];
            }

        }


        currentversionName=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSString *versionTable = @"version_info";

        NSDictionary *dbInfoDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      currentversionName,@"version_number",
                                      [NSNumber numberWithInt:isSupportSAML],@"isSupportSAML",
                                      nil];

        NSString *whereString = [NSString stringWithFormat:@"version_number = '%@'",currentversionName];
        [myDB updateTable:versionTable data:dbInfoDataDict where:whereString intoDatabase:@""];
    }

    [self.userDefaults synchronize];

    if (loadGoogleView)
    {
        [self.appDelegate updateLoginViewController:ssoOpenUrl];
    }
    else if ([[self.userDefaults objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        NSString *openUrl=[self.userDefaults objectForKey:@"RequestServiceURL"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openUrl]];
    }
    else
    {
        [self.userDefaults setBool:YES forKey:@"FromCompanyView"];
        [self.appDelegate updateLoginViewController:nil];
    }

    NSDictionary   *Dict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE],@"isError",nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil userInfo:Dict ];
}


-(void)handleUserIntegrationDetailsURLForFreeTrialResponse:(id)response
{
    [self.userDefaults setObject:[response objectForKey:@"serviceEndpointRootUrl"] forKey:@"serviceEndpointRootUrl"];

    if ([(NSMutableArray *)[response objectForKey:@"authenticationServiceProviders"] count]>0)
    {
        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSString *versionTable = @"version_info";

        int isSupportSAML = 0;
        NSString *currentversionName=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

        [self.userDefaults setObject:@"INTERNAL"  forKey:@"AuthMode"];
        isSupportSAML = 0;

        NSDictionary *dbInfoDataDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      currentversionName,@"version_number",
                                      [NSNumber numberWithInt:isSupportSAML],@"isSupportSAML",
                                      nil];

        NSString *whereString = [NSString stringWithFormat:@"version_number = '%@'",currentversionName];
        [myDB updateTable:versionTable data:dbInfoDataDict where:whereString intoDatabase:@""];
    }

    [self.userDefaults synchronize];

    [self.userDefaults setBool:YES forKey:@"FromCompanyView"];
   [[RepliconServiceManager loginService] sendrequestToFetchLightWeightHomeSummaryWithDelegate:self andLaunchHomeView:[NSNumber numberWithBool:YES]];
    [[RepliconServiceManager loginService] sendrequestToFetchHomeSummaryWithDelegate:self];
}


/************************************************************************************************************
 @Function Name   : handleHomeSummaryResponse
 @Purpose         : Called to store the user home details ie user's timesheet,expense,timeoff&expenses capabilities
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

- (void)handleHomeSummaryResponse:(NSDictionary *)homeSummaryResponse
{
    LoginModel *loginModel = [[LoginModel alloc]init];
    [loginModel flushUserDefinedFields];

    NSDictionary *userSummary=[homeSummaryResponse objectForKey:@"userSummary"];
    NSDictionary *timesheetCapabilities=[userSummary objectForKey:@"timesheetCapabilities"];
    NSDictionary *timesheetCurrentCapabilities=[timesheetCapabilities objectForKey:@"currentCapabilities"];
    NSMutableArray *sheetLevelEnableOnlyUdfUriArr=[timesheetCurrentCapabilities objectForKey:@"enabledCustomFieldUris"];
    NSMutableArray *cellOrRowLevelEnableOnlyUdfUriArr=[timesheetCurrentCapabilities objectForKey:@"enabledEntryCustomFieldUris"];

    NSDictionary *timeoffCapabilities=[userSummary objectForKey:@"timeoffCapabilities"];
    NSDictionary *timeoffCurrentCapabilities=[timeoffCapabilities objectForKey:@"currentCapabilities"];
    NSMutableArray *timeoffEnableOnlyUdfUriArr=[timeoffCurrentCapabilities objectForKey:@"enabledCustomFieldUris"];
    [self.userDefaults setObject:timeoffEnableOnlyUdfUriArr forKey:@"timeoffEnableOnlyUdfUriArr"];

    NSArray *timesheetCustomFieldsArr=[homeSummaryResponse objectForKey:@"timesheetCustomFields"];
    [self handleUserDefinedFields:timesheetCustomFieldsArr forModuleName:TIMESHEET_SHEET_UDF enabledUriArray:sheetLevelEnableOnlyUdfUriArr];

    //Implementation for US9371//JUHI
    NSArray *timesheetEntryCustomFieldsArr=nil;
    if ([(NSMutableArray *)[homeSummaryResponse objectForKey:@"timesheetEntryCellCustomFields"] count]>0)
    {
        timesheetEntryCustomFieldsArr=[homeSummaryResponse objectForKey:@"timesheetEntryCellCustomFields"];
    }


    [self handleUserDefinedFields:timesheetEntryCustomFieldsArr forModuleName:TIMESHEET_CELL_UDF enabledUriArray:cellOrRowLevelEnableOnlyUdfUriArr];
    //Implementation for US9371//JUHI
    NSArray *timesheetRowEntryCustomFieldsArr=nil;
    timesheetRowEntryCustomFieldsArr=[homeSummaryResponse objectForKey:@"timesheetEntryRowLeftCustomFields"];
    [self handleUserDefinedFields:timesheetRowEntryCustomFieldsArr forModuleName:TIMESHEET_ROW_UDF enabledUriArray:cellOrRowLevelEnableOnlyUdfUriArr];
    timesheetRowEntryCustomFieldsArr=[homeSummaryResponse objectForKey:@"timesheetEntryRowRightCustomFields"];
    [self handleUserDefinedFields:timesheetRowEntryCustomFieldsArr forModuleName:TIMESHEET_ROW_UDF enabledUriArray:cellOrRowLevelEnableOnlyUdfUriArr];

    NSArray *expenseEntryCustomFields=[homeSummaryResponse objectForKey:@"expenseEntryCustomFields"];
    [self handleUserDefinedFields:expenseEntryCustomFields forModuleName:EXPENSES_UDF enabledUriArray:nil];

    NSArray *timeOffCustomFieldsArr=[homeSummaryResponse objectForKey:@"timeOffCustomFields"];
    [self handleUserDefinedFields:timeOffCustomFieldsArr forModuleName:TIMEOFF_UDF enabledUriArray:timeoffEnableOnlyUdfUriArr];




    //BASE CURRENCY HANDLINGS
    NSDictionary *baseCurrencySummary=[homeSummaryResponse objectForKey:@"baseCurrency"];
    NSString *baseCurrencyName=[baseCurrencySummary objectForKey:@"displayText"];
    NSString *baseCurrencyUri=[baseCurrencySummary objectForKey:@"uri"];
    //APPROVAL CAPABILITIES

    NSDictionary *approvalCapabilities=[userSummary objectForKey:@"approvalCapabilities"];
    int areTimeSheetRejectCommentsRequired  =0;
    int isTimeOffApprover                   =0;
    int areTimeOffRejectCommentsRequired    =0;
    int isTimeSheetApprover                 =0;
    int isExpenseApprover                 =0;
    int areExpenseRejectCommentsRequired    =0;
    int isShiftsApprover                   =0;

    NSDictionary *approvalCapabilitiesTimeOff=[approvalCapabilities objectForKey:@"timeoffApprovalCapabilities"];

    if ([[approvalCapabilitiesTimeOff objectForKey:@"areRejectCommentsRequired"] boolValue] == YES )
    {
        areTimeOffRejectCommentsRequired = 1;
    }
    if ([[approvalCapabilitiesTimeOff objectForKey:@"isTimeOffApprover"] boolValue] == YES )
    {
        isTimeOffApprover = 1;

    }


    NSDictionary *approvalCapabilitiesTimeSheet=[approvalCapabilities objectForKey:@"timesheetApprovalCapabilities"];

    if ([[approvalCapabilitiesTimeSheet objectForKey:@"areRejectCommentsRequired"] boolValue] == YES )
    {
        areTimeSheetRejectCommentsRequired = 1;
    }
    if ([[approvalCapabilitiesTimeSheet objectForKey:@"isTimesheetApprover"] boolValue] == YES )
    {
        isTimeSheetApprover = 1;

    }

    NSDictionary *approvalCapabilitiesExpenses=[approvalCapabilities objectForKey:@"expenseApprovalCapabilities"];

    if ([[approvalCapabilitiesExpenses objectForKey:@"areRejectCommentsRequired"] boolValue] == YES )
    {
        areExpenseRejectCommentsRequired = 1;
    }
    if ([[approvalCapabilitiesExpenses objectForKey:@"isExpenseApprover"] boolValue] == YES )
    {
        isExpenseApprover = 1;

    }

    //TIMEOFF CAPABILITIES

    int hasTimeoffBookingAccess             =0;
    int isMultiDayTimeOffOptionAvailable    = 0;

    if ([[timeoffCapabilities objectForKey:@"hasTimeoffBookingAccess"] boolValue] == YES )
    {
        hasTimeoffBookingAccess = 1;
    }
    if ([[timeoffCapabilities objectForKey:@"isMultiDayTimeOffOptionAvailable"] boolValue] == YES )
    {
        isMultiDayTimeOffOptionAvailable = 1;
    }
    NSString *timeoffDisplayFormat=[[timeoffCapabilities objectForKey:@"currentCapabilities"] objectForKey:@"timeoffDisplayFormat"];
    int hasTimeOffEditAcess     =0;
    int hasTimeOffDeletetAcess  =0;
    if ([[[timeoffCapabilities objectForKey:@"currentCapabilities"] objectForKey:@"canDeleteTimeOff"] boolValue] == YES )
    {
        hasTimeOffDeletetAcess = 1;
    }
    if ([[[timeoffCapabilities objectForKey:@"currentCapabilities"] objectForKey:@"canEditTimeOff"] boolValue] == YES )
    {
        hasTimeOffEditAcess = 1;
    }

     NSDictionary *timePunchCapabilities=[userSummary objectForKey:@"timePunchCapabilities"];
    //TIMESHEET CAPABILITIES

    NSDictionary *shiftCapabilities=[userSummary objectForKey:@"shiftCapabilities"];

    NSDictionary *payDetailCapabilities=[userSummary objectForKey:@"payDetailCapabilities"];



    int hasBillingAccess            =0;
    int hasProjectAccess            =0;
    int hasClientAccess             =0;
    int hasProgramAccess            =0;//MOBI-746
    int projectTaskSelectionRequired=0;
    int hasTimesheetAccess          =0;
    int hasTimesheetTimeoffAccess   =0;
    int hasActivityAccess           =0;
    int activitySelectionRequired   =0;
    int hasBreakAccess              =0;
    int canEditTimePunch           =0;
    int hasPunchInOutAccess         =0;
	int punchInOutactivitySelectionRequired   =0;
    int punchInOuthasBillingAccess            =0;
    int punchInOuthasProjectAccess            =0;
    int punchInOuthasClientAccess             =0;
    int punchInOutprojectTaskSelectionRequired=0;
    int punchInOutHasActivityAccess           =0;
    int punchInOuthasBreakAccess              =0;
    int punchInOutAuditImageRequired          =0;
    int punchInOutGeolocationRequired         =0;
    int canViewTeamTimePunch                  =0;
    int canViewTimePunch                      =0;
    int canTransferTimePunchToTimesheet       =0;
    int canViewTeamTimesheet                  =0;
    int canViewTeamPayDetails                  =0;


    if ([[timesheetCurrentCapabilities objectForKey:@"hasBreakAccess"] boolValue] == YES ) {
        hasBreakAccess=1;
    }

    if ([[timesheetCurrentCapabilities objectForKey:@"hasBillingAccess"] boolValue] == YES )
    {
        hasBillingAccess = 1;
    }
    if ([[timesheetCurrentCapabilities objectForKey:@"hasProjectAccess"] boolValue] == YES )
    {
        hasProjectAccess = 1;
    }
    if ([[timesheetCurrentCapabilities objectForKey:@"hasClientAccess"] boolValue] == YES )
    {
        hasClientAccess = 1;
    }//MOBI-746
    if ([[timesheetCurrentCapabilities objectForKey:@"hasProgramAccess"] boolValue] == YES )
    {
        hasProgramAccess = 1;
    }
    if ([[timesheetCurrentCapabilities objectForKey:@"projectTaskSelectionRequired"] boolValue] == YES )
    {
        projectTaskSelectionRequired = 1;
    }
    if ([[timesheetCapabilities objectForKey:@"hasTimesheetAccess"] boolValue] == YES )
    {
        hasTimesheetAccess = 1;
    }
    if([timesheetCapabilities objectForKey:@"canViewTeamTimesheet"]!=nil && [timesheetCapabilities objectForKey:@"canViewTeamTimesheet"]!=(id)[NSNull null])
    {
        if([[timesheetCapabilities objectForKey:@"canViewTeamTimesheet"] boolValue]==YES)
        {
            canViewTeamTimesheet = 1;
        }
    }
    if ([[timesheetCurrentCapabilities objectForKey:@"hasTimesheetTimeOffAccess"] boolValue] == YES )
    {
        hasTimesheetTimeoffAccess = 1;
    }
    if ([[timesheetCurrentCapabilities objectForKey:@"activitySelectionRequired"] boolValue] == YES )
    {
        activitySelectionRequired = 1;
    }
    if ([[timesheetCurrentCapabilities objectForKey:@"hasActivityAccess"] boolValue] == YES )
    {
        hasActivityAccess = 1;
    }
    if ([[shiftCapabilities objectForKey:@"canViewShifts"] boolValue] == YES )
    {
        isShiftsApprover = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"hasTimePunchAccess"] boolValue] == YES || [[timePunchCapabilities objectForKey:@"hasManualTimePunchAccess"] boolValue] == YES)
    {
        hasPunchInOutAccess = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"activitySelectionRequired"] boolValue] == YES )
    {
        punchInOutactivitySelectionRequired = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"hasBillingAccess"] boolValue] == YES )
    {
        punchInOuthasBillingAccess = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"hasBreakAccess"] boolValue] == YES )
    {
        punchInOuthasBreakAccess = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"hasProjectAccess"] boolValue] == YES )
    {
        punchInOuthasProjectAccess = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"hasClientAccess"] boolValue] == YES )
    {
        punchInOuthasClientAccess = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"projectTaskSelectionRequired"] boolValue] == YES )
    {
        punchInOutprojectTaskSelectionRequired = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"hasActivityAccess"] boolValue] == YES )
    {
        punchInOutHasActivityAccess = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"auditImageRequired"] boolValue] == YES )
    {
        punchInOutAuditImageRequired = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"geolocationRequired"] boolValue] == YES )
    {
        punchInOutGeolocationRequired = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"canEditTimePunch"] boolValue] == YES )
    {
        canEditTimePunch = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"canViewTeamTimePunch"] boolValue] == YES )
    {
        canViewTeamTimePunch = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"canViewTimePunch"] boolValue] == YES )
    {
        canViewTimePunch = 1;
    }
    if ([[timePunchCapabilities objectForKey:@"canTransferTimePunchToTimesheet"] boolValue] == YES )
    {
        canTransferTimePunchToTimesheet = 1;
    }

    int canEditTeamTimePunch = 0;
    if ([[timePunchCapabilities objectForKey:@"canEditTeamTimePunch"] boolValue] == YES )
    {
        canEditTeamTimePunch = 1;
    }

    if ([[payDetailCapabilities objectForKey:@"canViewTeamPayDetails"] boolValue] == YES )
    {
        canViewTeamPayDetails = 1;
    }


    NSString *timesheetFormat=[timesheetCurrentCapabilities objectForKey:@"timesheetFormat"];
    NSString *timesheetHourFormat=[timesheetCapabilities objectForKey:@"timesheetHourFormat"];
    NSString *timesheetNoticePolicyUri=[timesheetCurrentCapabilities objectForKey:@"timesheetNoticePolicyUri"];
    //EXPENSE CAPABILITIES

    NSDictionary *expenseCapabilities=[userSummary objectForKey:@"expenseCapabilities"];
    NSDictionary *currentCapabilities=[expenseCapabilities objectForKey:@"currentCapabilities"];
    int hasBillClient               =0;
    int hasExpenseAccess            =0;
    int hasPaymentMethod            =0;
    int hasReimbursements           =0;
    int entryAgainstProjectsAllowed =0;
    int hasExpensesClientAccess =0;
    int entryAgainstProjectsRequired=0;
    int canViewReceipt=0;
    int canEditTask                 =0;
    NSString *expenseNoticePolicyUri=[currentCapabilities objectForKey:@"expenseNoticePolicyUri"];//Implementation as per US9172//JUHI
    if ([[currentCapabilities objectForKey:@"canViewBillToClient"] boolValue] == YES )
    {
        hasBillClient = 1;
    }
    if ([[expenseCapabilities objectForKey:@"hasExpenseAccess"] boolValue] == YES )
    {
        hasExpenseAccess = 1;
    }
    if ([[currentCapabilities objectForKey:@"canViewPaymentMethod"] boolValue] == YES )
    {
        hasPaymentMethod = 1;
    }
    if ([[currentCapabilities objectForKey:@"canViewReceipt"] boolValue] == YES )
    {
        canViewReceipt = 1;
    }
    if ([[currentCapabilities objectForKey:@"canViewReimburse"] boolValue] == YES )
    {
        hasReimbursements = 1;
    }
    if ([[currentCapabilities objectForKey:@"entryAgainstProjectsAllowed"] boolValue] == YES )
    {
        entryAgainstProjectsAllowed = 1;
    }
    if ([[currentCapabilities objectForKey:@"canEditTask"] boolValue] == YES )
    {
        canEditTask = 1;
    }
    if ([[currentCapabilities objectForKey:@"selectProjectByClient"] boolValue] == YES )
    {
        hasExpensesClientAccess = 1;
    }
    if ([[currentCapabilities objectForKey:@"entryAgainstProjectsRequired"] boolValue] == YES )
    {
        entryAgainstProjectsRequired = 1;
    }




    //LANGUAGE SETTINGS

    NSDictionary *language=[userSummary objectForKey:@"language"];
    NSString *language_cultureCode=[language objectForKey:@"cultureCode"];
    NSString *language_displayText=[language objectForKey:@"displayText"];
    NSString *language_isoName=[language objectForKey:@"languageCode"];
    NSString *language_uri=[language objectForKey:@"uri"];

    //USER DATA

    NSDictionary *user=[userSummary objectForKey:@"user"];
    NSString *displayText=[user objectForKey:@"displayText"];
    NSString *slug=[user objectForKey:@"slug"];
    NSString *uri=[user objectForKey:@"uri"];


    //SHIFTS URI
    NSString *workWeekStartDayUri = [[userSummary objectForKey:@"workWeekStartDay"] objectForKey:@"uri"];


    SQLiteDB *myDB	= [SQLiteDB getInstance];
    NSMutableDictionary *propertiesDict=[NSMutableDictionary dictionary];
    [propertiesDict setObject:[NSNumber numberWithInt:areTimeSheetRejectCommentsRequired] forKey:@"areTimeSheetRejectCommentsRequired"];
    [propertiesDict setObject:[NSNumber numberWithInt:isTimeSheetApprover] forKey:@"isTimesheetApprover"];
    [propertiesDict setObject:[NSNumber numberWithInt:areTimeOffRejectCommentsRequired] forKey:@"areTimeOffRejectCommentsRequired"];
    [propertiesDict setObject:[NSNumber numberWithInt:isTimeOffApprover] forKey:@"isTimeOffApprover"];
    [propertiesDict setObject:[NSNumber numberWithInt:isExpenseApprover] forKey:@"isExpenseApprover"];
    [propertiesDict setObject:[NSNumber numberWithInt:isShiftsApprover] forKey:@"canViewShifts"];
    [propertiesDict setObject:[NSNumber numberWithInt:areExpenseRejectCommentsRequired] forKey:@"areExpenseRejectCommentsRequired"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasBillClient] forKey:@"hasExpenseBillClient"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasExpenseAccess] forKey:@"hasExpenseAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasPaymentMethod] forKey:@"hasExpensePaymentMethod"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasReimbursements] forKey:@"hasExpenseReimbursements"];
    [propertiesDict setObject:[NSNumber numberWithInt:canViewReceipt] forKey:@"hasExpenseReceiptView"];
    [propertiesDict setObject:[NSNumber numberWithInt:entryAgainstProjectsAllowed] forKey:@"expenseEntryAgainstProjectsAllowed"];
    [propertiesDict setObject:[NSNumber numberWithInt:canEditTask] forKey:@"canEditTask"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasExpensesClientAccess] forKey:@"hasExpensesClientAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:entryAgainstProjectsRequired] forKey:@"expenseEntryAgainstProjectsRequired"];
    [propertiesDict setObject:language_cultureCode forKey:@"language_cultureCode"];
    [propertiesDict setObject:language_displayText forKey:@"language_displayText"];
    [propertiesDict setObject:language_isoName forKey:@"language_code"];
    [propertiesDict setObject:language_uri forKey:@"language_uri"];
    [propertiesDict setObject:workWeekStartDayUri forKey:@"workWeekStartDayUri"];

    if ([self.userDefaults objectForKey:@"workWeekStartDayUri"] == [NSNull class]) {
        [self.userDefaults setValue:workWeekStartDayUri forKey:@"workWeekStartDayUri"];
    }


    [propertiesDict setObject:[NSNumber numberWithInt:hasTimeoffBookingAccess] forKey:@"hasTimeoffBookingAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:isMultiDayTimeOffOptionAvailable] forKey:@"isMultiDayTimeOffOptionAvailable"];
    if (timeoffDisplayFormat!=nil && ![timeoffDisplayFormat isKindOfClass:[NSNull class]])
    {
        [propertiesDict setObject:timeoffDisplayFormat forKey:@"timeoffDisplayFormat"];
    }

    [propertiesDict setObject:[NSNumber numberWithInt:hasTimeOffDeletetAcess] forKey:@"hasTimeOffDeletetAcess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasTimeOffEditAcess] forKey:@"hasTimeOffEditAcess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasBillingAccess] forKey:@"hasTimesheetBillingAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasProjectAccess] forKey:@"hasTimesheetProjectAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasClientAccess] forKey:@"hasTimesheetClientAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasProgramAccess] forKey:@"hasTimesheetProgramAccess"];//MOBI-746
    [propertiesDict setObject:[NSNumber numberWithInt:projectTaskSelectionRequired] forKey:@"timesheetProjectTaskSelectionRequired"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasTimesheetAccess] forKey:@"hasTimesheetAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:canViewTeamTimesheet] forKey:@"canViewTeamTimesheet"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasTimesheetTimeoffAccess] forKey:@"hasTimesheetTimeoffAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasActivityAccess] forKey:@"hasTimesheetActivityAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:activitySelectionRequired] forKey:@"timesheetActivitySelectionRequired"];
    [propertiesDict setObject:timesheetFormat forKey:@"timesheetFormat"];
    [propertiesDict setObject:timesheetHourFormat forKey:@"timesheetHourFormat"];
    [propertiesDict setObject:timesheetNoticePolicyUri forKey:@"disclaimerTimesheetNoticePolicyUri"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasBreakAccess] forKey:@"hasTimesheetBreakAccess"];//Implentation for US8956//JUHI
    if (expenseNoticePolicyUri!=nil && ![expenseNoticePolicyUri isKindOfClass:[NSNull class]])
    {
        [propertiesDict setObject:expenseNoticePolicyUri forKey:@"disclaimerExpensesheetNoticePolicyUri"];//Implementation as per US9172//JUHI
    }

    [propertiesDict setObject:[NSNumber numberWithInt:canEditTimePunch] forKey:@"canEditTimePunch"];
    [propertiesDict setObject:displayText forKey:@"displayText"];
    [propertiesDict setObject:slug forKey:@"slug"];
    [propertiesDict setObject:uri forKey:@"uri"];
    [propertiesDict setObject:slug forKey:@"slug"];
    [propertiesDict setObject:uri forKey:@"uri"];
    if (baseCurrencyName!=nil && ![baseCurrencyName isKindOfClass:[NSNull class]])
    {
        [propertiesDict setObject:baseCurrencyName forKey:@"baseCurrencyName"];
    }
    if (baseCurrencyUri!=nil && ![baseCurrencyUri isKindOfClass:[NSNull class]])
    {
        [propertiesDict setObject:baseCurrencyUri forKey:@"baseCurrencyUri"];
    }
     [propertiesDict setObject:[NSNumber numberWithInt:hasPunchInOutAccess] forKey:@"hasPunchInOutAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:punchInOutactivitySelectionRequired] forKey:@"timepunchActivitySelectionRequired"];
    [propertiesDict setObject:[NSNumber numberWithInt:punchInOuthasBillingAccess] forKey:@"hasTimepunchBillingAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:punchInOutHasActivityAccess] forKey:@"hasTimepunchActivityAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:punchInOuthasBreakAccess] forKey:@"hasTimepunchBreakAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:punchInOuthasClientAccess] forKey:@"hasTimepunchClientAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:punchInOuthasProjectAccess] forKey:@"hasTimepunchProjectAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:punchInOutprojectTaskSelectionRequired] forKey:@"timepunchProjectTaskSelectionRequired"];
    [propertiesDict setObject:[NSNumber numberWithInt:punchInOutGeolocationRequired] forKey:@"timepunchGeolocationRequired"];
    [propertiesDict setObject:[NSNumber numberWithInt:punchInOutAuditImageRequired] forKey:@"timepunchAuditImageRequired"];
    //PUNCH-154 Ullas M L
    [propertiesDict setObject:[NSNumber numberWithInt:canViewTeamTimePunch] forKey:@"canViewTeamTimePunch"];
    [propertiesDict setObject:[NSNumber numberWithInt:canViewTimePunch] forKey:@"canViewTimePunch"];
    [propertiesDict setObject:[NSNumber numberWithInt:canTransferTimePunchToTimesheet] forKey:@"canTransferTimePunchToTimesheet"];

    [propertiesDict setObject:[NSNumber numberWithInt:canEditTeamTimePunch] forKey:@"canEditTeamTimePunch"];

    [propertiesDict setObject:[NSNumber numberWithInt:canViewTeamPayDetails] forKey:@"canViewTeamPayDetails"];

    [myDB deleteFromTable:@"userDetails" inDatabase:@""];
    [myDB insertIntoTable:@"userDetails" data:propertiesDict intoDatabase:@""];
    
    CLS_LOG(@"-------userUri and userSessionSet from handleHomeSummaryResponse--------- %@",uri);
    [self.userDefaults setBool:TRUE forKey:@"ValidUserSession"];
    [self.userDefaults setObject:uri forKey:@"UserUri"];
    [self.userDefaults synchronize];

    [AppPersistentStorage setObject:uri forKey:@"UserUri"];

    if (Util.isRelease)
    {
        if (uri!=nil && ![uri isKindOfClass:[NSNull class]])
        {
            [EventTracker.sharedInstance setUserID:uri];
        }
    }

    [[Crashlytics sharedInstance] setUserIdentifier:uri];
    [[Crashlytics sharedInstance] setUserName:[user objectForKey:@"loginName"]];

    NSString *companyName = nil;
    // MOBI-471
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
            companyName = [credentials valueForKey:ACKeychainCompanyName];
        }
    }
    if (companyName!=nil && ![companyName isKindOfClass:[NSNull class]])
    {
        [[Crashlytics sharedInstance] setObjectValue:companyName forKey:@"companyName"];
    }


    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OldHomeFlowServiceReceivedData"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"OldHomeFlowServiceReceivedData" object:nil];

    [self.homeSummaryDelegate homeSummaryFetcher:self didReceiveHomeSummaryResponse:homeSummaryResponse];

    [self.loginDelegate loginServiceDidFinishLoggingIn:self];
}

-(void)handleLightWeightHomeSummaryResponse:(id)response andIsLaunchHomeView:(BOOL)isLaunchHomeView
{
    
    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    
    NSDictionary *userSummary=[response objectForKey:@"userSummary"];
    

   
    int isTimeOffApprover                   =0;
    int isTimeSheetApprover                 =0;
    int isExpenseApprover                   =0;
    
    
    
    if ([[userSummary objectForKey:@"hasTimeOffApprovalAccess"] boolValue] == YES )
    {
        isTimeOffApprover = 1;
        
    }
    if ([[userSummary objectForKey:@"hasTimesheetApprovalAccess"] boolValue] == YES )
    {
        isTimeSheetApprover = 1;
        
    }
    if ([[userSummary objectForKey:@"hasExpenseApprovalAccess"] boolValue] == YES )
    {
        isExpenseApprover = 1;
        
    }
    

    
    
    
    
    int hasTimesheetAccess                    =0;
    int hasExpenseAccess                      =0;
    int canViewTeamTimePunch                  =0;
    int canViewTimePunch                      =0;
    int hasPunchInOutAccess                   =0;
    int hasTimeoffBookingAccess               =0;
    int hasShiftAccess                        =0;
    
    if ([[userSummary objectForKey:@"hasTimesheetAccess"] boolValue] == YES )
    {
        hasTimesheetAccess = 1;
    }
    if ([[userSummary objectForKey:@"hasExpenseAccess"] boolValue] == YES )
    {
        hasExpenseAccess = 1;
    }
    if ([[userSummary objectForKey:@"hasShiftAccess"] boolValue] == YES )
    {
        hasShiftAccess = 1;
    }
    
    if ([[userSummary objectForKey:@"hasTimePunchAccess"] boolValue] == YES )
    {
        hasPunchInOutAccess = 1;
    }
    
    if ([[userSummary objectForKey:@"canViewTeamTimePunch"] boolValue] == YES )
    {
        canViewTeamTimePunch = 1;
    }
    if ([[userSummary objectForKey:@"canViewTimePunch"] boolValue] == YES )
    {
        canViewTimePunch = 1;
    }
    if ([[userSummary objectForKey:@"hasTimeOffAccess"] boolValue] == YES )
    {
        hasTimeoffBookingAccess = 1;
    }

    
    
    
    
    
    
    
    //LANGUAGE SETTINGS
    
    NSDictionary *language=[userSummary objectForKey:@"language"];
    NSString *language_cultureCode=[language objectForKey:@"cultureCode"];
    NSString *language_displayText=[language objectForKey:@"displayText"];
    NSString *language_isoName=[language objectForKey:@"languageCode"];
    NSString *language_uri=[language objectForKey:@"uri"];
    
    
    //USER DATA
    
    NSDictionary *user=[userSummary objectForKey:@"user"];
    NSString *displayText=[user objectForKey:@"displayText"];
    NSString *slug=[user objectForKey:@"slug"];
    NSString *uri=[user objectForKey:@"uri"];
    
    
    
    
    
    SQLiteDB *myDB	= [SQLiteDB getInstance];
    NSMutableDictionary *propertiesDict=[NSMutableDictionary dictionary];
    
    
    [propertiesDict setObject:uri forKey:@"uri"];
    [propertiesDict setObject:slug forKey:@"slug"];
    [propertiesDict setObject:displayText forKey:@"displayText"];
    
    [propertiesDict setObject:[NSNumber numberWithInt:hasTimesheetAccess] forKey:@"hasTimesheetAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasExpenseAccess] forKey:@"hasExpenseAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasTimeoffBookingAccess] forKey:@"hasTimeOffAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasShiftAccess] forKey:@"hasShiftAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:hasPunchInOutAccess] forKey:@"hasTimePunchAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:canViewTimePunch] forKey:@"canViewTimePunch"];
    [propertiesDict setObject:[NSNumber numberWithInt:canViewTeamTimePunch] forKey:@"canViewTeamTimePunch"];

    [propertiesDict setObject:[NSNumber numberWithInt:isTimeSheetApprover] forKey:@"hasTimesheetApprovalAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:isTimeOffApprover] forKey:@"hasTimeOffApprovalAccess"];
    [propertiesDict setObject:[NSNumber numberWithInt:isExpenseApprover] forKey:@"hasExpenseApprovalAccess"];
   
    
    [propertiesDict setObject:language_cultureCode forKey:@"language_cultureCode"];
    [propertiesDict setObject:language_displayText forKey:@"language_displayText"];
    [propertiesDict setObject:language_isoName forKey:@"language_code"];
    [propertiesDict setObject:language_uri forKey:@"language_uri"];
    
    
    //SAVE TO USER DEFAULTS

    NSMutableArray *modulesOrderArray=[NSMutableArray array];
    
    
    BOOL _hasTimesheetAccess        = [[propertiesDict objectForKey:@"hasTimesheetAccess"]boolValue];
    BOOL _hasExpenseAccess          = [[propertiesDict objectForKey:@"hasExpenseAccess"]boolValue];
    
    BOOL _userTimeOffApprover       = [[propertiesDict objectForKey:@"hasTimeOffApprovalAccess"]boolValue];
    BOOL _userTimesheetApprover     = [[propertiesDict objectForKey:@"hasTimesheetApprovalAccess"]boolValue];
    BOOL _userExpenseApprover     = [[propertiesDict objectForKey:@"hasExpenseApprovalAccess"]boolValue];
    BOOL _hasTimeoffBookingAccesss =[[propertiesDict objectForKey:@"hasTimeOffAccess"]boolValue];
    BOOL _hasShiftsAccess = [[propertiesDict objectForKey:@"hasShiftAccess"]boolValue];
    
    
    BOOL _clockInOutUser            =[[propertiesDict objectForKey:@"hasTimePunchAccess"]boolValue];
    BOOL _isPunchHistoryUser        =[[propertiesDict objectForKey:@"canViewTimePunch"]boolValue];
    BOOL _hasApprovalAccess         = NO;
//TODO:Commenting below line because variable is unused,uncomment when using
//    BOOL _canViewTeamTimePunch       = [[propertiesDict objectForKey:@"canViewTeamTimePunch"]boolValue];;
    
    
    if (_userTimeOffApprover || _userTimesheetApprover || _userExpenseApprover)
    {
        _hasApprovalAccess=YES;
    }
    
    if (_clockInOutUser)
    {
        [modulesOrderArray addObject:CLOCK_IN_OUT_TAB_MODULE_NAME];
    }
    
    if (_isPunchHistoryUser)
    {
        [modulesOrderArray addObject:PUNCH_HISTORY_TAB_MODULE_NAME];//PUNCH-154 Ullas M L
    }

    if (_hasTimesheetAccess)
    {
        [modulesOrderArray addObject:TIMESHEETS_TAB_MODULE_NAME];
    }

    if (_hasTimeoffBookingAccesss)
    {
        [modulesOrderArray addObject:TIME_OFF_TAB_MODULE_NAME];
    }

    if (_hasShiftsAccess)
    {
        [modulesOrderArray addObject:SCHEDULE_TAB_MODULE_NAME];
    }
    
    if (_hasExpenseAccess)
    {
        [modulesOrderArray addObject:EXPENSES_TAB_MODULE_NAME];
    }

    if (_hasApprovalAccess)
    {
        [modulesOrderArray addObject:APPROVAL_TAB_MODULE_NAME];
    }


    [modulesOrderArray addObject:SETTINGS_TAB_MODULE_NAME];
    
    
    BOOL hasModulesToDisplay = (1 < [modulesOrderArray count]);
    

    if (hasModulesToDisplay) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"]!=nil && self.appDelegate.deviceID!=nil)
        {
            [[RepliconServiceManager loginService] sendrequestToRegisterForPushNotification:[Util stringWithDeviceToken:self.appDelegate.deviceID]];
        }
        
    }
    
    
    [standardUserDefaults setBool:TRUE forKey:@"isSuccessLogin"];
    [standardUserDefaults synchronize];
    
    
    
    
    SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
    NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromLightWeightHomeFlowDatabase];
    
    if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
    {
        [self.appDelegate compareDataUpdateForLighWeightHomeFlowServiceWithNewDate:propertiesDict];
    }
    
    
    
    //SAVE TO DATABASE
    
    [myDB deleteFromTable:@"NewUserDetails" inDatabase:@""];
    [myDB insertIntoTable:@"NewUserDetails" data:propertiesDict intoDatabase:@""];

    CLS_LOG(@"-------userUri is set from handleLightWeightHomeSummaryResponse--------- %@",uri);
    [standardUserDefaults setObject:uri forKey:@"UserUri"];
    [standardUserDefaults synchronize];
    
    [AppPersistentStorage setObject:uri forKey:@"UserUri"];

    
    
    
    if (Util.isRelease)
    {
        if (uri!=nil && ![uri isKindOfClass:[NSNull class]])
        {
            [EventTracker.sharedInstance setUserID:uri];
        }
        
    }
    
    [[Crashlytics sharedInstance] setUserIdentifier:uri];
    [[Crashlytics sharedInstance] setUserName:[user objectForKey:@"loginName"]];
    
    NSString *companyName = nil;
    // MOBI-471
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
        NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
        if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
            companyName = [credentials valueForKey:ACKeychainCompanyName];
        }
    }
    if (companyName!=nil && ![companyName isKindOfClass:[NSNull class]])
    {
        [[Crashlytics sharedInstance] setObjectValue:companyName forKey:@"companyName"];
    }
    
    
    
    
    
    //customTerms HANDLINGS
    NSArray *customTermsSummary=[response objectForKey:@"customTerms"];
    NSArray *previouscustomTermsSummary= [[NSUserDefaults standardUserDefaults] objectForKey:@"customTermsSummary"];
    
    NSSet *set1 = [NSSet setWithArray:customTermsSummary];
    NSSet *set2 = [NSSet setWithArray:previouscustomTermsSummary];
    
    
    if (![set1 isEqualToSet:set2])
    {
        [self.appDelegate resetLocalisedFilesAtStart:NO];
        [self.appDelegate AddCapabilityToDisplayRenamedLabelsInMobileApps:customTermsSummary];
        [[NSUserDefaults standardUserDefaults] setObject:customTermsSummary forKey:@"customTermsSummary"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        

        
    }
    else
    {
        NSString *applicationDocumentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [applicationDocumentsDir stringByAppendingPathComponent:@"Localizable.strings"];
        
       
        
        self.appDelegate.peristedLocalizableStringsDict = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filePath]];
    }


    [self.appDelegate renderRatingApplicationView];


}


-(void)handleUserDefinedFields:(NSArray *)udfsArray forModuleName:(NSString *)moduleName enabledUriArray:(NSMutableArray *)enabledUriArray
{

    for (int i=0; i<[udfsArray count]; i++)
    {
        NSDictionary *udfDict=[udfsArray objectAtIndex:i];
        NSMutableDictionary *udfDataDict=[NSMutableDictionary dictionary];
        NSString *uri=[udfDict objectForKey:@"uri"];
        if (uri!=nil && ![uri isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:uri forKey:@"uri"];
        }
        NSString *name=[udfDict objectForKey:@"displayText"];
        if (name!=nil && ![name isKindOfClass:[NSNull class]])
        {
            [udfDataDict setObject:name forKey:@"name"];
        }

        NSNumber *enabled=[NSNumber numberWithInt:[[udfDict objectForKey:@"isEnabled"]intValue]];
        [udfDataDict setObject:enabled forKey:@"enabled"];
        NSNumber *required=[NSNumber numberWithInt:[[udfDict objectForKey:@"isRequired"]intValue]];
        [udfDataDict setObject:required forKey:@"required"];
        NSNumber *visible=[NSNumber numberWithInt:[[udfDict objectForKey:@"isVisible"]intValue]];
        [udfDataDict setObject:visible forKey:@"visible"];
        [udfDataDict setObject:moduleName forKey:@"moduleName"];


        NSString *typeURI=[[udfDict objectForKey:@"type"] objectForKey:@"uri"];
        if ([typeURI isEqualToString:TEXT_UDF_TYPE])
        {
            NSDictionary *textConfiguration=[udfDict objectForKey:@"textConfiguration"];
            NSString *defaultTextValue=[textConfiguration objectForKey:@"defaultTextValue"];
            if (defaultTextValue!=nil && ![defaultTextValue isKindOfClass:[NSNull class]])
            {
                [udfDataDict setObject:defaultTextValue forKey:@"textDefaultValue"];
            }
            [udfDataDict setObject:TEXT_UDF_TYPE forKey:@"udfType"];
        }
        else if ([typeURI isEqualToString:NUMERIC_UDF_TYPE])
        {
            NSDictionary *numericConfiguration=[udfDict objectForKey:@"numericConfiguration"];
            NSString *defaultNumericValue=[numericConfiguration objectForKey:@"defaultNumericValue"];
            if (defaultNumericValue!=nil && ![defaultNumericValue isKindOfClass:[NSNull class]])
            {
                [udfDataDict setObject:defaultNumericValue forKey:@"numericDefaultValue"];
            }
            NSString *minimumNumericValueStr=[numericConfiguration objectForKey:@"minimumNumericValue"];
            if (minimumNumericValueStr!=nil && ![minimumNumericValueStr isKindOfClass:[NSNull class]])
            {
                [udfDataDict setObject:[NSNumber numberWithInt:[minimumNumericValueStr intValue]] forKey:@"numericMinValue"];
            }
            NSString *maximumNumericValueStr=[numericConfiguration objectForKey:@"maximumNumericValue"];
            if (maximumNumericValueStr!=nil && ![maximumNumericValueStr isKindOfClass:[NSNull class]])
            {
                [udfDataDict setObject:[NSNumber numberWithInt:[maximumNumericValueStr intValue]] forKey:@"numericMaxValue"];
            }


            NSNumber *decimalPlaces=[NSNumber numberWithInt:[[numericConfiguration objectForKey:@"decimalPlaces"]intValue]];
            [udfDataDict setObject:decimalPlaces forKey:@"numericDecimalPlaces"];

            [udfDataDict setObject:NUMERIC_UDF_TYPE forKey:@"udfType"];
        }
        else if ([typeURI isEqualToString:DATE_UDF_TYPE])
        {
            NSDictionary *dateConfiguration=[udfDict objectForKey:@"dateConfiguration"];
            NSNumber *isToday=[NSNumber numberWithInt:[[[dateConfiguration objectForKey:@"defaults"]objectForKey:@"useTodayAsDefault"]intValue]];
            [udfDataDict setObject:isToday forKey:@"isDateDefaultValueToday"];
            NSDictionary *dateDict=[[dateConfiguration objectForKey:@"defaults"] objectForKey:@"value"];
            if (dateDict!=nil && ![dateDict isKindOfClass:[NSNull class]])
            {
                NSDate *date=[Util convertApiDateDictToDateFormat:dateDict];
                [udfDataDict setObject:[NSNumber numberWithDouble:[date timeIntervalSince1970]] forKey:@"dateDefaultValue"];
            }


            NSDictionary *maxDateDict=[dateConfiguration objectForKey:@"maximumDate"];
            if (maxDateDict!=nil && ![maxDateDict isKindOfClass:[NSNull class]])
            {
                NSDate *maxDate=[Util convertApiDateDictToDateFormat:maxDateDict];
                [udfDataDict setObject:[NSNumber numberWithDouble:[maxDate timeIntervalSince1970]] forKey:@"dateMaxValue"];
            }


            NSDictionary *minDateDict=[dateConfiguration objectForKey:@"minimumDate"];
            if (minDateDict!=nil && ![minDateDict isKindOfClass:[NSNull class]])
            {
                NSDate *minDate=[Util convertApiDateDictToDateFormat:minDateDict];
                [udfDataDict setObject:[NSNumber numberWithDouble:[minDate timeIntervalSince1970]] forKey:@"dateMinValue"];
            }


            [udfDataDict setObject:DATE_UDF_TYPE forKey:@"udfType"];

        }

        if ([typeURI isEqualToString:DROPDOWN_UDF_TYPE])
        {
            NSString *defaultDropDownValue=[[udfDict objectForKey:@"defaultDropDownValue"]objectForKey:@"displayText"];
            if (defaultDropDownValue!=nil && ![defaultDropDownValue isKindOfClass:[NSNull class]])
            {
                [udfDataDict setObject:defaultDropDownValue forKey:@"textDefaultValue"];
                [udfDataDict setObject:[[udfDict objectForKey:@"defaultDropDownValue"]objectForKey:@"uri"] forKey:@"dropDownOptionDefaultURI"];
            }
            [udfDataDict setObject:DROPDOWN_UDF_TYPE forKey:@"udfType"];
        }


        LoginModel *loginModel=[[LoginModel alloc]init];
        [loginModel saveUserDefinedFieldsDataToDB:udfDataDict];
        [loginModel saveUserDefinedFieldsCloneDataToDB:udfDataDict];


    }

}

-(void)handleUserDefinedOptionFields:(id)response{
    NSMutableArray *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];

    if ([responseDict count]>0 && responseDict!=nil)
    {
        //Implemetation For MOBI-300//JUHI
        NSDictionary *dropDownDict= [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING, NONE_STRING),@"displayText",[NSNull null],@"uri", [NSNumber numberWithBool:true],@"isEnabled",[NSNumber numberWithBool:false],@"isDefaultValue",nil];
        [responseDict addObject: dropDownDict];
        LoginModel *loginModel=[[LoginModel alloc]init];
        [loginModel saveUfdDropDownOptionDataToDB:responseDict];


    }
    NSNumber *dropDownOptionDataDownloadCount=[NSNumber numberWithUnsignedInteger:[responseDict count]];
    [self.userDefaults setObject:dropDownOptionDataDownloadCount forKey:@"dropDownOptionDataDownloadCount"];
    [self.userDefaults synchronize];

    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

- (void)handleNextUserDefinedOptionFields:(id)response
{
    NSMutableArray *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];

    if ([responseDict count]>0 && responseDict!=nil)
    {

        LoginModel *loginModel=[[LoginModel alloc]init];
        [loginModel saveUfdDropDownOptionDataToDB:responseDict];

    }

    NSNumber *dropDownOptionDataDownloadCount=[NSNumber numberWithUnsignedInteger:[responseDict count]];
    [self.userDefaults setObject:dropDownOptionDataDownloadCount forKey:@"dropDownOptionDataDownloadCount"];
    [self.userDefaults synchronize];

    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];//Fix for defect DE15459
}

-(void)handleOEFTagOptionFields:(id)response{
    NSMutableArray *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];

    if ([responseDict count]>0 && responseDict!=nil)
    {
        //Implemetation For MOBI-300//JUHI
        NSDictionary *dropDownDict= [NSDictionary dictionaryWithObjectsAndKeys:RPLocalizedString(NONE_STRING, NONE_STRING),@"displayText",[NSNull null],@"uri",nil];
        [responseDict addObject: dropDownDict];
        LoginModel *loginModel=[[LoginModel alloc]init];
        [loginModel saveOEFDropDownTagOptionDataToDB:responseDict];


    }
    NSNumber *dropDownOptionDataDownloadCount=[NSNumber numberWithUnsignedInteger:[responseDict count]];
    [self.userDefaults setObject:dropDownOptionDataDownloadCount forKey:@"oefDropDownTagOptionDownloadCount"];
    [self.userDefaults synchronize];

    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DROPDOWN_OPTION_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

- (void)handleNextOEFTagOptionFields:(id)response
{
    NSMutableArray *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];

    if ([responseDict count]>0 && responseDict!=nil)
    {

        LoginModel *loginModel=[[LoginModel alloc]init];
        [loginModel saveOEFDropDownTagOptionDataToDB:responseDict];

    }

    NSNumber *dropDownOptionDataDownloadCount=[NSNumber numberWithUnsignedInteger:[responseDict count]];
    [self.userDefaults setObject:dropDownOptionDataDownloadCount forKey:@"oefDropDownTagOptionDownloadCount"];
    [self.userDefaults synchronize];

    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:@"isErrorOccured"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DROPDOWN_NEXT_OPTION_RECEIVED_NOTIFICATION object:nil userInfo:dataDict];
}

-(void)handleGetVersionUpdateDetails:(id)response
{
    NSDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];

    if (responseDict!=nil)
    {

        NSString *updateOptionUri=[responseDict objectForKey:@"updateOptionUri"];
        //updateOptionUri=@"urn:replicon-global:application-update-option:required";
        //updateOptionUri=@"urn:replicon-global:application-update-option:available";


         NSDictionary *newVersionDict=[responseDict objectForKey:@"newVersion"];




        if (updateOptionUri!=nil && ![updateOptionUri isKindOfClass:[NSNull class]])
        {

            NSDictionary *getUserDefaultsDict=[self.userDefaults objectForKey:@"GetVersionUpdateDetails"];
            NSDictionary *getNewVersionNumberDict=[getUserDefaultsDict objectForKey:@"newVersion"];
            BOOL isShownOnce=[[getUserDefaultsDict objectForKey:@"isShownOnce"]boolValue];

            if (getNewVersionNumberDict!=nil && ![getNewVersionNumberDict isKindOfClass:[NSNull class]] && newVersionDict!=nil && ![newVersionDict isKindOfClass:[NSNull class]])
            {


                if ([[newVersionDict objectForKey:@"major"]intValue]>[[getNewVersionNumberDict objectForKey:@"major"]intValue])
                {
                    isShownOnce=FALSE;
                }
                else if ([[newVersionDict objectForKey:@"minor"]intValue]>[[getNewVersionNumberDict objectForKey:@"minor"]intValue])
                {
                    isShownOnce=FALSE;
                }
                else if ([[newVersionDict objectForKey:@"build"]intValue]>[[getNewVersionNumberDict objectForKey:@"build"]intValue])
                {
                    isShownOnce=FALSE;
                }
                else if ([[newVersionDict objectForKey:@"revision"]intValue]>[[getNewVersionNumberDict objectForKey:@"revision"]intValue])
                {
                    isShownOnce=FALSE;
                }
            }


            if ([updateOptionUri isEqualToString:@"urn:replicon-global:application-update-option:available"])
            {

                if ([self checkForShowingAppUpdateAlert:[self.userDefaults integerForKey:@"appUpdateVersionTriggerCount"] isShownOnce:isShownOnce]) {

                    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"No", @"No")
                                                   otherButtonTitle:RPLocalizedString(@"Yes", @"Yes")
                                                           delegate:self
                                                            message:RPLocalizedString(New_App_Available_Message, New_App_Available_Message)
                                                              title:@""
                                                                tag:NEW_APP_AVAILBLE_ALERT_TAG];


                    [self.userDefaults setInteger:0 forKey:@"appUpdateVersionTriggerCount"];
                }
            }
            else  if ([updateOptionUri isEqualToString:@"urn:replicon-global:application-update-option:required"])
            {

                [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(Update_App, Update_App)
                                               otherButtonTitle:nil
                                                       delegate:self
                                                        message:RPLocalizedString(New_App_Required_Message,New_App_Required_Message)
                                                          title:@""
                                                            tag:NEW_APP_REQUIRED_ALERT_TAG];

            }
            else  if ([updateOptionUri isEqualToString:@"urn:replicon-global:application-update-option:not-available"])
            {
                [self.userDefaults setInteger:0 forKey:@"appUpdateVersionTriggerCount"];
            }


            if (newVersionDict != nil && ![newVersionDict isKindOfClass:[NSNull class]])
            {

                NSDictionary *userDefaultsDict=[NSDictionary dictionaryWithObjectsAndKeys:newVersionDict,@"newVersion",[NSNumber numberWithBool:TRUE],@"isShownOnce", nil];

                [self.userDefaults setObject:userDefaultsDict forKey:@"GetVersionUpdateDetails"];
                [self.userDefaults synchronize];
            }

        }
    }

}


-(BOOL)checkForShowingAppUpdateAlert :(NSInteger)triggerCount isShownOnce:(BOOL)isShownOnce
{
    if (triggerCount==5 || !isShownOnce)
    {
        return true;
    }
    return false;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0&& alertView.tag==9123)
    {
        [[[UIApplication sharedApplication]delegate]performSelector:@selector(launchResetPasswordViewController)];
    }
    else if (alertView.tag==123)
    {

        if (buttonIndex==0)
        {
            CLS_LOG(@"-----INTENDED FORCE CRASH TO MIMIC RESTART BEHAVIOR -----");

            //force crashing the app
            exit(0);
        }

    }
    else
    {
        if (buttonIndex == 1 && alertView.tag==NEW_APP_AVAILBLE_ALERT_TAG)
        {

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [[AppProperties getInstance] getAppPropertyFor: @"itunesAppUrl"]]];
        }

        else if (buttonIndex == 0 && alertView.tag==NEW_APP_REQUIRED_ALERT_TAG)
        {

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [[AppProperties getInstance] getAppPropertyFor: @"itunesAppUrl"]]];

            [self.appDelegate launchLoginViewController:NO];
            [self.appDelegate.window setUserInteractionEnabled:FALSE];

        }

    }

}

/************************************************************************************************************
 @Function Name   : handleCountOfApprovalsForUser
 @Purpose         : Called to store the pending approvals count.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)handleCountOfApprovalsForUser:(id)response
{
    NSDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (responseDict!=nil)
    {
        int pendingExpenseCount=[[responseDict objectForKey:@"pendingExpenseSheetApprovalCount"] intValue];
        int pendingTimeoffCount=[[responseDict objectForKey:@"pendingTimeOffApprovalCount"] intValue];
        int pendingTimesheetCount=[[responseDict objectForKey:@"pendingTimesheetApprovalCount"] intValue];
        [self.userDefaults setObject:[NSNumber numberWithInt:pendingExpenseCount] forKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
        [self.userDefaults setObject:[NSNumber numberWithInt:pendingTimeoffCount] forKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
        [self.userDefaults setObject:[NSNumber numberWithInt:pendingTimesheetCount] forKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];
        [self.userDefaults synchronize];

        [[NSNotificationCenter defaultCenter] postNotificationName:HOMEVIEW_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:SLIDERVIEW_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION object:nil];


        [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];

    }
}


-(void)handleCountOfGetMyNotificationSummary:(id)response
{
    NSDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    if (responseDict!=nil)
    {

        NSDictionary *userApprovalNotificationSummaryDict=[responseDict objectForKey:@"userApprovalNotificationSummary"];

        if (userApprovalNotificationSummaryDict!=nil)
        {
            int pendingExpenseCount=[[userApprovalNotificationSummaryDict objectForKey:@"pendingExpenseSheetApprovalCount"] intValue];
            int pendingTimeoffCount=[[userApprovalNotificationSummaryDict objectForKey:@"pendingTimeOffApprovalCount"] intValue];
            int pendingTimesheetCount=[[userApprovalNotificationSummaryDict objectForKey:@"pendingTimesheetApprovalCount"] intValue];

            [self.userDefaults setObject:[NSNumber numberWithInt:pendingExpenseCount] forKey:PENDING_APPROVALS_EXPENSE_SHEETS_COUNT_KEY];
            [self.userDefaults setObject:[NSNumber numberWithInt:pendingTimeoffCount] forKey:PENDING_APPROVALS_TIMEOFF_SHEETS_COUNT_KEY];
            [self.userDefaults setObject:[NSNumber numberWithInt:pendingTimesheetCount] forKey:PENDING_APPROVALS_TIMESHEET_SHEETS_COUNT_KEY];
        }

        NSDictionary *userExpenseNotificationSummaryDict=[responseDict objectForKey:@"userExpenseNotificationSummary"];

        if (userExpenseNotificationSummaryDict!=nil)
        {
            int rejectedExpenseSheetCount=[[userExpenseNotificationSummaryDict objectForKey:@"rejectedExpenseSheetCount"] intValue];

            [self.userDefaults setObject:[NSNumber numberWithInt:rejectedExpenseSheetCount] forKey:REJECTED_EXPENSE_SHEETS_COUNT_KEY];

        }

        NSDictionary *userTimeOffNotificationSummaryDict=[responseDict objectForKey:@"userTimeOffNotificationSummary"];

        if (userTimeOffNotificationSummaryDict!=nil)
        {
            int rejectedTimeOffBookingCount=[[userTimeOffNotificationSummaryDict objectForKey:@"rejectedTimeOffBookingCount"] intValue];

            [self.userDefaults setObject:[NSNumber numberWithInt:rejectedTimeOffBookingCount] forKey:REJECTED_TIMEOFF_BOOKING_COUNT_KEY];

        }

        NSDictionary *userTimesheetNotificationSummaryDict=[responseDict objectForKey:@"userTimesheetNotificationSummary"];

        if (userTimesheetNotificationSummaryDict!=nil)
        {
            int rejectedTimesheetCount=[[userTimesheetNotificationSummaryDict objectForKey:@"rejectedTimesheetCount"] intValue];

            int timesheetPastDueCount=[[userTimesheetNotificationSummaryDict objectForKey:@"timesheetPastDueCount"] intValue];

            [self.userDefaults setObject:[NSNumber numberWithInt:timesheetPastDueCount] forKey:TIMESHEET_PAST_DUE_COUNT_KEY];
            [self.userDefaults setObject:[NSNumber numberWithInt:rejectedTimesheetCount] forKey:REJECTED_TIMESHEET_COUNT_KEY];

        }
        [self.userDefaults synchronize];


        [[NSNotificationCenter defaultCenter] postNotificationName:HOMEVIEW_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:SLIDERVIEW_PENDING_APPROVALS_COUNT_RECEIVED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] postNotificationName:GET_MY_NOTIFICATION_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]                                                                          forKey:@"isError"]];
    }
}

//Implementation For Mobi-190//Reset Password//JUHI
/************************************************************************************************************
 @Function Name   : handlePasswordUpdate
 @Purpose         : Called to update Password.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

-(void)handlePasswordUpdate:(id)response
{
    NSDictionary *responseDict=[[response objectForKey:@"response"]objectForKey:@"d"];
    NSString *newPassword=[[response objectForKey:@"refDict"]objectForKey:@"params"];
    // MOBI-471
    ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
    NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
    if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
        NSString *companyName = [credentials valueForKey:ACKeychainCompanyName];
        NSString *loginName   = [credentials valueForKey:ACKeychainUsername];
        if ([keychain storeUsername:loginName password:newPassword companyName:companyName forService:@"repliconUserCredentials"]) {
            NSLog(@"**SAVED**");
        }
    }
    if (responseDict!=nil)
    {
        NSDictionary *dataDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                             forKey:@"isErrorOccured"];
        [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEPASSWORD_NOTIFICATION object:nil userInfo:dataDict];

    }
}

-(void)handleServerDownStatusResponse:(id)response
{

    BOOL isServerDown=[[response[@"response"] objectForKey:@"IsServerDown"] boolValue];
    NSString *serviceURL = response[@"refDict"][@"params"];
    NSString *errorMsg = nil;

    if (isServerDown == TRUE) {
        [self convertToUserDeviceTimeZone:response];
    }
    else{
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        errorMsg = RPLocalizedString(RepliconServerMaintenanceError, RepliconServerMaintenanceError);
        [Util errorAlert:@"" errorMessage:RPLocalizedString(RepliconServerMaintenanceError, ERROR_SERVER_MAINTENANCE_ERROR)];
        [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMsg serviceURL:serviceURL];
    }


}


-(NSString*)convertToUserDeviceTimeZone :(id)response
{

    NSString *errorMsg = nil;

    NSString* timeFromString = [response[@"response"] objectForKey:@"DownTimeFrom"];
    NSString* timeToString = [response[@"response"] objectForKey:@"DownTimeTo"];

    if (timeFromString!=nil && timeToString!=nil)
    {
        NSString *timeZoneString = [self checkForTimeZoneString];



        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];


        NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
        [dateFormatter2 setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter2 setDateFormat:@"MM/dd/yyyy hh:mm a"];

        NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithName:@"America/Los_Angeles"];
        NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];


        //calc time difference
        NSInteger sourceGMTOffsetFromDate = [sourceTimeZone secondsFromGMTForDate:[dateFormatter dateFromString:timeFromString]];
        NSInteger destinationGMTOffsetFromDate = [destinationTimeZone secondsFromGMTForDate:[dateFormatter dateFromString:timeFromString]];
        NSTimeInterval intervalFromDate = destinationGMTOffsetFromDate - sourceGMTOffsetFromDate;

        //set current real date
        NSDate* fromDate = [[NSDate alloc] initWithTimeInterval:intervalFromDate sinceDate:[dateFormatter dateFromString:timeFromString]];

        //calc time difference
        NSInteger sourceGMTOffsetToDate = [sourceTimeZone secondsFromGMTForDate:[dateFormatter dateFromString:timeToString]];
        NSInteger destinationGMTOffsetToDate = [destinationTimeZone secondsFromGMTForDate:[dateFormatter dateFromString:timeToString]];
        NSTimeInterval intervalToDate = destinationGMTOffsetToDate - sourceGMTOffsetToDate;

        //set current real date
        NSDate* ToDate = [[NSDate alloc] initWithTimeInterval:intervalToDate sinceDate:[dateFormatter dateFromString:timeToString]];
        NSString* dateFromString  = [dateFormatter2 stringFromDate:fromDate];
        NSString* dateToString  = [dateFormatter2 stringFromDate:ToDate];

        NSArray* stringDownTimeFromArray = [dateFromString componentsSeparatedByString: @" "];
        NSArray* stringDownTimeToArray = [dateToString componentsSeparatedByString: @" "];

        CLSLog(@"---stringDownTimeFromArray=%@---",stringDownTimeFromArray);
        CLSLog(@"---stringDownTimeFromArray=%@---",stringDownTimeFromArray);

        NSString  *fromDateString = [stringDownTimeFromArray  objectAtIndex:0];
        NSString  *toDateString = [stringDownTimeToArray  objectAtIndex:0];
        NSString  *fromTimeString = [stringDownTimeFromArray  objectAtIndex:1];
        NSString  *toTimeString = [stringDownTimeToArray  objectAtIndex:1];
        NSString  *fromAmOrPmString = [stringDownTimeFromArray  objectAtIndex:2];
        NSString  *toAmOrPmString = [stringDownTimeToArray  objectAtIndex:2];


        errorMsg = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@.\n%@",RPLocalizedString(SERVER_MAINTENANCE_DOWN_TIME_ERROR, @""), fromTimeString, fromAmOrPmString, timeZoneString, RPLocalizedString(ON_TEXT, @""), fromDateString, RPLocalizedString(TO_STRING, TO_STRING), toTimeString,toAmOrPmString, timeZoneString, RPLocalizedString(ON_TEXT, @""), toDateString, RPLocalizedString(TRY_AGAIN_TEXT, TRY_AGAIN_TEXT)];

        [Util errorAlert:@"" errorMessage:errorMsg];

        NSString *serviceURL = response[@"refDict"][@"params"];
        [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMsg serviceURL:serviceURL];

        return [NSString stringWithFormat:@"%@ %@ %@",fromDateString, fromTimeString, fromAmOrPmString];
    }
     return nil;
}


-(NSString*)checkForTimeZoneString
{
    return   [[NSTimeZone localTimeZone] localizedName:NSTimeZoneNameStyleStandard locale:[NSLocale currentLocale]];;
}

#pragma mark - <LoginDelegate>

- (void)loginServiceDidFinishLoggingIn:(LoginService *)loginService
{
    [self.spinnerDelegate hideTransparentLoadingOverlay];
}

@end
