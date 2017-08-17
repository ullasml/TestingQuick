#import <Foundation/Foundation.h>


@class KSPromise;
@class TeamStatusSummaryDeserializer;
@class RequestDictionaryBuilder;
@class DateProvider;
@class RepliconClient;

@interface TeamStatusSummaryRepository : NSObject

@property (nonatomic, readonly) TeamStatusSummaryDeserializer *teamStatusSummaryDeserializer;
@property (nonatomic, readonly) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) RepliconClient *client;
@property (nonatomic, readonly) NSCalendar *calendar;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithJSONClientTeamStatusSummaryDeserializer:(TeamStatusSummaryDeserializer *)deserializer
                                       requestDictionaryBuilder:(RequestDictionaryBuilder *)builder
                                                   dateProvider:(DateProvider *)provider
                                                         client:(RepliconClient *)client
                                                       calendar:(NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

-(KSPromise *)fetchTeamStatusSummary;

@end
