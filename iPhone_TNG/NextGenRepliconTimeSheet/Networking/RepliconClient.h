#import <Foundation/Foundation.h>
#import "RequestPromiseClient.h"
#import "ApplicationFlowControl.h"

@class ServerErrorSerializer;
@class HttpErrorSerializer;
@class ErrorReporter;
@class ErrorPresenter;

@interface RepliconClient : NSObject <RequestPromiseClient>

@property (nonatomic, readonly) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic, readonly) ServerErrorSerializer *serverErrorSerializer;
@property (nonatomic, readonly) HttpErrorSerializer *httpErrorSerializer;
@property (nonatomic, readonly) ErrorReporter *errorReporter;
@property (nonatomic, readonly) ApplicationFlowControl *flowControl;
@property (nonatomic, readonly) ErrorPresenter *errorPresenter;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithClient:(id<RequestPromiseClient>)requestPromiseClient
         serverErrorSerializer:(ServerErrorSerializer *)serverErrorSerializer
           httpErrorSerializer:(HttpErrorSerializer *)httpErrorSerializer
                   flowControl:(ApplicationFlowControl *)flowControl
                errorPresenter:(ErrorPresenter *)errorPresenter
                 errorReporter:(ErrorReporter *)errorReporter NS_DESIGNATED_INITIALIZER;

@end
