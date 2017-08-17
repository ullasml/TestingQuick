#import "URLSessionClient.h"
#import <KSDeferred/KSDeferred.h>
#import "DoorKeeper.h"
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"
#import "Constants.h"
#import "AppProperties.h"


@interface URLSessionClient ()

@property (nonatomic) NSURLSession *session;
@property (nonatomic) DoorKeeper   *doorKeeper;
@property (nonatomic) BOOL         isInvalidateSession;
@property (nonatomic) id<BSInjector> injector;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) NSDateFormatter *dateFormatter;
@end


@implementation URLSessionClient

- (instancetype)initWithURLSession:(NSURLSession *)session
                        doorKeeper:(DoorKeeper *)doorKeeper
                      userDefaults:(NSUserDefaults *)defaults
                     dateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self)
    {
        self.session = session;
        self.doorKeeper = doorKeeper;
        self.defaults = defaults;
        [self.doorKeeper addLogOutObserver:self];
        self.dateFormatter = dateFormatter;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - <RequestPromiseClient>

- (KSPromise *)promiseWithRequest:(NSURLRequest *)request
{

    if (self.isInvalidateSession)
    {
        self.session = [self.injector getInstance:InjectorKeyURLSessionWithDefaultSessionConfiguration];
        self.isInvalidateSession = NO;
    }

    KSDeferred *deferred = [[KSDeferred alloc] init];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:request
                                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                                                         NSDictionary *headerFields = request.allHTTPHeaderFields;
                                                         BOOL isFromRequestMadeWhilePendingQueueSync=NO;

                                                         if (headerFields != nil && headerFields != (id)[NSNull null])
                                                         {
                                                             NSString *value = [headerFields objectForKey:RequestMadeWhilePendingQueueSyncHeaderKey];
                                                             if (value != nil && [value isEqualToString:RequestMadeWhilePendingQueueSyncHeaderValue])
                                                             {
                                                                 isFromRequestMadeWhilePendingQueueSync=YES;

                                                                 if (error) {
                                                                     NSError *errorNew = [[NSError alloc] initWithDomain:InvalidUserSessionRequestDomain code:error.code userInfo:nil];
                                                                     isFromRequestMadeWhilePendingQueueSync=YES;
                                                                     [deferred rejectWithError:errorNew];
                                                                 }
                                                                 else
                                                                 {
                                                                      [deferred resolveWithValue:data];
                                                                 }


                                                             }

                                                         }

                                                         if (!isFromRequestMadeWhilePendingQueueSync)
                                                         {
                                                             if (error.code==-999)
                                                             {

                                                                 NSError *errorNew = [[NSError alloc] initWithDomain:InvalidUserSessionRequestDomain code:error.code userInfo:nil];
                                                                 [deferred rejectWithError:errorNew];
                                                             }

                                                             else if (self.isInvalidateSession) {
                                                                 NSError *invalidError = [self serializeInvalidUserSessionErrorForUrl:response.URL data:data];
                                                                 [deferred rejectWithError:invalidError];
                                                             }
                                                             else{

                                                                 NSUInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                                                                 NSError *forbiddenError = [self serializeForbiddenErrorForStatusCode:statusCode url:response.URL data:data];


                                                                 if (forbiddenError)
                                                                 {
                                                                     [deferred rejectWithError:forbiddenError];
                                                                 }
                                                                 else if (error)
                                                                 {
                                                                     NSError * internalModifiedError = nil;
                                                                     internalModifiedError=error;
                                                                     if (response)
                                                                     {
                                                                         if (response.URL!=nil && ![response.URL isKindOfClass:[NSNull class]] && data!=nil && ![data isKindOfClass:[NSNull class]])
                                                                         {
                                                                             internalModifiedError = [NSError errorWithDomain:error.domain code:error.code userInfo:@{@"NSErrorFailingURLStringKey":response.URL,@"failedData":data}];
                                                                         }
                                                                         else
                                                                         {
                                                                             internalModifiedError = [NSError errorWithDomain:error.domain code:error.code userInfo:nil];
                                                                         }

                                                                     }

                                                                     [deferred rejectWithError:internalModifiedError];
                                                                 }
                                                                 else if (statusCode == 504 || statusCode == 503 || statusCode == 303)
                                                                 {
                                                                     NSError *serviceUnAvailabilityError = [[NSError alloc] initWithDomain:RepliconServiceUnAvailabilityResponseErrorDomain code:statusCode userInfo:nil];
                                                                     [deferred rejectWithError:serviceUnAvailabilityError];
                                                                 }
                                                                 else
                                                                 {
                                                                    BOOL shouldRequestBeHonoured = [self shouldRequestBeHonouredCorrespondsToSearch:request];

                                                                 if (shouldRequestBeHonoured)
                                                                 {

                                                                     BOOL shouldRequestBeHonouredCorrespondsTimePunchesDetails = [self shouldRequestBeHonouredCorrespondsToTimePunchDetailsForDateRangeAndLastTwoPunchDetails:request andResponseData:data];
                                                                     if (shouldRequestBeHonouredCorrespondsTimePunchesDetails)
                                                                     {
                                                                        BOOL shouldRequestBeHonouredCorrespondsToGetTimesheetSummary = [self shouldRequestBeHonouredCorrespondsToGetTimesheetSummary:request andResponseData:data];

                                                                         if (shouldRequestBeHonouredCorrespondsToGetTimesheetSummary)
                                                                         {
                                                                             [deferred resolveWithValue:data];
                                                                             [self updateErrorDetailsTimeSheetLastModifiedTime:response];
                                                                         }
                                                                         else
                                                                         {
                                                                             NSError *noAlertError = [[NSError alloc] initWithDomain:RepliconNoAlertErrorDomain code:error.code userInfo:nil];
                                                                             [deferred rejectWithError:noAlertError];
                                                                         }

                                                                     }

                                                                     else
                                                                     {
                                                                          NSError *noAlertError = [[NSError alloc] initWithDomain:RepliconNoAlertErrorDomain code:error.code userInfo:nil];
                                                                         [deferred rejectWithError:noAlertError];
                                                                     }


                                                                 }
                                                                 else
                                                                 {
                                                                     NSError *serializedError = [self serializeInvalidSearchErrorForUrl:request.URL];
                                                                     [deferred rejectWithError:serializedError];
                                                                 }

                                                                 }
                                                             }

                                                         }



                                                     }];
    [dataTask resume];

    return deferred.promise;
}

#pragma mark - <DoorKeeperObserver>

- (void)doorKeeperDidLogOut:(DoorKeeper *)doorKeeper
{
    [self.session invalidateAndCancel];

    //We have to defer resetWithCompletionHandler until all the pending tasks are either cancelled or completed.
    //Only then we should call resetWithCompletionHandler
    //because this empties all cookies, cache and credential stores, removes disk files
    //and once the above are removed pending tasks behave abnormaly
    /*[self.session resetWithCompletionHandler:^{}];*/
    
    // resetWithCompletionHandler itself issues -flushWithCompletionHandler:. Hence flushWithCompletionHandler is no longer required
    /*[self.session  flushWithCompletionHandler:^{}];*/

    self.isInvalidateSession = YES;
}

#pragma mark - Private

-(NSError *)serializeForbiddenErrorForStatusCode:(NSUInteger)statusCode url:(NSURL *)url data:(NSData *)data
{
    if (statusCode==403)
    {
        NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url.absoluteString,
                                   @"failedData":data};
        return [[NSError alloc]initWithDomain:RepliconFailureStatusCodeDomain code:-888 userInfo:userInfo];
    }
    return nil;
}

-(NSError *)serializeInvalidUserSessionErrorForUrl:(NSURL *)url data:(NSData *)data
{
    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url.absoluteString,
                               @"failedData":data};
    return [[NSError alloc]initWithDomain:InvalidUserSessionRequestDomain code:-888 userInfo:userInfo];
}

-(BOOL)shouldRequestBeHonouredCorrespondsToSearch:(NSURLRequest *)request
{
    NSString *searchString = request.allHTTPHeaderFields[RequestMadeForSearchWithHeaderKey];
    if (searchString !=nil && searchString != (id) [NSNull null] && searchString.length > 0) {
        NSString *storedString = [self.defaults objectForKey:RequestMadeForSearchWithValue];
        if (![searchString isEqualToString:storedString])
        {
            return NO;
        }
    }
    return YES;
}

-(NSError *)serializeInvalidSearchErrorForUrl:(NSURL *)url
{
    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":url.absoluteString};
    return [[NSError alloc]initWithDomain:RepliconNoAlertErrorDomain code:-888 userInfo:userInfo];
}

-(void)updateErrorDetailsTimeSheetLastModifiedTime:(NSURLResponse *)httpResponse
{
    NSString *url = httpResponse.URL.absoluteString;
    if (url!=nil && ![url isKindOfClass:[NSNull class]])
    {
        AppProperties *appProperties = [AppProperties getInstance];
        NSString *endpointPath = [appProperties getServiceURLFor:@"GetTimesheetUpdateData"];
        if ([url containsString:endpointPath])
        {
            NSDictionary *headerFields = ((NSHTTPURLResponse *)httpResponse).allHeaderFields;
            NSString *serverTimestamp=[headerFields objectForKey:@"Date"];
            if (serverTimestamp!=nil && ![serverTimestamp isKindOfClass:[NSNull class]])
            {
                NSString *key=@"ErrorTimeSheetLastModifiedTime";
                [self.defaults removeObjectForKey:key];
                [self.defaults  setObject:serverTimestamp forKey:key];
                [self.defaults  synchronize];
            }
        }
    }


}

-(BOOL)shouldRequestBeHonouredCorrespondsToTimePunchDetailsForDateRangeAndLastTwoPunchDetails:(NSURLRequest *)httpRequest andResponseData:(NSData *)responseData
{
    NSString *url = httpRequest.URL.absoluteString;
    if (url!=nil && ![url isKindOfClass:[NSNull class]])
    {
        AppProperties *appProperties = [AppProperties getInstance];
        NSString *endpointPath = [appProperties getServiceURLFor:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"];
        if ([url containsString:endpointPath])
        {

            NSData *oldResponseData = [self.defaults objectForKey:@"oldMostRecentPunchData"];
            [self.defaults setObject:responseData forKey:@"oldMostRecentPunchData"];
            [self.defaults synchronize];
            if ([oldResponseData isEqual: responseData])
            {
                return NO;
            }

            NSDictionary *headerFields = httpRequest.allHTTPHeaderFields;
            NSString *serverTimestamp=[headerFields objectForKey:MostRecentPunchDateIdentifierHeader];
            if (serverTimestamp!=nil && ![serverTimestamp isKindOfClass:[NSNull class]])
            {
                NSString *serverTimestampLastPunchRecorded=[self.defaults objectForKey:@"PunchRecordedLastModifiedTime"];
                if (serverTimestampLastPunchRecorded!=nil && ![serverTimestampLastPunchRecorded isKindOfClass:[NSNull class]])
                {
                    NSDate *currentDate = [self.dateFormatter dateFromString:serverTimestamp];
                    NSDate *timePunchDate = [self.dateFormatter dateFromString:serverTimestampLastPunchRecorded];
                    if ([currentDate compare:timePunchDate] == NSOrderedAscending)
                    {
                       return NO;
                    }
                }

            }
        }
    }

    return YES;
}

-(BOOL)shouldRequestBeHonouredCorrespondsToGetTimesheetSummary:(NSURLRequest *)httpRequest andResponseData:(NSData *)responseData
{
    NSString *url = httpRequest.URL.absoluteString;
    if (url!=nil && ![url isKindOfClass:[NSNull class]])
    {
        AppProperties *appProperties = [AppProperties getInstance];
        NSString *endpointPath = [appProperties getServiceURLFor:@"GetTimesheetSummary"];
        if ([url containsString:endpointPath])
        {

            NSDictionary *headerFields = httpRequest.allHTTPHeaderFields;
            NSString *serverTimestamp=[headerFields objectForKey:GetTimesheetSummaryDateIdentifierHeader];
            if (serverTimestamp!=nil && ![serverTimestamp isKindOfClass:[NSNull class]])
            {
                NSString *serverTimestampLastPunchRecorded=[self.defaults objectForKey:@"PunchRecordedLastModifiedTime"];
                if (serverTimestampLastPunchRecorded!=nil && ![serverTimestampLastPunchRecorded isKindOfClass:[NSNull class]])
                {
                    NSDate *currentDate = [self.dateFormatter dateFromString:serverTimestamp];
                    NSDate *timePunchDate = [self.dateFormatter dateFromString:serverTimestampLastPunchRecorded];
                    if ([currentDate compare:timePunchDate] == NSOrderedAscending)
                    {
                        return NO;
                    }
                }

            }
        }
    }
    
    return YES;
}

@end
