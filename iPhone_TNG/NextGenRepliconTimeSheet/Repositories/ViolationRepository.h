#import <Foundation/Foundation.h>


@class KSPromise;
@class DateProvider;
@class ViolationRequestProvider;
@class ViolationsDeserializer;
@class ViolationsForTimesheetPeriodDeserializer;
@class ViolationsForPunchDeserializer;

@protocol RequestPromiseClient;


@interface ViolationRepository : NSObject

@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) ViolationRequestProvider *violationRequestProvider;
@property (nonatomic, readonly) ViolationsDeserializer *violationsDeserializer;
@property (nonatomic, readonly) ViolationsForPunchDeserializer *violationsForPunchDeserializer;
@property (nonatomic, readonly) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic, readonly) ViolationsForTimesheetPeriodDeserializer *violationsForTimesheetPeriodDeserializer;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithViolationsForTimesheetPeriodDeserializer:(ViolationsForTimesheetPeriodDeserializer *)violationsForTimesheetPeriodDeserializer
                                  violationsForPunchDeserializer:(ViolationsForPunchDeserializer *)violationsForPunchDeserializer
                                        violationRequestProvider:(ViolationRequestProvider *)violationRequestProvider
                                          violationsDeserializer:(ViolationsDeserializer *)violationsDeserializer
                                            requestPromiseClient:(id<RequestPromiseClient>)requestPromiseClient
                                                    dateProvider:(DateProvider *)dateProvider;

- (KSPromise *)fetchAllViolationSectionsForToday;
- (KSPromise *)fetchValidationsForPunchURI:(NSString *)punchURI;

@end
