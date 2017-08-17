#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimesheetDurationSpec)

describe(@"TimesheetDuration", ^{
    __block TimesheetDuration *durationA;
    __block TimesheetDuration *durationB;


    describe(@"equality", ^{
        
        context(@"when the two objects are not the same type", ^{
            
            it(@"should not be equal", ^{
                durationA = [[TimesheetDuration alloc]initWithRegularHours:nil
                                                                breakHours:nil
                                                              timeOffHours:nil];
                durationB = (TimesheetDuration *)@"asdf";
                durationA should_not equal(durationB);
            });
        });
        
        context(@"when all the properties are nil", ^{
            
            it(@"should be equal", ^{
                durationA = [[TimesheetDuration alloc]initWithRegularHours:nil
                                                               breakHours:nil
                                                             timeOffHours:nil];
                durationB = [[TimesheetDuration alloc]initWithRegularHours:nil
                                                               breakHours:nil
                                                             timeOffHours:nil];
                durationA should equal(durationB);
            });
        });
        
        context(@"workBreakAndTimeoffDuration", ^{
            
            it(@"should not be equal", ^{
                
                NSDateComponents *regularHoursA = [[NSDateComponents alloc]init];
                regularHoursA.hour = 1;
                regularHoursA.minute = 2;
                regularHoursA.second = 3;
                
                NSDateComponents *breakHoursA = [[NSDateComponents alloc]init];
                breakHoursA.hour = 1;
                breakHoursA.minute = 2;
                breakHoursA.second = 3;
                
                NSDateComponents *timeoffHoursA = [[NSDateComponents alloc]init];
                timeoffHoursA.hour = 1;
                timeoffHoursA.minute = 2;
                timeoffHoursA.second = 3;
                
                
                NSDateComponents *regularHoursB = [[NSDateComponents alloc]init];
                regularHoursB.hour = 1;
                regularHoursB.minute = 2;
                regularHoursB.second = 3;
                
                NSDateComponents *breakHoursB = [[NSDateComponents alloc]init];
                breakHoursB.hour = 4;
                breakHoursB.minute = 2;
                breakHoursB.second = 5;
                
                NSDateComponents *timeoffHoursB = [[NSDateComponents alloc]init];
                timeoffHoursB.hour = 11;
                timeoffHoursB.minute = 22;
                timeoffHoursB.second = 33;
                
                
                
                durationA = [[TimesheetDuration alloc]initWithRegularHours:regularHoursA 
                                                                                   breakHours:breakHoursA 
                                                                                 timeOffHours:timeoffHoursA];
                
                
                durationB = [[TimesheetDuration alloc]initWithRegularHours:regularHoursB 
                                                                                   breakHours:breakHoursB 
                                                                                 timeOffHours:timeoffHoursB];
                durationA should_not equal(durationB);
            });
            
            it(@"should be equal", ^{
                
                NSDateComponents *regularHoursA = [[NSDateComponents alloc]init];
                regularHoursA.hour = 1;
                regularHoursA.minute = 2;
                regularHoursA.second = 3;
                
                NSDateComponents *breakHoursA = [[NSDateComponents alloc]init];
                breakHoursA.hour = 1;
                breakHoursA.minute = 2;
                breakHoursA.second = 3;
                
                NSDateComponents *timeoffHoursA = [[NSDateComponents alloc]init];
                timeoffHoursA.hour = 1;
                timeoffHoursA.minute = 2;
                timeoffHoursA.second = 3;
                
                
                NSDateComponents *regularHoursB = [[NSDateComponents alloc]init];
                regularHoursB.hour = 1;
                regularHoursB.minute = 2;
                regularHoursB.second = 3;
                
                NSDateComponents *breakHoursB = [[NSDateComponents alloc]init];
                breakHoursB.hour = 1;
                breakHoursB.minute = 2;
                breakHoursB.second = 3;
                
                NSDateComponents *timeoffHoursB = [[NSDateComponents alloc]init];
                timeoffHoursB.hour = 1;
                timeoffHoursB.minute = 2;
                timeoffHoursB.second = 3;
                
                
                TimesheetDuration *durationA = [[TimesheetDuration alloc]initWithRegularHours:regularHoursA 
                                                                                   breakHours:breakHoursA 
                                                                                 timeOffHours:timeoffHoursA];
                
                
                TimesheetDuration *durationB = [[TimesheetDuration alloc]initWithRegularHours:regularHoursB 
                                                                                   breakHours:breakHoursB 
                                                                                 timeOffHours:timeoffHoursB];
                durationA should equal(durationB);
            });
            
        });
        
    });
});

SPEC_END
