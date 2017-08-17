
#import "ServerErrorSerializer.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "URLStringProvider.h"
#import "ApprovalsExpenseHistoryViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsTimeOffHistoryViewController.h"
#import "SupervisorDashboardNavigationController.h"
#import "PunchHomeNavigationController.h"

@interface ServerErrorSerializer ()

@property (nonatomic) AppDelegate *appDelegate;
@property (nonatomic) URLStringProvider *urlStringProvider;
@end

@implementation ServerErrorSerializer

- (instancetype)initWithAppdelegateUrlStringProvider:(URLStringProvider *)urlStringProvider
                                         appDelegate:(AppDelegate *)appDelegate {
    self = [super init];
    if (self) {
        self.appDelegate = appDelegate;
        self.urlStringProvider = urlStringProvider;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSError *)deserialize:(NSDictionary *)jsonDictionary isFromRequestMadeWhilePendingQueueSync:(BOOL)isFromRequestMadeWhilePendingQueueSync request:(NSURLRequest *)request
{
    if ([jsonDictionary respondsToSelector:@selector(objectAtIndex:)]) {
        return nil;
    }

    NSDictionary *errorDictionary = jsonDictionary[@"error"];
    id jsonObject = jsonDictionary[@"d"];
    if (errorDictionary)
    {
        if (!isFromRequestMadeWhilePendingQueueSync)
        {
            NSString *errorType = [errorDictionary objectForKey:@"type"];

            if ([errorType isEqualToString:@"InvalidTimesheetFormatError1"])
            {
                NSString *error = RPLocalizedString(TIMESHEET_FORMAT_NOT_SUPPORTED_IN_MOBILE, nil);
                return [self errorWithDomain:InvalidTimesheetFormatErrorDomain message:error];
            }
            else if ([errorType isEqualToString:@"OperationExecutionTimeoutError1"])
            {
                NSString *error = RPLocalizedString(ERROR_URLErrorTimedOut_FromServer, nil);
                return [self errorWithDomain:OperationTimeoutErrorDomain message:error];
            }
            else if ([errorType isEqualToString:@"UriError1"])
            {
                NSString *error = [self messageForUriErrorDomain];
                return [self errorWithDomain:UriErrorDomain message:error];
            }
            else if ([errorType isEqualToString:@"AuthorizationError1"])
            {
                NSString *error = RPLocalizedString(USER_FRIENDLY_ERROR_MSG, nil);
                return [self errorWithDomain:AuthorizationErrorDomain message:error];
            }
            else
            {
                NSDictionary *errorDetails = errorDictionary[@"details"];
                return [self getErrorFromDetailsNode:errorDetails url:request.URL];
            }
        }
        else
        {
            NSDictionary *errorDetails = errorDictionary[@"details"];
            NSArray *notifications = errorDetails[@"notifications"];
            NSString *error = [self errorMessageTextForError:notifications];
            return [self errorWithDomain:RepliconNoAlertErrorDomain message:error];
        }
    }
    else if ([jsonObject respondsToSelector:@selector(objectAtIndex:)])
    {
        NSArray *errors = jsonObject;
        if (errors!= nil && errors != (id)[NSNull null] && errors.count > 0)
        {
            NSMutableArray *errorArr = [@[]mutableCopy];
            NSString *errorMessage;
            for (int i=0; i<errors.count; i++)
            {
                NSDictionary *errorNode = jsonObject[i][@"error"];
                if (errorNode== nil)
                {
                    return nil;
                }
                else if(errorNode != (id)[NSNull null])
                {
                    NSMutableDictionary *errorDict = [@{}mutableCopy];
                    NSString *message;
                    NSArray *notifications = errorNode[@"notifications"];
                    if (notifications!= nil && notifications != (id)[NSNull null] && notifications.count > 0) {
                        message = [self errorMessageTextForError:notifications];
                    }
                    else{
                        message = [self errorMessageTextForErrorDictionary:errorNode];
                    }

                    NSDictionary *parameter = errorNode[@"parameter"];
                    NSString *parameterCorrelationId = [self parameterCorrelationIdForError:parameter];

                    if (message)
                    {
                        [errorDict setObject:message forKey:@"displayText"];
                    }
                    if (parameterCorrelationId)
                    {
                        [errorDict setObject:parameterCorrelationId forKey:@"parameterCorrelationId"];
                    }
                    
                    NSString *failureUri = [self failureUriForError:errorNode];
                    
                    if (failureUri) {
                        [errorDict setObject:failureUri forKey:@"failureUri"];
                    }

                    [errorArr addObject:errorDict];
                    if (errorMessage)
                    {
                        errorMessage = [NSString stringWithFormat:@"%@\n%@",errorMessage,message];
                    }
                    else
                    {
                        errorMessage = [NSString stringWithFormat:@"%@",message];
                    }
                }

            }

            if (errorMessage && errorArr)
            {
                NSDictionary*userInfo = @{NSLocalizedDescriptionKey: errorMessage,@"ErroredPunches": errorArr};
                NSError *error = [[NSError alloc] initWithDomain:RandomErrorDomain code:200 userInfo:userInfo];
                return error;
            }

            return nil;

        }

    }
    else if([jsonObject respondsToSelector:@selector(objectForKey:)])
    {
        NSArray *errors = jsonObject[@"errors"];
        if (errors!= nil && errors != (id)[NSNull null] && errors.count > 0)
        {
            NSMutableArray *errorArr = [@[]mutableCopy];
            NSString *errorMessage;
            for (int i=0; i<errors.count; i++)
            {
                NSMutableDictionary *errorDict = [@{}mutableCopy];
                NSString *message;
                NSArray *notifications = errors[i][@"notifications"];
                if (notifications!= nil && notifications != (id)[NSNull null] && notifications.count > 0) {
                    message = [self errorMessageTextForError:notifications];
                }
                else{
                    message = [self errorMessageTextForErrorDictionary:errors[i]];
                }

                NSDictionary *parameter = errors[i][@"parameter"];
                NSString *parameterCorrelationId = [self parameterCorrelationIdForError:parameter];
                

                if (message)
                {
                    [errorDict setObject:message forKey:@"displayText"];
                }
                if (parameterCorrelationId)
                {
                    [errorDict setObject:parameterCorrelationId forKey:@"parameterCorrelationId"];
                }
                
                NSString *failureUri = [self failureUriForError:errors[i]];
                if (failureUri) {
                    [errorDict setObject:failureUri forKey:@"failureUri"];
                }

                [errorArr addObject:errorDict];
                if (errorMessage)
                {
                    errorMessage = [NSString stringWithFormat:@"%@\n%@",errorMessage,message];
                }
                else
                {
                    errorMessage = [NSString stringWithFormat:@"%@",message];
                }
            }

            if (errorMessage && errorArr)
            {
                NSString *urlStringFromRequest = [request.URL absoluteString];
                NSString *urlString =  [self.urlStringProvider urlStringWithEndpointName:BulkPunchWithCreatedAtTime3];
                if ([urlStringFromRequest isEqualToString:urlString]) {
                    NSDictionary*userInfo = @{NSLocalizedDescriptionKey: errorMessage,@"ErroredPunches": errorArr};
                    NSError *error = [[NSError alloc] initWithDomain:RepliconNoAlertErrorDomain code:200 userInfo:userInfo];
                    return error;
                }
                else{
                    NSDictionary*userInfo = @{NSLocalizedDescriptionKey: errorMessage,@"ErroredPunches": errorArr};
                    NSError *error = [[NSError alloc] initWithDomain:RandomErrorDomain code:200 userInfo:userInfo];
                    return error;
                }
            }
        }

    }

    return nil;
}

#pragma mark - Private

- (NSError *)getErrorFromDetailsNode:(NSDictionary *)errorDetails url:(NSURL *)url {

    NSString *error = nil;
    if (errorDetails != (id) [NSNull null]) {

        NSString *failureUri = errorDetails[@"failureUri"];
        NSArray *notifications = errorDetails[@"notifications"];
        error = [self errorMessageTextForError:notifications];

        if (IsValidString(failureUri)) {
            return [self getErrorFromDetailsNodeWhenFailureURIPresent:failureUri];
        } else if([notifications count] > 0){

            NSString *urlString =  [self.urlStringProvider urlStringWithEndpointName:@"NewTimeLineSummary"];
            if (![url.absoluteString isEqualToString:urlString]) {
                return [self errorWithDomain:RandomErrorDomain message:error];
            }
        }
    }
    NSDictionary*userInfo = @{NSLocalizedDescriptionKey: error};
    return [[NSError alloc] initWithDomain:RepliconNoAlertErrorDomain code:500 userInfo:userInfo];
}

- (NSError *)getErrorFromDetailsNodeWhenFailureURIPresent:(NSString *)failureUri {

    if ([failureUri isEqualToString:USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR] ||
        [failureUri isEqualToString:USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_1])
    {
        NSString *error = RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, nil);
        return [self errorWithDomain:PasswordAuthenticationErrorDomain message:error];
    }
    else if ([failureUri isEqualToString:COMPANY_NOT_EXISTS_ERROR])
    {
        NSString *error = RPLocalizedString(COMPANY_NOT_EXISTS_ERROR_MESSAGE, nil);
        return [self errorWithDomain:CompanyAuthenticationErrorDomain message:error];
    }
    else if ([failureUri isEqualToString:COMPANY_DISABLED_ERROR] ||
             [failureUri isEqualToString:COMPANY_DISABLED_ERROR_1])
    {
        NSString *error = RPLocalizedString(COMPANY_DISABLED_ERROR_MESSAGE, nil);
        return [self errorWithDomain:CompanyDisabledErrorDomain message:error];
    }
    else if ([failureUri isEqualToString:NO_AUTH_CREDENTIALS_PROVIDED_ERROR] ||
             [failureUri isEqualToString:NO_AUTH_CREDENTIALS_PROVIDED_ERROR_1])
    {
        NSString *error = RPLocalizedString(NO_AUTH_CREDENTIALS_PROVIDED_ERROR_MESSAGE, nil);
        return [self errorWithDomain:NoAuthErrorDomain message:error];
    }
    else if ([failureUri isEqualToString:PASSWORD_EXPIRED] ||
             [failureUri isEqualToString:PASSWORD_EXPIRED1])
    {
        NSString *error = RPLocalizedString(USER_NOT_EXISTS_OR_PASSWORD_INCORRECT_ERROR_MESSAGE, nil);
        return [self errorWithDomain:PasswordExpiredErrorDomain message:error];
    }
    else if ([failureUri isEqualToString:UNKNOWN_ERROR] ||
             [failureUri isEqualToString:UNKNOWN_ERROR_1])
    {
        NSString *error = RPLocalizedString(UNKNOWN_ERROR_MESSAGE, nil);
        return [self errorWithDomain:UnknownErrorDomain message:error];
    }
    else if ([failureUri isEqualToString:USER_AUTHENTICATION_CHANGE_ERROR] ||
             [failureUri isEqualToString:USER_AUTHENTICATION_CHANGE_ERROR_1])
    {
        NSString *error = RPLocalizedString(USER_AUTHENTICATION_CHANGE_ERROR_MESSAGE, nil);
        return [self errorWithDomain:UserAuthChangeErrorDomain message:error];
    }
    else if ([failureUri isEqualToString:USER_DISABLED_ERROR] ||
             [failureUri isEqualToString:USER_DISABLED_ERROR_1])
    {
        NSString *error = RPLocalizedString(USER_DISABLED_ERROR_MESSAGE, nil);
        return [self errorWithDomain:UserDisabledErrorDomain message:error];
    }

    return nil;
}

-(NSString *)errorMessageTextForError:(NSArray *)errors
{
    NSString *message;
    if (errors != (id)[NSNull null])
    {
        for (NSDictionary *notification in errors) {

            if (message && message != (id)[NSNull null])
            {
                message=[NSString stringWithFormat:@"%@\n\n%@",message,notification[@"displayText"]];
            }
            else
            {
                message = notification[@"displayText"];
            }
        }
    }
    
    if (message ==nil || message == (id)[NSNull null])
    {
        message = RPLocalizedString(UNKNOWN_ERROR_MESSAGE, nil);
    }

    return message;
}

-(NSString *)errorMessageTextForErrorDictionary:(NSDictionary *)errorDictionary
{
    NSString *message;
    if (errorDictionary != nil && errorDictionary != (id)[NSNull null]) {
        if (errorDictionary[@"displayText"] != nil && errorDictionary[@"displayText"] != (id)[NSNull null]) {
            message = errorDictionary[@"displayText"];
        }
    }
    
    if (message ==nil || message == (id)[NSNull null]){
        message = RPLocalizedString(UNKNOWN_ERROR_MESSAGE, nil);
    }
    
    return message;
}


-(NSError *)errorWithDomain:(NSString *)domain message:(NSString *)message
{
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey: message};
    NSError *error = [[NSError alloc] initWithDomain:domain code:500 userInfo:userInfo];
    return error;
}

-(NSString *)messageForUriErrorDomain
{
    UITabBarController *tabBarController = self.appDelegate.rootTabBarController;
    UIViewController *selectedController = tabBarController.selectedViewController;
    NSString *errorMessage = @"";
    if ([selectedController isKindOfClass:[TimesheetNavigationController class]])
    {
        errorMessage=RPLocalizedString(Timesheet_URLError_Msg, @"");
    }
    else if ([selectedController isKindOfClass:[ExpensesNavigationController class]])
    {
        errorMessage=RPLocalizedString(Expense_URLError_Msg, @"");
    }
    else if ([selectedController isKindOfClass:[BookedTimeOffNavigationController class]])
    {
        errorMessage=RPLocalizedString(TimeOff_URLErroe_Msg, @"");
    }
    else if ([selectedController isKindOfClass:[ApprovalsNavigationController class]])
    {
        UINavigationController *navigationController=(ApprovalsNavigationController *)selectedController;
        errorMessage = [self messageForApproverNavigationWithController:navigationController];
    }
    else if ([selectedController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        UINavigationController *navigationController=(SupervisorDashboardNavigationController *)selectedController;
        errorMessage = [self messageForApproverNavigationWithController:navigationController];
    }
    else
    {
        errorMessage=RPLocalizedString(Punch_URLError_Msg, @"");
    }

    return errorMessage;
}

-(NSString *)messageForApproverNavigationWithController:(UINavigationController *)navigation
{
    NSString *errorMessage = @"";
    NSArray *approvalsControllers = navigation.viewControllers;
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

    return errorMessage;

}

-(NSString *)parameterCorrelationIdForError:(NSDictionary *)parameterDict
{
    if (parameterDict && parameterDict != (id)[NSNull null])
    {
        NSString *parameterCorrelationId = parameterDict[@"parameterCorrelationId"];
        if (parameterCorrelationId && parameterCorrelationId != (id)[NSNull null])
        {
            return parameterCorrelationId;
        }
    }
    return nil;
}

-(NSString *)failureUriForError:(NSDictionary *)errorDict
{
    if (errorDict && errorDict != (id)[NSNull null])
    {
        NSString *failureUri = errorDict[@"failureUri"];
        if (failureUri && failureUri != (id)[NSNull null]){
            return failureUri;
        }
    }
    return nil;
}

@end
