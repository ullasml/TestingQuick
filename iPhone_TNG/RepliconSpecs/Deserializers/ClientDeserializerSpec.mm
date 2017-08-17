#import <Cedar/Cedar.h>
#import "ClientDeserializer.h"
#import "RepliconSpecHelper.h"
#import "ClientType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ClientDeserializerSpec)

describe(@"ClientDeserializer", ^{
    __block ClientDeserializer *subject;
    __block NSArray *clientsArray;

    beforeEach(^{
        subject = [[ClientDeserializer alloc]init];
        NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"get_clients"];
        clientsArray = [subject deserialize:jsonDictionary];
    });

    it(@"should deserialize clients correctly", ^{

        ClientType *clientA = [[ClientType alloc]initWithName:@"Advantage Technologies"
                                                          uri:@"urn:replicon-tenant:punch:client:2"];
        ClientType *clientB = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                          uri:@"urn:replicon-tenant:punch:client:3"];
        ClientType *clientC = [[ClientType alloc]initWithName:@"Joan Arc Inc"
                                                          uri:@"urn:replicon-tenant:punch:client:5"];
        ClientType *clientD = [[ClientType alloc]initWithName:@"Xo Xo Communications"
                                                          uri:@"urn:replicon-tenant:punch:client:4"];
        NSArray *expectedClientsArray = @[clientA,clientB,clientC,clientD];

        clientsArray should equal(expectedClientsArray);
    });
});

SPEC_END
