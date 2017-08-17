#import "BreakTypeDeserializer.h"
#import "BreakType.h"


@implementation BreakTypeDeserializer

- (NSArray *) deserialize: (NSDictionary *) responseDictionary
{
    NSMutableArray *breakTypeList = [NSMutableArray array];

    NSArray *breakTypeDictionaries = responseDictionary[@"d"];
    for (NSDictionary *breakTypeDictionary in breakTypeDictionaries) {
        NSString *name = breakTypeDictionary[@"displayText"];
        NSString *uri = breakTypeDictionary[@"uri"];
        BreakType *breakType = [[BreakType alloc] initWithName:name uri:uri];
        [breakTypeList addObject:breakType];
    }

    return breakTypeList;
}

@end
