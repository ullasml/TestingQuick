#import <Foundation/Foundation.h>
#import "Cursor.h"


@class TimesheetPeriod;


@interface TimesheetPeriodCursor : NSObject<Cursor>

@property (nonatomic, readonly) TimesheetPeriod *previousPeriod;
@property (nonatomic, readonly) TimesheetPeriod *currentPeriod;
@property (nonatomic, readonly) TimesheetPeriod *nextPeriod;


+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithCurrentPeriod:(TimesheetPeriod *)currentPeriod
                       previousPeriod:(TimesheetPeriod *)previousPeriod
                           nextPeriod:(TimesheetPeriod *)nextPeriod NS_DESIGNATED_INITIALIZER;

- (BOOL)canMoveForwards;
- (BOOL)canMoveBackwards;

@end
