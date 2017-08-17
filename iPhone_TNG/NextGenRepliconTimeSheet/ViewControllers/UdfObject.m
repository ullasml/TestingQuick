//
//  UdfObject.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 1/14/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "UdfObject.h"

@implementation UdfObject

-(id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self!=nil) {
        
        NSString *udfType=[dict objectForKey:@"type"];
        if ([udfType isEqualToString:TEXT_UDF_TYPE])
            self.udfType=UDF_TYPE_TEXT;
        else if ([udfType isEqualToString:NUMERIC_UDF_TYPE])
            self.udfType=UDF_TYPE_NUMERIC;
        else if ([udfType isEqualToString:DATE_UDF_TYPE])
            self.udfType=UDF_TYPE_DATE;
        else if ([udfType isEqualToString:DROPDOWN_UDF_TYPE])
            self.udfType=UDF_TYPE_DROPDOWN;
        
        self.udfUri=[dict objectForKey:@"uri"];
        self.udfName=[dict objectForKey:@"name"];
        
        id defaultvalue=[dict objectForKey:@"defaultValue"];
        if (defaultvalue!=nil && ![defaultvalue isKindOfClass:[NSNull class]])
        {
            if ([udfType isEqualToString:DATE_UDF_TYPE])
            {
                if ([defaultvalue isKindOfClass:[NSDate class]])
                {
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    NSLocale *locale=[NSLocale currentLocale];
                    [df setLocale:locale];
                    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [df setDateFormat:@"MMMM d, yyyy"];
                    NSString *dateInString =  [df stringFromDate:[dict objectForKey:@"defaultValue"]];
                    self.defaultValue=dateInString;
                }
                else{
                    self.defaultValue=[dict objectForKey:@"defaultValue"];
                }
                
            }
            else{
                self.defaultValue=[dict objectForKey:@"defaultValue"];
            }
        }
        
        
        id defaultMaxValue=[dict objectForKey:@"defaultMaxValue"];
        if (defaultMaxValue!=nil && ![defaultMaxValue isKindOfClass:[NSNull class]])
            self.maxValue=[[dict objectForKey:@"defaultMaxValue"] floatValue];
        
        id defaultMinValue=[dict objectForKey:@"defaultMinValue"];
        if (defaultMinValue!=nil && ![defaultMinValue isKindOfClass:[NSNull class]])
            self.minValue=[[dict objectForKey:@"defaultMinValue"] floatValue];
        
        id dropDownOptionUri=[dict objectForKey:@"dropDownOptionUri"];
        if (dropDownOptionUri!=nil && ![dropDownOptionUri isKindOfClass:[NSNull class]])
            self.dropDownOptionUri=[dict objectForKey:@"dropDownOptionUri"];
        
        
        id decimalPlaces=[dict objectForKey:@"defaultDecimalValue"];
        if (decimalPlaces!=nil && ![decimalPlaces isKindOfClass:[NSNull class]])
            self.decimalPlaces=[[dict objectForKey:@"defaultDecimalValue"] intValue];
    }
    return self;
}
@end
