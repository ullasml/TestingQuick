#import "RepliconClient.h"
#import <KSDeferred/KSDeferred.h>
#import "ServerErrorSerializer.h"
#import "HttpErrorSerializer.h"
#import "ErrorReporter.h"
#import "Constants.h"
#import "ApplicationFlowControl.h"
#import "ErrorPresenter.h"
#import "MobileLoggerWrapperUtil.h"

@interface RepliconClient()

@property (nonatomic) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic) ServerErrorSerializer *serverErrorSerializer;
@property (nonatomic) HttpErrorSerializer *httpErrorSerializer;
@property (nonatomic) ErrorReporter *errorReporter;
@property (nonatomic) ApplicationFlowControl *flowControl;
@property (nonatomic) ErrorPresenter *errorPresenter;


@end


@implementation RepliconClient

- (instancetype)initWithClient:(id<RequestPromiseClient>)requestPromiseClient
         serverErrorSerializer:(ServerErrorSerializer *)serverErrorSerializer
           httpErrorSerializer:(HttpErrorSerializer *)httpErrorSerializer
                   flowControl:(ApplicationFlowControl *)flowControl
                errorPresenter:(ErrorPresenter *)errorPresenter
                 errorReporter:(ErrorReporter *)errorReporter
{
    self = [super init];
    if (self)
    {
        self.requestPromiseClient = requestPromiseClient;
        self.serverErrorSerializer = serverErrorSerializer;
        self.httpErrorSerializer = httpErrorSerializer;
        self.errorReporter = errorReporter;
        self.flowControl = flowControl;
        self.errorPresenter = errorPresenter;
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
    KSDeferred *deferred = [[KSDeferred alloc] init];

    KSPromise *promise = [self.requestPromiseClient promiseWithRequest:request];

    [promise then:^id(NSDictionary *jsonDictionary) {

        if (jsonDictionary)
        {

            NSDictionary *headerFields = request.allHTTPHeaderFields;
            BOOL isFromRequestMadeWhilePendingQueueSync=NO;
            BOOL isFromRequestMadeWhilePunching=NO;
            if (headerFields != nil && headerFields != (id)[NSNull null])
            {
                NSString *value = [headerFields objectForKey:RequestMadeWhilePendingQueueSyncHeaderKey];
                if (value != nil && [value isEqualToString:RequestMadeWhilePendingQueueSyncHeaderValue])
                {
                    isFromRequestMadeWhilePendingQueueSync=YES;
                }

                NSString *punchRequestIdentifierValue = [headerFields objectForKey:PunchRequestIdentifierHeader];
                if (punchRequestIdentifierValue != nil)
                {
                    isFromRequestMadeWhilePunching=YES;
                }
            }

            NSError *domainError = [self.serverErrorSerializer deserialize:jsonDictionary isFromRequestMadeWhilePendingQueueSync:isFromRequestMadeWhilePendingQueueSync request:request];

            if (domainError)
            {
                [self.flowControl performFlowControlForError:domainError];

                [self.errorPresenter presentAlertViewForError:domainError];

                BOOL validErrorForReporting = [self isValidErrorForReporting:domainError];

                if (validErrorForReporting)
                {
                    [self reportError:domainError];
                }

                if (isFromRequestMadeWhilePendingQueueSync)
                {
                    [deferred resolveWithValue:@{@"error": domainError.localizedDescription}];
                }
                else if (isFromRequestMadeWhilePunching)
                {

                    if (![domainError.userInfo.allKeys containsObject:@"ErroredPunches"])
                    {
                        [deferred rejectWithError:domainError];
                    }
                    else
                    {
                        [deferred resolveWithValue:@{@"d": @{@"errors": @[@{@"displayText": domainError.localizedDescription}],@"erroredPunches":domainError.userInfo[@"ErroredPunches"]}}];
                    }

                }
                else
                {
                    [deferred rejectWithError:domainError];
                }


            }
            else
            {
                [deferred resolveWithValue:jsonDictionary];
            }
        }
        return nil;
    } error:^id(NSError *error) {

        
         [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Error Received in Replicon Client::::: %@",error] forLogLevel:LoggerCocoaLumberjack];
        
        NSError *domainError = [self.httpErrorSerializer serializeHTTPError:error];
        
        NSDictionary *headerFields = request.allHTTPHeaderFields;
        ApplicateState applicationState = [[headerFields objectForKey:ApplicationStateHeaders]intValue];
        
        if (applicationState == Foreground && [Util requestMadeAfterApplicationWasLaunched:[headerFields objectForKey:RequestTimestamp]])
        {
             [self.errorPresenter presentAlertViewForError:domainError];
        }
        
        
        
        [self reportError:domainError];

        [deferred rejectWithError:domainError];

        return nil;
    }];

    return deferred.promise;
}

#pragma mark - Private

-(void)reportError:(NSError *)domainError
{
    BOOL shouldCheckForServerMaintenanace = ([[domainError domain] isEqualToString:RepliconServiceUnAvailabilityResponseErrorDomain] || [[domainError domain] isEqualToString:RepliconHTTPNonJsonResponseErrorDomain]);
    if (shouldCheckForServerMaintenanace)
    {
        [self.errorReporter checkForServerMaintenanaceWithError:domainError];
    }
    else
    {
        [self.errorReporter reportToCustomerSupportWithError:domainError];
    }
}

-(BOOL)isValidErrorForReporting:(NSError *)error
{
    NSArray *validErrors = @[InvalidTimesheetFormatErrorDomain,
                             OperationTimeoutErrorDomain,
                             UriErrorDomain,
                             UnknownErrorDomain,
                             NoAuthErrorDomain,
                             RandomErrorDomain,
                             AuthorizationErrorDomain];

    return [validErrors containsObject:[error domain]];
}

@end
