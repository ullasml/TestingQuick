
#import "EntryCellDetails.h"

@implementation EntryCellDetails

@synthesize dataSourceArray;
@synthesize fieldName;
@synthesize fieldValue;
@synthesize fieldType;
@synthesize componentSelectedIndexArray;
@synthesize defaultValue;
@synthesize maxValue;
@synthesize minValue;
@synthesize decimalPoints;
@synthesize required;
@synthesize udfIdentity;
@synthesize udfModule;
@synthesize dropdownOptionUri;
@synthesize systemDefaultValue;

-(id)initWithDefaultValue :(id)_defaultValue {
	
	self = [super init];
	if(self != nil){
		[self setDefaultValue:_defaultValue];
	}
	
	return self;
}

#pragma mark - <NSCopying>

- (id)copy
{
    return [self copyWithZone:NULL];
}


-(id) copyWithZone: (NSZone *) zone
{
    EntryCellDetails *copyObject = [[EntryCellDetails allocWithZone: zone] init];
    
    [copyObject setComponentSelectedIndexArray:[self.componentSelectedIndexArray mutableCopy]];
    [copyObject setSystemDefaultValue:[self.systemDefaultValue copy]];
    [copyObject setDropdownOptionUri:[self.dropdownOptionUri copy]];
    [copyObject setDataSourceArray:[self.dataSourceArray mutableCopy]];
    [copyObject setDefaultValue:[self.defaultValue copy]];
    [copyObject setUdfIdentity:[self.udfIdentity copy]];
    [copyObject setFieldValue:[self.fieldValue copy]];
    [copyObject setDecimalPoints:self.decimalPoints];
    [copyObject setFieldType:[self.fieldType copy]];
    [copyObject setFieldName:[self.fieldName copy]];
    [copyObject setUdfModule:[self.udfModule copy]];
    [copyObject setMinValue:[self.minValue copy]];
    [copyObject setMaxValue:[self.maxValue copy]];
    [copyObject setRequired:self.required];
    return copyObject;
}
@end
