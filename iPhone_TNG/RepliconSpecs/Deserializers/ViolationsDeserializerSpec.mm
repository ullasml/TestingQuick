#import <Cedar/Cedar.h>
#import "ViolationsDeserializer.h"
#import "RepliconSpecHelper.h"
#import "Violation.h"
#import "SingleViolationDeserializer.h"
#import "WaiverDeserializer.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ViolationsDeserializerSpec)

describe(@"ViolationsDeserializer", ^{
    __block ViolationsDeserializer *subject;
    __block WaiverDeserializer *waiverDeserializer;
    __block SingleViolationDeserializer *singleViolationDeserializer;

    beforeEach(^{
        waiverDeserializer = [[WaiverDeserializer alloc] init];
        singleViolationDeserializer = [[SingleViolationDeserializer alloc] initWithWaiverDeserializer:waiverDeserializer];
        subject = [[ViolationsDeserializer alloc] initWithSingleViolationDeserializer:singleViolationDeserializer];
    });

    describe(@"deserialize:", ^{
        __block NSArray *violations;

        context(@"when there is valid violations data", ^{
            beforeEach(^{
                NSArray *json = [RepliconSpecHelper jsonArrayWithFixture:@"employee_time_segment_violations"];
                violations = [subject deserialize:json];
            });

            it(@"should have the correct number of violations", ^{
                violations.count should equal(3);
            });
        });

        context(@"when there is no timePunchValidationMessages", ^{
            __block NSArray *json;
            beforeEach(^{
                json = @[@{@"timePunchValidationMessages": @[]}];
            });

            it(@"should not raise an exception", ^{
                ^ {[subject deserialize:json]; } should_not raise_exception;
            });
        });

        context(@"when there is no timesheetValidationMessages", ^{
            __block NSArray *json;
            beforeEach(^{
                json = @[@{@"timesheetValidationMessages": @[]}];
            });

            it(@"should not raise an exception", ^{
                ^ {[subject deserialize:json]; } should_not raise_exception;
            });
        });
    });
    
    describe(@"deserializeViolationsFromPunchValidationResult:", ^{
        __block NSArray *violations;
        
        context(@"when there is valid violations data", ^{
            beforeEach(^{
                NSDictionary *json = [RepliconSpecHelper jsonWithFixture:@"punch_validation_result"];
                violations = [subject deserializeViolationsFromPunchValidationResult:json];
            });
            
            it(@"should have the correct number of violations", ^{
                violations.count should equal(1);
            });
        });
        
        context(@"when there is no validationMessages", ^{
            __block NSDictionary *json;
            beforeEach(^{
                json = @{@"punchValidationResult": @{@"validationMessages":@[]}};
            });
            
            it(@"should not raise an exception", ^{
                ^ {[subject deserializeViolationsFromPunchValidationResult:json]; } should_not raise_exception;
            });
        });
        
        context(@"when there is no punchValidationResult", ^{
            __block NSDictionary *json;
            beforeEach(^{
                json = @{@"punchValidationResult": [NSNull null]};
            });
            
            it(@"should not raise an exception", ^{
                ^ {[subject deserializeViolationsFromPunchValidationResult:json]; } should_not raise_exception;
            });
        });
    });
});

SPEC_END
