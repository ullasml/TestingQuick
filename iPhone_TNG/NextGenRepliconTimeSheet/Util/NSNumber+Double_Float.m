//
//  NSNumber+Double_Float.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 7/2/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "NSNumber+Double_Float.h"

@implementation NSNumber (Double_Float)

-(double) newDoubleValue
{
     NSString * newString = [[NSString stringWithFormat:@"%@",self]stringByReplacingOccurrencesOfString:@"," withString:@"."];
    return [newString doubleValue];
}

-(float) newFloatValue
{
    NSString * newString = [[NSString stringWithFormat:@"%@",self]stringByReplacingOccurrencesOfString:@"," withString:@"."];
    return [newString floatValue];
}

@end
