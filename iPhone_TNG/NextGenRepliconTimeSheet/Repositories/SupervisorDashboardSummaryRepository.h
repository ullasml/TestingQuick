#import <Foundation/Foundation.h>

@class KSPromise;
@class RequestDictionaryBuilder;
@class SupervisorDashboardSummaryDeserializer;
@class DateProvider;
@protocol RequestPromiseClient;


@interface SupervisorDashboardSummaryRepository : NSObject

@property (nonatomic, readonly) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic, readonly) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic, readonly) SupervisorDashboardSummaryDeserializer *dashboardSummaryDeserializer;
@property (nonatomic, readonly) DateProvider *dateProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRequestPromiseClient:(id<RequestPromiseClient>)requestPromiseClient
                    requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                dashboardSummaryDeserializer:(SupervisorDashboardSummaryDeserializer *)deserializer
                                dateProvider:(DateProvider *)dateProvider;

- (KSPromise *)fetchMostRecentDashboardSummary;

@end
