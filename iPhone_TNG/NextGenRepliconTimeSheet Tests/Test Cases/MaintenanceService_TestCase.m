//
//  MaintenanceService_TestCase.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 09/12/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RepliconServiceManager.h"

@interface MaintenanceService_TestCase : XCTestCase

@end

@implementation MaintenanceService_TestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


-(void)testcheckForUserDeviceZoneTime
{
    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:@"2014-12-01 10:15",@"DownTimeFrom",@"2014-12-01 11:15", @"DownTimeTo", nil];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    XCTAssertNotNil([dateFormatter dateFromString:[[RepliconServiceManager loginService] convertToUserDeviceTimeZone:tempDict]],@"date is not nil");
}

-(void)testForTimeZomeStringNilOrNot
{
    XCTAssertNotNil([[RepliconServiceManager loginService] checkForTimeZoneString],@"time zone  is not nil");
}


@end
