//
//  RecalculatePunchTotal_TestCase.m
//  NextGenRepliconTimeSheet
//
//  Created by xxx
//  Copyright (c) 2014 Replicon. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "AppProperties.h"

@interface RecalculatePunchTotal_TestCase : XCTestCase

@end

@implementation RecalculatePunchTotal_TestCase


- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
  
}
-(void)testForCheckingRecalculatePunchTotalServiceUrl{
   XCTAssertNotNil([[AppProperties getInstance] getServiceURLFor:@"RecalculateScriptData"], @"RecalculateScriptData URL is present");
    
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



@end
