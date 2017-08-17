
#import "HttpErrorSerializer.h"
#import "Constants.h"
#import "AppProperties.h"

@implementation HttpErrorSerializer

-(NSError *)serializeHTTPError:(NSError *)error
{
    NSString *errorDomain;
    NSString* statusError;
    BOOL noAlertError = [self shouldSuppressAlertForError:error];
    if (noAlertError)
    {
        errorDomain = RepliconNoAlertErrorDomain;
        statusError = @"";
    }
    else
    {
        errorDomain = RepliconHTTPRequestErrorDomain;

        if ([error code]==-998)
        {
            statusError = RPLocalizedString(RepliconHTTPRequestError_998,RepliconHTTPRequestError_998);
        }
        else if ([error code]==-999)
        {
            statusError = RPLocalizedString(RepliconHTTPRequestError_999,RepliconHTTPRequestError_999);
        }
        else if ([error code]==-1001)
        {
            statusError = RPLocalizedString(RepliconHTTPRequestError_1001,RepliconHTTPRequestError_1001);
        }
        else if ([error code]==-1200)
        {
            statusError = RPLocalizedString(RepliconHTTPRequestError_1200,RepliconHTTPRequestError_1200);
        }
        else if ([error code]==-1003||
                 [error code]==-1004||
                 [error code]==-1005||
                 [error code]==-1006||
                 [error code]==-1008||
                 [error code]==-1009||
                 [error code]==-1011)
        {
            statusError = error.localizedDescription;
        }
        else if ([[error domain]isEqualToString:RepliconHTTPNonJsonResponseErrorDomain])
        {
            errorDomain = RepliconHTTPNonJsonResponseErrorDomain;
            statusError = RPLocalizedString(RepliconServerMaintenanceError,nil);
        }
        else if ([[error domain]isEqualToString:RepliconServiceUnAvailabilityResponseErrorDomain])
        {
            errorDomain = RepliconServiceUnAvailabilityResponseErrorDomain;
            statusError = RPLocalizedString(RepliconServerMaintenanceError,nil);
        }
        else if ([[error domain]isEqualToString:RepliconFailureStatusCodeDomain])
        {
            errorDomain = RepliconFailureStatusCodeDomain;
            statusError = RPLocalizedString(USER_FRIENDLY_ERROR_MSG,nil);
        }
        else if ([[error domain]isEqualToString:NSPOSIXErrorDomain])
        {
            errorDomain = NSPOSIXErrorDomain;
            statusError = [NSString stringWithFormat:@"%@.%@",error.localizedDescription,RepliconGenericPosixOrUrlDomainError];

        }
        else if ([[error domain]isEqualToString:NSURLErrorDomain])
        {
            errorDomain = NSURLErrorDomain;
            statusError=[NSString stringWithFormat:@"%@.%@",error.localizedDescription,RepliconGenericPosixOrUrlDomainError];
        }

        else if ([[error domain]isEqualToString:RepliconNoAlertErrorDomain])
        {
            errorDomain = RepliconNoAlertErrorDomain;
            statusError = @"";
        }
        else
        {
            statusError = RPLocalizedString(UNKNOWN_ERROR_MESSAGE,UNKNOWN_ERROR_MESSAGE);
        }

    }

    if ([error code]==-1009)
    {
        errorDomain = RepliconNoAlertErrorDomain;
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
    NSDictionary* userInfo = @{NSLocalizedDescriptionKey: statusError,@"NSErrorFailingURLStringKey": failedUrl};
    return [[NSError alloc] initWithDomain:errorDomain code:error.code userInfo:userInfo];
}

#pragma mark - Private

-(BOOL)shouldSuppressAlertForError:(NSError *)error
{
    NSString *failedURL = [error userInfo][@"NSErrorFailingURLStringKey"];
    if ([[error domain] isEqualToString:InvalidUserSessionRequestDomain]) {
        return YES;
    }
    NSArray *urlList = [self listOfURLWithNoAlert];
    for (NSString *url in urlList) {
        if ([failedURL isKindOfClass:[NSString class]] && [failedURL hasString:url]) {
            return YES;
            break;
        }
    }
    return NO;
}

-(NSArray *)listOfURLWithNoAlert
{
    AppProperties *properties = [AppProperties getInstance];
    NSArray *array = [NSArray arrayWithObjects:
                      [properties getServiceURLFor:@"GetVersionUpdateDetails"],
                      [properties getServiceURLFor:@"GetMyNotificationSummary"],
                      [properties getServiceURLFor:@"getServerDownStatus"],
                      [properties getServiceURLFor:@"RegisterForPushNotifications"],
                      [properties getServiceURLFor:@"Gen4TimesheetValidation"],
                      [properties getServiceURLFor:@"GetHomeSummary"],
                      [properties getServiceURLFor:@"GetHomeSummary2"],
                      [properties getServiceURLFor:@"GetPunchClients"],
                      [properties getServiceURLFor:@"GetPunchProjects"],
                      [properties getServiceURLFor:@"GetPunchTasks"],
                      [properties getServiceURLFor:@"GetPunchActivities"],
                      [properties getServiceURLFor:@"GetExpenseClients"],
                      [properties getServiceURLFor:@"GetExpenseProjects"],
                      [properties getServiceURLFor:@"GetExpenseTasks"],
                      [properties getServiceURLFor:@"GetPageOfObjectExtensionTagsFilteredBySearch"],nil];
    return array;
}

@end
