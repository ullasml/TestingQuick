#import <Cedar/Cedar.h>
#import "AppProperties.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface AppProperties()
@property(nonatomic) NSDictionary *mobileBackendURLDict;
@property(nonatomic) NSDictionary *originalServicesURLDict;
@end

SPEC_BEGIN(AppPropertiesSpec)

describe(@"AppProperties", ^{
    __block AppProperties *subject;
    
    beforeEach(^{
        subject = [AppProperties getInstance];
        spy_on(subject);
    });
    
    describe(@"Properties dictionary", ^{
        
        it(@"should have valid values", ^{
            [subject getAppPropertyFor:@"DomainName"] should equal(@"replicon.com");
        });
        
        
    });
    
    describe(@"Service Mapping dictionary", ^{
        
        it(@"should have valid values", ^{
            [subject getServiceMappingPropertyFor:@"GetNextPageOfObjectExtensionTagsFilteredBySearch"] should equal(@(172));
        });
        
    });
    
    describe(@"Original Service URL dictionary", ^{
        
        it(@"should not have mobile-backend in the url", ^{
            [subject.originalServicesURLDict valueForKey:@"GetTimesheetSummaryData"] should equal(@"mobile/TimesheetFlowservice1.svc/Load3");
        });
        
    });
    
    describe(@"MobileBackend Service URL dictionary", ^{
        
        it(@"should have mobile-backend in the url", ^{
            [subject.mobileBackendURLDict valueForKey:@"GetTimesheetSummaryData"] should equal(@"mobile-backend/TimesheetFlowservice1.svc/Load3");
        });
        
    });
    
    describe(@"TimeSheet URI Array", ^{
        
        it(@"should have valid number of items", ^{
            
            [[subject getTimesheetColumnURIFromPlist] count] should equal(31);
        });
    });
    
    describe(@"Expense URI Array", ^{
        
        it(@"should have valid number of items", ^{
            
            [[subject getExpenseSheetColumnURIFromPlist] count] should equal(20);
        });
    });
    
    describe(@"TimeOff URI Array", ^{
        
        it(@"should have valid number of items", ^{
            
            [[subject getTimeOffColumnURIFromPlist] count] should equal(23);
        });
    });
    
    describe(@"TeamTime URI Array", ^{
        
        it(@"should have valid number of items", ^{
            
            [[subject getTeamTimeColumnURIFromPlist] count] should equal(12);
        });
    });
    
});

SPEC_END
