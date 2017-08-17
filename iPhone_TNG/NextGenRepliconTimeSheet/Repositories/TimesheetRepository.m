#import "TimesheetRepository.h"
#import "RequestBuilder.h"
#import "RequestDictionaryBuilder.h"
#import "JSONClient.h"
#import <KSDeferred/KSDeferred.h>
#import "TimesheetDeserializer.h"
#import "TimesheetForDateRange.h"
#import "DateProvider.h"
#import "TimesheetRequestBodyProvider.h"
#import "TimesheetRequestProvider.h"
#import "Timesheet.h"
#import "SingleTimesheetDeserializer.h"
#import "TimesheetInfoDeserializer.h"
#import "ReporteePermissionsStorage.h"
#import "UserUriDetector.h"
#import "AstroUserDetector.h"
#import "AstroAwareTimesheet.h"
#import "TimesheetInfo.h"


@interface TimesheetRepository ()

@property (nonatomic) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic) TimesheetRequestProvider *timesheetRequestProvider;
@property (nonatomic) TimesheetDeserializer *timesheetDeserializer;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) id<RequestPromiseClient> client;
@property (nonatomic) TimesheetRequestBodyProvider *timesheetRequestBodyProvider;
@property (nonatomic) SingleTimesheetDeserializer *singleTimesheetDeserializer;
@property (nonatomic) TimesheetInfoDeserializer *timesheetInfoDeserializer;
@property (nonatomic) ReporteePermissionsStorage *reporteePermissionsStorage;
@property (nonatomic) UserUriDetector *userUriDetector;
@property (nonatomic) WidgetTimesheetCapabilitiesDeserializer *capabilitiesDeserializer;
@property (nonatomic) WidgetPlatformDetector *widgetPlatformDetector;

@end


@implementation TimesheetRepository

- (instancetype)initWithCapabilitiesDeserializer:(WidgetTimesheetCapabilitiesDeserializer *)capabilitiesDeserializer
                    timesheetRequestBodyProvider:(TimesheetRequestBodyProvider *)timesheetRequestBodyProvider
                       timesheetInfoDeserializer:(TimesheetInfoDeserializer *)timesheetInfoDeserializer
                     singleTimesheetDeserializer:(SingleTimesheetDeserializer *)singleTimesheetDeserializer
                      reporteePermissionsStorage:(ReporteePermissionsStorage *)reporteePermissionsStorage
                        requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                        timesheetRequestProvider:(TimesheetRequestProvider *)timesheetRequestProvider
                          widgetPlatformDetector:(WidgetPlatformDetector *)widgetPlatformDetector
                           timesheetDeserializer:(TimesheetDeserializer *)timesheetDeserializer
                                 userUriDetector:(UserUriDetector *)userUriDetector
                                    userDefaults:(NSUserDefaults *)userDefaults
                                          client:(id <RequestPromiseClient>)client {
    self = [super init];
    if (self) {
        self.capabilitiesDeserializer = capabilitiesDeserializer;
        self.timesheetRequestProvider = timesheetRequestProvider;
        self.requestDictionaryBuilder = requestDictionaryBuilder;
        self.timesheetDeserializer = timesheetDeserializer;
        self.timesheetRequestBodyProvider = timesheetRequestBodyProvider;
        self.singleTimesheetDeserializer = singleTimesheetDeserializer;
        self.reporteePermissionsStorage = reporteePermissionsStorage;
        self.timesheetInfoDeserializer = timesheetInfoDeserializer;
        self.widgetPlatformDetector = widgetPlatformDetector;
        self.userUriDetector = userUriDetector;
        self.userDefaults = userDefaults;
        self.client = client;
    }
    return self;
}

- (KSPromise *)fetchTimesheetWithURI:(NSString *)timesheetUri
{
    NSURLRequest *request = [self.timesheetRequestProvider requestForTimesheetWithURI:timesheetUri];
    KSPromise *dictionaryPromise = [self.client promiseWithRequest:request];

    return [dictionaryPromise then:^id(NSDictionary *timesheetResponseDictionary) {
        NSDictionary *responseDictionary = timesheetResponseDictionary[@"d"];
        NSDictionary *capabilities = responseDictionary[@"capabilities"];
        NSMutableDictionary *punchCapabilities = capabilities[@"timePunchCapabilities"];
        NSNumber *canAccessProject;
        NSString *userUri;
        if (punchCapabilities!=nil && ![punchCapabilities isKindOfClass:[NSNull class]]){
            canAccessProject = punchCapabilities[@"hasProjectAccess"];
        }
        userUri = [self.userUriDetector userUriFromTimesheetLoad:timesheetResponseDictionary];
        AstroAwareTimesheet *astroAwareTimesheet = [self.singleTimesheetDeserializer deserialize:timesheetResponseDictionary];
        BOOL isAstroUser =  (astroAwareTimesheet.astroUserType == TimesheetAstroUserTypeAstro);

        BOOL isPunchIntoProjectsUser = isAstroUser && [canAccessProject boolValue];

        if (isAstroUser){
            [self saveReporteePermissions:punchCapabilities userUri:userUri isPunchIntoProjectsUser:isPunchIntoProjectsUser];
        }

        return astroAwareTimesheet;
    } error:^id(NSError *error) {
        return error;
    }];
}

- (KSPromise *)fetchMostRecentTimesheet
{
    return [self fetchTimesheetWithOffset:0];
}

- (KSPromise *)fetchTimesheetWithOffset:(NSUInteger) offset
{
    KSDeferred *timesheetDeferred = [[KSDeferred alloc] init];
    NSString *userURI = [self.userDefaults stringForKey:@"UserUri"];

    NSDictionary *httpBodyDictionary = [self.timesheetRequestBodyProvider requestBodyDictionaryForMostRecentTimesheetWithUserURI:userURI];
    NSDictionary *requestDictionary = [self.requestDictionaryBuilder requestDictionaryWithEndpointName:@"GetFirstTimesheets"
                                                                                    httpBodyDictionary:httpBodyDictionary];

    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];

    KSPromise *jsonPromise = [self.client promiseWithRequest:request];

    [jsonPromise then:^id(NSDictionary *jsonDictionary) {
        NSArray *timesheetForDateRangeArray = [self.timesheetDeserializer deserialize:jsonDictionary];
        [timesheetDeferred resolveWithValue:timesheetForDateRangeArray[offset]];
        return nil;
    } error:^id(NSError *error) {
        [timesheetDeferred rejectWithError:error];
        return nil;
    }];

    return timesheetDeferred.promise;
}

- (KSPromise *)fetchTimesheetInfoForDate:(NSDate*)date
{
    KSDeferred *deferred = [[KSDeferred alloc] init];
    NSDictionary *httpBodyDictionary = [self.timesheetRequestBodyProvider requestBodyDictionaryTimesheetWithDate:date];
    NSDictionary *requestDictionary = [self.requestDictionaryBuilder requestDictionaryWithEndpointName:@"NewTimeLineSummary"
                                                                                    httpBodyDictionary:httpBodyDictionary];
    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];
    KSPromise *jsonPromise = [self.client promiseWithRequest:request];
    [jsonPromise then:^id(NSArray *jsonDictionary) {
        TimesheetInfo *timesheetInfo = [self.timesheetInfoDeserializer deserializeTimesheetInfo:jsonDictionary];
        [deferred resolveWithValue:timesheetInfo];
        return nil;
    } error:^id(NSError *error) {
        [deferred rejectWithError:error];
        return nil;
    }];
    
    return deferred.promise;
}

- (KSPromise *)fetchTimesheetInfoForTimsheetUri:(NSString*)uri
{
    KSDeferred *deferred = [[KSDeferred alloc] init];
    NSDictionary *httpBodyDictionary = [self.timesheetRequestBodyProvider requestBodyDictionaryTimesheetWithTimesheetURI:uri];
    NSDictionary *requestDictionary = [self.requestDictionaryBuilder requestDictionaryWithEndpointName:@"NewTimeLineSummary"
                                                                                    httpBodyDictionary:httpBodyDictionary];
    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];
    KSPromise *jsonPromise = [self.client promiseWithRequest:request];
    [jsonPromise then:^id(NSArray *jsonDictionary) {
        TimesheetInfo *timesheetInfo = [self.timesheetInfoDeserializer deserializeTimesheetInfo:jsonDictionary];
        [deferred resolveWithValue:timesheetInfo];
        return nil;
    } error:^id(NSError *error) {
        [deferred rejectWithError:error];
        return nil;
    }];
    
    return deferred.promise;
}

- (KSPromise *)fetchTimesheetCapabilitiesWithURI:(NSString *)timesheetUri
{
    NSURLRequest *request = [self.timesheetRequestProvider requestForTimesheetPoliciesWithURI:timesheetUri];
    KSPromise *dictionaryPromise = [self.client promiseWithRequest:request];
    
    return [dictionaryPromise then:^id(NSDictionary *timesheetResponseDictionary) {
        BOOL isWidgetPlatformSupported = false;
        NSArray *userConfiguredWidgetUris =  timesheetResponseDictionary[@"widgets"];
        if (userConfiguredWidgetUris != nil && userConfiguredWidgetUris != (id)[NSNull null]) {
            [self.widgetPlatformDetector setupWithUserConfiguredWidgetUris:userConfiguredWidgetUris];
            isWidgetPlatformSupported = [self.widgetPlatformDetector isWidgetPlatformSupported];
        }
        return @(isWidgetPlatformSupported);
    } error:^id(NSError *error) {
        return error;
    }];
}

#pragma mark - Private

-(void)saveReporteePermissions:(NSDictionary*)timepunchCapabilities userUri:(NSString*)userUri isPunchIntoProjectsUser:(BOOL)isPunchIntoProjectsUser{
    NSNumber *canAccessProject = 0;
    NSNumber *canAccessClient= 0;
    NSNumber *canAccessActivity= 0;
    NSNumber *projectTaskSelectionRequired= 0;
    NSNumber *activitySelectionRequired= 0;
    NSNumber *canAccessBreak = 0;
    
    if (timepunchCapabilities!=nil && ![timepunchCapabilities isKindOfClass:[NSNull class]])
    {
        canAccessProject = timepunchCapabilities[@"hasProjectAccess"];
        canAccessClient = timepunchCapabilities[@"hasClientAccess"];
        canAccessActivity = timepunchCapabilities[@"hasActivityAccess"];
        projectTaskSelectionRequired = timepunchCapabilities[@"projectTaskSelectionRequired"];
        activitySelectionRequired = timepunchCapabilities[@"activitySelectionRequired"];
        canAccessBreak = timepunchCapabilities[@"hasBreakAccess"];
    }
    
    [self.reporteePermissionsStorage persistCanAccessProject:canAccessProject
                                             canAccessClient:canAccessClient
                                           canAccessActivity:canAccessActivity
                                projectTaskSelectionRequired:projectTaskSelectionRequired
                                   activitySelectionRequired:activitySelectionRequired
                                      isPunchIntoProjectUser:@(isPunchIntoProjectsUser)
                                                     userUri:userUri
                                              canAccessBreak:canAccessBreak];
}

@end
