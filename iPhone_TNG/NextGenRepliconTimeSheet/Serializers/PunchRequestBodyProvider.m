#import "PunchRequestBodyProvider.h"
#import "Punch.h"
#import "GUIDProvider.h"
#import "Constants.h"
#import "BreakType.h"
#import "PunchSerializer.h"
#import "Util.h"
#import "RemotePunch.h"
#import "PunchClock.h"
#import "UserSession.h"


@interface PunchRequestBodyProvider ()

@property (nonatomic) PunchSerializer *punchSerializer;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) GUIDProvider *guidProvider;
@property (nonatomic) NSString *guid;

@end


@implementation PunchRequestBodyProvider

- (instancetype)initWithPunchSerializer:(PunchSerializer *)punchSerializer
                           guidProvider:(GUIDProvider *)guidProvider
                            userSession:(id<UserSession>)userSession
{
    self = [super init];
    if (self)
    {
        self.punchSerializer = punchSerializer;
        self.guidProvider = guidProvider;
        self.userSession = userSession;
        self.guid = @"";
    }
    return self;
}

- (NSDictionary *)requestBodyForPunch:(NSArray *)punchesArray
{
    NSMutableArray *timePunchDictionaries = [@[]mutableCopy];

    for (id<Punch>punch in punchesArray)
    {
        [timePunchDictionaries addObject:[self.punchSerializer timePunchDictionaryForPunch:punch]];
    }

    self.guid = (self.guidProvider != nil && self.guidProvider) ? [self.guidProvider guid] : [Util getRandomGUID];

    return @{
            @"unitOfWorkId" : self.guid,
            @"punchWithCreatedAtTimeBulkParameters" : timePunchDictionaries
    };
}

- (NSDictionary *)requestBodyForPunchesWithDate:(NSDate *)date userURI:(NSString *)userURI
{
    NSDate *startDate = [date dateByAddingDays:-1];
    NSDate *endDate = [date dateByAddingDays:1];

    NSDictionary *startDateDict = [Util convertDateToApiDateDictionaryOnLocalTimeZone:startDate];
    NSDictionary *endDateDict = [Util convertDateToApiDateDictionaryOnLocalTimeZone:endDate];
    return @{
                           @"user" : @{@"uri": userURI ? userURI:[NSNull null]},
                           @"dateRange" : @{
                                   @"startDate" : startDateDict,
                                   @"endDate" : endDateDict
                                   }
                           };
}

- (NSDictionary *)requestBodyForPunchesWithLastTwoMostRecentPunchWithDate:(NSDate *)date
{
    NSDictionary *dateDict = [Util convertDateToApiDateDictionaryOnLocalTimeZone:date];
    return @{
                     @"date" : dateDict,
                     @"checkIsTimeEntryAvailable" : @"urn:replicon:check-punch-time-entry-available:penultimate-only"
                     };
}

- (NSDictionary *)requestBodyForMostRecentPunchForUserUri:(NSString *)userUri
{
    if (userUri)
    {
        return @{@"user" : @{@"uri": userUri}};
    }
    else
    {
        return @{@"user" : @{@"uri": self.userSession.currentUserURI}};
    }

}

- (NSDictionary *)requestBodyToDeletePunchWithURI:(NSString *)uri
{
    return @{
            @"timePunchUris" : @[uri]
    };
}

- (NSDictionary *)requestBodyToUpdatePunch:(NSArray *)remotePunchesArray
{

    NSMutableArray *timePunchDictionaries = [@[]mutableCopy];

    for (RemotePunch *punch in remotePunchesArray)
    {
        NSDictionary *punchDictionary = [self.punchSerializer timePunchDictionaryForPunch:punch];

        NSMutableDictionary *timePunchDictionary = [punchDictionary[@"timePunch"] mutableCopy];
        timePunchDictionary[@"target"] = @{@"uri": punch.uri, @"parameterCorrelationId": punch.requestID};

        NSMutableDictionary *mutablePunchDictionary = [punchDictionary mutableCopy];
        mutablePunchDictionary[@"timePunch"] = timePunchDictionary;

        [timePunchDictionaries addObject:mutablePunchDictionary];
    }



    return @{
             @"putTimePunchParameters": timePunchDictionaries,
             @"unitOfWorkId": [self.guidProvider guid]
             };
}

- (NSDictionary *)requestBodyToRecalculateScriptDataForUserURI:(NSString *)userURI withDateDict:(NSDictionary *)dateDict
{

    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     userURI,@"uri",
                                     [NSNull null],@"loginName",
                                     [NSNull null],@"parameterCorrelationId",nil];

    NSMutableDictionary *containerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          [NSNull null],@"uri",
                                          userDict,@"user",
                                          dateDict,@"date",nil];

    NSMutableDictionary *requestBodyDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      containerDict,@"timesheet",nil];

    return requestBodyDict;
}




@end
