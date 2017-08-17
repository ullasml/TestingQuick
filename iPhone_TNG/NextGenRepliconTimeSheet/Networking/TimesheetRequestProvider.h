#import <Foundation/Foundation.h>


@class URLStringProvider;


@interface TimesheetRequestProvider : NSObject

@property (nonatomic, readonly) URLStringProvider *urlStringProvider;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
                            dateFormatter:(NSDateFormatter *)dateFormatter NS_DESIGNATED_INITIALIZER;

- (NSURLRequest *)requestForTimesheetWithURI:(NSString *)timesheetUri;

- (NSURLRequest *)requestForFetchingTimesheetWidgetsForDate:(NSDate *)date;

- (NSURLRequest *)requestForFetchingTimesheetWidgetsForTimesheetUri:(NSString *)timesheetUri;

- (NSURLRequest *)requestForTimesheetPoliciesWithURI:(NSString *)timesheetUri;
@end
