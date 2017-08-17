//
//  NSString+repContainsOnly0to9.m
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "NSString+repContainsOnly0to9.h"

@implementation NSString (repContainsOnly0to9)

- (BOOL)repContainsOnly0to9
{
    NSCharacterSet *notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

    return ([self rangeOfCharacterFromSet: notDigits].location == NSNotFound);
}

@end
