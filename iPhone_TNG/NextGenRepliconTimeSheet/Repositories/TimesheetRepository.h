#import <Foundation/Foundation.h>


@class KSPromise;
@class DateProvider;
@class TimesheetDeserializer;
@class RequestDictionaryBuilder;
@class TimesheetRequestProvider;
@class SingleTimesheetDeserializer;
@class TimesheetRequestBodyProvider;
@class TimesheetInfoDeserializer;
@protocol RequestPromiseClient;
@class ReporteePermissionsStorage;
@class UserUriDetector;
@class AstroUserDetector;
@class WidgetTimesheetCapabilitiesDeserializer;
@class WidgetPlatformDetector;



@interface TimesheetRepository : NSObject

@property (nonatomic, readonly) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic, readonly) TimesheetRequestProvider *timesheetRequestProvider;
@property (nonatomic, readonly) TimesheetInfoDeserializer *timesheetInfoDeserializer;
@property (nonatomic, readonly) TimesheetDeserializer *timesheetDeserializer;
@property (nonatomic, readonly) TimesheetRequestBodyProvider *timesheetRequestBodyProvider;
@property (nonatomic, readonly) SingleTimesheetDeserializer *singleTimesheetDeserializer;
@property (nonatomic, readonly) ReporteePermissionsStorage *reporteePermissionsStorage;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, readonly) id<RequestPromiseClient> client;
@property (nonatomic, readonly) UserUriDetector *userUriDetector;
@property (nonatomic, readonly) WidgetTimesheetCapabilitiesDeserializer *capabilitiesDeserializer;
@property (nonatomic, readonly) WidgetPlatformDetector *widgetPlatformDetector;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


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
                                          client:(id <RequestPromiseClient>)client NS_DESIGNATED_INITIALIZER;

- (KSPromise *)fetchTimesheetWithURI:(NSString *)timesheetUri;
- (KSPromise *)fetchMostRecentTimesheet;
- (KSPromise *)fetchTimesheetWithOffset:(NSUInteger)offset;
- (KSPromise *)fetchTimesheetInfoForDate:(NSDate*)date;
- (KSPromise *)fetchTimesheetInfoForTimsheetUri:(NSString*)timesheetUri;
- (KSPromise *)fetchTimesheetCapabilitiesWithURI:(NSString *)timesheetUri;
@end
