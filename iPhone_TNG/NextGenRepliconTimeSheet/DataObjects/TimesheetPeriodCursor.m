#import "TimesheetPeriodCursor.h"
#import "TimesheetPeriod.h"


@interface TimesheetPeriodCursor ()

@property (nonatomic) TimesheetPeriod *previousPeriod;
@property (nonatomic) TimesheetPeriod *currentPeriod;
@property (nonatomic) TimesheetPeriod *nextPeriod;

@end


@implementation TimesheetPeriodCursor

- (instancetype)initWithCurrentPeriod:(TimesheetPeriod *)currentPeriod
                       previousPeriod:(TimesheetPeriod *)previousPeriod
                            nextPeriod:(TimesheetPeriod *)nextPeriod

{
    self = [super init];
    if (self)
    {
        self.previousPeriod = previousPeriod;
        self.nextPeriod = nextPeriod;
        self.currentPeriod = currentPeriod;
    }
    return self;
}

- (BOOL)canMoveForwards
{
    return (self.nextPeriod != nil && self.nextPeriod != (id)[NSNull null]);
}

- (BOOL)canMoveBackwards
{
    return (self.previousPeriod != nil && self.previousPeriod != (id)[NSNull null]);
}

@end
