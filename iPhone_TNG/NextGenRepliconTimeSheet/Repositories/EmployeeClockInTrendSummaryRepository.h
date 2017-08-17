#import <Foundation/Foundation.h>


@class KSPromise;
@class RequestDictionaryBuilder;
@class EmployeeClockInTrendSummaryDeserializer;
@protocol RequestPromiseClient;
@class DateProvider;


@interface EmployeeClockInTrendSummaryRepository : NSObject

@property (nonatomic, readonly) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic, readonly) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic, readonly) EmployeeClockInTrendSummaryDeserializer *employeeClockInTrendSummaryDeserializer;
@property(nonatomic, readonly) NSCalendar *calendar;
@property(nonatomic, readonly) DateProvider *dateProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithEmployeeClockInTrendSummaryDeserializer:(EmployeeClockInTrendSummaryDeserializer *)employeeClockInTrendSummaryDeserializer
                                           requestPromiseClient:(id <RequestPromiseClient>)requestPromiseClient requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                                                   dateProvider:(DateProvider *)dateProvider
                                                       calendar:(NSCalendar *)calendar;


- (KSPromise *)fetchEmployeeClockInTrendSummary;

@end
