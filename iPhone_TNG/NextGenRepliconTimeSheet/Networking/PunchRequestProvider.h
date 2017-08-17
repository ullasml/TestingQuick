#import <Foundation/Foundation.h>


@protocol Punch;
@class LocalPunch;
@class RemotePunch;
@class GUIDProvider;
@class PunchRequestBodyProvider;
@class URLStringProvider;
@class DateProvider;


@interface PunchRequestProvider : NSObject

@property (nonatomic, readonly) URLStringProvider *urlStringProvider;
@property (nonatomic, readonly) PunchRequestBodyProvider *punchRequestBodyProvider;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchRequestBodyProvider:(PunchRequestBodyProvider *)punchRequestBodyProvider urlStringProvider:(URLStringProvider *)urlStringProvider dateProvider:(DateProvider *)dateProvider dateFormatter:(NSDateFormatter *)dateFormatter;

- (NSURLRequest *)punchRequestWithPunch:(NSArray *)punchesArray;

- (NSURLRequest *)mostRecentPunchRequestForUserUri:(NSString *)userUri;

- (NSURLRequest *)requestForPunchesWithDate:(NSDate *)date userURI:(NSString *)userURI;

- (NSURLRequest *)deletePunchRequestWithPunchUri:(NSString *)punchUri;

- (NSURLRequest *)requestToUpdatePunch:(NSArray *)remotePunchesArray;

- (NSURLRequest *)requestToRecalculateScriptDataForuser:(NSString *)userURI withDateDict:(NSDictionary *)dateDict;

- (NSURLRequest *)requestForPunchesWithLastTwoMostRecentPunchWithDate:(NSDate *)date;

@end
