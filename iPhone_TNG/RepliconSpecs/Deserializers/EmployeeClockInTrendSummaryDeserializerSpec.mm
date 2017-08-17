#import <Cedar/Cedar.h>
#import "EmployeeClockInTrendSummaryDeserializer.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "EmployeeClockInTrendSummary.h"
#import "EmployeeClockInTrendSummaryDataPoint.h"
#import "RepliconSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(EmployeeClockInTrendSummaryDeserializerSpec)

describe(@"EmployeeClockInTrendSummaryDeserializer", ^{
    __block EmployeeClockInTrendSummaryDeserializer *subject;
    __block id <BSInjector> injector;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        subject = [injector getInstance:[EmployeeClockInTrendSummaryDeserializer class]];
    });
    
    
    describe(@"-deserialize:samplingIntervalSeconds", ^{
        __block EmployeeClockInTrendSummary *employeeClockInTrendSummary;
        
        context(@"When Json Response is not null", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary = [RepliconSpecHelper jsonWithFixture:@"employee_clock_in_trend_summary"];
                
                employeeClockInTrendSummary = [subject deserialize:jsonDictionary samplingIntervalSeconds:1234];
            });
            
            it(@"should return the correctly configured EmployeeClockInTrendSummary", ^{
                employeeClockInTrendSummary should be_instance_of([EmployeeClockInTrendSummary class]);
            });
            
            it(@"should set the sampling interval seconds", ^{
                employeeClockInTrendSummary.samplingIntervalSeconds should equal(1234);
            });
            
            it(@"should deserialize an array of EmployeeClockInTrendDataPoint objects", ^{
                NSArray *dataPoints = employeeClockInTrendSummary.dataPoints;
                dataPoints.count should equal(3);
                
                for(EmployeeClockInTrendSummaryDataPoint *dataPoint in dataPoints)
                {
                    dataPoint should be_instance_of([EmployeeClockInTrendSummaryDataPoint class]);
                }
                
                EmployeeClockInTrendSummaryDataPoint *firstDataPoint = dataPoints[0];
                firstDataPoint.numberOfTimePunchUsersPunchedIn should equal(1);
                NSDate *firstDataPointExpectedStartDate = [NSDate dateWithTimeIntervalSince1970:1434304460];
                firstDataPoint.startDate should equal(firstDataPointExpectedStartDate);
                
                EmployeeClockInTrendSummaryDataPoint *secondDataPoint = dataPoints[1];
                NSDate *secondDataPointExpectedStartDate = [NSDate dateWithTimeIntervalSince1970:1434308060];
                secondDataPoint.numberOfTimePunchUsersPunchedIn should equal(2);
                secondDataPoint.startDate should equal(secondDataPointExpectedStartDate);
                
                EmployeeClockInTrendSummaryDataPoint *thirdDataPoint = dataPoints[2];
                NSDate *thirdDataPointExpectedStartDate = [NSDate dateWithTimeIntervalSince1970:1434311660];
                thirdDataPoint.numberOfTimePunchUsersPunchedIn should equal(3);
                thirdDataPoint.startDate should equal(thirdDataPointExpectedStartDate);
            });
        });
        
        context(@"When Json Response is null", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary = @{@"d":[NSNull null]};
                employeeClockInTrendSummary = [subject deserialize:jsonDictionary samplingIntervalSeconds:1234];
            });
            
            it(@"should return the null EmployeeClockInTrendSummary count", ^{
                employeeClockInTrendSummary should be_instance_of([EmployeeClockInTrendSummary class]);
                employeeClockInTrendSummary.samplingIntervalSeconds should equal(1234);
            });
            
            it(@"should deserialize a null count of EmployeeClockInTrendDataPoint objects", ^{
                NSArray *dataPoints = employeeClockInTrendSummary.dataPoints;
                dataPoints.count should equal(0);
                
            });
        });
    });
});

SPEC_END
