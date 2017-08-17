#import <Foundation/Foundation.h>


@class KSPromise;
@class RequestDictionaryBuilder;
@class SingleTimesheetDeserializer;
@class TimesheetRequestBodyProvider;
@protocol RequestPromiseClient;
@class TimesheetInfoAndExtrasDeserializer;
@class AstroClientPermissionStorage;


@interface TimesheetInfoAndPermissionsRepository : NSObject

@property (nonatomic, readonly) TimesheetInfoAndExtrasDeserializer *timesheetInfoAndExtrasDeserializer;
@property (nonatomic, readonly) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic, readonly) AstroClientPermissionStorage *astroClientPermissionStorage;
@property (nonatomic, readonly) id<RequestPromiseClient> client;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithTimesheetInfoAndExtrasDeserializer:(TimesheetInfoAndExtrasDeserializer *)timesheetInfoAndExtrasDeserializer
                              astroClientPermissionStorage:(AstroClientPermissionStorage *)astroClientPermissionStorage
                                  requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                                                    client:(id <RequestPromiseClient>)client NS_DESIGNATED_INITIALIZER;

- (KSPromise *)fetchTimesheetInfoForTimsheetUri:(NSString*)timesheetUri userUri:(NSString*)userUri;

@end
