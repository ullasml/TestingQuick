#import "JSONClient.h"
#import "RequestPromiseClient.h"
#import <KSDeferred/KSDeferred.h>
#import "Constants.h"
#import "SNLog.h"
#import <repliconkit/repliconkit.h>
#import "ImageStripper.h"

@interface JSONClient()

@property (nonatomic) id<RequestPromiseClient> client;
@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic) id <UserSession> userSession;


@end


@implementation JSONClient

- (instancetype)initWithURLSessionClient:(id<RequestPromiseClient>)client
                             userSession:(id<UserSession>)userSession
                                   queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self)
    {
        self.client = client;
        self.queue = queue;
        self.userSession = userSession;
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

- (KSPromise *)promiseWithRequest:(NSURLRequest *) request
{
    KSDeferred *deferred = [[KSDeferred alloc] init];
    KSPromise *dataPromise = [self.client promiseWithRequest:request];
    [dataPromise then:^id(NSData *data) {
        NSError *error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

        [self logRequestWithData:request.HTTPBody andResponseWithData:data url:request.URL];
        
        if (error)
        {
            [self.queue addOperationWithBlock:^{
                if ([self.userSession validUserSession])
                {
                    NSDictionary* userInfo = @{@"NSErrorFailingURLStringKey":request.URL.absoluteString};
                    NSError *nonJsonError = [[NSError alloc]initWithDomain:RepliconHTTPNonJsonResponseErrorDomain code:0 userInfo:userInfo];
                    [deferred rejectWithError:nonJsonError];
                }
                else
                {
                    NSError *invalidUserSessionError = [self serializeInvalidUserSessionError];
                    [deferred rejectWithError:invalidUserSessionError];
                }

            }];
        }
        else
        {
            [self.queue addOperationWithBlock:^{
                if ([self.userSession validUserSession])
                {
                    [deferred resolveWithValue:json];
                }
                else
                {
                    if (![self isRequestMadeWithInvalidSession:request] && ![self isAppConfigRequest:request])
                    {
                        NSError *invalidUserSessionError = [self serializeInvalidUserSessionError];
                        [deferred rejectWithError:invalidUserSessionError];
                    }
                    else
                    {
                        [deferred resolveWithValue:json];
                    }

                }

            }];
        }

        return nil;
    } error:^id(NSError *error) {
        [self.queue addOperationWithBlock:^{
            NSData *failureData =error.userInfo[@"failedData"];
            [self logRequestWithData:request.HTTPBody andResponseWithData:failureData url:request.URL];
            [deferred rejectWithError:error];
        }];

        return nil;
    }];

    return deferred.promise;
}

#pragma mark - Private

-(NSError *)serializeInvalidUserSessionError
{
    return [[NSError alloc]initWithDomain:InvalidUserSessionRequestDomain code:-888 userInfo:nil];
}

-(BOOL)isRequestMadeWithInvalidSession:(NSURLRequest *)request
{
    NSDictionary *headerFields = request.allHTTPHeaderFields;
    if (headerFields != nil && headerFields != (id)[NSNull null]) {
        NSString *value = [headerFields objectForKey:RequestMadeWhileInvalidUserSessionHeaderKey];
        if (value != nil && [value isEqualToString:RequestMadeWhileInvalidUserSessionHeaderValue])
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isAppConfigRequest:(NSURLRequest *)request {
    return [[[request URL] relativePath] isEqualToString:@"/app-config"];;
}


-(void)logRequestWithData:(NSData *)requestData andResponseWithData:(NSData *)responseData url:(NSURL *)url
{
    NSString *urlString = url.absoluteString;

    if (![urlString containsString:@"GetMyTimePunchDetailsForDateRangeAndLastTwoPunchDetails"]&&
        ![urlString containsString:@"GetPageOfUserTimeSegmentLoadSummariesForDate"])
    {
        NSString *urlLog = [NSString stringWithFormat:@"----URL after response:::::\n%@",urlString];
        CLS_LOG(@"----URL after response:::::\n%@",urlString);
        [LogUtil logLoggingInfo:urlLog forLogLevel:LoggerCocoaLumberjack];

        NSString *requestSent = [[NSString alloc]initWithData:requestData encoding:NSUTF8StringEncoding];

        NSString *datatoLogStr = [ImageStripper removeImageDataFromString:requestSent];

        NSString *requestLog = [NSString stringWithFormat:@"----REQUEST after response:::::\n%@",datatoLogStr];
        CLS_LOG(@"----REQUEST after response:::::\n%@",datatoLogStr);
        [LogUtil logLoggingInfo:requestLog forLogLevel:LoggerCocoaLumberjack];

        NSString *responseRecieved = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
        NSString *responseDatatoLogStr = [ImageStripper removeImageDataFromString:responseRecieved];
        CLS_LOG(@"----RESPONSE:::::\n%@",responseDatatoLogStr);
        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"----RESPONSE:::::\n%@",responseDatatoLogStr] forLogLevel:LoggerCocoaLumberjack];
    }


}



@end
