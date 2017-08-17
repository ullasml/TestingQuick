#import <Foundation/Foundation.h>


@class URLStringProvider;


@interface PunchLogRequestProvider : NSObject

@property (nonatomic, readonly) URLStringProvider *urlStringProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider;

- (NSURLRequest *)requestWithPunchURI:(NSString *)punchURI;

@end
