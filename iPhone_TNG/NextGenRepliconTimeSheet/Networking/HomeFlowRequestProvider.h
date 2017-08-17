
#import <Foundation/Foundation.h>

@class URLStringProvider;


@interface HomeFlowRequestProvider : NSObject

@property (nonatomic, readonly) URLStringProvider *urlStringProvider;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider;

- (NSURLRequest *)requestForHomeFlowService;


@end
