#import <Foundation/Foundation.h>



@class SupervisorDashboardSummary;
@class OvertimeUserDeserializer;
@class PunchUserDeserializer;
@protocol BadgesDelegate;

@interface SupervisorDashboardSummaryDeserializer : NSObject

@property (nonatomic, readonly) NSUserDefaults *userdefaults;
@property (nonatomic, readonly) PunchUserDeserializer *punchUserDeserializer;
@property (nonatomic, readonly, weak) id<BadgesDelegate> badgesDelegate;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchUserDeserializer:(PunchUserDeserializer *)punchUserDeserializer userdefaults:(NSUserDefaults *)userdefaults badgesDelegate:(id<BadgesDelegate>)badgesDelegate notificationCenter:(NSNotificationCenter *)notificationCenter;
- (SupervisorDashboardSummary *)deserialize:(NSDictionary *)summaryDictionary;

@end
