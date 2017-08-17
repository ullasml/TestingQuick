#import "TeamStatusSummaryDeserializer.h"
#import "TeamStatusSummary.h"
#import "PunchUserDeserializer.h"


@interface TeamStatusSummaryDeserializer ()

@property (nonatomic) PunchUserDeserializer *punchUserDeserializer;

@end


@implementation TeamStatusSummaryDeserializer

- (instancetype)initWithPunchUserDeserializer:(PunchUserDeserializer *)punchUserDeserializer
{
    self = [super init];
    if (self) {
        self.punchUserDeserializer = punchUserDeserializer;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (TeamStatusSummary *)deserialize:(NSDictionary *)teamStatusDictionary
{
    NSDictionary *dataDictionary = teamStatusDictionary[@"d"];
    NSMutableArray *usersInArray = [NSMutableArray arrayWithCapacity:[dataDictionary[@"clockedInUsers"] count]];
    NSMutableArray *usersNotInArray = [NSMutableArray arrayWithCapacity:[dataDictionary[@"notInUsers"] count]];
    NSMutableArray *usersOnBreakArray = [NSMutableArray arrayWithCapacity:[dataDictionary[@"onBreakUsers"] count]];

    for (NSDictionary *punchUserDictionary in dataDictionary[@"clockedInUsers"]) {
        [usersInArray addObject:[self.punchUserDeserializer deserialize:punchUserDictionary]];
    }

    for (NSDictionary *punchUserDictionary in dataDictionary[@"notInUsers"]) {
        [usersNotInArray addObject:[self.punchUserDeserializer deserialize:punchUserDictionary]];
    }

    for (NSDictionary *punchUserDictionary in dataDictionary[@"onBreakUsers"]) {
        [usersOnBreakArray addObject:[self.punchUserDeserializer deserialize:punchUserDictionary]];
    }

    TeamStatusSummary *teamStatusSummary = [[TeamStatusSummary alloc] initWithUsersInArray:[usersInArray copy] onBreakArray:[usersOnBreakArray copy] notInArray:[usersNotInArray copy]];
    return teamStatusSummary;
}

@end
