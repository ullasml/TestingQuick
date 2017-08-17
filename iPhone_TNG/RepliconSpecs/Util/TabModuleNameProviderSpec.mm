#import <Cedar/Cedar.h>
#import "TabModuleNameProvider.h"
#import "Constants.h"
#import "RepliconSpecHelper.h"
#import "AstroUserDetector.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TabModuleNameProviderSpec)

describe(@"TabModuleNameProvider", ^{
    __block TabModuleNameProvider *subject;
    __block NSMutableDictionary *homeSummaryResponse;
    __block NSMutableDictionary *userSummary;
    __block NSMutableDictionary *timePunchCapabilities;
    __block AstroUserDetector *astroUserDetector;


    beforeEach(^{

        astroUserDetector = nice_fake_for([AstroUserDetector class]);
        subject = [[TabModuleNameProvider alloc] initWithAstroUserDetector:astroUserDetector];
        homeSummaryResponse = [[RepliconSpecHelper jsonWithFixture:@"home_summary_response"][@"d"] mutableCopy];
        userSummary = [homeSummaryResponse[@"userSummary"] mutableCopy];
        timePunchCapabilities = [userSummary[@"timePunchCapabilities"] mutableCopy];
    });

    it(@"does not include old punch tabs"
       @"and adds the new punch tab"
       @"when"
       @"the user has punch in / out access"
       @"the user canViewTimePunch"
       @"there is no activity access"
       @"the user has no project / client access"
       @"no custom punch extension fields",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"canViewTimePunch"] = @1;
           timePunchCapabilities[@"hasActivityAccess"] = @0;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;
           NSDictionary *currentCapabilities = userSummary[@"timesheetCapabilities"][@"currentCapabilities"];

           astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).with(currentCapabilities,timePunchCapabilities,NO).and_return(YES);

           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:NO];
           tabModuleNames should_not contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_IN_PROJECT_MODULE_NAME);
           tabModuleNames should contain(NEW_PUNCH_WIDGET_MODULE_NAME);

       });

    it(@"does not include old punch tabs"
       @"and adds the new punch tab"
       @"when"
       @"the user has punch in / out access"
       @"the user has project / client access"
       @"the user canViewTimePunch"
       @"there is no activity access"
       @"no custom punch extension fields",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"canViewTimePunch"] = @1;
           timePunchCapabilities[@"hasActivityAccess"] = @0;
           timePunchCapabilities[@"hasProjectAccess"] = @1;
           timePunchCapabilities[@"hasClientAccess"] = @0;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;
           NSDictionary *currentCapabilities = userSummary[@"timesheetCapabilities"][@"currentCapabilities"];

           astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).with(currentCapabilities,timePunchCapabilities,NO).and_return(YES);

           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:NO];
           tabModuleNames should_not contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should_not contain(NEW_PUNCH_WIDGET_MODULE_NAME);
           tabModuleNames should contain(PUNCH_IN_PROJECT_MODULE_NAME);

       });

    it(@"does not include old punch tabs"
       @"and adds the new punch tab"
       @"when"
       @"the user has punch in / out access"
       @"the user has no project / client access"
       @"the user canViewTimePunch"
       @"there is activity access"
       @"no custom punch extension fields",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"canViewTimePunch"] = @1;
           timePunchCapabilities[@"hasActivityAccess"] = @1;
           timePunchCapabilities[@"hasProjectAccess"] = @0;
           timePunchCapabilities[@"hasClientAccess"] = @0;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;
           NSDictionary *currentCapabilities = userSummary[@"timesheetCapabilities"][@"currentCapabilities"];

           astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).with(currentCapabilities,timePunchCapabilities,NO).and_return(YES);

           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:NO];
           tabModuleNames should_not contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should_not contain(NEW_PUNCH_WIDGET_MODULE_NAME);
           tabModuleNames should contain(PUNCH_INTO_ACTIVITIES_MODULE_NAME);
           
       });

    it(@"does not include old punch tabs"
       @"and adds the new punch tab"
       @"when"
       @"the user has punch in / out access"
       @"the user has no project / client access"
       @"the user canViewTimePunch"
       @"there is no activity access"
       @"has custom punch extension fields",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"canViewTimePunch"] = @1;
           timePunchCapabilities[@"hasActivityAccess"] = @0;
           timePunchCapabilities[@"hasProjectAccess"] = @0;
           timePunchCapabilities[@"hasClientAccess"] = @0;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;
           NSDictionary *currentCapabilities = userSummary[@"timesheetCapabilities"][@"currentCapabilities"];

           astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).with(currentCapabilities,timePunchCapabilities,NO).and_return(YES);

           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:NO];
           tabModuleNames should_not contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should_not contain(NEW_PUNCH_WIDGET_MODULE_NAME);
           tabModuleNames should contain(PUNCH_INTO_SIMPLE_PUNCH_OEF_MODULE_NAME);
           
       });
    
    
    it(@"does not include old punch tabs"
       @"and adds the new punch tab"
       @"when"
       @"the user has punch in / out access"
       @"the user has project / client access"
       @"the user canViewTimePunch"
       @"the user has activity access"
       @"no custom punch extension fields",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"canViewTimePunch"] = @1;
           timePunchCapabilities[@"hasActivityAccess"] = @1;
           timePunchCapabilities[@"hasProjectAccess"] = @1;
           timePunchCapabilities[@"hasClientAccess"] = @1;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;
           NSDictionary *currentCapabilities = userSummary[@"timesheetCapabilities"][@"currentCapabilities"];
           
           astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).with(currentCapabilities,timePunchCapabilities,NO).and_return(YES);
           
           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:NO];
           tabModuleNames should_not contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should_not contain(NEW_PUNCH_WIDGET_MODULE_NAME);
           tabModuleNames should contain(WRONG_CONFIGURATION_MODULE_NAME);
           
       });



    it(@"includes the old punch tabs when"
       @"the user has punch in / out access"
       @"the user canViewTimePunch"
       @"there is activity access"
       @"there are no custom punch extension fields",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"hasActivityAccess"] = @1;
           timePunchCapabilities[@"canViewTimePunch"] = @1;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;

           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:NO];
           tabModuleNames should contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should_not contain(NEW_PUNCH_WIDGET_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_IN_PROJECT_MODULE_NAME);


       });
    
    it(@"includes the old punch tabs when"
       @"the user has punch in / out access"
       @"the user has no time punch access"
       @"the user canViewTimePunch"
       @"there is activity access"
       @"there are no custom punch extension fields",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"hasActivityAccess"] = @1;
           timePunchCapabilities[@"canViewTimePunch"] = @1;
           timePunchCapabilities[@"hasTimePunchAccess"] = @0;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;
           
           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:YES];
           tabModuleNames should_not contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should_not contain(NEW_PUNCH_WIDGET_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_IN_PROJECT_MODULE_NAME);
           
           
       });

    it(@"includes the old punch tabs when"
       @"the user has punch in / out access"
       @"the user canViewTimePunch"
       @"there is no activity access"
       @"there are custom punch extension fields",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"canViewTimePunch"] = @1;

           timePunchCapabilities[@"hasActivityAccess"] = @0;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};

           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;

           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:NO];
           tabModuleNames should contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should_not contain(NEW_PUNCH_WIDGET_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_IN_PROJECT_MODULE_NAME);


    });
    
    it(@"includes the old punch tabs when"
       @"the user has punch in / out access"
       @"the user has no time punch access"
       @"the user canViewTimePunch"
       @"there is no activity access"
       @"there are custom punch extension fields",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"canViewTimePunch"] = @1;
           timePunchCapabilities[@"hasTimePunchAccess"] = @0;
           timePunchCapabilities[@"hasActivityAccess"] = @0;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
           
           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;
           
           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse
                                                                        userDetails:userDetails isWidgetPlatformSupported:YES];
           tabModuleNames should_not contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should_not contain(NEW_PUNCH_WIDGET_MODULE_NAME);
           tabModuleNames should_not contain(PUNCH_IN_PROJECT_MODULE_NAME);
           
           
       });

    it(@"includes the old punch tabs and not duplicate them", ^{
        timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
        timePunchCapabilities[@"hasActivityAccess"] = @0;
        userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
        homeSummaryResponse[@"userSummary"] = userSummary;

        NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:@[@{@"hasPunchInOutAccess" : @1}] isWidgetPlatformSupported:NO];
        NSCountedSet *set = [[NSCountedSet alloc] initWithArray:tabModuleNames];
        [set countForObject:PUNCH_HISTORY_TAB_MODULE_NAME] should equal(1);
    });
    
    it(@"includes the old punch tabs when no punch access and has only timesheet access", ^{
        timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[@{}]};
        timePunchCapabilities[@"hasActivityAccess"] = @0;
        userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
        homeSummaryResponse[@"userSummary"] = userSummary;
        
        NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:@[@{@"hasPunchInOutAccess" : @0},@{@"hasTimesheetAccess": @1}] isWidgetPlatformSupported:NO];
        tabModuleNames should_not contain(TIMESHEETS_TAB_MODULE_NAME);
    });

    it(@"shows the wrong configuration tab"
       @"when"
       @"the user has punch in / out access"
       @"the user has project access"
       @"the user canViewTimePunch"
       @"no custom punch extension fields"
       @"and the user is non-astro",
       ^{
           NSArray *userDetails = @[@{@"hasPunchInOutAccess": @1}];
           timePunchCapabilities[@"canViewTimePunch"] = @1;
           timePunchCapabilities[@"hasProjectAccess"] = @1;
           timePunchCapabilities[@"timePunchExtensionFields"] = @{@"SomeExtensionFieldOrSometing": @[]};
           userSummary[@"timePunchCapabilities"] = timePunchCapabilities;
           homeSummaryResponse[@"userSummary"] = userSummary;
           NSDictionary *currentCapabilities = userSummary[@"timesheetCapabilities"][@"currentCapabilities"];

           astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).with(currentCapabilities,timePunchCapabilities,NO).and_return(NO);

           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:homeSummaryResponse userDetails:userDetails isWidgetPlatformSupported:NO];
           tabModuleNames should_not contain(CLOCK_IN_OUT_TAB_MODULE_NAME);
           tabModuleNames should contain(PUNCH_HISTORY_TAB_MODULE_NAME);
           tabModuleNames should contain(SETTINGS_TAB_MODULE_NAME);
           tabModuleNames should contain(WRONG_CONFIGURATION_MODULE_NAME);

       });
    
    it(@"includes the new punch tabs when"
        @"is widget platform and"
        @"user is an astro user",
       ^{
           NSArray *userDetails = @[@{@"hasTimesheetAccess": @1}];
           astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).and_return(YES);
           NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:nil userDetails:userDetails isWidgetPlatformSupported:YES];
           tabModuleNames should contain(NEW_PUNCH_WIDGET_MODULE_NAME);
           tabModuleNames should_not contain(TIMESHEETS_TAB_MODULE_NAME);
       });
    
    it(@"includes the old punch tabs when"
        @"is widget platform and"
        @"user is a non astro user",
        ^{
            NSArray *userDetails = @[@{@"hasTimesheetAccess": @1}];
            astroUserDetector stub_method(@selector(isAstroUserWithCapabilities:timePunchCapabilities:isWidgetPlatformSupported:)).and_return(NO);
            NSArray *tabModuleNames = [subject tabModuleNamesWithHomeSummaryResponse:nil userDetails:userDetails isWidgetPlatformSupported:YES];
            tabModuleNames should contain(TIMESHEETS_TAB_MODULE_NAME);
            tabModuleNames should_not contain(NEW_PUNCH_WIDGET_MODULE_NAME);
        });
    


});

SPEC_END
