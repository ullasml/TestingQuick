#import <Cedar/Cedar.h>
#import "SingleTimesheetDeserializer.h"
#import "Timesheet.h"
#import "RepliconSpecHelper.h"
#import "AstroUserDetector.h"
#import "AstroAwareTimesheet.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(SingleTimesheetDeserializerSpec)

describe(@"SingleTimesheetDeserializer", ^{
    __block SingleTimesheetDeserializer *subject;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block AstroUserDetector *astroUserDetector;

    beforeEach(^{
        astroUserDetector = nice_fake_for([AstroUserDetector class]);
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        userPermissionsStorage stub_method(@selector(isWidgetPlatformSupported)).and_return(YES);
        subject = [[SingleTimesheetDeserializer alloc] initWithAstroUserDetector:astroUserDetector userPermissionStorage:userPermissionsStorage];
    });

    describe(@"deserialize", ^{
        __block AstroAwareTimesheet *timesheet;
        context(@"when the timesheet belongs to an astro punch user", ^{
            __block NSDictionary *astroDictionary;
            beforeEach(^{
                astroDictionary = [RepliconSpecHelper jsonWithFixture:@"timesheet_detail_astro"];
                NSDictionary *responseDictionary = astroDictionary[@"d"];
                NSDictionary *capabilitiesDictionary = responseDictionary[@"capabilities"];
                NSMutableDictionary *timePunchCapabilities = capabilitiesDictionary[@"timePunchCapabilities"];
                astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).with(capabilitiesDictionary,timePunchCapabilities,YES).and_return(YES);
                timesheet = [subject deserialize:astroDictionary];
            });

            it(@"should turn the dictionary into a timesheet", ^{
                timesheet.astroUserType should equal(TimesheetAstroUserTypeAstro);
            });

            it(@"should have the correct timesheet format", ^{
                timesheet.format should equal(@"urn:replicon:policy:timesheet:timesheet-format:gen4-timesheet");
            });

            it(@"should have the correct URI", ^{
                timesheet.uri should equal(@"urn:replicon-tenant:astro:timesheet:a693e20d-47ca-4480-af35-646257e8cc76");
            });

            it(@"should have the correct timesheetdictionary", ^{
                timesheet.timesheetDictionary should equal(astroDictionary);
            });
            
            it(@"should have the correct timesheetdictionary", ^{
                timesheet.hasPayrollSummary should be_truthy;
            });


        });

        context(@"when the timesheet belongs to a non astro punch user", ^{
            __block NSDictionary *nonAstroDictionary;
            beforeEach(^{
                nonAstroDictionary = [[RepliconSpecHelper jsonWithFixture:@"timesheet_detail_non_astro"]mutableCopy];
                NSDictionary *responseDictionary = nonAstroDictionary[@"d"];
                NSDictionary *capabilitiesDictionary = responseDictionary[@"capabilities"];
                NSMutableDictionary *timePunchCapabilities = capabilitiesDictionary[@"timePunchCapabilities"];
                astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).with(capabilitiesDictionary,timePunchCapabilities,YES).and_return(NO);
                timesheet = [subject deserialize:nonAstroDictionary];
            });

            it(@"should turn the dictionary into a timesheet", ^{
                [timesheet astroUserType] should equal(TimesheetAstroUserTypeNonAstro);
            });

            it(@"should have the correct timesheet format", ^{
                timesheet.format should equal(@"urn:replicon:policy:timesheet:timesheet-format:standard-timesheet");
            });

            it(@"should have the correct URI", ^{
                timesheet.uri should equal(@"urn:replicon-tenant:astro:timesheet:ad6af2db-13de-4d62-874a-35676fe34e1b");
            });

            it(@"should have the correct timesheetdictionary", ^{
                timesheet.timesheetDictionary should equal(nonAstroDictionary);
            });
        });
    });
});

SPEC_END
