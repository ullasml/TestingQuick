
#import <Foundation/Foundation.h>
#import "DoorKeeper.h"

@protocol WorkHours;
@protocol UserSession;
@class DoorKeeper;
@class DateProvider;
@class DurationCalculator;

@interface WorkHoursStorage : NSObject <DoorKeeperLogOutObserver>

@property (nonatomic,readonly) NSFileManager *fileManager;
@property (nonatomic,readonly) DoorKeeper *doorKeeper;
@property (nonatomic,readonly) DateProvider *dateProvider;
@property (nonatomic,readonly) DurationCalculator *durationCalculator;
@property (nonatomic,readonly) id<UserSession> userSession;

@property (nonatomic,readonly,copy) NSString *summaryHoursFilename;
@property (nonatomic,readonly,copy) NSString *summaryDateFilename;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDurationCalculator:(DurationCalculator *)durationCalculator
                               fileManager:(NSFileManager *)fileManager
                              dateProvider:(DateProvider *)dateProvider
                                doorKeeper:(DoorKeeper *)doorKeeper
                               userSession:(id<UserSession>)userSession NS_DESIGNATED_INITIALIZER;

- (void)setupWithSummaryFilename:(NSString *)summaryFilename dateFileName:(NSString *)dateFileName;

- (void)saveWorkHoursSummary:(id <WorkHours>)workHours;

- (id <WorkHours>)getWorkHoursSummary;

- (id <WorkHours>)getCombinedWorkHoursSummary;


@end
