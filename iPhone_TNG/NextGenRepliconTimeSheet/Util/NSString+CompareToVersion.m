//
//  NSString+CompareToVersion.m
//  Skylight BVBA
//
//  Created by Stijn Mathysen on 27/02/14.
//  Copyright (c) 2014 Stijn Mathysen. Released under the MIT license
//

#import "NSString+CompareToVersion.h"

@implementation NSString (CompareToVersion)

-(NSComparisonResult)compareToVersion:(NSString *)version{
    NSComparisonResult result;
    
    result = NSOrderedSame;
    
    if(![self isEqualToString:version]){
        NSArray *thisVersion = [self componentsSeparatedByString:@"."];
        NSArray *compareVersion = [version componentsSeparatedByString:@"."];
        
        for(NSInteger index = 0; index < [thisVersion count]; index++){
            NSInteger thisSegment = [[thisVersion objectAtIndex:index] integerValue];
            NSInteger compareSegment = (index < [compareVersion count]) ? [[compareVersion objectAtIndex:index] integerValue] : 0;
            
            if(thisSegment < compareSegment){
                result = NSOrderedAscending;
                break;
            }
            
            if(thisSegment > compareSegment){
                result = NSOrderedDescending;
                break;
            }
        }
        
        if((result == NSOrderedSame) && ([compareVersion count] > [thisVersion count])){
            result = NSOrderedAscending;
        }
    }
    
    return result;
}


-(BOOL)isOlderThanVersion:(NSString *)version{
    return ([self compareToVersion:version] == NSOrderedAscending);
}

-(BOOL)isNewerThanVersion:(NSString *)version{
    return ([self compareToVersion:version] == NSOrderedDescending);
}

-(BOOL)isEqualToVersion:(NSString *)version{
    return ([self compareToVersion:version] == NSOrderedSame);
}

-(BOOL)isEqualOrOlderThanVersion:(NSString *)version{
    return ([self compareToVersion:version] != NSOrderedDescending);
}

-(BOOL)isEqualOrNewerThanVersion:(NSString *)version{
    return ([self compareToVersion:version] != NSOrderedAscending);
}

-(BOOL)isEmptyString
{
    if (self==nil||[self isKindOfClass:[NSNull class]]||[self isEqualToString:@""]||[self length]==0) {
        return YES;
    }
    return NO;
}

@end