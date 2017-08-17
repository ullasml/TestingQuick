#import "RemotePunchListDeserializer.h"
#import "RemotePunchDeserializer.h"
#import "LocalPunch.h"
#import "RemotePunch.h"
#import "DateProvider.h"
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"


@interface RemotePunchListDeserializer ()

@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) id<BSInjector> injector;

@end

@implementation RemotePunchListDeserializer

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                       dateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self) {
        self.dateProvider = dateProvider;
        self.dateFormatter = dateFormatter;
    }
    return self;
}

- (NSArray *)deserializeWithArray:(NSArray *)jsonArray
{
    RemotePunchDeserializer *punchDeserializer = [self.injector getInstance:[RemotePunchDeserializer class]];;
    NSArray *punchDictionaryList = jsonArray;
    NSMutableArray *punchList = [@[]mutableCopy];
    for (NSDictionary *data in punchDictionaryList)
    {
        NSArray *timePunches = data[@"timePunches"];
        for (NSDictionary *punchDictionary in timePunches) {
            if (punchDictionary[@"uri"]) {
                RemotePunch *punch = [punchDeserializer deserialize:punchDictionary];
                [punchList addObject:punch];
            }
        }
    }
    return punchList;
}

- (NSArray *)deserialize:(NSDictionary *)jsonDictionary
{
    RemotePunchDeserializer *punchDeserializer = [self.injector getInstance:[RemotePunchDeserializer class]];;
    NSArray *punchDictionaryList = jsonDictionary[@"d"] != [NSNull null] ? jsonDictionary[@"d"] : @[];
    NSMutableArray *punchList = [@[]mutableCopy];
    if (punchDictionaryList)
    {
        punchList = [NSMutableArray arrayWithCapacity:punchDictionaryList.count];
        for (NSDictionary *punchDictionary in punchDictionaryList) {
            if (punchDictionary[@"uri"]) {
            RemotePunch *punch = [punchDeserializer deserialize:punchDictionary];
                [punchList addObject:punch];
            }
        }
    }
    return punchList;
}



@end
