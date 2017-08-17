//
//  NSString+Double_Float.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 7/2/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "NSString+Double_Float.h"

@implementation NSString (Double_Float)

-(double) newDoubleValue
{
     NSString * newString = [self stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    return [newString doubleValue];
}

-(float) newFloatValue
{
    NSString * newString = [self stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    return [newString floatValue];
}

@end
