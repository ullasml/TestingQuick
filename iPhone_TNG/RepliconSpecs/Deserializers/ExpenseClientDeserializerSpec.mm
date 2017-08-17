#import <Cedar/Cedar.h>
#import "ExpenseClientDeserializer.h"
#import "RepliconSpecHelper.h"
#import "ClientType.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseClientDeserializerSpec)

describe(@"ExpenseClientDeserializer", ^{
    __block ExpenseClientDeserializer *subject;
    __block NSArray *clientsArray;
    
    beforeEach(^{
        subject = [[ExpenseClientDeserializer alloc]init];
        NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"expense_get_clients"];
        clientsArray = [subject deserialize:jsonDictionary];
    });
    
    it(@"should deserialize clients correctly", ^{
        
        ClientType *clientA = [[ClientType alloc]initWithName:@"Advantage Technologies"
                                                          uri:@"urn:replicon-tenant:qa:client:2"];
        ClientType *clientB = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                          uri:@"urn:replicon-tenant:qa:client:3"];
        ClientType *clientC = [[ClientType alloc]initWithName:@"Joan Arc Inc"
                                                          uri:@"urn:replicon-tenant:qa:client:5"];
        ClientType *clientD = [[ClientType alloc]initWithName:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque sit amet blandit erat. Pellentesque in auctor augue, id feugiat mauris. Vestibulum in finibus justo. Sed iaculis ornare purus. Donec auctor ex sollicitudin sapien feugiat, vitae molestie jus"
                                                          uri:@"urn:replicon-tenant:qa:client:10"];
        ClientType *clientE = [[ClientType alloc]initWithName:@"Xo Xo Communications"
                                                          uri:@"urn:replicon-tenant:qa:client:4"];
        NSArray *expectedClientsArray = @[clientA,clientB,clientC,clientD, clientE];
        
        clientsArray should equal(expectedClientsArray);
    });
});

SPEC_END
