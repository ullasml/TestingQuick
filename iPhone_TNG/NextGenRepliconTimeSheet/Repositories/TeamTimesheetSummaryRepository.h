#import <Foundation/Foundation.h>


@class TeamTimesheetSummaryDeserializer;
@class RequestDictionaryBuilder;
@class TimesheetPeriod;
@class RepliconClient;
@class KSPromise;


@interface TeamTimesheetSummaryRepository : NSObject

@property (nonatomic, readonly) TeamTimesheetSummaryDeserializer *teamTimesheetSummaryDeserializer;
@property (nonatomic, readonly) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic, readonly) RepliconClient *client;
@property (nonatomic, readonly) NSCalendar *calendar;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTeamTimesheetSummaryDeserializer:(TeamTimesheetSummaryDeserializer *)teamTimesheetSummaryDeserializer
                                requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                                                  client:(RepliconClient *)client
                                                calendar:(NSCalendar *)calendar;

- (KSPromise *)fetchTeamTimesheetSummaryWithTimesheetPeriod:(TimesheetPeriod *)timesheetPeriod;


@end
