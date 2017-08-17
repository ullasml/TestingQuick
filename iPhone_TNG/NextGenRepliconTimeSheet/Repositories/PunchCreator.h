#import <Foundation/Foundation.h>


@class PunchRequestProvider;
@class PunchOutboxStorage;
@class LocalPunch;
@class KSPromise;
@protocol RequestPromiseClient;
@class PunchNotificationScheduler;
@class TimeLinePunchesStorage;
@class FailedPunchStorage;
@protocol Punch;
@class FailedPunchErrorStorage;
@class PunchErrorPresenter;
@class DateProvider;
@class InvalidProjectAndTakDetector;

@interface PunchCreator : NSObject

@property (nonatomic, readonly) PunchRequestProvider *punchRequestProvider;
@property (nonatomic, readonly) FailedPunchStorage *failedPunchStorage;
@property (nonatomic, readonly) PunchOutboxStorage *punchOutboxStorage;
@property (nonatomic, readonly) FailedPunchErrorStorage *failedPunchErrorStorage;
@property (nonatomic, readonly) TimeLinePunchesStorage *timeLinePunchesStorage;
@property (nonatomic, readonly) id<RequestPromiseClient> client;
@property (nonatomic, readonly) PunchNotificationScheduler *punchNotificationScheduler;
@property (nonatomic, readonly) UIApplication *application;
@property (nonatomic, readonly) PunchErrorPresenter *punchErrorPresenter;
@property (nonatomic, readonly) NSUserDefaults *defaults;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) InvalidProjectAndTakDetector *invalidProjectAndTakDetector;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithInvalidProjectAndTakDetector:(InvalidProjectAndTakDetector *)invalidProjectAndTakDetector
                          punchNotificationScheduler:(PunchNotificationScheduler *)punchNotificationScheduler
                             failedPunchErrorStorage:(FailedPunchErrorStorage *)failedPunchErrorStorage
                              timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
                                punchRequestProvider:(PunchRequestProvider *)punchRequestProvider
                                 punchErrorPresenter:(PunchErrorPresenter *)punchErrorPresenter
                                  punchOutboxStorage:(PunchOutboxStorage *)punchOutboxStorage
                                  failedPunchStorage:(FailedPunchStorage *)failedPunchStorage
                                         application:(UIApplication *)application
                                              client:(id <RequestPromiseClient>)client
                                            defaults:(NSUserDefaults *)defaults
                                        dateProvider:(DateProvider *)dateProvider
                                       dateFormatter:(NSDateFormatter *)dateFormatter;

- (KSPromise *)creationPromiseForPunch:(NSArray *)punchesArray;

@end
