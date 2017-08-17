#import <Cedar/Cedar.h>
#import "TimesheetPeriodCursor.h"
#import "TimesheetPeriod.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetPeriodCursorSpec)

describe(@"TimesheetPeriodCursor", ^{
    it(@"should be able to move forward if there is a next period", ^{
        TimesheetPeriodCursor *cursor = [[TimesheetPeriodCursor alloc] initWithCurrentPeriod:fake_for([TimesheetPeriod class])
                                                                              previousPeriod:nil
                                                                                  nextPeriod:fake_for([TimesheetPeriod class])];
        [cursor canMoveForwards] should be_truthy;
        [cursor canMoveBackwards] should be_falsy;
    });

    it(@"should be able to move backwards if there is a previous period", ^{
        TimesheetPeriodCursor *cursor = [[TimesheetPeriodCursor alloc] initWithCurrentPeriod:fake_for([TimesheetPeriod class])
                                                                              previousPeriod:fake_for([TimesheetPeriod class])
                                                                                  nextPeriod:nil];
        [cursor canMoveForwards] should be_falsy;
        [cursor canMoveBackwards] should be_truthy;
    });
    
    it(@"should correctly set its properties", ^{
        TimesheetPeriod *nextPeriod = fake_for([TimesheetPeriod class]);
        TimesheetPeriod *currentPeriod = fake_for([TimesheetPeriod class]);
        TimesheetPeriod *previousPeriod = fake_for([TimesheetPeriod class]);
        
        
        TimesheetPeriodCursor *cursor = [[TimesheetPeriodCursor alloc] initWithCurrentPeriod:currentPeriod
                                                                              previousPeriod:previousPeriod
                                                                                  nextPeriod:nextPeriod];
        cursor.currentPeriod should be_same_instance_as(currentPeriod);
        cursor.previousPeriod should be_same_instance_as(previousPeriod);
        cursor.nextPeriod should be_same_instance_as(nextPeriod);
        
    });
});

SPEC_END
