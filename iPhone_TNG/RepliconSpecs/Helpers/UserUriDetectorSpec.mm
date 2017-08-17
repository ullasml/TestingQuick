#import <Cedar/Cedar.h>
#import "UserUriDetector.h"
#import "RepliconSpecHelper.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(UserUriDetectorSpec)

describe(@"UserUriDetector", ^{
    __block UserUriDetector *subject;
    __block NSString *userUri;

    beforeEach(^{
        subject = [[UserUriDetector alloc]init];
    });

    context(@"When timesheet is of Standard Format", ^{
        beforeEach(^{
            NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"timesheet_load_standard"];
            userUri = [subject userUriFromTimesheetLoad:jsonDictionary];
        });

        it(@"should detect the user uri correctly", ^{
            userUri should equal(@"urn:replicon-tenant:iphone:user:61");
        });
    });

    context(@"When timesheet is of InOut Format", ^{
        beforeEach(^{
            NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"timesheet_load_inout"];
            userUri = [subject userUriFromTimesheetLoad:jsonDictionary];
        });

        it(@"should detect the user uri correctly", ^{
            userUri should equal(@"urn:replicon-tenant:repliconiphone-2:user:461");
        });
    });

    context(@"When timesheet is of Widget Punch Format", ^{
        beforeEach(^{
            NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"timesheet_load_widget_punch"];
            userUri = [subject userUriFromTimesheetLoad:jsonDictionary];
        });

        it(@"should detect the user uri correctly", ^{
            userUri should equal(@"urn:replicon-tenant:iphone:user:65");
        });
    });

    context(@"When timesheet is of Widget Inout Format", ^{
        beforeEach(^{
            NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"timesheet_load_widget_inout"];
            userUri = [subject userUriFromTimesheetLoad:jsonDictionary];
        });

        it(@"should detect the user uri correctly", ^{
            userUri should equal(@"http://www.example.com/");
        });
    });


});

SPEC_END
