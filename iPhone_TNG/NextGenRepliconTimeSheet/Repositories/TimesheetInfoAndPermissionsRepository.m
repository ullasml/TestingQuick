#import "TimesheetInfoAndPermissionsRepository.h"
#import "RequestBuilder.h"
#import "RequestDictionaryBuilder.h"
#import "JSONClient.h"
#import <KSDeferred/KSDeferred.h>
#import "TimesheetRequestBodyProvider.h"
#import "Timesheet.h"
#import "TimesheetInfo.h"
#import "TimesheetInfoAndExtrasDeserializer.h"
#import "TimesheetAdditionalInfo.h"
#import "AstroClientPermissionStorage.h"


@interface TimesheetInfoAndPermissionsRepository ()

@property (nonatomic) TimesheetInfoAndExtrasDeserializer *timesheetInfoAndExtrasDeserializer;
@property (nonatomic) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic) AstroClientPermissionStorage *astroClientPermissionStorage;
@property (nonatomic) id<RequestPromiseClient> client;

@end


@implementation TimesheetInfoAndPermissionsRepository

- (instancetype)initWithTimesheetInfoAndExtrasDeserializer:(TimesheetInfoAndExtrasDeserializer *)timesheetInfoAndExtrasDeserializer
                              astroClientPermissionStorage:(AstroClientPermissionStorage *)astroClientPermissionStorage
                                  requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                                                    client:(id <RequestPromiseClient>)client {
    self = [super init];
    if (self) {
        self.timesheetInfoAndExtrasDeserializer = timesheetInfoAndExtrasDeserializer;
        self.astroClientPermissionStorage = astroClientPermissionStorage;
        self.requestDictionaryBuilder = requestDictionaryBuilder;
        self.client = client;
    }
    return self;
}

- (KSPromise *)fetchTimesheetInfoForTimsheetUri:(NSString*)timesheetUri userUri:(NSString*)userUri
{
    KSDeferred *deferred = [[KSDeferred alloc] init];
    NSDictionary *requestDictionary = [self.requestDictionaryBuilder requestDictionaryWithEndpointName:@"TimelineExtras"
                                                                                    httpBodyDictionary:@{@"timesheetUri": timesheetUri}];
    
    NSURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:requestDictionary];
    KSPromise *jsonPromise = [self.client promiseWithRequest:request];
    [jsonPromise then:^id(NSDictionary *jsonDictionary) {
        TimesheetAdditionalInfo  *timesheetAdditionalInfo = [self.timesheetInfoAndExtrasDeserializer deserialize:jsonDictionary];
        NSNumber *hasClientsAvailableForTimeAllocation =jsonDictionary[@"permittedActions"][@"hasClientsAvailableForTimeAllocation"];
        [self.astroClientPermissionStorage setUpWithUserUri:userUri];
        [self.astroClientPermissionStorage persistUserHasClientPermission:hasClientsAvailableForTimeAllocation];
        [deferred resolveWithValue:timesheetAdditionalInfo];
        return nil;
    } error:^id(NSError *error) {
        [deferred rejectWithError:error];
        return nil;
    }];
    
    return deferred.promise;
}

@end
