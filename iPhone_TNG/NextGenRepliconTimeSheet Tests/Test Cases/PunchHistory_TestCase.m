//
//  PunchHistory_TestCase.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 10/12/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "TeamTimeViewController.h"
#import "SupportDataModel.h"

@interface PunchHistory_TestCase : XCTestCase
@property (nonatomic,strong)TeamTimeViewController *teamTimeViewCtrl;
@end

@implementation PunchHistory_TestCase
@synthesize teamTimeViewCtrl;

- (void)setUp {
    [super setUp];
    teamTimeViewCtrl=[[TeamTimeViewController alloc]init];
    [teamTimeViewCtrl viewDidLoad];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    XCTAssertNotNil(teamTimeViewCtrl, @"Cannot create TeamTimeViewController instance");
}
-(void)testForShowAddButton{
    BOOL isShowPlusButton=[teamTimeViewCtrl showAddButton:TRUE];
   

    XCTAssertTrue(isShowPlusButton , @"Show Add Button");
   
 
    
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



@end
