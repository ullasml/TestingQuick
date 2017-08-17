#import <Foundation/Foundation.h>


@class URLStringProvider;


@interface ViolationRequestProvider : NSObject

@property (nonatomic, readonly) URLStringProvider *urlStringProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider;

- (NSURLRequest *)provideRequestWithDate:(NSDate *)date;

- (NSURLRequest *)provideRequestWithPunchURI:(NSString *)punchURI;

@end
