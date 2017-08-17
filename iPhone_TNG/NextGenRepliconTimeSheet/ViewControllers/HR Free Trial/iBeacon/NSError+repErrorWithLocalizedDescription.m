//
//  NSError+repErrorWithLocalizedDescription.m
//  Replicon
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "NSString+repContainsOnly0to9.h"

@implementation NSError (repErrorWithLocalizedDescription)

+ (NSError *)repErrorWithLocalizedDescription: (NSString *)localizedDescription
{
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : localizedDescription};

    NSString *errorDomain = [NSBundle mainBundle].bundleIdentifier;
    
    NSError *error = [NSError errorWithDomain: errorDomain
                                         code: 0
                                     userInfo: userInfo];
    
    return error;
}

@end
