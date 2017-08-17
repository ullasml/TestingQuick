
#import <Foundation/Foundation.h>

@class AppDelegate;
@class URLStringProvider;

@interface ServerErrorSerializer : NSObject

@property (nonatomic,readonly) AppDelegate *appDelegate;
@property (nonatomic,readonly) URLStringProvider *urlStringProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithAppdelegateUrlStringProvider:(URLStringProvider *)urlStringProvider
                                         appDelegate:(AppDelegate *)appDelegate;

-(NSError *)deserialize:(NSDictionary *)jsonDictionary isFromRequestMadeWhilePendingQueueSync:(BOOL)isFromRequestMadeWhilePendingQueueSync request:(NSURLRequest *)request;

@end
