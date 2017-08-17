
#import "ExpenseClientDeserializer.h"
#import "ClientType.h"


@implementation ExpenseClientDeserializer

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary
{
    NSArray *clients = jsonDictionary[@"d"];
    NSMutableArray *allClients = [[NSMutableArray alloc]initWithCapacity:clients.count];
    for (NSDictionary *client in clients) {
        ClientType *clientType = [[ClientType alloc]initWithName:client[@"name"] uri:client[@"uri"]];
        [allClients addObject:clientType];
    }
    return allClients;
}

@end
