

#import <Foundation/Foundation.h>
@protocol Timesheet;
@class GUIDProvider;

@interface TimesheetActionRequestBodyProvider : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithGuidProvider:(GUIDProvider *)guidProvider NS_DESIGNATED_INITIALIZER;

- (NSDictionary *)requestBodyDictionaryWithComment:(NSString *)comment timesheet:(id <Timesheet>)timesheet;

@end
