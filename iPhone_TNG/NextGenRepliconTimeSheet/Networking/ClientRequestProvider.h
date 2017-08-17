
#import <Foundation/Foundation.h>
@class URLStringProvider;
@class DateProvider;

@interface ClientRequestProvider : NSObject

@property (nonatomic,readonly) URLStringProvider *urlStringProvider;
@property (nonatomic,readonly) DateProvider *dateProvider;
@property (nonatomic,readonly) NSCalendar *calendar;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
                             dateProvider:(DateProvider *)dateProvider
                                 calendar:(NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

- (NSURLRequest *)requestForClientsForUserWithURI:(NSString *)userUri
                                       searchText:(NSString *)text
                                             page:(NSNumber *)page;
@end
