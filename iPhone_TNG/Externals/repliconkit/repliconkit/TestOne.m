//
//  TestOne.m
//  repliconkit
//
//  Created by Anil Reddy on 3/28/16.
//  Copyright © 2016 replicon. All rights reserved.
//

#import "TestOne.h"
#import <repliconkit/repliconkit-Swift.h>

@implementation TestOne

- (NSString *)getHelloFromObjc:(NSString *)str{
    return [NSString stringWithFormat:@"Hello from Obc %@", str];
}

- (NSString *)sayHelloToSwift:(NSString *)str{
    return [[[TestTwo alloc] init] sayHelloToObjc:@"swifty"];
}

- (NSString *)testCommit:(NSString *)str {
    return nil;
}

- (NSString *)testCommit2:(NSString *)str {
    return nil;
}

@end
