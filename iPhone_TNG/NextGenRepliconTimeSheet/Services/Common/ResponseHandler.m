//
//  ResponseHandler.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 2/4/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "ResponseHandler.h"
#import "RepliconServiceManager.h"
#import "Constants.h"
#import "SNLog.h"
#import "LoginModel.h"
#import "AppDelegate.h"

#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsExpenseHistoryViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsTimeOffHistoryViewController.h"

#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
#import <repliconkit/repliconkit.h>

@implementation ResponseHandler


#define SUCCESS_RESPONSE_CODE 200
#define FORBIDDEN_RESPONSE_CODE 403


+ (id)sharedResponseHandler {
    static ResponseHandler *sharedResponseHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedResponseHandler = [[self alloc] init];
    });
    return sharedResponseHandler;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)handleServerResponseError:(NSDictionary *)errorDict serviceURL:(NSString *)serviceURL {

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
        [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];
    }
    
}


-(void)handleHTTPResponseError:(NSInteger)statusCode andDescription:(NSString *)responseHeaders andError:(NSError *)error applicationState:(ApplicateState)applicationState
{
    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response HTTP Code ::::: %ld ",(long)statusCode] forLogLevel:LoggerCocoaLumberjack];
    
    CLS_LOG(@"Response HTTP Code ::::: %ld ",(long)statusCode);
    
    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received :::::\n %@",responseHeaders] forLogLevel:LoggerCocoaLumberjack];

    
    CLS_LOG(@"Response Received :::::\n %@",responseHeaders);

        
    if (statusCode==FORBIDDEN_RESPONSE_CODE)
    {
        if (applicationState == Foreground)
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:nil
                                           otherButtonTitle:RPLocalizedString(APP_REFRESH_DATA_TITLE, @"")
                                                   delegate:[[UIApplication sharedApplication]delegate]
                                                    message:RPLocalizedString(USER_FRIENDLY_ERROR_MSG, @" ")
                                                      title:nil
                                                        tag:555];
        }
        
        id errorUserInfoDict=[error userInfo];
        NSString *failedUrl=@"";

        if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
        {
            failedUrl=[errorUserInfoDict objectForKey:@"NSErrorFailingURLStringKey"];
            if (!failedUrl)
            {
                if ([errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]!=nil)
                {
                    failedUrl=[[errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]absoluteString];
                }

                if (!failedUrl)
                {
                    failedUrl=@"";
                }

            }
        }
        [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(USER_FRIENDLY_ERROR_MSG, USER_FRIENDLY_ERROR_MSG) serviceURL:failedUrl];

    }

    else if (statusCode==504 || statusCode==503 ||  statusCode==303)
    {
        if (applicationState == Foreground)
        {
            NSError *error1 = [NSError errorWithDomain:serviceUnavailabilityIssue code:statusCode userInfo:[error userInfo]];
            [self handleNSURLErrorDomainCodes:error1 applicationState:applicationState];

        }
    }
    else
    {
        if (applicationState == Foreground)
        {
             [self handleNSURLErrorDomainCodes:error applicationState:applicationState];
        }
       
    }
    

}

-(void)handleNSURLErrorDomainCodes:(NSError *)error applicationState:(ApplicateState)applicationState
{
    id errorUserInfoDict=[error userInfo];
    NSString *failedUrl=@"";

    if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
    {
        failedUrl=[errorUserInfoDict objectForKey:@"NSErrorFailingURLStringKey"];
        if (!failedUrl)
        {
            if ([errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]!=nil)
            {
                failedUrl=[[errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]absoluteString];
            }

            if (!failedUrl)
            {
                failedUrl=@"";
            }

        }
    }

    NSString *errorMsg=nil;
    
    if ([error code]==-998)
    {
        errorMsg=RPLocalizedString(ERROR_URLErrorUnknown_998, ERROR_URLErrorUnknown_998);
    }
    else if ([error code]==-999)
    {
        errorMsg=RPLocalizedString(ERROR_URLErrorUnknown_999, ERROR_URLErrorUnknown_999);
        
    }
    else if ([error code]==-1001 || [error code]==-1200)
    {
        errorMsg=RPLocalizedString(ERROR_URLErrorTimedOut_1001, ERROR_URLErrorTimedOut_1001);
        
    }
    else if ([error code]==-1003)
    {
        errorMsg=error.localizedDescription;
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LAUNCH_LOGIN_VIEW_CONTROLLER object:nil];
    }
    else if ([error code]==-1004)
    {
        errorMsg=error.localizedDescription;
        
    }
    else if ([error code]==-1005)
    {
        errorMsg=error.localizedDescription;
        
    }
    else if ([error code]==-1006)
    {
        errorMsg=error.localizedDescription;
        
    }
    else if ([error code]==-1008)
    {
        errorMsg=error.localizedDescription;
        
    }
    else if ([error code]==-1009)
    {
        errorMsg=error.localizedDescription;
        
    }
    else if ([error code]==504 || [error code]==503 || [error code]==303 || (error!=nil && [[error domain] isEqualToString:__NonJsonResponse]))
    {
        errorMsg=RPLocalizedString(RepliconServerMaintenanceError, RepliconServerMaintenanceError);

        [[RepliconServiceManager loginService] sendRequestToCheckServerDownStatusWithServiceURL:failedUrl];

        return;
    }
    else if ([error code]==-1011)
    {
        errorMsg=error.localizedDescription;
        
    }

    else
    {
        
        if ([[error domain] isEqualToString:@"NSPOSIXErrorDomain"])
        {
            errorMsg=[NSString stringWithFormat:@"%@.Please try again. If the problem persists, please contact Replicon support.",error.localizedDescription];
        }
        else if ([[error domain] isEqualToString:@"NSURLErrorDomain"])
        {
            errorMsg=[NSString stringWithFormat:@"%@.Please try again. If the problem persists, please contact Replicon support.",error.localizedDescription];
        }
        else
        {
            errorMsg=RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE);
        }
        
    }
    

    
    if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
    {
        
        if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor: @"GetVersionUpdateDetails"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"GetMyNotificationSummary"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"getServerDownStatus"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"RegisterForPushNotifications"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"Gen4TimesheetValidation"]])
        {
            errorMsg=@"";
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"GetHomeSummary2"]])
        {
            LoginModel *loginModel=[[LoginModel alloc]init];
            NSMutableArray *userDetailsArr=[loginModel getAllNewUserDetailsInfoFromDb];
            if ([userDetailsArr count]>0)
            {
                errorMsg=@"";
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                
                if (!appDelegate.isReceivedOldHomeFlowServiceData)
                {
                    [[NSNotificationCenter defaultCenter]postNotificationName:SHOW_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION object:nil];
                }
            }
            else
            {
                if (applicationState == Foreground)
                {
                     [Util errorAlert:@"" errorMessage:errorMsg];
                }
               
            }
            
        }
        else if ([failedUrl hasString:[[AppProperties getInstance] getServiceURLFor:@"GetHomeSummary"]])
        {
            errorMsg=@"";
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            appDelegate.isReceivedOldHomeFlowServiceData=TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OldHomeFlowServiceReceivedData" object:nil];
            
        }
        
        else
        {
            if (applicationState == Foreground)
            {
                [Util errorAlert:@"" errorMessage:errorMsg];
            }
            
        }
    }
    else
    {
        if (applicationState == Foreground)
        {
            [Util errorAlert:@"" errorMessage:errorMsg];
        }
        
    }
    
    
    
    [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMsg serviceURL:failedUrl];
}


- (BOOL)checkForExceptions:(NSDictionary *)response serviceURL:(NSString *)serviceURL
{
    BOOL exception=NO;
    
    NSString *errorURI=@"";
    if (response!=nil)
    {
        
        NSArray *notificationsArr=[[response objectForKey:@"details"] objectForKey:@"notifications"];
        if (notificationsArr!=nil && ![notificationsArr isKindOfClass:[NSNull class]])
        {
            for (int i=0; i<[notificationsArr count]; i++)
            {
                
                NSDictionary *notificationDict=[notificationsArr objectAtIndex:i];
                
                errorURI=[notificationDict objectForKey:@"failureUri"];
                
                exception= [self _validateForFailureURIWithURI:errorURI forErrorDict:response serviceURL:serviceURL];
                
                if (exception)
                {
                    break;
                }
                
            }
        }
        
        
        
    }
    

    
    if (!exception)
    {
        errorURI=[[response objectForKey:@"details"] objectForKey:@"failureUri"];
        exception= [self _validateForFailureURIWithURI:errorURI forErrorDict:response serviceURL:serviceURL];
    }
    
    
    
    return exception;
}

- (BOOL)_validateForFailureURIWithURI:(NSString *)errorURI forErrorDict:(NSDictionary *)errorDictionary serviceURL:(NSString *)serviceURL
{
    BOOL exception=NO;
    BOOL uriError=NO;
    BOOL authorizationError=NO;
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
                [appDelegate launchLoginViewController:YES];
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
                [[NSNotificationCenter defaultCenter]postNotificationName:HIDE_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION object:nil];
                exception= YES;
                
                [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMessage serviceURL:serviceURL];
                
            }
            else if ([typeStr isEqualToString:@"OperationExecutionTimeoutError1"])
            {
                errorMessage=RPLocalizedString(ERROR_URLErrorTimedOut_FromServer, ERROR_URLErrorTimedOut_FromServer);
                [[NSNotificationCenter defaultCenter]postNotificationName:HIDE_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION object:nil];
                exception= YES;
                
                [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMessage serviceURL:serviceURL];
                
            }
            
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
                [[NSNotificationCenter defaultCenter]postNotificationName:HIDE_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION object:nil];
                exception= YES;
            }

            else if ([typeStr isEqualToString:@"AuthorizationError1"])
            {
                errorMessage=RPLocalizedString(USER_FRIENDLY_ERROR_MSG, @"");
                authorizationError=YES;
                [[NSNotificationCenter defaultCenter]postNotificationName:HIDE_TRANSPARENT_LOADING_OVERLAY_NOTIFICATION object:nil];
                exception= YES;

            }
        }
    }
    
    
    
    if (exception)
    {
        //Implementation For Mobi-190//Reset Password
        if ([errorMessage isEqualToString:RPLocalizedString(PASSWORD_EXPIRED_MESSAGE, PASSWORD_EXPIRED_MESSAGE)])
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:[RepliconServiceManager loginService]
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
        else if (authorizationError)
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(APP_REFRESH_DATA_TITLE, @"")
                                           otherButtonTitle:nil
                                                   delegate:appDelegate
                                                    message:errorMessage
                                                      title:nil
                                                        tag:555];


            [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:errorMessage serviceURL:serviceURL];
        }
        else
            [Util errorAlert:@"" errorMessage:errorMessage];
    }
    
    return exception;
}

@end
