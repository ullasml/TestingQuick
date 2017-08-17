#import <Foundation/Foundation.h>


@class Waiver;
@class WaiverOption;
@class URLStringProvider;


@interface UpdateWaiverRequestProvider : NSObject

@property (nonatomic, readonly) URLStringProvider *urlStringProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider;

- (NSURLRequest *)provideRequestWithWaiver:(Waiver *)waiver waiverOption:(WaiverOption *)waiverOption;

@end
