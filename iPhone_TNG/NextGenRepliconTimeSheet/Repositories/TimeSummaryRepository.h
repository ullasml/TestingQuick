#import <Foundation/Foundation.h>
#import "GUIDProvider.h"
#import "TimeSummaryDeserializer.h"
#import "TimesheetRepository.h"
#import "RequestDictionaryBuilder.h"
#import "TimeSummaryFetcher.h"
#import "AstroClientPermissionStorage.h"

@class KSPromise;
@class DateProvider;
@protocol RequestPromiseClient;


@interface TimeSummaryRepository : NSObject <TimeSummaryFetcher>

@property (nonatomic, readonly) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic, readonly) TimeSummaryDeserializer *timeSummaryDeserializer;
@property (nonatomic, readonly) TimesheetRepository *timesheetRepository;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, readonly) id<RequestPromiseClient> client;
@property (nonatomic, readonly) AstroClientPermissionStorage *astroClientPermissionStorage;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRequestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder astroClientPermissionStorage:(AstroClientPermissionStorage *)astroClientPermissionStorage timeSummaryDeserializer:(TimeSummaryDeserializer *)timeSummaryDeserializer timesheetRepository:(TimesheetRepository *)timesheetRepository dateProvider:(DateProvider *)dateProvider userDefaults:(NSUserDefaults *)userDefaults client:(id <RequestPromiseClient>)client dateFormatter:(NSDateFormatter *)dateFormatter;
-(void)setUpWithUserUri:(NSString*)userUri;
@end
