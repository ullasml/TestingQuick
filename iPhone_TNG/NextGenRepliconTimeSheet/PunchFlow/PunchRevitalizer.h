#import <Foundation/Foundation.h>


@class PunchCreator;
@class PunchNotificationScheduler;
@class PunchOutboxStorage;
@class PunchRepository;
@protocol UserSession;

@interface PunchRevitalizer : NSObject

@property (nonatomic, readonly) PunchNotificationScheduler *punchNotificationScheduler;
@property (nonatomic, readonly) PunchOutboxStorage *punchOutboxStorage;
@property (nonatomic, readonly) PunchRepository *punchRepository;
@property (nonatomic,readonly) id <UserSession> userSession;
@property (nonatomic, readonly) PunchCreator *punchCreator;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithPunchNotificationScheduler:(PunchNotificationScheduler *)punchNotificationScheduler
                                punchOutboxStorage:(PunchOutboxStorage *)punchOutboxStorage
                                   punchRepository:(PunchRepository *)punchRepository
                                       userSession:(id <UserSession>)userSession
                                      punchCreator:(PunchCreator *)punchCreator;

- (void)revitalizePunches;

@end
