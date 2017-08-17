#import <Cedar/Cedar.h>
#import "ErrorDetailsDeserializer.h"
#import "ErrorDetails.h"
#import "InjectorProvider.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorKeys.h"
#import "RepliconSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ErrorDetailsDeserializerSpec)

describe(@"ErrorDetailsDeserializer", ^{
    __block ErrorDetailsDeserializer *subject;
    __block id<BSInjector, BSBinder> injector;
    beforeEach(^{
        injector = [InjectorProvider injector];

        NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
        DateProvider *dateProvider = fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(date);
        [injector bind:[DateProvider class] toInstance:dateProvider];

        subject = [injector getInstance:[ErrorDetailsDeserializer class]];
    });

    describe(@"deserialize:", ^{
        __block NSArray *errorDetailsArr;
        beforeEach(^{
            NSDictionary *json = @{
                                               @"error_msg" : @"May 9 to May 15: Comment is required to perform approval action.",
                                               @"module" : @"Timesheets_Module",
                                               @"uri" : @"urn:replicon-tenant:iphone:timesheet:e448f0d1-53bf-4f02-b6e3-fafa393ff2d3"
                                               };
            errorDetailsArr = [subject deserialize:json];
        });

        it(@"should deserialize ErrorDetails correctly", ^{

            ErrorDetails *errorDetails = [[ErrorDetails alloc] initWithUri:@"urn:replicon-tenant:iphone:timesheet:e448f0d1-53bf-4f02-b6e3-fafa393ff2d3" errorMessage:@"May 9 to May 15: Comment is required to perform approval action." errorDate:@"1970-01-01 12:00:00 +0000" moduleName:@"Timesheets_Module"];


            errorDetailsArr.count should equal(1);
            errorDetails should equal(errorDetailsArr[0]);
        });
    });

    describe(@"deserializeValidationServiceResponse:", ^{
         __block NSArray *errorDetailsArr;
        beforeEach(^{
             NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"error_details_validation"];
             errorDetailsArr = [subject deserializeValidationServiceResponse:jsonDictionary];
        });

        it(@"should deserialize ErrorDetails correctly", ^{

            ErrorDetails *errorDetailsA = [[ErrorDetails alloc] initWithUri:@"urn:replicon-tenant:i-phone:timesheet:58f56e04-49a4-4e40-a514-a71d670f5656" errorMessage:@"Jun 29 to Jul 4: Please enter an out time to go with the in time of 1:00 PM." errorDate:@"1970-01-01 12:00:00 +0000" moduleName:@"Timesheets_Module"];

            ErrorDetails *errorDetailsB = [[ErrorDetails alloc] initWithUri:@"urn:replicon-tenant:i-phone:timesheet:ac1570de-7768-4b1a-a9fb-d5d19d0e4949" errorMessage:@"Jun 22 to Jun 28: More than 24 hours have been entered.\n\nJun 22 to Jun 28: Please enter an out time to go with the in time of 5:00 AM." errorDate:@"1970-01-01 12:00:00 +0000" moduleName:@"Timesheets_Module"];


            errorDetailsArr.count should equal(2);
            errorDetailsArr[0] should equal(errorDetailsA);
            errorDetailsArr[1] should equal(errorDetailsB);
        });

    });

    describe(@"deserializeValidationServiceResponse:", ^{
        __block NSArray *timesheetUrisArr;


        context(@"when delta update", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"timesheet_delta"];
                timesheetUrisArr = [subject deserializeTimeSheetUpdateData:jsonDictionary];
            });

            it(@"should deserialize ErrorDetails correctly", ^{
                timesheetUrisArr.count should equal(2);
                timesheetUrisArr[0] should equal(@"urn:replicon-tenant:iphone:timesheet:8dc88758-5729-4a5f-9f69-a8571e72dde3");
                timesheetUrisArr[1] should equal(@"urn:replicon-tenant:iphone:timesheet:d808d9a8-cd78-4fcb-9dd8-ad54cf7dd70e");
            });
        });

        context(@"when full update", ^{
            beforeEach(^{
                NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"timesheet_delta_full_update"];
                timesheetUrisArr = [subject deserializeTimeSheetUpdateData:jsonDictionary];
            });
 
            it(@"should deserialize ErrorDetails correctly", ^{
                timesheetUrisArr.count should equal(10);
                NSArray *expectedArr = @[
                                         @"urn:replicon-tenant:touchpointsolutions-2:timesheet:998b98bf-93a3-4abc-80ac-c5f2ff4d4352",@"urn:replicon-tenant:touchpointsolutions-2:timesheet:e109cfed-d41f-4bfa-86aa-b27ad4f15b13",@"urn:replicon-tenant:touchpointsolutions-2:timesheet:08f33c66-8b83-41b0-a330-2134f96d443a",@"urn:replicon-tenant:touchpointsoluti ons-2:timesheet:8718770a-1888-4d05-b650-cabf1ba0204a",@"urn:replicon-tenant:touchpointsolutions-2:timesheet:43f6e891-cee6-4020-a199-b66c22f0f265",@"urn:replicon-tenant:touchpointsolutions-2:timesheet:e80a11ab-b549-4c93-9b9f-5fb11c63ab10",@"urn:replicon-tenant:touchpointsolutions-2:timesheet:dbc896ba-82d2-46e8-a4c6-ca5ad07d9661",@"urn:replicon-tenant:touchpointsolutions-2:timesheet:19c6ec4e-e467-4229-851c-7e54b97ebab9",@"urn:replicon-tenant:touchpointsolutions-2:timesheet:2323f9e9-4d59-4437-88b3-1a9cc83bdbd8",@"urn:replicon-tenant:touchpointsolutions-2:timesheet:1219abe5-b782-4c80-aa33-4b22cb05881e"];
                timesheetUrisArr should equal(expectedArr);

            });
        });

    });
});

SPEC_END
