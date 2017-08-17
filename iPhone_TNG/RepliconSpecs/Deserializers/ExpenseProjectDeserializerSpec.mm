#import <Cedar/Cedar.h>
#import "ExpenseProjectDeserializer.h"
#import "RepliconSpecHelper.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "ProjectBillingType.h"
#import "ProjectTimeAndExpenseEntryType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseProjectDeserializerSpec)

describe(@"ExpenseProjectDeserializer", ^{
    __block ExpenseProjectDeserializer *subject;
    __block NSArray *projectsArray;
    
    beforeEach(^{
        subject = [[ExpenseProjectDeserializer alloc]init];
        NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"expense_get_projects"];
        projectsArray = [subject deserialize:jsonDictionary];
    });
    
    it(@"should deserialize projects correctly", ^{
        
        
        ClientType *clientA = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                          uri:@"urn:replicon-tenant:qa:client:3"];
        ClientType *clientD = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                          uri:@"urn:replicon-tenant:qa:client:3"];
        ClientType *clientE = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                          uri:@"urn:replicon-tenant:qa:client:3"];
        ClientType *clientB = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                          uri:@"urn:replicon-tenant:qa:client:3"];
        ClientType *clientC = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                          uri:@"urn:replicon-tenant:qa:client:3"];
        
        ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                    isTimeAllocationAllowed:NO
                                                                              projectPeriod:nil
                                                                                 clientType:clientA
                                                                                       name:@"Financial data reporting fixes"
                                                                                        uri:@"urn:replicon-tenant:qa:project:28"];
        
        ProjectType *projectD = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                    isTimeAllocationAllowed:NO
                                                                              projectPeriod:nil
                                                                                 clientType:clientD
                                                                                       name:@"Financial data reporting fixes"
                                                                                        uri:@"urn:replicon-tenant:qa:project:28"];
        
        ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeA = nil;
        ProjectBillingType *projectBillingTypeA = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:non-billable" displayText:@"Non-Billable"];
        
        projectD.projectBillingType = projectBillingTypeA;
        projectD.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeA;
        
        ProjectType *projectE = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                    isTimeAllocationAllowed:NO
                                                                              projectPeriod:nil
                                                                                 clientType:clientE
                                                                                       name:@"Financial data reporting fixes"
                                                                                        uri:@"urn:replicon-tenant:qa:project:28"];
        
        ProjectTimeAndExpenseEntryType *projectTimeAndEntryTypeB = [[ProjectTimeAndExpenseEntryType alloc] initWithUri:@"urn:replicon:time-and-expense-entry-type:non-billable" displayText:@"Non-Billable"];
        ProjectBillingType *projectBillingTypeB = [[ProjectBillingType alloc] initWithUri:@"urn:replicon:billing-type:time-and-material" displayText:@"Time & Materials"];
        
        projectE.projectBillingType = projectBillingTypeB;
        projectE.projectTimeAndExpenseEntryType = projectTimeAndEntryTypeB;
        
        
        ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                    isTimeAllocationAllowed:NO
                                                                              projectPeriod:nil
                                                                                 clientType:clientB
                                                                                       name:@"New Customer Service System"
                                                                                        uri:@"urn:replicon-tenant:qa:project:16"];
        
        ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                    isTimeAllocationAllowed:NO
                                                                              projectPeriod:nil
                                                                                 clientType:clientC
                                                                                       name:@"Next gen ERP Deployment"
                                                                                        uri:@"urn:replicon-tenant:qa:project:18"];
        
        
        
        projectsArray should equal(@[projectA, projectD, projectE, projectB, projectC]);
    });
});

SPEC_END
