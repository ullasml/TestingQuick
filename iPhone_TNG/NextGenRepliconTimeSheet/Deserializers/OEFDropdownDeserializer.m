
#import "OEFDropdownDeserializer.h"
#import "OEFDropDownType.h"

@implementation OEFDropdownDeserializer

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary
{
    NSArray *dropDownValues = jsonDictionary[@"d"];
    NSMutableArray *allDropDownValues = [[NSMutableArray alloc]initWithCapacity:dropDownValues.count];
    for (NSDictionary *dropDownValuesInfo in dropDownValues) {
        OEFDropDownType *oefDropDownType = [[OEFDropDownType alloc]initWithName:dropDownValuesInfo[@"displayText"] uri:dropDownValuesInfo[@"uri"]];
        [allDropDownValues addObject:oefDropDownType];
    }
    return allDropDownValues;
}
@end
