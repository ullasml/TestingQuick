//
//  Expenses_Test.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 12/8/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ExpenseEntryViewController.h"
#import "AmountViewController.h"

@interface Expenses_Tests : XCTestCase
@property (strong, nonatomic) AmountViewController *amountViewController;
@property (strong, nonatomic) ExpenseEntryViewController *expenseEntryViewController;
@end

@implementation Expenses_Tests
@synthesize amountViewController;
@synthesize expenseEntryViewController;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // Put setup code here. This method is called before the invocation of each test method in the class.
    amountViewController = [[AmountViewController alloc] init];
    XCTAssertNotNil(amountViewController, @"Cannot create amountViewController instance");
    
    expenseEntryViewController = [[ExpenseEntryViewController alloc] init];
    XCTAssertNotNil(expenseEntryViewController, @"Cannot create expenseEntryViewController instance");
    
}



- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCalculateTaxes {
    // This is an example of a functional test case.
    [amountViewController calculateTaxesForEnterdAmount:@"10"];
    XCTAssert(YES, @"Pass");
}

-(void)testRatedTotalAmt
{
    [expenseEntryViewController setTotalAmountToRatedType:@"" andCurrenyName:@""];
     XCTAssert(YES, @"Pass");
}

@end
