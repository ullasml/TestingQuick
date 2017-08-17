//
//  NSString+IntConversion.m
//  NextGenRepliconTimeSheet
//
//  Created by Ravikumar Duvvuri on 12/01/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

#import "NSString+IntConversion.h"

@implementation NSString (IntConversion)

- (unsigned int)intFromHexString
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:self];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}


@end
