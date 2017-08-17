//
//  CommonUtil.m
//  iOSCommonLibrary
//
//  Created by Dipta on 12/21/15.
//  Copyright © 2015 replicon. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

+(BOOL)isRelease {

    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundleIdentifier containsString:@".debug"] && ![bundleIdentifier containsString:@".inhouse"])
    {
        return YES;
    }

    return NO;

}

+(BOOL)isInHouse {
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleIdentifier containsString:@".inhouse"])
    {
        return YES;
    }
    
    return NO;
    
}


@end
