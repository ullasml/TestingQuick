//
//  ExpenseEntry_TestCase.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 16/12/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ExpenseEntryViewController.h"

@interface ExpenseEntry_TestCase : XCTestCase
@property (strong, nonatomic) ExpenseEntryViewController *expenseEntryViewController;
@end

@implementation ExpenseEntry_TestCase
@synthesize expenseEntryViewController;
- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    expenseEntryViewController = [[ExpenseEntryViewController alloc] init];
    [expenseEntryViewController viewDidLoad];
    XCTAssertNotNil(expenseEntryViewController, @"Cannot create expenseEntryViewController instance");
    
}
-(void)testForClearOprtion{
    expenseEntryViewController.currentIndexPath = [NSIndexPath indexPathForRow:5 inSection:1];
    BOOL isLoginSuccessfull=[[NSUserDefaults standardUserDefaults] boolForKey:@"isSuccessLogin"];
    
   
    
    if (isLoginSuccessfull)
    {
        [expenseEntryViewController pickerClear:nil];
    }
    else
    {
         XCTAssertFalse(isLoginSuccessfull,@"is user logged out!!!");
    }
    
    XCTAssert(YES, @"Pass");
   
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

@end
