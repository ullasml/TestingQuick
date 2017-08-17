#import <Foundation/Foundation.h>
#import "RequestPromiseClient.h"
#import "DoorKeeper.h"


@class KSPromise;


@interface URLSessionClient : NSObject <RequestPromiseClient, DoorKeeperLogOutObserver>

@property (nonatomic, readonly) NSURLSession *session;
@property (nonatomic, readonly) DoorKeeper   *doorKeeper;
@property (nonatomic, readonly) NSUserDefaults *defaults;
@property (nonatomic, readonly) BOOL         isInvalidateSession;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLSession:(NSURLSession *)session doorKeeper:(DoorKeeper *)doorKeeper userDefaults:(NSUserDefaults *)defaults dateFormatter:(NSDateFormatter *)dateFormatter NS_DESIGNATED_INITIALIZER;

@end
