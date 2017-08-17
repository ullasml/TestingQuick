//
//  UpdateApp_TestCase.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 18/12/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "RepliconServiceManager.h"

@interface UpdateApp_TestCase : XCTestCase

@end

@implementation UpdateApp_TestCase

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

-(void)testAppUpdateAvailableAlertForTriggerCount
{
    XCTAssertTrue([[RepliconServiceManager loginService] checkForShowingAppUpdateAlert:5 isShownOnce:YES],@"show Alert for app update");
}

-(void)testAppUpdateAvailableAlert
{
    XCTAssertTrue([[RepliconServiceManager loginService] checkForShowingAppUpdateAlert:10 isShownOnce:NO],@"latest version is available, show Alert for app update. ");
}


@end
