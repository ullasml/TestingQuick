//
//  ProgramObject_tests.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 09/12/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SelectClientOrProjectViewController.h"
#import "ProgramObject.h"

@interface ProgramObject_tests : XCTestCase
@property (nonatomic, strong) SelectClientOrProjectViewController *selectVC;

@end

@implementation ProgramObject_tests
@synthesize selectVC;

- (void)setUp {
    [super setUp];
    SelectClientOrProjectViewController *tmpSelectVC=[[SelectClientOrProjectViewController alloc]init];
    selectVC=tmpSelectVC;
    [selectVC setIsProgramAccess:YES];
    [selectVC intialiseView];
    selectVC.arrayOfCharacters=[[NSMutableArray alloc]init];
    [selectVC.arrayOfCharacters addObject:@"P"];
    
    ProgramObject *programObj=[[ProgramObject alloc]init];
    [programObj setProgramName:@"Program_Test"];
    [programObj setProgramUri:@"Program_Identity"];
    [programObj setProgramCode:@"Program_Code"];
    NSMutableArray *tmpArray=[NSMutableArray array];
    [tmpArray addObject:programObj];
    [selectVC.objectsForCharacters setObject:tmpArray forKey:@"P"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
     XCTAssertNotNil(selectVC, @"Cannot create SelectClientOrProjectViewController instance");
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
-(void)testProgramPoulatingInSelectClientOrProjectViewController
{
    int section=[selectVC.arrayOfCharacters count]-1;
    int expectedRows=[[selectVC.objectsForCharacters objectForKey:[selectVC.arrayOfCharacters objectAtIndex:section]] count];
    NSIndexPath *nowIndex=[NSIndexPath indexPathForRow:expectedRows inSection:section];
    UITableViewCell *cell = [selectVC.mainTableView cellForRowAtIndexPath:nowIndex];
    for (UILabel* label in cell.subviews)
    {
        XCTAssertEqualObjects(label.text, @"Program_Test",@"Cell should have the name as set in test program Object");
    }
}
- (void)testTableViewNumberOfRowsInSection
{
    int expectedsection=[selectVC.arrayOfCharacters count];
    XCTAssertTrue([selectVC.mainTableView numberOfSections]==expectedsection, @"Table has %ld section but it should have %ld", (long)[selectVC.mainTableView numberOfSections], (long)expectedsection);
    int section=[selectVC.arrayOfCharacters count]-1;
    int expectedRows=[[selectVC.objectsForCharacters objectForKey:[selectVC.arrayOfCharacters objectAtIndex:section]] count];
    XCTAssertTrue([selectVC tableView:self.selectVC.mainTableView numberOfRowsInSection:0]==expectedRows, @"Table has %ld rows but it should have %ld", (long)[self.selectVC tableView:self.selectVC.mainTableView numberOfRowsInSection:0], (long)expectedRows);
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
