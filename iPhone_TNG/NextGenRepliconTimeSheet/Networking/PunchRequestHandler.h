#import <Foundation/Foundation.h>
#import "URLSessionListener.h"


@class PunchOutboxStorage;
@class FailedPunchStorage;
@class PunchNotificationScheduler;


@interface PunchRequestHandler : NSObject <URLSessionListenerObserver>

@property (nonatomic, readonly) PunchNotificationScheduler *punchNotificationScheduler;
@property (nonatomic, readonly) FailedPunchStorage *failedPunchStorage;
@property (nonatomic, readonly) PunchOutboxStorage *punchOutboxStorage;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithPunchNotificationScheduler:(PunchNotificationScheduler *)punchNotificationScheduler
                                failedPunchStorage:(FailedPunchStorage *)failedPunchStorage
                                punchOutboxStorage:(PunchOutboxStorage *)punchOutboxStorage
                                urlSessionListener:(URLSessionListener *)urlSessionListener;

@end
